//
//  EditExerciseViewController.swift
//  Workouts
//
//  Created by Ian MacCallum on 3/13/15.
//  Copyright (c) 2015 MacCDevTeam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditExerciseViewController: UIViewController {
    
    @IBOutlet weak var exercisesPickerView: UIPickerView!
    @IBOutlet weak var weightLabel: UISliderLabel!
    @IBOutlet weak var setLabel: UISliderLabel!
    @IBOutlet weak var durationLabel: UISliderLabel!
    
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController = NSFetchedResultsController()
    var exerciseData: ExerciseData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchAllExercises(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        exercisesPickerView.dataSource = self
        exercisesPickerView.delegate = self
        
        
        if let exercise = exerciseData.exercise {
            let index = find(fetchedResultsController.fetchedObjects as! [Exercise], exercise)
            exercisesPickerView.selectRow(index!, inComponent: 0, animated: false)
        }
        
        setupLabels()
    }
    
    func setupLabels() {
        // Delegation
        weightLabel.delegate = self
        setLabel.delegate = self
        durationLabel.delegate = self
        
        // Set default values
        weightLabel.value = CGFloat(exerciseData.weight)
        setLabel.value = CGFloat(exerciseData.sets)
        durationLabel.value = CGFloat(exerciseData.duration)
    }
}

// MARK: UIPickerViewDataSource & Delegate
extension EditExerciseViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return (fetchedResultsController.fetchedObjects as! [Exercise])[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }
}

// MARK: IBActions
extension EditExerciseViewController {
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Create Exercise", message: "", preferredStyle: .Alert)
        var nameTextField: UITextField!
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            nameTextField = textField
            textField.placeholder = "exercise name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .Default) { action in
            self.createExercise(nameTextField.text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in }
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true) {}
    }
    
    @IBAction func dismissButtonPressed(sender: UIBarButtonItem) {
        exerciseData.exercise = fetchedResultsController.fetchedObjects?.count > 0 ? fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: exercisesPickerView.selectedRowInComponent(0), inSection: 0)) as? Exercise : nil
        exerciseData.weight = weightLabel.value
        exerciseData.sets = setLabel.value
        exerciseData.duration = durationLabel.value

        dismissViewControllerAnimated(true) {
            
        }
    }
}

// MARK: CRUD
extension EditExerciseViewController {
    
    func createExercise(name: String) {
        let newExercise = NSEntityDescription.insertNewObjectForEntityForName("Exercise", inManagedObjectContext: managedObjectContext!) as! Exercise
        newExercise.name = name
        managedObjectContext?.save(nil)
    }
    
    func fetchAllExercises() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Exercise")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension EditExerciseViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        exercisesPickerView.reloadAllComponents()
    }
}

extension EditExerciseViewController: UISliderLabelDelegate {
    func sliderLabel(sliderLabel: UISliderLabel, didChangeValue value: CGFloat) {

    }
    
    func sliderLabel(sliderLabel: UISliderLabel, formatForValue value: CGFloat) -> String? {
        if sliderLabel == weightLabel {
            return value == 1.0 ? "\(Int(value)) lb" : "\(Int(value)) lbs"
        } else if sliderLabel == setLabel {
            return value == 1.0 ? "\(Int(value)) set" : "\(Int(value)) sets"
        } else if sliderLabel == durationLabel {
            return value == 1.0 ? "\(Int(value)) second" : "\(Int(value)) seconds"
        } else {
            return "\(Int(value))"
        }
    }
    
    func sliderLabel(minValueForSliderLabel sliderLabel: UISliderLabel) -> CGFloat? {
        return 0
    }
    
    func sliderLabel(maxValueForSliderLabel sliderLabel: UISliderLabel) -> CGFloat? {
        return 1000
    }
    
    func sliderLabel(deviationValueForSliderLabel sliderLabel: UISliderLabel) -> CGFloat? {
        return 20
    }
    
    func sliderLabel(incrementByValueForSliderLabel sliderLabel: UISliderLabel) -> CGFloat? {
        return 1
    }
}