//
//  NSDateExtension.swift
//  Workouts
//
//  Created by Ian MacCallum on 3/13/15.
//  Copyright (c) 2015 MacCDevTeam. All rights reserved.
//

import Foundation


enum NSDateFormat {
    case Standard, FromSQL, Custom(String)
}

enum TimeZone {
    case UTC, EST, Custom(String)
}

extension NSDate {
    
    func toString(format format: NSDateFormat, timeZone: TimeZone) -> String
    {
        let formatter = NSDateFormatter()
        formatter.calendar = NSCalendar.currentCalendar()
        
        var dateFormat: String
        
        switch format {
        case .Standard: dateFormat = "MM/dd/yyyy HH:mm:ss"
        case .FromSQL: dateFormat = "yyyy-MM-dd HH:mm:ss"
        case .Custom(let string): dateFormat = string
        }
        
        switch timeZone {
        case .EST: formatter.timeZone = NSTimeZone(name: "EST")
        case .UTC: formatter.timeZone = NSTimeZone(name: "UTC")
        case .Custom(let customTimeZone): formatter.timeZone = NSTimeZone(name: customTimeZone)
        }
        
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(self)
    }
}