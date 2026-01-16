//
//  PendingProfileData.swift
//  Calibrr
//
//  Stores pending profile data before user signs up
//

import UIKit
import OpenAPIClient

/// Stores pending profile data before user signs up
class PendingProfileData {
    static let shared = PendingProfileData()
    
    var firstName: String?
    var lastName: String?
    var city: String?
    var politics: String?
    var religion: String?
    var education: String?
    var occupation: String?
    var gender: String?
    var sexuality: String?
    var relationship: String?
    var bio: String?
    var greekLife: String?
    var favoriteGame: String?
    var favoriteTV: String?
    var favoriteMusic: String?
    var studying: String?
    var classYear: String?
    var campus: String?
    var careerAspirations: String?
    var postgraduate: String?
    var postgraduatePlans: String?
    var hometown: String?
    var highSchool: String?
    var club: String?
    var jerseyNumber: String?
    var myCourses: [String] = []
    var myFriends: [(firstName: String, lastName: String)] = []
    var socialInfo: UserSocialInfo?
    
    // Temporary image data (before upload)
    var profileImageData: Data?
    var coverImageData: Data?
    var profileImage: UIImage?
    var coverImage: UIImage?
    
    var hasPendingData: Bool {
        return firstName != nil || lastName != nil || city != nil || education != nil
    }
    
    func clear() {
        firstName = nil
        lastName = nil
        city = nil
        politics = nil
        religion = nil
        education = nil
        occupation = nil
        gender = nil
        sexuality = nil
        relationship = nil
        bio = nil
        greekLife = nil
        favoriteGame = nil
        favoriteTV = nil
        favoriteMusic = nil
        studying = nil
        classYear = nil
        campus = nil
        careerAspirations = nil
        postgraduate = nil
        postgraduatePlans = nil
        hometown = nil
        highSchool = nil
        club = nil
        jerseyNumber = nil
        myCourses = []
        myFriends = []
        socialInfo = nil
        profileImageData = nil
        coverImageData = nil
        profileImage = nil
        coverImage = nil
    }
    
    /// Creates a User object from the pending data
    func toUser(withId id: String) -> User {
        var personalInfo = UserPersonalInfo()
        personalInfo.city = city
        personalInfo.politics = politics
        personalInfo.religion = religion
        personalInfo.education = education
        personalInfo.occupation = occupation
        personalInfo.gender = gender
        personalInfo.sexuality = sexuality
        personalInfo.relationship = relationship
        personalInfo.bio = bio
        personalInfo.greekLife = greekLife
        personalInfo.favoriteGame = favoriteGame
        personalInfo.favoriteTV = favoriteTV
        personalInfo.favoriteMusic = favoriteMusic
        personalInfo.studying = studying
        personalInfo.classYear = classYear
        personalInfo.campus = campus
        personalInfo.careerAspirations = careerAspirations
        personalInfo.postgraduate = postgraduate
        personalInfo.postgraduatePlans = postgraduatePlans
        personalInfo.hometown = hometown
        personalInfo.highSchool = highSchool
        
        if let clubName = club, !clubName.isEmpty, let number = jerseyNumber, !number.isEmpty {
            personalInfo.club = UserClub(club: clubName, number: number)
        }
        
        let coursesData = myCourses.filter { !$0.isEmpty }.map { MyCourse(name: $0) }
        let friendsData = myFriends.filter { !$0.firstName.isEmpty && !$0.lastName.isEmpty }
            .map { BestFriends(firstName: $0.firstName, lastName: $0.lastName) }
        
        let user = User(
            id: id,
            email: nil,
            phone: nil,
            firstName: firstName ?? "",
            lastName: lastName ?? "",
            ghostMode: false,
            subscription: nil,
            location: nil,
            locationTimestamp: nil,
            pictureProfile: nil,
            pictureCover: nil,
            personalInfo: personalInfo,
            socialInfo: socialInfo ?? UserSocialInfo(),
            liked: nil,
            likeCount: nil,
            visitCount: nil,
            myFriends: friendsData,
            myCourses: coursesData
        )
        
        return user
    }
}

