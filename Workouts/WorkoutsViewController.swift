//
//  ViewController.swift
//  Workouts
//
//  Created by Ian MacCallum on 3/12/15.
//  Copyright (c) 2015 MacCDevTeam. All rights reserved.
//

import UIKit
import Foundation
import CoreData



class WorkoutsViewController: UICollectionViewController {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchedResultsController = NSFetchedResultsController()
    var snapshotCell: UIView!
    var startIndex: NSIndexPath!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView?.collectionViewLayout = CustomLayout()
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchAllWorkouts(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        collectionView?.addGestureRecognizer(longPressGesture)

        
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        let touch = sender.locationInView(collectionView)
        
        switch sender.state {
        case .Began:
            if let indexPath = collectionView?.indexPathForItemAtPoint(touch), let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? WorkoutCell {
                    startIndex = indexPath
                    snapshotCell = cell.snapshotViewAfterScreenUpdates(true)
                    snapshotCell.frame = cell.frame
                    cell.hidden = true
                    cell.userInteractionEnabled = false
                    UIView.animateWithDuration(0.1) { self.snapshotCell.center = touch }
                    collectionView?.addSubview(snapshotCell)
            }
        case .Changed:
            

            if let indexPath = collectionView?.indexPathForItemAtPoint(touch) {
                if indexPath != startIndex {

                    let endingObject = fetchedResultsController.objectAtIndexPath(indexPath) as! Workout
                    let endIndex = endingObject.index

                    if startIndex.row < indexPath.row {
                        // Dragged down a row
                        // Get all rows after start index that need update
                        for i in (startIndex.row + 1)...indexPath.row {
                            let ip = NSIndexPath(forItem: i, inSection: 0)
                            let object = fetchedResultsController.objectAtIndexPath(ip) as! Workout
                            object.index = object.index.integerValue + 1
                        }
                    } else if startIndex.row > indexPath.row {
                        // Dragged up a row
                        // Get all rows before start index that need update
                        for i in indexPath.row..<startIndex.row {
                            let ip = NSIndexPath(forItem: i, inSection: 0)
                            let object = fetchedResultsController.objectAtIndexPath(ip) as! Workout
                            object.index = object.index.integerValue - 1
                        }
                    }
                    
                    let startingObject = fetchedResultsController.objectAtIndexPath(startIndex) as! Workout
                    startingObject.index = endIndex

                    collectionView?.moveItemAtIndexPath(startIndex, toIndexPath: indexPath)
                    startIndex = indexPath
                }
            }
            
            snapshotCell.center = touch
        default:
            if let cell = collectionView?.cellForItemAtIndexPath(startIndex) as? WorkoutCell {
                UIView.animateWithDuration(0.3, animations: {
                    self.snapshotCell.frame = cell.frame
                }, completion: { success in
                    
                    cell.hidden = false
                    cell.userInteractionEnabled = true
                    self.snapshotCell.removeFromSuperview()
                })
            }

            do {
                try managedObjectContext?.save()
            } catch _ {
            }
        }
        
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WorkoutSegue" {
            let destination = segue.destinationViewController as? WorkoutViewController
            destination?.managedObjectContext = managedObjectContext
            if let indexPath = sender as? NSIndexPath {
                destination?.workout = fetchedResultsController.objectAtIndexPath(indexPath) as! Workout
            }
        }
    }
}

// MARK: IBActions/Functions
extension WorkoutsViewController {
    func addButtonPressed(sender: NSIndexPath) {
        let alertController = UIAlertController(title: "Create Workout", message: "", preferredStyle: .Alert)
        var nameTextField: UITextField!
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            nameTextField = textField
            textField.placeholder = "workout name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .Default) { action in
            self.createWorkout(nameTextField.text ?? "")
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in }

        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true) {}
    }
}

// MARK: CRUD
extension WorkoutsViewController {
    
    func createWorkout(name: String) {
        let newWorkout = NSEntityDescription.insertNewObjectForEntityForName("Workout", inManagedObjectContext: managedObjectContext!) as! Workout
        
        if fetchedResultsController.fetchedObjects?.count > 0 {
            newWorkout.index = (fetchedResultsController.fetchedObjects![0] as! Workout).index.integerValue + 1
        } else {
            newWorkout.index = 0
        }
        
        newWorkout.name = name
    }
    
    func fetchAllWorkouts() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Workout")
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
}

// MARK: UICollectionView Data Source
extension WorkoutsViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController.sections?[section].numberOfObjects ?? 0) + 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == fetchedResultsController.fetchedObjects?.count {
            // Add Workout Cell
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddWorkoutCell", forIndexPath: indexPath) as! AddWorkoutCell
            return cell
        
        } else {
            // Workout Cell
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
            let cellWorkout = fetchedResultsController.objectAtIndexPath(indexPath) as! Workout
            cell.nameLabel.text = cellWorkout.name
            cell.exerciseLabel.text = "\(cellWorkout.exercises.count) exercise(s)"
            return cell
        }
    }
}


// MARK: UICollectionViewDelegateFlowLayout
extension WorkoutsViewController: UICollectionViewDelegateFlowLayout {
    var spacing: CGFloat! { return 8.0 }
    var rows: CGFloat! { return 4.0 }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == fetchedResultsController.fetchedObjects?.count {
            addButtonPressed(indexPath)
        } else {
            performSegueWithIdentifier("WorkoutSegue", sender: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let x = (view.frame.width - (rows + 1.0) * spacing) / rows
        return CGSize(width: x, height: x)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeZero
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension WorkoutsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {}
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {}
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            collectionView?.insertItemsAtIndexPaths([newIndexPath!])
        case NSFetchedResultsChangeType.Delete:
            collectionView?.deleteItemsAtIndexPaths([indexPath!])
        case NSFetchedResultsChangeType.Move:
            break
        case NSFetchedResultsChangeType.Update:
            collectionView?.reloadItemsAtIndexPaths([indexPath!])
        }

    }
}





