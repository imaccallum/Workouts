//
//  ExerciseData.swift
//  Workouts
//
//  Created by Ian MacCallum on 3/12/15.
//  Copyright (c) 2015 MacCDevTeam. All rights reserved.
//

import Foundation
import CoreData

class ExerciseData: NSManagedObject {

    @NSManaged var index: NSNumber
    @NSManaged var sets: NSNumber
    @NSManaged var weight: NSNumber
    @NSManaged var reps: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var exercise: Exercise?
    @NSManaged var workout: Workout

}
