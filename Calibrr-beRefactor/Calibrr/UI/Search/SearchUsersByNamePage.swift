//
//  SearchUsersByNamePage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 13/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient

class SearchUsersByNamePage : APage, UITableViewDelegate, UITextFieldDelegate
{
    lazy var activeUser = ActiveUser.singleton
    
    @IBOutlet weak var searchView: UIStackView!
    @IBOutlet var searchInput : UITextField!
    @IBOutlet var resultsTable : CBRTableView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var myAreaStudyButton: UIButton!
    @IBOutlet weak var myCoursesButton: UIButton!
    @IBOutlet weak var myCoursesLabel: UILabel!
    @IBOutlet weak var myAreaStudyLabel: UILabel!
    
    private let datasource = SearchUsersDatasource()
    let ghostModeView = GhostModeView()
    
    var areaStudySelected: Bool = false
    var myCoursesSelected: Bool = false
    
    let myCourses = "Show people in ‘my courses’"
    let myArea = "Show people sharing ‘my area of study’"
    let myCoursesUnderLine = "‘my courses’"
    let myAreaUnderLine = "‘my area of study’"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        print("🔓 [SEARCH BY NAME] User unblocked notification received, clearing cached results")
        // Clear cached results so next search will include unblocked users
        DispatchQueue.main.async {
            self.datasource.items = []
            self.resultsTable.reloadData()
        }
    }
    
    @objc private func onUserBlocked(_ notification: Notification) {
        print("🚫 [SEARCH BY NAME] User blocked notification received, clearing cached results")
        // Clear cached results so next search will exclude blocked users
        DispatchQueue.main.async {
            self.datasource.items = []
            self.resultsTable.reloadData()
        }
    }
    
    private func setupUI() {
        self.datasource._noContentMessage = "No Results\n\nTry broadening your search\nor inviting them to Calibrr Social"
        title = "Search For Anyone"
        searchView.layer.cornerRadius = 8.0
        searchView.clipsToBounds = true
        resultsTable.dataSource = datasource
        hideKeyboardWhenTappedAround()
        
        resultsTable.isEnableRefresh = true
        resultsTable.refreshDelegate = self
        ghostModeView.updateUIView = {
            self.updateUIGhostMode()
        }
        
        inviteView.layer.cornerRadius = 15.0
        inviteView.clipsToBounds = true
        
        myAreaStudyLabel.text = myArea
        myAreaStudyLabel.underlineMyText(range: myAreaUnderLine)
        myCoursesLabel.text = myCourses
        myCoursesLabel.underlineMyText(range: myCoursesUnderLine)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIGhostMode()
    }
    
    func updateUIGhostMode() {
        let ghostMode = DatabaseService.singleton.getProfile().user.ghostMode ?? false
        resultsTable.resetEmptyView()
        if ghostMode {
            self.resultsTable.emptyView = ghostModeView
            self.datasource.items.removeAll()
            self.searchInput.isEnabled = false
            self.searchInput.alpha = 0.5
            self.searchView.alpha = 0.5
            self.searchInput.text = ""
        } else {
            self.resultsTable.emptyView = nil
            self.searchInput.isEnabled = true
            self.searchInput.alpha = 1
            self.searchView.alpha = 1
        }
        self.resultsTable.reloadData()
    }
    
    @IBAction func shareButton(_ sender: Any) {
        ShareActivity.shared.share()
    }
    
    override func refreshUI()
    {
        super.refreshUI()
        
        setupNoResultMessage()
        datasource.reload()
        resultsTable.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        search()
        return true
    }
    
    func setupNoResultMessage() {
        let searchString = checkQueryValid().0
        if !self.checkQueryValid().1 {
            self.datasource._noContentMessage = ""
        } else if self.areaStudySelected || self.myCoursesSelected {
            self.datasource._noContentMessage = "No Results\nfor \"\(searchString)\"\nWho share your courses or studies\n\nTry broadening your search\nor inviting them to Calibrr Social"
        } else {
            self.datasource._noContentMessage = "No Results\nfor \"\(searchString)\"\n\nTry broadening your search\nor inviting them to Calibrr Social"
        }
    }
    
    private func search() {
        let searchString = checkQueryValid().0
        let isValid = checkQueryValid().1
        setupNoResultMessage()
        if isValid {
            self.showLoadingView()
            SearchAPI.searchByName(name: searchString, inCourse: self.myCoursesSelected, inStudying: self.areaStudySelected).thenInActionVoid { result in
                self.resultsTable.endRefreshing()
                
                self.datasource.items = result
                self.refreshUI()
                
                if self.datasource.items.isEmpty {
                    if self.areaStudySelected,
                       self.myCoursesSelected {
                        Alert.Choice(title: "Can’t find anyone who courses or your Area of Study?", message: "Looks like there aren’t any Calibrr Members who courses or your Area of Study with you yet-- consider inviting them to join Calibrr", actionTitle: "Invite", completionHandler: {
                            ShareActivity.shared.share()
                        })
                    } else if self.areaStudySelected {
                        Alert.Choice(title: "Can’t find anyone who shares your Area of Study?", message: "Looks like there aren’t any Calibrr Members who share your Area of Study with you yet-- consider inviting them to join Calibrr", actionTitle: "Invite", completionHandler: {
                            ShareActivity.shared.share()
                        })
                    } else if self.myCoursesSelected {
                        Alert.Choice(title: "Can’t find anyone in your courses?", message: "Looks like there aren’t any Calibrr Members who share courses with you yet-- consider inviting them to join Calibrr", actionTitle: "Invite", completionHandler: {
                            ShareActivity.shared.share()
                        })
                    }
                }
            }.ensure {
                self.hideLoadingView()
                self.resultsTable.reloadData()
            }.catchCBRError(show: true, from: self)
        } else {
            Alert.Error(title: "Be more specific", message: "Your search was too broad. Search using a full First/Last Name", from: self)
        }
    }
    
    func checkQueryValid() -> (String, Bool) {
        if let searchString = searchInput.text?.trimmingCharacters(in: CharacterSet.whitespaces), searchString.count >= 3 {
            return (searchString, true)
        }
        
        if self.myCoursesSelected || self.areaStudySelected {
            return (searchInput.text ?? "", true)
        }
        
        
        return ("", false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let p = ProfileFriendPage()
        guard let user = datasource.itemAt(indexPath) else { return }
        p.friendId = user.id
        p.firstName = user.firstName
        nav.push(p)
    }
    
    @IBAction func myCoursesLink(_ sender: Any) {
        Alert.Choice(title: "Add your courses", message: "By adding your courses, you and your classmates can find each other’s profiles") { [weak self] in
            self?.nav.push(ProfileEditPage())
        }
    }
    
    @IBAction func areaStudyLink(_ sender: Any) {
        Alert.Choice(title: "Add your area of study", message: "By adding your area of study, you and your classmates can find each other’s profiles") { [weak self] in
            self?.nav.push(ProfileEditPage())
        }
    }
    
    @IBAction func myCourses(_ sender: Any) {
        myCoursesButton.isSelected = !myCoursesButton.isSelected
        myCoursesSelected = myCoursesButton.isSelected
        if self.checkQueryValid().1 {
            search()
        } else if !myCoursesSelected {
            self.datasource.items = []
            self.refreshUI()
        }
    }
    
    @IBAction func myAreaStudyButton(_ sender: Any) {
        myAreaStudyButton.isSelected = !myAreaStudyButton.isSelected
        areaStudySelected = myAreaStudyButton.isSelected
        if self.checkQueryValid().1 {
            search()
        } else if !areaStudySelected {
            self.datasource.items = []
            self.refreshUI()
        }
    }
    
}

extension SearchUsersByNamePage: CBRTableViewDelegate {
    func refreshData() {
        self.search()
    }
}
