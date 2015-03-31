//
//  Workout.swift
//  Workouts
//
//  Created by Ian MacCallum on 3/12/15.
//  Copyright (c) 2015 MacCDevTeam. All rights reserved.
//

import Foundation
import CoreData

class Workout: NSManagedObject {

    @NSManaged var index: NSNumber
    @NSManaged var name: String
    @NSManaged var exercises: NSOrderedSet

}
