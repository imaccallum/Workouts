// Playground - noun: a place where people can play

import Cocoa
import Foundation

let dateAsString = "6:35 PM"
let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "h:mm a"
let date = dateFormatter.dateFromString(dateAsString)

dateFormatter.dateFormat = "HH:mm"
let date24 = dateFormatter.stringFromDate(date!)


//NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//dateFormatter.dateFormat = @"HH:mm";
//NSDate *date = [dateFormatter dateFromString:@"15:15"];
//
//dateFormatter.dateFormat = @"hh:mm a";
//NSString *pmamDateString = [dateFormatter stringFromDate:date];