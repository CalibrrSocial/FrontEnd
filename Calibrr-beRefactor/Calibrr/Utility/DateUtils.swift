//
//  DateUtils.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation

public class DateUtils
{
    public static let HOUR_IN_SECONDS = 60.0*60.0
    public static let DAY_IN_SECONDS = 24.0*HOUR_IN_SECONDS
    public static let FORMAT_TIME = "h:mm a"
    public static let FORMAT_DAY = "dd"
    public static let FORMAT_DATE = "yyyy-MM-dd"
    public static let FORMAT_DATE_MONTH = "MMMM"
    public static let FORMAT_DATE_MONTH_YEAR = "MMMM yyyy"
    public static let FORMAT_DATE_MONTH_YEAR_SHORT = "MM/yyyy"
    public static let FORMAT_TIME_DATE = FORMAT_TIME + " " + FORMAT_DATE
    
    static func GetFormatter(_ format: String? = nil) -> DateFormatter
    {
        let formatter = DateFormatter()
        if let format = format {
            formatter.dateFormat = format
        }
        return formatter
    }
    
    public static let FORMATTER_TIME                    = GetFormatter(FORMAT_TIME)
    public static let FORMATTER_DAY                     = GetFormatter(FORMAT_DAY)
    public static let FORMATTER_DATE                    = GetFormatter(FORMAT_DATE)
    public static let FORMATTER_DATE_MONTH              = GetFormatter(FORMAT_DATE_MONTH)
    public static let FORMATTER_DATE_MONTH_YEAR         = GetFormatter(FORMAT_DATE_MONTH_YEAR)
    public static let FORMATTER_DATE_MONTH_YEAR_SHORT   = GetFormatter(FORMAT_DATE_MONTH_YEAR_SHORT)
    public static let FORMATTER_TIME_DATE               = GetFormatter(FORMAT_TIME_DATE)
    public static let FORMATTER_TIME_DATE_SHORT : DateFormatter = {
        var formatter = GetFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    public static let FORMATTER_DATE_SHORT : DateFormatter = {
        var formatter = GetFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    public static func Combine(date: Date, time: Date) -> Date
    {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        
        return calendar.date(from: components)!
    }
    
    public static func Create(month: Int, year: Int) -> Date
    {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 10
        components.hour = 1
        components.minute = 0
        components.second = 0
        
        return Calendar.current.date(from: components)!
    }
    
    public static func GetDurationSinceString(from: Date, to: Date? = nil, short: Bool = false) -> String?
    {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.calendar = DateFormatter().calendar
        dateComponentsFormatter.unitsStyle = .positional
        if short {
            dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
            dateComponentsFormatter.zeroFormattingBehavior = .pad
        }
        
        return dateComponentsFormatter.string(from: from, to: to ?? Date())
    }
}

extension Date
{
    func tomorrow() -> Date
    {
        return Date(timeIntervalSince1970: self.timeIntervalSince1970 + DateUtils.DAY_IN_SECONDS)
    }
    func yesterday() -> Date
    {
        return Date(timeIntervalSince1970: self.timeIntervalSince1970 - DateUtils.DAY_IN_SECONDS)
    }
    func beginningOfDay() -> Date
    {
        return Calendar.current.startOfDay(for: self)
    }
    func age() -> Int
    {
        let ageComponents = Calendar.current.dateComponents([.year],
                                                            from: self.beginningOfDay(),
                                                            to: Date().beginningOfDay())
        return ageComponents.year!
    }
    func getTimeString() -> String
    {
        return DateUtils.FORMATTER_TIME.string(from: self)
    }
    func getDateString(_ isSendToSever: Bool) -> String
    {
        if isSendToSever {
            return DateUtils.FORMATTER_DATE.string(from: self)
        } else {
            return self.toString(format: .custom("MM/dd/YYYY")) ?? ""
        }
    }
    func getTimeDateString(_ short: Bool = false) -> String
    {
        return short ? DateUtils.FORMATTER_TIME_DATE_SHORT.string(from: self) : DateUtils.FORMATTER_TIME_DATE.string(from: self)
    }
    func getDayString() -> String
    {
        return DateUtils.FORMATTER_DAY.string(from: self)
    }
    func getMonthString() -> String
    {
        return DateUtils.FORMATTER_DATE_MONTH.string(from: self)
    }
    func getMonthYearString(_ short: Bool = false) -> String
    {
        let formatter = short ? DateUtils.FORMATTER_DATE_MONTH_YEAR_SHORT : DateUtils.FORMATTER_DATE_MONTH_YEAR
        return formatter.string(from: self)
    }
    func getDurationSinceString(_ short: Bool = false, _ to: Date? = nil) -> String?
    {
        return DateUtils.GetDurationSinceString(from: self, to: to, short: short)
    }
    
    func getTimestamp() -> Int64
    {
        return Int64(self.timeIntervalSince1970)
    }
}

extension Int64
{
    func getDate() -> Date?
    {
        if self != 0 {
            return Date(timeIntervalSince1970: TimeInterval(self))
        }
        return nil
    }
    func getDate(_ timeOffset: Int64) -> Date?
    {
        return (self + timeOffset).getDate()
    }
}

extension String
{
    func getDate() -> Date?
    {
        return DateUtils.FORMATTER_DATE.date(from: self)
    }
}
