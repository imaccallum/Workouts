//
//  WorkoutViewController.swift
//  Workouts
//
//  Created by Ian MacCallum on 3/12/15.
//  Copyright (c) 2015 MacCDevTeam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class WorkoutViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var workout: Workout!
    
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController = NSFetchedResultsController()
    var fetchRequest: NSFetchRequest! {
        var fetchRequest = NSFetchRequest(entityName: "ExerciseData")
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: false)
        
        let predicate = NSPredicate(format: "workout == %@", workout! ?? Workout())
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        return fetchRequest
    }
    var snapshotCell: UIView!
    var startIndex: NSIndexPath!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        tableView.delegate = self
        tableView.dataSource = self        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        tableView?.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        let touch = sender.locationInView(tableView)
        
        switch sender.state {
        case .Began:
            if let indexPath = tableView?.indexPathForRowAtPoint(touch) {
                if let cell = tableView?.cellForRowAtIndexPath(indexPath) {
                    startIndex = indexPath
                    snapshotCell = cell.snapshotViewAfterScreenUpdates(true)
                    snapshotCell.frame = cell.frame
                    cell.hidden = true
                    cell.userInteractionEnabled = false
                    UIView.animateWithDuration(0.1) { self.snapshotCell.center.y = touch.y }
                    tableView?.addSubview(snapshotCell)
                }
            }
            break
        case .Changed:
            snapshotCell.center.y = touch.y
           
            if let indexPath = tableView?.indexPathForRowAtPoint(touch) {
                if !indexPath.isEqual(startIndex) {
                    
                    let firstObj = fetchedResultsController.objectAtIndexPath(startIndex) as! ExerciseData
                    let secondObj = fetchedResultsController.objectAtIndexPath(indexPath) as! ExerciseData
                    
                    let tempIndex = firstObj.index
                    firstObj.index = secondObj.index
                    secondObj.index = tempIndex
                    
                    tableView.moveRowAtIndexPath(startIndex!, toIndexPath: indexPath)
                    startIndex = indexPath
                }
            }
        default:
            
            if let cell = tableView.cellForRowAtIndexPath(startIndex) {
                UIView.animateWithDuration(0.3, animations: {
                    self.snapshotCell.frame = cell.frame
                }, completion: { success in
                    cell.hidden = false
                    cell.userInteractionEnabled = true
                    self.snapshotCell.removeFromSuperview()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        tableView.scrollEnabled = true
        return proposedDestinationIndexPath
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        let newExerciseData = NSEntityDescription.insertNewObjectForEntityForName("ExerciseData", inManagedObjectContext: managedObjectContext) as! ExerciseData
        newExerciseData.weight = 0
        newExerciseData.sets = 1
        newExerciseData.duration = 0
        newExerciseData.exercise = nil
        newExerciseData.workout = workout
        
        if fetchedResultsController.fetchedObjects?.count > 0 {
            newExerciseData.index = (fetchedResultsController.fetchedObjects![0] as! ExerciseData).index.integerValue + 1
        } else {
            newExerciseData.index = 0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditExerciseSegue" {
            let destinationNav = segue.destinationViewController as! UINavigationController
            let destination = destinationNav.viewControllers[0] as! EditExerciseViewController
            destination.managedObjectContext = managedObjectContext
            destination.fetchedResultsController = fetchedResultsController
            
            if let indexPath = sender as? NSIndexPath {
                let exerciseData = fetchedResultsController.objectAtIndexPath(indexPath) as! ExerciseData
                destination.exerciseData = exerciseData
            }
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension WorkoutViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Move:
            break
        case NSFetchedResultsChangeType.Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
}

// MARK: UITableViewDataSource
extension WorkoutViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell", forIndexPath: indexPath) as! UITableViewCell
        let cellExerciseData = fetchedResultsController.objectAtIndexPath(indexPath) as! ExerciseData
        cell.textLabel?.text = cellExerciseData.exercise?.name ?? "New Exercise"
        cell.detailTextLabel?.text = cellExerciseData.index.stringValue
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension WorkoutViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("EditExerciseSegue", sender: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let obj = fetchedResultsController.objectAtIndexPath(indexPath) as! ExerciseData
            managedObjectContext.deleteObject(obj)
        case .Insert:
            break
        case .None:
            break
        }
    }
}