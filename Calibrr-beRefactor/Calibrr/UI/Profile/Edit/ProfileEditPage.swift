//
//  ProfileEditPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import SDWebImage
import OpenAPIClient
import Alamofire
import Toast_Swift

class ProfileEditPage : APage, UITextFieldDelegate, KASquareCropViewControllerDelegate, KACircleCropViewControllerDelegate, CBRTextInputViewDelegate
{
    lazy var databaseService = DatabaseService.singleton
    
    @IBOutlet var coverPicImage : UIImageView!
    @IBOutlet var profilePicImage : UIImageView!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var inputsView : UIView!
    @IBOutlet var locationInput : CBRTextInputView!
    @IBOutlet var politicsInput : CBRTextInputView!
    @IBOutlet var religionInput : CBRTextInputView!
    @IBOutlet var educationInput : CBRTextInputView!
    @IBOutlet var occupationInput : CBRTextInputView!
    @IBOutlet var genderInput : CBRTextInputView!
    @IBOutlet var sexualityInput : CBRTextInputView!
    @IBOutlet var relationshipInput : CBRTextInputView!
    @IBOutlet var bioInput : PlaceholderUITextView!
    @IBOutlet var saveButton : CBRButton!
    
    @IBOutlet weak var avatarErrorLabel: UILabel!
    @IBOutlet weak var headerErrorLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIView!
    @IBOutlet weak var heightTextViewBioContraint: NSLayoutConstraint!
    @IBOutlet weak var socialView: SocialLink!
    @IBOutlet weak var socialAccountMessage: UILabel!
    @IBOutlet weak var favoriteMusicInput: CBRTextInputView!
    @IBOutlet weak var studyingInput: CBRTextInputView!
    @IBOutlet weak var greekLifeInput: CBRTextInputView!
    @IBOutlet weak var favoriteGamesInput: CBRTextInputView!
    @IBOutlet weak var favoriteTVInput: CBRTextInputView!
    
    @IBOutlet weak var jerseyNumber: UITextField!
    @IBOutlet weak var myClub: CBRTextInputView!
    @IBOutlet var myCoursesTextField: [UITextField]!
    @IBOutlet var myBestFriendView: [BestFriendView]!
    
    // New profile fields
    @IBOutlet weak var classYearInput: CBRTextInputView!
    @IBOutlet weak var campusInput: CBRTextInputView!
    @IBOutlet weak var careerAspirationsInput: CBRTextInputView!
    @IBOutlet weak var postgraduateInput: CBRTextInputView!
    @IBOutlet weak var postgraduatePlansInput: CBRTextInputView!
    @IBOutlet weak var hometownInput: CBRTextInputView!
    @IBOutlet weak var highSchoolInput: CBRTextInputView!
    
    private var userProfile : User? = nil
    private var politicsChoicesDatasource : ChoicePickerDatasource? = nil
    private var religionChoicesDatasource : ChoicePickerDatasource? = nil
    private var genderChoicesDatasource : ChoicePickerDatasource? = nil
    private var sexualityChoicesDatasource : ChoicePickerDatasource? = nil
    private var relationshipChoicesDatasource : ChoicePickerDatasource? = nil
    private var classYearChoicesDatasource : ChoicePickerDatasource? = nil
    private var campusChoicesDatasource : ChoicePickerDatasource? = nil
    private var postgraduateChoicesDatasource : ChoicePickerDatasource? = nil
    private var keyboardHelper: KeyboardHelper?
    
    private var editChanges = false
    var isHaveCover = false
    var isHaveAvatar = false
    var isValidSocialAccount = false
    
    public var isHiddenBack: Bool = false
    var drawerDisplayController: DrawerDisplayController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        politicsChoicesDatasource = ChoicePickerDatasource(input: politicsInput, choices: ["", "Democrat", "Liberal", "Republican", "Conservative", "Libertarian", "Centrist", "Independent", "Apolitical", "SKIP", "CUSTOM OPTION"])
        politicsInput.inputField.inputView = UIPickerView().setup(politicsChoicesDatasource!)
        politicsInput.currentInputView = politicsInput.inputField.inputView
        politicsInput.inputField.autocapitalizationType = .words
        religionChoicesDatasource = ChoicePickerDatasource(input: religionInput, choices: ["", "Christianity", "Islam", "Buddhism", "Judaism", "Hinduism", "None", "None (Agnostic)", "None (Atheist)", "SKIP", "CUSTOM OPTION"])
        religionInput.inputField.autocapitalizationType = .words
        religionInput.inputField.inputView = UIPickerView().setup(religionChoicesDatasource!)
        religionInput.currentInputView = religionInput.inputField.inputView
        genderChoicesDatasource = ChoicePickerDatasource(input: genderInput, choices: ["", "Male", "Female", "CUSTOM OPTION"])
        genderInput.inputField.autocapitalizationType = .words
        genderInput.inputField.inputView = UIPickerView().setup(genderChoicesDatasource!)
        genderInput.currentInputView = genderInput.inputField.inputView
        sexualityChoicesDatasource = ChoicePickerDatasource(input: sexualityInput, choices: ["", "Straight", "Bisexual", "Gay", "Asexual","SKIP", "CUSTOM OPTION"])
        sexualityInput.inputField.autocapitalizationType = .words
        sexualityInput.inputField.inputView = UIPickerView().setup(sexualityChoicesDatasource!)
        sexualityInput.currentInputView = sexualityInput.inputField.inputView
        relationshipChoicesDatasource = ChoicePickerDatasource(input: relationshipInput, choices: ["", "Single", "In a relationship", "Married", "CUSTOM OPTION"])
        relationshipInput.inputField.autocapitalizationType = .words
        relationshipInput.inputField.inputView = UIPickerView().setup(relationshipChoicesDatasource!)
        relationshipInput.currentInputView = relationshipInput.inputField.inputView
        
        // New field datasources
        classYearChoicesDatasource = ChoicePickerDatasource(input: classYearInput, choices: ["", "Freshman", "Sophomore", "Junior", "Senior", "CUSTOM OPTION"])
        classYearInput.inputField.autocapitalizationType = .words
        classYearInput.inputField.inputView = UIPickerView().setup(classYearChoicesDatasource!)
        classYearInput.currentInputView = classYearInput.inputField.inputView
        
        campusChoicesDatasource = ChoicePickerDatasource(input: campusInput, choices: ["", "Main campus", "CUSTOM OPTION"])
        campusInput.inputField.autocapitalizationType = .words
        campusInput.inputField.inputView = UIPickerView().setup(campusChoicesDatasource!)
        campusInput.currentInputView = campusInput.inputField.inputView
        
        postgraduateChoicesDatasource = ChoicePickerDatasource(input: postgraduateInput, choices: ["", "Yes", "Likely", "Unsure", "No", "Currently enrolled", "SKIP"])
        postgraduateInput.inputField.autocapitalizationType = .words
        postgraduateInput.inputField.inputView = UIPickerView().setup(postgraduateChoicesDatasource!)
        postgraduateInput.currentInputView = postgraduateInput.inputField.inputView
        
        politicsInput.delegate = self
        religionInput.delegate = self
        genderInput.delegate = self
        sexualityInput.delegate = self
        relationshipInput.delegate = self
        politicsInput.delegate = self
        relationshipInput.delegate = self
        favoriteMusicInput.delegate = self
        studyingInput.delegate = self
        greekLifeInput.delegate = self
        favoriteGamesInput.delegate = self
        favoriteTVInput.delegate = self
        
        // New field delegates
        classYearInput.delegate = self
        campusInput.delegate = self
        careerAspirationsInput.delegate = self
        postgraduateInput.delegate = self
        postgraduatePlansInput?.delegate = self
        hometownInput.delegate = self
        highSchoolInput.delegate = self
        
        headerErrorLabel?.setupRed(textSize: 12, bold: true)
        avatarErrorLabel?.setupRed(textSize: 12, bold: true)
        // Hide errors if images are present from a previous session
        let currentInitial = databaseService.getProfile().user
        if !(currentInitial.pictureCover ?? "").isEmpty { isHaveCover = true }
        if !(currentInitial.pictureProfile ?? "").isEmpty { isHaveAvatar = true }
        showErrorImage(forceCover: isHaveCover, forceAvatar: isHaveAvatar)
        socialView.isEditMode = true
        socialView.delegate = self
        ActiveUser.singleton.startLocationServices()
        
        for item in myCoursesTextField {
            item.delegate = self
        }
        
        setupProfilePage()
    }
    
    override func refreshUI()
    {
        super.refreshUI()
    }
    
    func setupProfilePage() {
        var profile = databaseService.getProfile().user

        // Ensure personalInfo is initialized
        if profile.personalInfo == nil {
            profile.personalInfo = UserPersonalInfo()
        }
        
        // Ensure socialInfo is initialized
        if profile.socialInfo == nil {
            profile.socialInfo = UserSocialInfo()
        }
        
        // Quiet non-save logs: only log save-related events elsewhere
        

        socialView.setupData(account: profile.socialInfo)
        nameLabel.text = "\(profile.firstName) \(profile.lastName)"
        profilePicImage.roundFull()
        profilePictureView.roundFull()
        if let profilePic = profile.pictureProfile, let url =  URL(string: profilePic) {
            profilePicImage.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_avatar_placeholder"), context: nil)
            isHaveAvatar = true
        } else {
            profilePicImage.image = UIImage(named: "icon_avatar_placeholder")
        }
        
        if let coverPic = profile.pictureCover,
           let url = URL(string: coverPic) {
            coverPicImage.sd_setImage(with: url, placeholderImage: UIImage(named: "background"), context: nil)
            isHaveCover = true
        } else {
            coverPicImage.image = UIImage(named: "background")
        }
        
        if let location = profile.personalInfo?.city {
            locationInput.setupInput(location)
        }
        if let politics = profile.personalInfo?.politics {
            politicsInput.setupInput(politics)
        }
        if let religion = profile.personalInfo?.religion {
            religionInput.setupInput(religion)
        }
        if let education = profile.personalInfo?.education {
            educationInput.setupInput(education)
        }
        if let occupation = profile.personalInfo?.occupation {
            occupationInput.setupInput(occupation)
        }
        if let gender = profile.personalInfo?.gender {
            genderInput.setupInput(gender)
        }
        if let sexuality = profile.personalInfo?.sexuality {
            sexualityInput.setupInput(sexuality)
        }
        if let relationship = profile.personalInfo?.relationship {
            relationshipInput.setupInput(relationship)
        }
        if let bio = profile.personalInfo?.bio {
            bioInput.text = bio
            let sizeThatFitsTextView = bioInput.sizeThatFits(CGSize(width: bioInput.frame.size.width, height: CGFloat(MAXFLOAT)))
            let heightOfText = sizeThatFitsTextView.height
            if heightOfText > 60 {
                self.heightTextViewBioContraint.constant = heightOfText
                self.view.layoutIfNeeded()
            }
        }
        
        if let favoriteTV = profile.personalInfo?.favoriteTV {
            favoriteTVInput.setupInput(favoriteTV)
        }
        
        if let favoriteGame = profile.personalInfo?.favoriteGame {
            favoriteGamesInput.setupInput(favoriteGame)
        }
        
        if let favoriteMusic = profile.personalInfo?.favoriteMusic {
            favoriteMusicInput.setupInput(favoriteMusic)
        }
        
        if let greekLife = profile.personalInfo?.greekLife {
            greekLifeInput.setupInput(greekLife)
        }
        
        if let studying = profile.personalInfo?.studying {
            studyingInput.setupInput(studying)
        }
        
        // Setup new fields from profile
        if let classYear = profile.personalInfo?.classYear {
            classYearInput.setupInput(classYear)
        }
        if let campus = profile.personalInfo?.campus {
            campusInput.setupInput(campus)
        }
        if let careerAspirations = profile.personalInfo?.careerAspirations {
            careerAspirationsInput.setupInput(careerAspirations)
        }
        if let postgraduate = profile.personalInfo?.postgraduate {
            postgraduateInput.setupInput(postgraduate)
        }
        if let postgraduatePlans = profile.personalInfo?.postgraduatePlans {
            postgraduatePlansInput?.setupInput(postgraduatePlans)
        }
        if let hometown = profile.personalInfo?.hometown {
            hometownInput.setupInput(hometown)
        }
        if let highSchool = profile.personalInfo?.highSchool {
            highSchoolInput.setupInput(highSchool)
        }
        
        var indexCourses: Int = 0
        for item in Array(profile.myCourses.prefix(6)) {
            let textField = myCoursesTextField[indexCourses]
            textField.text = item.name
            indexCourses += 1
        }
        
        let friends = Array(profile.myFriends.prefix(6))
        var indexFriends: Int = 0
        for item in friends {
            let bestFriendView = myBestFriendView[indexFriends]
            bestFriendView.setupData(item)
            indexFriends += 1
        }
        
        if let club = profile.personalInfo?.club {
            self.myClub.setupInput(club.club ?? "")
            self.jerseyNumber.text = club.number
        }
        
        self.userProfile = profile
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nav.setNavigationBarHidden(isHiddenBack, animated: false)
    }
    
    override func backAction(_ sender: UIButton?)
    {
        if editChanges {
            Alert.Choice(title: "Changes Unsaved", message: "Would you like to save your profile changes before going back?", actionTitle: "Save Changes", actionDestructive: false, cancelTitle: "Don't Save", cancelDestructive: true, from: self, completionHandler: {
                self.clickSave(sender)
            }, cancelHandler: {
                super.backAction(sender)
            })
        }else{
            super.backAction(sender)
        }
    }
    
    @IBAction func clickCoverPic(_ sender: UIButton)
    {
        Alert.PhotoSelection(from: self, title: "Select a Cover Photo", message: "Photo Source", sourceView: coverPicImage){ image in
            let c = KASquareCropViewController(withImage: image)
            c.delegate = self
            self.dismiss(animated: false)
            self.present(c, animated: false)
        }
    }
    
    @IBAction func clickProfilePic(_ sender: UIButton)
    {
        Alert.PhotoSelection(from: self, title: "Select a Profile Photo", message: "Photo Source", sourceView: profilePicImage){ image in
            let c = KACircleCropViewController(withImage: image)
            c.delegate = self
            self.dismiss(animated: false)
            self.present(c, animated: false)
        }
    }
    
    private func validateAndShow() -> Bool
    {
        // Re-evaluate image presence based on current stored URLs to avoid timing issues after upload
        let current = databaseService.getProfile().user
        let coverPresent = isHaveCover || !(current.pictureCover ?? "").isEmpty
        let avatarPresent = isHaveAvatar || !(current.pictureProfile ?? "").isEmpty

        print("[Validation] isHaveCover=\(isHaveCover) isHaveAvatar=\(isHaveAvatar) coverURL='\(current.pictureCover ?? "")' avatarURL='\(current.pictureProfile ?? "")' → coverPresent=\(coverPresent) avatarPresent=\(avatarPresent)")
        
        showErrorImage(forceCover: coverPresent, forceAvatar: avatarPresent)
        showSocialLinkError()
        let isGenderValid = genderInput.validateAndShow()
        let isEduValid = educationInput.validateAndShow()
        let isLocationValid = locationInput.validateAndShow()
        let isRelationValid = relationshipInput.validateAndShow()
        let isCampusValid = campusInput.validateAndShow()
        let isStudyingValid = studyingInput.validateAndShow()
        let isClassYearValid = classYearInput.validateAndShow()
        let isPostgraduateValid = postgraduateInput.validateAndShow()
        return isGenderValid
        && isEduValid
        && isLocationValid
        && isRelationValid
        && isCampusValid
        && isStudyingValid
        && isClassYearValid
        && isPostgraduateValid
        && coverPresent
        && avatarPresent
        && isValidSocialAccount
    }
    
    private func showErrorImage(forceCover: Bool? = nil, forceAvatar: Bool? = nil) {
        let coverOK = forceCover ?? isHaveCover
        let avatarOK = forceAvatar ?? isHaveAvatar
        self.headerErrorLabel.isHidden = coverOK
        self.avatarErrorLabel.isHidden = avatarOK
    }
    
    private func showSocialLinkError() {
        isValidSocialAccount = self.userProfile?.socialInfo?.getAccountValid().count ?? 0 >= 2
        self.socialAccountMessage.isHidden = isValidSocialAccount
    }
    
    @IBAction func clickSave(_ sender: UIButton?)
    {
        let data = validateAndShow()
        
        if !data {
            return
        }
        
        // Prevent multiple saves while one is in progress
        if !saveButton.isEnabled {
            return
        }
        
        saveButton.showWaiting()
        saveButton.isEnabled = false
        
        let city = locationInput.getInput() ?? ""
        let politics = politicsInput.getInput() ?? ""
        let religion = religionInput.getInput() ?? ""
        let education = educationInput.getInput() ?? ""
        let occupation = occupationInput.getInput() ?? ""
        let gender = genderInput.getInput() ?? ""
        let sexuality = sexualityInput.getInput() ?? ""
        let relationship = relationshipInput.getInput() ?? ""
        let bio = bioInput.text ?? ""
        let greekLife = greekLifeInput.getInput() ?? ""
        let favoriteGame = favoriteGamesInput.getInput() ?? ""
        let favoriteTV = favoriteTVInput.getInput() ?? ""
        let favoriteMusic = favoriteMusicInput.getInput() ?? ""
        let studying = studyingInput.getInput() ?? ""
        
        // Get new field values
        let classYear = classYearInput.getInput() ?? ""
        let campus = campusInput.getInput() ?? ""
        let careerAspirations = careerAspirationsInput.getInput() ?? ""
        let postgraduate = postgraduateInput.getInput() ?? ""
        let postgraduatePlans = postgraduatePlansInput?.getInput() ?? ""
        let hometown = hometownInput.getInput() ?? ""
        let highSchool = highSchoolInput.getInput() ?? ""
        
        var userUpdate =  self.userProfile
        
        // Ensure personalInfo is initialized
        if userUpdate?.personalInfo == nil {
            userUpdate?.personalInfo = UserPersonalInfo()
        }
        
        // Ensure socialInfo is initialized
        if userUpdate?.socialInfo == nil {
            userUpdate?.socialInfo = UserSocialInfo()
        }
        
        // Preserve image URLs from local database (these come from legacy backend)
        let currentProfile = databaseService.getProfile().user
        if userUpdate?.pictureProfile == nil || userUpdate?.pictureProfile?.isEmpty == true {
            userUpdate?.pictureProfile = currentProfile.pictureProfile
        }
        if userUpdate?.pictureCover == nil || userUpdate?.pictureCover?.isEmpty == true {
            userUpdate?.pictureCover = currentProfile.pictureCover
        }
        
        // Ensure firstName and lastName are preserved from current profile
        userUpdate?.firstName = currentProfile.firstName
        userUpdate?.lastName = currentProfile.lastName
        
        if let location = ActiveUser.singleton.currentLocation {
            userUpdate?.location = Position(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        
        userUpdate?.personalInfo?.bio = bio
        userUpdate?.personalInfo?.education = education
        userUpdate?.personalInfo?.city = city
        
        userUpdate?.personalInfo?.politics = politics
        userUpdate?.personalInfo?.religion = religion
        userUpdate?.personalInfo?.sexuality = sexuality
        userUpdate?.personalInfo?.relationship = relationship
        userUpdate?.personalInfo?.gender = gender
        userUpdate?.personalInfo?.occupation = occupation
        userUpdate?.personalInfo?.greekLife = greekLife
        userUpdate?.personalInfo?.favoriteTV = favoriteTV
        userUpdate?.personalInfo?.favoriteGame = favoriteGame
        userUpdate?.personalInfo?.favoriteMusic = favoriteMusic
        userUpdate?.personalInfo?.studying = studying
        
        // Assign new field values
        userUpdate?.personalInfo?.classYear = classYear
        userUpdate?.personalInfo?.campus = campus
        userUpdate?.personalInfo?.careerAspirations = careerAspirations
        userUpdate?.personalInfo?.postgraduate = postgraduate
        userUpdate?.personalInfo?.postgraduatePlans = postgraduatePlans
        userUpdate?.personalInfo?.hometown = hometown
        userUpdate?.personalInfo?.highSchool = highSchool
        
        // Debug log to verify classYear is set
        print("[SaveProfile] Setting classYear: '\(classYear)' -> personalInfo.classYear: '\(userUpdate?.personalInfo?.classYear ?? "nil")'")
        
        setupSocialAccount(isUpdate: true)
        userUpdate?.socialInfo = userProfile?.socialInfo
        
        if let club = self.myClub.getInput(),
           !club.isEmpty,
           let number = self.jerseyNumber.text,
           !number.isEmpty {
            let club = UserClub(club: club, number: number)
            userUpdate?.personalInfo?.club = club
        } else {
            userUpdate?.personalInfo?.club = UserClub()
        }
        
        var myCourses: [MyCourse] = []
        for item in self.myCoursesTextField {
            if let value = item.text,
               !value.isEmpty {
                myCourses.append(MyCourse(name: value))
            }
        }
        userUpdate?.myCourses = myCourses
        
        var myFriends: [BestFriends] = []
        
        for item in self.myBestFriendView {
            if let firstName = item.firstName.text,
               !firstName.isEmpty,
               let lastName = item.lastName.text,
               !lastName.isEmpty {
                let myFriend = BestFriends(firstName: firstName, lastName: lastName)
                myFriends.append(myFriend)
            }
        }
        userUpdate?.myFriends = myFriends
        if let user = userUpdate {
            print("[SaveProfile] Sending update: avatar='\(user.pictureProfile ?? "")' cover='\(user.pictureCover ?? "")'")
            print("[SaveProfile] PersonalInfo.classYear before send: '\(user.personalInfo?.classYear ?? "nil")'")
            // Route through Laravel API instead of Lambda
            ProfileAPI.updateUserProfile(id: user.id, user: user).thenInAction{ userUpdated in
                print("[SaveProfile] Success: avatar='\(userUpdated.pictureProfile ?? "")' cover='\(userUpdated.pictureCover ?? "")'")
                // Update the cached profile in DatabaseService so location updates use the latest data
                self.databaseService.updateAccount(userUpdated)
                DispatchQueue.main.async {
                    self.processSaveProfile(userUpdated)
                }
            }.ensure {
                DispatchQueue.main.async {
                    self.saveButton.showNormal()
                    self.saveButton.isEnabled = true
                }
            }.catchCBRError(show: true, from: self)
        }
        
    }
    
    func setupSocialAccount(isUpdate: Bool = false) {
        var socialAccount = UserSocialInfo()
        
        if isUpdate {
            socialAccount.facebook = ""
            socialAccount.instagram = ""
            socialAccount.tiktok = ""
            socialAccount.snapchat = ""
            socialAccount.twitter = ""
            socialAccount.linkedIn = ""
            socialAccount.vsco = ""
        }
        for item in self.socialView.getValidAccount() {
            switch item.type {
            case .instagarm:
                socialAccount.instagram = item.account
            case .facebook:
                socialAccount.facebook = item.account
            case .tiktok:
                socialAccount.tiktok = item.account
            case .snapchat:
                socialAccount.snapchat = item.account
            case .x:
                socialAccount.twitter = item.account
            case .linkedin:
                socialAccount.linkedIn = item.account
            case .vsco:
                socialAccount.vsco = item.account
            }
        }
        userProfile?.socialInfo = socialAccount
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        editChanges = true
    }
    
    var currentText: String?
    func textFieldDidChange(inputView: CBRTextInputView, text: String) {
        if let picker = inputView.currentInputView as? UIPickerView,
           let dataSource = picker.dataSource as? ChoicePickerDatasource,
           dataSource.isCustomOption,
           currentText != text {
            inputView.inputField.text = text.capitalized
            currentText = inputView.inputField.text
        }
    }
    
    func squareCropDidCropImage(_ image: UIImage)
    {
        self.headerErrorLabel.isHidden = true
        coverPicImage.image = image
        isHaveCover = true  // Mark as having cover when image is selected
        print("[ImageSelect] Cover image selected, isHaveCover=\(isHaveCover)")
        saveCoverPic()
        dismiss(animated: true)
    }
    
    func squareCropDidCancel()
    {
        dismiss(animated: true)
    }
    
    func circleCropDidCancel()
    {
        dismiss(animated: true)
    }
    
    func circleCropDidCropImage(_ image: UIImage)
    {
        self.avatarErrorLabel.isHidden = true
        profilePicImage.image = image
        isHaveAvatar = true  // Mark as having avatar when image is selected
        print("[ImageSelect] Avatar image selected, isHaveAvatar=\(isHaveAvatar)")
        saveProfilePic()
        dismiss(animated: true)
    }
    
    private func processSaveProfile(_ updatedProfile: User) //UserProfileData)
    {
        editChanges = false
        
        // Preserve the current image URLs before doing anything else
        let currentProfile = databaseService.getProfile().user
        let currentProfilePicture = currentProfile.pictureProfile
        let currentCoverPicture = currentProfile.pictureCover
        
        // Create an updated profile object with server data but preserved images
        var profile = updatedProfile
        profile.personalInfo?.bio = updatedProfile.personalInfo?.bio
        profile.location = updatedProfile.location
        profile.personalInfo?.dob = updatedProfile.personalInfo?.dob
        profile.personalInfo?.education = updatedProfile.personalInfo?.education
        profile.personalInfo?.politics = updatedProfile.personalInfo?.politics
        profile.personalInfo?.religion = updatedProfile.personalInfo?.religion
        profile.personalInfo?.occupation = updatedProfile.personalInfo?.occupation
        profile.personalInfo?.sexuality = updatedProfile.personalInfo?.sexuality
        profile.personalInfo?.relationship = updatedProfile.personalInfo?.relationship
        profile.personalInfo?.gender = updatedProfile.personalInfo?.gender
        profile.personalInfo?.classYear = updatedProfile.personalInfo?.classYear
        profile.personalInfo?.campus = updatedProfile.personalInfo?.campus
        profile.personalInfo?.careerAspirations = updatedProfile.personalInfo?.careerAspirations
        profile.personalInfo?.postgraduate = updatedProfile.personalInfo?.postgraduate
        profile.personalInfo?.hometown = updatedProfile.personalInfo?.hometown
        profile.personalInfo?.highSchool = updatedProfile.personalInfo?.highSchool
        
        // Preserve image URLs if they exist in the current profile (uploaded during this session)
        // Always use current profile images if they exist, regardless of server response
        if let currentProfilePic = currentProfilePicture, !currentProfilePic.isEmpty {
            profile.pictureProfile = currentProfilePic
        }
        if let currentCoverPic = currentCoverPicture, !currentCoverPic.isEmpty {
            profile.pictureCover = currentCoverPic
        }
        
        // Update the database service with the final profile
        databaseService.getProfile().user = profile
        
        // Pop back on the main thread after a slight delay to allow UI updates and toasts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.nav.pop(animated: true)
        }
        Alert.Basic(title: "Success", message: "Your profile has been successfully updated!")
    }
    
    private func saveCoverPic()
    {
        if let image = coverPicImage.image {
            let profile = databaseService.getProfile().user
            let fileUrl = URL(string: APIKeys.BASE_API_URL + "/profile/\(profile.id)/coverImage")
            // Only send Authorization; let Alamofire set multipart Content-Type
            let headers = [
                APIKeys.HTTP_AUTHORIZATION_HEADER: OpenAPIClientAPI.customHeaders[APIKeys.HTTP_AUTHORIZATION_HEADER]!
            ]
            
            let url = try! URLRequest(url: fileUrl!, method: .post, headers: headers)
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                if let imgData = image.jpegData(compressionQuality: 0.7) {
                    multipartFormData.append(imgData, withName: "coverImage", fileName: "CoverProfile.jpg", mimeType: "image/jpg")
                }
            }, with: url, encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { [weak self] response in
                        DispatchQueue.main.async {
                            switch response.result {
                            case .success(let data):
                                print("[CoverUpload] Success response: \(data)")
                                if let url = (data as? [String: Any])?["url"] as? String {
                                    print("[CoverUpload] Extracted URL: \(url)")
                                    self?.databaseService.updateCover(url: url)
                                    self?.userProfile?.pictureCover = url
                                    self?.view.makeToast("Cover picture uploaded successfully", duration: 3.0, position: .bottom)
                                } else {
                                    print("[CoverUpload] Could not extract URL from response")
                                    self?.view.makeToast("Cover picture uploaded but URL not found")
                                }
                                self?.isHaveCover = true
                            case .failure(_):
                                print("[CoverUpload] Upload failed: \(String(describing: response.response?.statusCode)) body=\(String(data: response.data ?? Data(), encoding: .utf8) ?? "<nil>")")
                                self?.view.makeToast("Cover picture can't upload")
                            }
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    break
                }
            })
        }
    }
    
    private func saveProfilePic()
    {
        if let image = profilePicImage.image {
            let profile = databaseService.getProfile().user
            let fileUrl = URL(string: APIKeys.BASE_API_URL + "/profile/\(profile.id)/upload")
            // Only send Authorization; let Alamofire set multipart Content-Type
            let headers = [
                APIKeys.HTTP_AUTHORIZATION_HEADER: OpenAPIClientAPI.customHeaders[APIKeys.HTTP_AUTHORIZATION_HEADER]!
            ]
            
            let url = try! URLRequest(url: fileUrl!, method: .post, headers: headers)
            
            Alamofire.upload(multipartFormData:{ multipartFormData in
                if let imgData = image.jpegData(compressionQuality: 0.7) {
                    multipartFormData.append(imgData, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/jpg")
                }
            }, with: url, encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { [weak self] response in
                        DispatchQueue.main.async {
                            switch response.result {
                            case .success(let data):
                                print("[AvatarUpload] Success response: \(data)")
                                if let url = (data as? [String: Any])?["url"] as? String {
                                    print("[AvatarUpload] Extracted URL: \(url)")
                                    self?.databaseService.updateAvatar(url: url)
                                    self?.userProfile?.pictureProfile = url
                                    self?.view.makeToast("Profile picture uploaded successfully", duration: 3.0, position: .bottom)
                                } else {
                                    print("[AvatarUpload] Could not extract URL from response")
                                    self?.view.makeToast("Profile picture uploaded but URL not found")
                                }
                                self?.isHaveAvatar = true
                            case .failure(_):
                                print("[AvatarUpload] Upload failed: \(String(describing: response.response?.statusCode)) body=\(String(data: response.data ?? Data(), encoding: .utf8) ?? "<nil>")")
                                self?.view.makeToast("Profile picture can't upload")
                            }
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    break
                }
            })
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.myCoursesTextField.contains(where: { $0 == textField }) {
            if (string == " ") {
                return false
            }
            let allowedCharacters = CharacterSet.letters.union(.decimalDigits)
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string.uppercased())
            return false
        }
        return true
    }
}

class ChoicePickerDatasource : NSObject, UIPickerViewDataSource, UIPickerViewDelegate
{
    private let input : CBRTextInputView
    private let choices : [String]
    public var isCustomOption: Bool = false
    var currentIndex: Int = 0
    
    enum DataPicker: String {
        case skip = "SKIP"
        case custom = "CUSTOM OPTION"
    }
    
    init(input: CBRTextInputView, choices: [String])
    {
        self.input = input
        self.choices = choices
    }
    
    public func getIndex(_ data: String?) -> Int {
        guard let data = data else { return 0 }
        return choices.firstIndex(of: data) ?? 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return choices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return choices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        if row == 0, choices[row].isEmpty {
            (self.input.currentInputView as? UIPickerView)?.selectRow(currentIndex, inComponent: 0, animated: true)
            return
        }
        currentIndex = row
        isCustomOption = false
        let data = choices[row]
        setToolBar(false)
        if data == DataPicker.skip.rawValue {
            input.setupInput("")
        } else if data == DataPicker.custom.rawValue  {
            isCustomOption = true
            input.setupInput("")
            input.inputField.resignFirstResponder()
            input.inputField.inputView = nil
            setToolBar(true)
            input.offSuggestion()
            input.inputField.becomeFirstResponder()
        } else {
            input.setupInput(data)
        }
        input.offSuggestion()
    }
    
    private func setToolBar(_ isShowBack: Bool) {
        
        let accessory = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
        
        accessory.backgroundColor = UIColor.white
        accessory.alpha = 0.8
        accessory.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = doneButton.titleLabel?.font.withSize(18)
        doneButton.addTarget(self, action: #selector(self.dismiss), for: .touchUpInside)
        doneButton.showsTouchWhenHighlighted = true
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        accessory.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.bottom.top.right.equalTo(0)
        }
        doneButton.makeAccessible("DoneButton")
        
        if isShowBack {
            let backButton = UIButton(type: .system)
            backButton.setTitle("Back to options", for: .normal)
            backButton.titleLabel?.font = doneButton.titleLabel?.font.withSize(18)
            backButton.showsTouchWhenHighlighted = true
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.addTarget(self, action: #selector(self.backToOptions), for: .touchUpInside)
            accessory.addSubview(backButton)
            backButton.snp.makeConstraints { (make) in
                make.width.equalTo(150)
                make.bottom.top.left.equalTo(0)
            }
            backButton.makeAccessible("BackButton")
        }
        
        input.inputField.inputAccessoryView = accessory
    }
    
    @objc
    func backToOptions() {
        self.currentIndex = 0
        isCustomOption = false
        input.inputField.inputView = input.currentInputView
        setToolBar(false)
        input.inputField.resignFirstResponder()
        input.inputField.becomeFirstResponder()
    }
    
    @objc
    func dismiss() {
        input.inputField.resignFirstResponder()
    }
}

extension ProfileEditPage: SocialLinkDelegate, SocialLinkViewControllerDelegate {
    
    func didTapOnItem(item: SocialItemData?) {
        showEditSocialView(item: item)
    }
    
    func socialAccount(_ account: [SocialItemData]) {
        self.socialView.items = account
        self.setupSocialAccount()
        self.socialView.reloadData()
    }
    
    func showEditSocialView(item: SocialItemData?) {
        let viewController = SocialLinkViewController(item: item, validItems: self.socialView.getValidAccount())
        viewController.delegate = self
        var configuration = DrawerConfiguration()
        
        configuration.totalDurationInSeconds = 0.6
        configuration.durationIsProportionalToDistanceTraveled = false
        configuration.timingCurveProvider = UISpringTimingParameters(dampingRatio: 0.8)
        configuration.supportsPartialExpansion = true
        configuration.dismissesInStages = false
        configuration.isDrawerDraggable = false
        configuration.isFullyPresentableByDrawerTaps = false
        configuration.numberOfTapsForFullDrawerPresentation = 1
        configuration.isDismissableByOutsideDrawerTaps = false
        configuration.numberOfTapsForOutsideDrawerDismissal = 1
        configuration.flickSpeedThreshold = 3
        configuration.cornerAnimationOption = .none
        configuration.passthroughTouchesInStates = [.collapsed]
        
        var handleViewConfiguration = HandleViewConfiguration()
        handleViewConfiguration.autoAnimatesDimming = false
        handleViewConfiguration.backgroundColor = .clear
        handleViewConfiguration.size = CGSize(width: 28, height: 10)
        handleViewConfiguration.top = 8
        configuration.handleViewConfiguration = handleViewConfiguration
        
        let backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let backgroundViewConfiguration = BackgroundViewConfiguration(backgroundColor: backgroundColor, isBlurEnabled: false)
        configuration.backgroundViewConfiguration = backgroundViewConfiguration
        
        drawerDisplayController = DrawerDisplayController(presentingViewController: self,
                                                          presentedViewController: viewController,
                                                          configuration: configuration,
                                                          inDebugMode: false)
        
        present(viewController, animated: true)
    }
}

extension UIPickerView
{
    func setup(_ datasource: ChoicePickerDatasource) -> UIPickerView
    {
        self.dataSource = datasource
        self.delegate = datasource
        return self
    }
}
