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
    @IBOutlet weak var myAreaStudyButton: UIButton!
    @IBOutlet weak var myCoursesButton: UIButton!
    @IBOutlet weak var myCoursesLabel: UILabel!
    @IBOutlet weak var myAreaStudyLabel: UILabel!
    
    private let datasource = SearchUsersDistanceDatasource()
    
    let stepMile: Float = 1.0
    let ghostModeView = GhostModeView()
    var distances = [0.0284, 0.071, 0.142, 0.284]
    var distancesLabel = ["0.05", "0.20", "0.33", "1/2"]
    
    var areaStudySelected: Bool = false
    var myCoursesSelected: Bool = false
    var allUsers: [User] = [] // Store all users from API
    
    let myCourses = "Show people in 'my courses'"
    let myArea = "Show people sharing 'my area of study'"
    let myCoursesUnderLine = "'my courses'"
    let myAreaUnderLine = "'my area of study'"
    
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
        
        // Listen for user block/unblock notifications to refresh search results
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserUnblocked),
            name: NSNotification.Name("UserUnblocked"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserBlocked),
            name: NSNotification.Name("UserBlocked"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func onUserUnblocked(_ notification: Notification) {
        print("🔓 [SEARCH BY DISTANCE] User unblocked notification received, refreshing search results")
        // Refresh the search to show the unblocked user
        DispatchQueue.main.async {
            self.search()
        }
    }
    
    @objc private func onUserBlocked(_ notification: Notification) {
        print("🚫 [SEARCH BY DISTANCE] User blocked notification received, refreshing search results")
        // Refresh the search to hide the blocked user
        DispatchQueue.main.async {
            self.search()
        }
    }
 
    private func setupUI() {
        whiteBoxView.layer.borderColor = UIColor.black.cgColor
        whiteBoxView.layer.borderWidth = 1.0
        whiteBoxView.layer.cornerRadius = 10
        whiteBoxView.clipsToBounds = true
        searchButton.backgroundColor = .white
        searchButton.layer.cornerRadius = 20
        
        // Setup checkbox labels
        myAreaStudyLabel.text = myArea
        myAreaStudyLabel.underlineMyText(range: myAreaUnderLine)
        myCoursesLabel.text = myCourses
        myCoursesLabel.underlineMyText(range: myCoursesUnderLine)
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
                self.myCoursesButton.isEnabled = false
                self.myAreaStudyButton.isEnabled = false
                self.distanceSlider.alpha = 0.5
                self.searchButton.alpha = 0.5
                self.whiteBoxView.alpha = 0.5
                self.myCoursesButton.alpha = 0.5
                self.myAreaStudyButton.alpha = 0.5
                self.myCoursesLabel.alpha = 0.5
                self.myAreaStudyLabel.alpha = 0.5
            } else {
                self.resultsTable.emptyView = nil
                self.distanceSlider.isEnabled = true
                self.searchButton.isEnabled = true
                self.myCoursesButton.isEnabled = true
                self.myAreaStudyButton.isEnabled = true
                self.distanceSlider.alpha = 1
                self.searchButton.alpha = 1
                self.whiteBoxView.alpha = 1.0
                self.myCoursesButton.alpha = 1.0
                self.myAreaStudyButton.alpha = 1.0
                self.myCoursesLabel.alpha = 1.0
                self.myAreaStudyLabel.alpha = 1.0
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
        // Don't clear items here - wait until we have new data
        if DatabaseService.singleton.getProfile().user.ghostMode ?? false {
            self.datasource.items = []
            self.refreshUI()
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
                // Only update data if we successfully received new data
                self.allUsers = result
                self.applyFilters()
                self.refreshUI()
            }.ensure {
                self.hideLoadingView()
                self.resultsTable.endRefreshing() // Ensure we always end refreshing
            }.catchCBRError(show: true, from: self)
        } else {
            // If no location, end refreshing without clearing data
            self.resultsTable.endRefreshing()
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
    
    private func applyFilters() {
        var filteredUsers = allUsers
        
        if myCoursesSelected || areaStudySelected {
            let currentUser = DatabaseService.singleton.getProfile().user
            
            filteredUsers = allUsers.filter { user in
                var matchesCriteria = false
                
                if myCoursesSelected {
                    // Check if user shares courses with current user
                    let userCourses = user.myCourses
                    let currentCourses = currentUser.myCourses
                    
                    if !userCourses.isEmpty && !currentCourses.isEmpty {
                        let userCourseSet = Set(userCourses.compactMap { $0.name })
                        let currentCourseSet = Set(currentCourses.compactMap { $0.name })
                        matchesCriteria = matchesCriteria || !userCourseSet.intersection(currentCourseSet).isEmpty
                    }
                }
                
                if areaStudySelected {
                    // Check if user shares area of study with current user
                    if let userAreaOfStudy = user.personalInfo?.studying,
                       let currentAreaOfStudy = currentUser.personalInfo?.studying,
                       !userAreaOfStudy.isEmpty && !currentAreaOfStudy.isEmpty {
                        matchesCriteria = matchesCriteria || userAreaOfStudy == currentAreaOfStudy
                    }
                }
                
                return matchesCriteria
            }
        }
        
        self.datasource.items = filteredUsers
    }
    
    @IBAction func myCoursesLink(_ sender: Any) {
        Alert.Choice(title: "Add your courses", message: "By adding your courses, you and your classmates can find each other's profiles") { [weak self] in
            self?.nav.push(ProfileEditPage())
        }
    }
    
    @IBAction func areaStudyLink(_ sender: Any) {
        Alert.Choice(title: "Add your area of study", message: "By adding your area of study, you and your classmates can find each other's profiles") { [weak self] in
            self?.nav.push(ProfileEditPage())
        }
    }
    
    @IBAction func myCourses(_ sender: Any) {
        myCoursesButton.isSelected = !myCoursesButton.isSelected
        myCoursesSelected = myCoursesButton.isSelected
        applyFilters()
        refreshUI()
    }
    
    @IBAction func myAreaStudyButton(_ sender: Any) {
        myAreaStudyButton.isSelected = !myAreaStudyButton.isSelected
        areaStudySelected = myAreaStudyButton.isSelected
        applyFilters()
        refreshUI()
    }
}

extension SearchUsersByDistancePage: CBRTableViewDelegate {
    func refreshData() {
        self.search()
    }
}
