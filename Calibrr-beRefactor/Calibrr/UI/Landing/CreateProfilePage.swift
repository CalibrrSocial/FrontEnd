//
//  CreateProfilePage.swift
//  Calibrr
//
//  Pre-signup profile creation page - allows users to create their profile before signing up
//

import UIKit
import OpenAPIClient

/// CreateProfilePage - Subclass of ProfileEditPage for pre-signup profile creation
/// This page allows users to create their profile BEFORE signing up
class CreateProfilePage: ProfileEditPage {
    
    /// Flag to indicate this is a pre-signup flow
    private var isPreSignupFlow = true
    
    /// Use ProfileEditPage's XIB since we inherit from it and share the same UI
    convenience init() {
        self.init(nibName: "ProfileEditPage", bundle: nil)
    }
    
    override func getBackPage() -> IPage? { return LandingPage() }
    
    override func viewDidLoad() {
        // Set the hidden back flag before calling super
        isHiddenBack = false
        super.viewDidLoad()
        
        title = "Create Your Profile"
        
        // Load any previously saved pending data
        loadPendingDataIfExists()
        
        // Update save button text
        saveButton?.setTitle("Continue to Sign Up", for: .normal)
        
        // Update name label to placeholder since there's no logged in user
        nameLabel?.text = "Your Name"
    }
    
    /// Override to prevent loading profile from database (no user logged in yet)
    override func setupProfilePage() {
        // Don't call super - there's no logged in user yet
        // Just set up default/empty state for the UI
        
        profilePicImage?.roundFull()
        profilePictureView?.roundFull()
        profilePicImage?.image = UIImage(named: "icon_avatar_placeholder")
        coverPicImage?.image = UIImage(named: "background")
        
        socialView?.isEditMode = true
        socialView?.delegate = self
        
        headerErrorLabel?.setupRed(textSize: 12, bold: true)
        avatarErrorLabel?.setupRed(textSize: 12, bold: true)
        showErrorImage(forceCover: false, forceAvatar: false)
        
        ActiveUser.singleton.startLocationServices()
    }
    
    /// Helper to show/hide image error labels
    private func showErrorImage(forceCover: Bool, forceAvatar: Bool) {
        headerErrorLabel?.isHidden = forceCover
        avatarErrorLabel?.isHidden = forceAvatar
    }
    
    private func loadPendingDataIfExists() {
        let pending = PendingProfileData.shared
        
        if let city = pending.city { locationInput?.setupInput(city) }
        if let politics = pending.politics { politicsInput?.setupInput(politics) }
        if let religion = pending.religion { religionInput?.setupInput(religion) }
        if let education = pending.education { educationInput?.setupInput(education) }
        if let occupation = pending.occupation { occupationInput?.setupInput(occupation) }
        if let gender = pending.gender { genderInput?.setupInput(gender) }
        if let sexuality = pending.sexuality { sexualityInput?.setupInput(sexuality) }
        if let relationship = pending.relationship { relationshipInput?.setupInput(relationship) }
        if let bio = pending.bio { bioInput?.text = bio }
        if let greekLife = pending.greekLife { greekLifeInput?.setupInput(greekLife) }
        if let favoriteGame = pending.favoriteGame { favoriteGamesInput?.setupInput(favoriteGame) }
        if let favoriteTV = pending.favoriteTV { favoriteTVInput?.setupInput(favoriteTV) }
        if let favoriteMusic = pending.favoriteMusic { favoriteMusicInput?.setupInput(favoriteMusic) }
        if let studying = pending.studying { studyingInput?.setupInput(studying) }
        if let classYear = pending.classYear { classYearInput?.setupInput(classYear) }
        if let campus = pending.campus { campusInput?.setupInput(campus) }
        if let careerAspirations = pending.careerAspirations { careerAspirationsInput?.setupInput(careerAspirations) }
        if let postgraduate = pending.postgraduate { postgraduateInput?.setupInput(postgraduate) }
        if let postgraduatePlans = pending.postgraduatePlans { postgraduatePlansInput?.setupInput(postgraduatePlans) }
        if let hometown = pending.hometown { hometownInput?.setupInput(hometown) }
        if let highSchool = pending.highSchool { highSchoolInput?.setupInput(highSchool) }
        if let club = pending.club { myClub?.setupInput(club) }
        if let jersey = pending.jerseyNumber { jerseyNumber?.text = jersey }
        
        // Load images if they exist
        if let profileImage = pending.profileImage {
            profilePicImage?.image = profileImage
            isHaveAvatar = true
        }
        if let coverImage = pending.coverImage {
            coverPicImage?.image = coverImage
            isHaveCover = true
        }
        
        // Load social info
        if let socialInfo = pending.socialInfo {
            socialView?.setupData(account: socialInfo)
        }
    }
    
    /// Override the save action to save to pending data and navigate to signup
    @IBAction override func clickSave(_ sender: UIButton?) {
        // Use parent's validation
        let isGenderValid = genderInput?.validateAndShow() ?? true
        let isEduValid = educationInput?.validateAndShow() ?? true
        let isLocationValid = locationInput?.validateAndShow() ?? true
        let isRelationValid = relationshipInput?.validateAndShow() ?? true
        let isCampusValid = campusInput?.validateAndShow() ?? true
        let isStudyingValid = studyingInput?.validateAndShow() ?? true
        let isClassYearValid = classYearInput?.validateAndShow() ?? true
        let isPostgraduateValid = postgraduateInput?.validateAndShow() ?? true
        
        // Check required validations
        let isValid = isGenderValid && isEduValid && isLocationValid && isRelationValid
            && isCampusValid && isStudyingValid && isClassYearValid && isPostgraduateValid
            && isHaveCover && isHaveAvatar && isValidSocialAccount
        
        if !isValid {
            Alert.Error(message: "Please complete all required fields!", from: self)
            return
        }
        
        // Save all data to pending storage
        saveToPendingData()
        
        // Show the message and navigate to sign up
        let alert = UIAlertController(
            title: "Almost There!",
            message: "To save your profile and get started, please finish signing up.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Continue to Sign Up", style: .default) { _ in
            self.nav.push(CreateAccountPage())
        })
        
        present(alert, animated: true)
    }
    
    private func saveToPendingData() {
        let pending = PendingProfileData.shared
        
        pending.city = locationInput?.getInput()
        pending.politics = politicsInput?.getInput()
        pending.religion = religionInput?.getInput()
        pending.education = educationInput?.getInput()
        pending.occupation = occupationInput?.getInput()
        pending.gender = genderInput?.getInput()
        pending.sexuality = sexualityInput?.getInput()
        pending.relationship = relationshipInput?.getInput()
        pending.bio = bioInput?.text
        pending.greekLife = greekLifeInput?.getInput()
        pending.favoriteGame = favoriteGamesInput?.getInput()
        pending.favoriteTV = favoriteTVInput?.getInput()
        pending.favoriteMusic = favoriteMusicInput?.getInput()
        pending.studying = studyingInput?.getInput()
        pending.classYear = classYearInput?.getInput()
        pending.campus = campusInput?.getInput()
        pending.careerAspirations = careerAspirationsInput?.getInput()
        pending.postgraduate = postgraduateInput?.getInput()
        pending.postgraduatePlans = postgraduatePlansInput?.getInput()
        pending.hometown = hometownInput?.getInput()
        pending.highSchool = highSchoolInput?.getInput()
        pending.club = myClub?.getInput()
        pending.jerseyNumber = jerseyNumber?.text
        
        // Save courses
        var courses: [String] = []
        for item in myCoursesTextField ?? [] {
            if let value = item.text, !value.isEmpty {
                courses.append(value)
            }
        }
        pending.myCourses = courses
        
        // Save best friends
        var friends: [(firstName: String, lastName: String)] = []
        for item in myBestFriendView ?? [] {
            if let firstName = item.firstName.text, !firstName.isEmpty,
               let lastName = item.lastName.text, !lastName.isEmpty {
                friends.append((firstName: firstName, lastName: lastName))
            }
        }
        pending.myFriends = friends
        
        // Get social accounts
        var socialAccount = UserSocialInfo()
        for item in socialView?.getValidAccount() ?? [] {
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
        pending.socialInfo = socialAccount
        
        // Save images
        if let profileImage = profilePicImage?.image, isHaveAvatar {
            pending.profileImage = profileImage
            pending.profileImageData = profileImage.jpegData(compressionQuality: 0.7)
        }
        if let coverImage = coverPicImage?.image, isHaveCover {
            pending.coverImage = coverImage
            pending.coverImageData = coverImage.jpegData(compressionQuality: 0.7)
        }
    }
}

