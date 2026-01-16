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
            
            // Courses: show label once, subsequent items marked as subitems
            var hasEmittedCoursesHeader = false
            for (_, course) in myCourses.enumerated() {
                if let courseName = course.name, !courseName.isEmpty {
                    if !hasEmittedCoursesHeader {
                        appendNonNull(title: "In Courses:", value: courseName)
                        hasEmittedCoursesHeader = true
                    } else {
                        // Use a marker in the title so the cell can compute displayLabel while UI shows only once
                        appendNonNull(title: "In Courses:__SUBITEM__", value: courseName)
                    }
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
            
            // Best Friends: show label once, subsequent items marked as subitems
            var hasEmittedBestFriendsHeader = false
            for (_, friend) in bestFriends.enumerated() {
                let firstName = friend.firstName ?? ""
                let lastName = friend.lastName ?? ""
                if !firstName.isEmpty || !lastName.isEmpty {
                    let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
                    if !hasEmittedBestFriendsHeader {
                        appendNonNull(title: "Best Friends:", value: fullName)
                        hasEmittedBestFriendsHeader = true
                    } else {
                        appendNonNull(title: "Best Friends:__SUBITEM__", value: fullName)
                    }
                }
            }
            
            if let politics = profile.politics, !politics.isEmpty {
                appendNonNull(title: "Politics:", value: politics)
            }
            
            // Favorite Music: show label once, subsequent items marked as subitems
            if let music = profile.favoriteMusic, !music.isEmpty {
                let musicArtists = music.components(separatedBy: CharacterSet(charactersIn: ",\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                var hasEmittedMusicHeader = false
                for (_, artist) in musicArtists.enumerated() {
                    if !hasEmittedMusicHeader {
                        appendNonNull(title: "Favorite Music:", value: artist)
                        hasEmittedMusicHeader = true
                    } else {
                        appendNonNull(title: "Favorite Music:__SUBITEM__", value: artist)
                    }
                }
            }
            
            // Favorite TV: show label once, subsequent items marked as subitems
            if let tv = profile.favoriteTV, !tv.isEmpty {
                let tvShows = tv.components(separatedBy: CharacterSet(charactersIn: ",\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                var hasEmittedTVHeader = false
                for (_, show) in tvShows.enumerated() {
                    if !hasEmittedTVHeader {
                        appendNonNull(title: "Favorite TV:", value: show)
                        hasEmittedTVHeader = true
                    } else {
                        appendNonNull(title: "Favorite TV:__SUBITEM__", value: show)
                    }
                }
            }
            
            // Favorite Games: show label once, subsequent items marked as subitems
            if let game = profile.favoriteGame, !game.isEmpty {
                let games = game.components(separatedBy: CharacterSet(charactersIn: ",\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                var hasEmittedGamesHeader = false
                for (_, gameItem) in games.enumerated() {
                    if !hasEmittedGamesHeader {
                        appendNonNull(title: "Favorite Games:", value: gameItem)
                        hasEmittedGamesHeader = true
                    } else {
                        appendNonNull(title: "Favorite Games:__SUBITEM__", value: gameItem)
                    }
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
