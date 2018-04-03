//
//  LocationViewController.swift
//  ACCSports
//
//  Created by Osman Balci on 9/26/17.
//  Copyright © 2017 Osman Balci. All rights reserved.
//

import UIKit

import UIKit
import MapKit

class LocationViewController: UIViewController, MKMapViewDelegate {
    
    /*
     dataObjectPassed[0] = university name
     dataObjectPassed[1] = map type
     */
    var dataObjectPassed = [String]()
    
    /*
     Store the object reference of the MKMapView object, created in the
     Storyboard (Interface Builder), into instance variable mapView.
     */
    @IBOutlet var mapView: MKMapView!
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Obtain the selected university name from the data object passed
        let selectedUniversityName = dataObjectPassed[0]
        
        // Set the title of the view controller to the selected university name
        self.title = selectedUniversityName
        
        /*
         MKCoordinateSpan is a structure that defines the area spanned by a map region.
         
         typedef struct {
         CLLocationDegrees latitudeDelta;
         CLLocationDegrees longitudeDelta;
         } MKCoordinateSpan;
         
         Create a span with latitude delta to 2 degrees, i.e., 2 x 111 kilometers (69 miles)
         and longitude delta to 2 degrees, i.e., 2 x 111 kilometers (69 miles)
         */
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        
        /*
         latitudeDelta: The amount of north-to-south distance (measured in degrees) to display on the map. Unlike longitudinal distances,
         which vary based on the latitude, one degree of latitude is always approximately 111 kilometers (69 miles).
         longitudeDelta: The amount of east-to-west distance (measured in degrees) to display for the map region. The number of kilometers
         spanned by a longitude range varies based on the current latitude. For example, one degree of longitude spans a distance of
         approximately 111 kilometers (69 miles) at the equator but shrinks to 0 kilometers at the poles.
         */
        
        // Instantiate a Geocoder Object
        let geocoder = CLGeocoder()
        
        /**************** FORWARD GEOCODING LOCATION DATA ******************************
         Geocoder Objects
         
         <> Reverse geocoding is the process of converting a latitude and longitude into a placemark.
         <> Forward geocoding is the process of converting place name information into a latitude and longitude value.
         
         http://developer.apple.com/library/ios/#documentation/userexperience/conceptual/LocationAwarenessPG/UsingGeocoders/UsingGeocoders.html
         
         Converting Place Names Into Coordinates
         
         CLGeocoder class is used to initiate forward-geocoding requests using either a dictionary of Address Book information or a simple string.
         There is no designated format for string-based requests; delimiter characters are welcome, but not required, and the geocoder server
         treats the string as case-insensitive. Therefore, any of the following strings would yield results:
         
         "Apple Inc”
         "1 Infinite Loop”
         "1 Infinite Loop, Cupertino, CA USA”
         
         The more information you can provide to the forward geocoder, the better the results returned to you. The geocoder object parses the
         information you give it and, if it finds a match, returns some number of placemark objects. The number of returned placemark objects
         depends greatly on the specificity of the information provided. Thus, providing street, city, province, and country information is much
         more likely to return a single address than just street and city information. The completion handler block you pass to the geocoder
         should therefore be prepared to handle multiple placemarks, as shown below.
         *****************************************************************************/
        
        // Set the selectedUniversityName to be the address for Apple map API (spaces are okay unlike Google map API query)
        let address = selectedUniversityName
        
        /*
         We use a Closure below in-between { and }.
         
         "Closure expression syntax has the following general form:
         
         { (parameters) -> return type in
         statements
         }
         
         Closures are self-contained blocks of functionality that can be passed around and used in your code. Closures in Swift are
         similar to blocks in C and Objective-C and to lambdas in other programming languages." [Swift Guide]
         */
        
        geocoder.geocodeAddressString(address) { (placemarks, error) -> Void in
            
            // If the optional first element in the placemarks array returned has a value, it will be the geolocation we want
            if let aPlacemark = placemarks?[0] as CLPlacemark! {
                
                // Set the span and the center of the map region to display
                let region: MKCoordinateRegion = MKCoordinateRegion(center: aPlacemark.location!.coordinate, span: span)
                
                // Ask the map view object to display the defined map region in an animated way
                self.mapView.setRegion(region, animated: true)
                
                // Ask the map view object to display the map region as fitting to the map frame
                self.mapView.regionThatFits(region)
                
                switch self.dataObjectPassed[1] {
                    
                case "Standard":
                    self.mapView.mapType = MKMapType.standard
                    
                case "Satellite":
                    self.mapView.mapType = MKMapType.satellite
                    
                case "Hybrid":
                    self.mapView.mapType = MKMapType.hybrid
                    
                default:
                    print("Unable to determine map type!")
                    return
                }
                
            } else {
                print("Unable to compute forward geocoding!")
            }
        }
    }
    
    /*
     ------------------------------------------
     MARK: - MKMapViewDelegate Protocol Methods
     ------------------------------------------
     */
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        
        // Starting to load the map. Show the animated activity indicator in the status bar
        // to indicate to the user that the map view object is busy loading the map.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        // Finished loading the map. Hide the activity indicator in the status bar.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        
        // An error occurred during the map load. Hide the activity indicator in the status bar.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: "Unable to Load the Map for: \(dataObjectPassed[0])!",
            message: "Error description: \(error.localizedDescription)",
            preferredStyle: UIAlertControllerStyle.alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller by calling the presentViewController method
        present(alertController, animated: true, completion: nil)
    }
    
}

