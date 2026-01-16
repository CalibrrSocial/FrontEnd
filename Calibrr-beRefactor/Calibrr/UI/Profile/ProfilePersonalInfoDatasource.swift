//
//  ProfilePersonalInfoDatasource.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 20/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation
import OpenAPIClient

class ProfilePersonalInfoDatasource : AStandardItemsDatasource<ProfileCell, (String, String, Bool)>
{
    lazy var databaseService = DatabaseService.singleton
    
    override var noContentMessage: String {
        get { return "No Personal Info" }
    }
    
    var profile : UserPersonalInfo? = nil
    var myCourses: [MyCourse] = []
    var bestFriends: [BestFriends] = []
    
    override func reload()
    {
        items = []
        
        if let profile = profile {
            if let dateValue = profile.dob.date {
                let age = profile.dob.date!.age()
                let date = dateValue.getBirthdayString()
                if !date.isEmpty {
                    appendNonNull(title: "Born:", value: "\(date) (\(age) years old)")
                }
            }
            
            if let liveIn = profile.city, !liveIn.isEmpty {
                appendNonNull(title: "Currently lives in:", value: liveIn)
            }
            
            if let hometown = profile.hometown, !hometown.isEmpty {
                appendNonNull(title: "Hometown:", value: hometown)
            }
            
            if let highSchool = profile.highSchool, !highSchool.isEmpty {
                appendNonNull(title: "Past High School, Graduated from:", value: highSchool)
            }
            
            if let education = profile.education, !education.isEmpty {
                appendNonNull(title: "Current College/School:", value: education)
            }
            
            if let studying = profile.studying, !studying.isEmpty {
                appendNonNull(title: "Major/Studying:", value: studying)
            }
            
            if let classYear = profile.classYear, !classYear.isEmpty {
                appendNonNull(title: "Class/Graduation Year:", value: classYear)
            }
            
            if let campus = profile.campus, !campus.isEmpty {
                appendNonNull(title: "Current Campus:", value: campus)
            }
            
            if let careerAspirations = profile.careerAspirations, !careerAspirations.isEmpty {
                appendNonNull(title: "Career Aspirations:", value: careerAspirations)
            }
            
            if let postgraduate = profile.postgraduate, !postgraduate.isEmpty {
                appendNonNull(title: "Postgraduate Plans:", value: postgraduate)
            }
            
            // Display each course as a separate likeable item
            for (index, course) in myCourses.enumerated() {
                if let courseName = course.name, !courseName.isEmpty {
                    let title = index == 0 ? "In Courses:" : "  "
                    appendNonNull(title: title, value: courseName)
                }
            }
            
            if let greekLife = profile.greekLife, !greekLife.isEmpty {
                appendNonNull(title: "Greek life:", value: greekLife)
            }
            
            if let club = profile.club,
               let name = club.club,
               !name.isEmpty,
               let number = club.number,
               !number.isEmpty {
                let text = name + "\n" + "#\(number)"
                appendNonNull(title: "Team/Club:", value: text)
            }
            
            // Display each best friend as a separate likeable item
            for (index, friend) in bestFriends.enumerated() {
                let firstName = friend.firstName ?? ""
                let lastName = friend.lastName ?? ""
                if !firstName.isEmpty || !lastName.isEmpty {
                    let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
                    let title = index == 0 ? "Best Friends:" : "  "
                    appendNonNull(title: title, value: fullName)
                }
            }
            
            if let politics = profile.politics, !politics.isEmpty {
                appendNonNull(title: "Politics:", value: politics)
            }
            
            // Display each music artist as a separate likeable item
            if let music = profile.favoriteMusic, !music.isEmpty {
                let musicArtists = music.components(separatedBy: CharacterSet(charactersIn: ",\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                for (index, artist) in musicArtists.enumerated() {
                    let title = index == 0 ? "Favorite Music:" : "  "
                    appendNonNull(title: title, value: artist)
                }
            }
            
            // Display each TV show as a separate likeable item
            if let tv = profile.favoriteTV, !tv.isEmpty {
                let tvShows = tv.components(separatedBy: CharacterSet(charactersIn: ",\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                for (index, show) in tvShows.enumerated() {
                    let title = index == 0 ? "Favorite TV:" : "  "
                    appendNonNull(title: title, value: show)
                }
            }
            
            // Display each game as a separate likeable item
            if let game = profile.favoriteGame, !game.isEmpty {
                let games = game.components(separatedBy: CharacterSet(charactersIn: ",\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                for (index, gameItem) in games.enumerated() {
                    let title = index == 0 ? "Favorite Games:" : "  "
                    appendNonNull(title: title, value: gameItem)
                }
            }
            
            if let religion = profile.religion, !religion.isEmpty {
                appendNonNull(title: "Religion:", value: religion)
            }
            
            if let occupation = profile.occupation, !occupation.isEmpty {
                appendNonNull(title: "Occupation:", value: occupation)
            }
            
            if let gender = profile.gender, !gender.isEmpty {
                appendNonNull(title: "Gender:", value: gender)
            }
            
            if let sexuality = profile.sexuality, !sexuality.isEmpty {
                appendNonNull(title: "Sexuality:", value: sexuality)
            }
            
            if let relationship = profile.relationship, !relationship.isEmpty {
                appendNonNull(title: "Relationship:", value: relationship)
            }
            
            if let bio = profile.bio, !bio.isEmpty {
                appendNonNull(title: "Bio:", value: bio)
            }
        }
    }
    
    private func appendNonNull(title: String, value: String?)
    {
        if let v = value {
            items.append((title, v, true))
        }
    }
}

extension Optional where Wrapped == String {
    var date: Date? {
        get {
            guard let dob = self else { return nil }
            return Date(detectFromString: dob)
        }
    }
}
