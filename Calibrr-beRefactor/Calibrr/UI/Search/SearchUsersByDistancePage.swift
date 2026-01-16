//
//  SearchUsersByDistancePage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import TTRangeSlider
import OpenAPIClient

class SearchUsersByDistancePage : APage, UITableViewDelegate
{
    lazy var activeUser = ActiveUser.singleton
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet var searchButton : UIButton!
    @IBOutlet var resultsTable : CBRTableView!
    @IBOutlet weak var whiteBoxView: UIView!
    @IBOutlet weak var titleWhiteBoxLabel: UILabel!
    
    private let datasource = SearchUsersDistanceDatasource()
    
    let stepMile: Float = 1.0
    let ghostModeView = GhostModeView()
    var distances = [0.0284, 0.071, 0.142, 0.284]
    var distancesLabel = ["0.05", "0.20", "0.33", "1/2"]
    
    var debounceTimer: Timer?
    
    var currentDistance: Int = 0 {
        didSet {
            distanceChange = currentDistance != oldValue
        }
    }
    
    var distanceChange: Bool = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "See Who’s Nearby"
        
        resultsTable.dataSource = datasource
        
        resultsTable.isEnableRefresh = true
        resultsTable.refreshDelegate = self
        distanceSlider.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)
        self.distanceSlider.value = 4.0
        self.updateLableWhiteBox(Int(self.distanceSlider.value))
        self.search()
        ghostModeView.updateUIView = {
            self.updateUIGhostMode()
        }
        setupUI()
    }
 
    private func setupUI() {
        whiteBoxView.layer.borderColor = UIColor.black.cgColor
        whiteBoxView.layer.borderWidth = 1.0
        whiteBoxView.layer.cornerRadius = 10
        whiteBoxView.clipsToBounds = true
        searchButton.backgroundColor = .white
        searchButton.layer.cornerRadius = 20
    }
    
    private func updateLableWhiteBox(_ value: Int) {
        let string = "Showing who's within \(distancesLabel[value-1]) miles of you"
        if let range = string.range(of: "0") {
            let attributedString = NSMutableAttributedString(string: string)
            let boldFont = UIFont.boldSystemFont(ofSize: 24)
            attributedString.addAttributes([NSAttributedString.Key.font: boldFont], range: NSRange(range, in: string))
            titleWhiteBoxLabel.attributedText = attributedString
        } else {
            titleWhiteBoxLabel.text = string
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIGhostMode()
    }
    
    func updateUIGhostMode() {
        let ghostMode = DatabaseService.singleton.getProfile().user.ghostMode ?? false
        resultsTable.resetEmptyView()
        DispatchQueue.main.async {
            if ghostMode {
                self.resultsTable.emptyView = self.ghostModeView
                self.datasource.items.removeAll()
                self.distanceSlider.isEnabled = false
                self.searchButton.isEnabled = false
                self.distanceSlider.alpha = 0.5
                self.searchButton.alpha = 0.5
                self.whiteBoxView.alpha = 0.5
            } else {
                self.resultsTable.emptyView = nil
                self.distanceSlider.isEnabled = true
                self.searchButton.isEnabled = true
                self.distanceSlider.alpha = 1
                self.searchButton.alpha = 1
                self.whiteBoxView.alpha = 1.0
                self.search()
            }
            self.resultsTable.reloadData()
        }
    }
    
    override func refreshUI()
    {
        super.refreshUI()
        
        datasource.reload()
        resultsTable.reloadData()
    }
    
    @objc
    func sliderValueChanged() {
        let roundedValue = round(distanceSlider.value / stepMile) * stepMile
        distanceSlider.value = roundedValue
        if Int(roundedValue) != self.currentDistance {
            self.currentDistance = Int(roundedValue)
        }
        self.updateLableWhiteBox(Int(roundedValue))
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.distanceChange {
                self.search()
                self.currentDistance = Int(self.distanceSlider.value)
            }
        }
    }
    
    @IBAction func clickSearch(_ sender: UIButton)
    {
        search()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let p = ProfileFriendPage()
        p.friendId = datasource.itemAt(indexPath)!.id
        nav.push(p)
    }
    
    private func search() {
        activeUser.startUpdateLocation()
        self.datasource.items = []
        self.refreshUI()
        if DatabaseService.singleton.getProfile().user.ghostMode ?? false {
            self.resultsTable.endRefreshing()
            return 
        }
        
        //TODO: currentLocation could be nil
        if let location = activeUser.currentLocation {
            self.showLoadingView()
            SearchAPI.searchByDistance(position: Position(latitude: location.coordinate.latitude,
                                                          longitude: location.coordinate.longitude),
                                       maxDistance: Distance(type: .miles, amount: Double(distances[Int(self.distanceSlider.value)-1])))
            .thenInActionVoid{ result in
                self.resultsTable.endRefreshing()
                self.datasource.items = result
                self.refreshUI()
            }.ensure {
                self.hideLoadingView()
            }.catchCBRError(show: true, from: self)
        }
    }
    
    func animateRotation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = Double.pi * 2.0
        animation.duration = 1.0
        animation.repeatCount = .infinity
        searchButton.layer.add(animation, forKey: "rotationAnimation")
        
        searchButton.layer.setValue(animation, forKey: "rotationAnimation")
    }

    func stopRotation() {
        searchButton.layer.removeAnimation(forKey: "rotationAnimation")
        
        searchButton.layer.setAffineTransform(.identity)
    }
}

extension SearchUsersByDistancePage: CBRTableViewDelegate {
    func refreshData() {
        self.search()
    }
}
