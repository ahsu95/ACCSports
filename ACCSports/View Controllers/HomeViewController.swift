//
//  HomeViewController.swift
//  ACCSports
//
//  Created by Osman Balci on 9/26/17.
//  Copyright © 2017 Osman Balci. All rights reserved.
//

import UIKit
import WebKit

@objc

// Define HomeViewControllerDelegate as a protocol with two optional methods
protocol HomeViewControllerDelegate {
    
    @objc optional func toggleMenuView()
    @objc optional func collapseMenuView()
}


class HomeViewController: UIViewController, MenuViewControllerDelegate, WKNavigationDelegate {
    
    /*
     Store the object reference of the UIWebView object, created in the
     Storyboard (Interface Builder), into instance variable webView.
     */
    @IBOutlet var webView: WKWebView!
    
    /*
     This instance variable designates the object that adopts the HomeViewControllerDelegate protocol.
     ContainerViewController adopts this protocol and implements its two optional methods (see its code).
     */
    var delegate: HomeViewControllerDelegate?
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Set self (HomeViewController object) to be the webView (WKWebView) object's navigation delegate
         so that we can implement the three WKNavigationDelegate protocol methods given below.
         */
        webView.navigationDelegate = self
        
        // Display the homePage.html file, provided in the main bundle, as the homepage.
        displayHomepage()
    }
    
    /*
     ------------------------
     MARK: - Display Homepage
     ------------------------
     */
    func displayHomepage() {
        
        // Obtain the URL of the homePage.html file in the main bundle.
        let url : URL? = Bundle.main.url(forResource: "homePage", withExtension: "html", subdirectory: "HTML Files")
        
        /*
         Convert the NSURL object into an NSURLRequest object and store its object reference into the local variable request.
         An NSURLRequest object represents a URL load request in a manner independent of protocol and URL scheme.
         */
        let request = URLRequest(url: url!)
        
        // Ask the webView object to display the requested web page.
        self.webView.load(request)
    }
    
    /*
     ----------------------------------------------
     MARK: - Take Action for the Menu Item Selected
     ----------------------------------------------
     
     MenuViewControllerDelegate Protocol Method
     */
    func sportSelected(_ url: URL) {
        
        // Obtain the URL of the sport website to show
        let request = URLRequest(url: url)
        
        // Ask the web view object to display the sport website
        self.webView.load(request)
        
        /*
         Ask the navigation controller to pop all of the view controllers on the stack
         except the root view controller and update the display.
         */
        _ = self.navigationController?.popToRootViewController(animated: false)
        
        /*
         Tell the delegate (ContainerViewController) to execute its implementation of the
         HomeViewControllerDelegate protocol method collapseMenuView()
         */
        delegate?.collapseMenuView!()
    }
    
    /*
     ----------------------
     MARK: - Buttons Tapped
     ----------------------
     */
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        
        /*
         Tell the delegate (ContainerViewController) to execute its implementation of the
         HomeViewControllerDelegate protocol method toggleMenuView()
         */
        delegate?.toggleMenuView!()
    }
    
    @IBAction func homeButtonTapped(_ sender: UIBarButtonItem) {
        
        // Display the homePage.html file, provided in the main bundle, as the homepage.
        displayHomepage()
    }
    
    /**********************************************************************************************************
     ACC Map button is directly connected to display its view controller in the Storyboard. When a button is
     directly connected to show its view controller, you have no control over the segue, which happens directly.
     If you wish to prepare the view controller before it is shown, do it like the Location button is handled:
     Control-drag from the view controller object to segue instead of directly from the button.
     **********************************************************************************************************/
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        
        // Perform the segue named "Selection View"
        performSegue(withIdentifier: "Selection View", sender: self)
    }
    
    /*
     ---------------------------------------------
     MARK: - WKNavigationDelegate Protocol Methods
     ---------------------------------------------
     */
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Starting to load the web page. Show the animated activity indicator in the status bar
        // to indicate to the user that the UIWebVIew object is busy loading the web page.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Finished loading the web page. Hide the activity indicator in the status bar.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        /*
         Ignore this error if the page is instantly redirected via JavaScript or in another way.
         NSURLErrorCancelled is returned when an asynchronous load is cancelled, which happens
         when the page is instantly redirected via JavaScript or in another way.
         */
        
        if (error as NSError).code == NSURLErrorCancelled  {
            return
        }
        
        // An error occurred during the web page load. Hide the activity indicator in the status bar.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // Create the error message in HTML as a character string and store it into the local constant errorString
        let errorString = "<html><font size=+4 color='red'><p>Unable to Display Webpage: <br />Possible Causes:<br />- No network connection<br />- Wrong URL entered<br />- Server computer is down</p></font></html>" + error.localizedDescription
        
        // Display the error message within the UIWebView object
        // self. is required here since this method has a parameter with the same name.
        self.webView.loadHTMLString(errorString, baseURL: nil)
    }
    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     
     This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
     You never call this method. It is invoked by the system.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "Selection View" {
            
            // Obtain the object reference of the destination (downstream) view controller
            // var selectionViewController: SelectionViewController = segue.destinationViewController as! SelectionViewController
            
            /*
             We do not need to pass anything to the downstream view controller. However, this tutorial provides the
             structure here so that if you need to, you can do it right here.
             
             This view controller creates the dataObjectToPass and passes it (by value) to the downstream view controller
             selectionViewController by copying its content into selectionViewController's property dataObjectPassed.
             */
            // selectionViewController.dataObjectPassed = dataObjectToPass
        }
    }
    
}
