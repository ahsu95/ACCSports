 //
//  SelectionViewController.swift
//  ACCSports
//
//  Created by Osman Balci on 9/26/17.
//  Copyright © 2017 Osman Balci. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    /*
     Store the object reference of the UIPickerView object, created in the
     Storyboard (Interface Builder), into instance variable pickerView.
     */
    @IBOutlet var pickerView: UIPickerView!
    
    /*
     Store the object reference of the UISegmentedControl object, created in the
     Storyboard (Interface Builder), into instance variable mapTypeSegmentedControl.
     */
    @IBOutlet var mapTypeSegmentedControl: UISegmentedControl!
    
    var dict1_UniversityName_Dict2  = [String: AnyObject]()
    var universityNames             = [String]()
    
    /*
     dataObjectToPass is the data object to pass to the downstream view controller (i.e., LocationViewController)
     Create the array to hold 2 string values as specified at index 0 and 1.
     
     NOTE: To store values in an array using its index, you must create the array with the number of index values to be used.
     */
    var dataObjectToPass: [String] = ["", ""]
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Obtain the URL to the accSports.plist file in subdirectory "plist Files"
        let accSportsPlistURL : URL? = Bundle.main.url(forResource: "accSports", withExtension: "plist", subdirectory: "Plist Files")
        
        /*
         NSDictionary manages an *unordered* collection of key-value pairs.
         Instantiate an NSDictionary object and initialize it with the contents of the accSports.plist file.
         */
        let dictionary1FromFile: NSDictionary? = NSDictionary(contentsOf: accSportsPlistURL!)
        
        if let dictionaryForAccSportsPlistFile = dictionary1FromFile {
            
            // Typecast the created dictionary of type NSDictionary as Dictionary type
            // and assign it to the class property named dict1_UniversityName_Dict2
            dict1_UniversityName_Dict2 = dictionaryForAccSportsPlistFile as! Dictionary
            
            /*
             allKeys returns a new array containing the dictionary’s keys as of type AnyObject.
             Therefore, typecast the AnyObject type keys to be of type String.
             The keys in the array are *unordered*; therefore, they need to be sorted.
             */
            universityNames = dictionaryForAccSportsPlistFile.allKeys as! [String]
            
            // Sort the universityNames within itself in alphabetical order
            universityNames.sort { $0 < $1 }
            
        } else {
            /*
             Create a UIAlertController object; dress it up with title, message, and preferred style;
             and store its object reference into local constant alertController
             */
            let alertController = UIAlertController(title: "Unable to Access the accSports.plist file!",
                                                    message: "The file does not reside in the application's main bundle (project folder)!",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            present(alertController, animated: true, completion: nil)
            
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Obtain the number of the row in the middle of the university names list
        let numberOfRowToShow = Int(universityNames.count / 2)
        
        // Show the picker view of the university names from the middle
        pickerView.selectRow(numberOfRowToShow, inComponent: 0, animated: false)
        
        // Deselect the earlier selected map type
        mapTypeSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    /*
     -------------------------
     MARK: - Map Type Selected
     -------------------------
     */
    @IBAction func mapTypeSelected(_ sender: UISegmentedControl) {
        
        var mapType: String = ""
        
        switch sender.selectedSegmentIndex {
            
        case 0:   // Standard map type selected
            mapType = "Standard"
            
        case 1:   // Satellite map type selected
            mapType = "Satellite"
            
        case 2:   // Hybrid map type selected
            mapType = "Hybrid"
            
        default:
            return
        }
        
        // Prepare the data object to pass to the downstream view controller
        
        let indexNumber: Int = pickerView.selectedRow(inComponent: 0)
        dataObjectToPass[0] = universityNames[indexNumber]
        
        dataObjectToPass[1] = mapType
        
        // Perform the segue named "Show Location on Map"
        performSegue(withIdentifier: "Show Location on Map", sender: self)
    }
    
    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     
     This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
     You never call this method. It is invoked by the system.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "Show Location on Map" {
            
            // Obtain the object reference of the destination (downstream) view controller
            let locationViewController: LocationViewController = segue.destination as! LocationViewController
            
            /*
             This view controller creates the dataObjectToPass and passes it (by value) to the downstream view controller
             LocationViewController by copying its content into LocationViewController's property dataObjectPassed.
             */
            locationViewController.dataObjectPassed = dataObjectToPass
        }
    }
    
    /*
     -----------------------------------------------
     MARK: - UIPickerViewDataSource Protocol Methods
     -----------------------------------------------
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return universityNames.count
    }
    
    /*
     --------------------------------------------
     MARK: - UIPickerViewDelegate Protocol Method
     --------------------------------------------
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return universityNames[row]
    }
    
}
