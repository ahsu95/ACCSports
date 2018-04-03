
//  ContainerViewController.swift
//  ACCSports
//
//  This class was originally created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//
//  Modified and Documented by Osman Balci on 09/22/2016.
//

import UIKit
import QuartzCore

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


enum SlideOutState {
    case menuCollapsed
    case menuExpanded
}


class ContainerViewController: UIViewController, HomeViewControllerDelegate, UIGestureRecognizerDelegate {
    
    /*
     This class is named Container, because it is a Container type of view controller controlling two child view controllers:
     1. NavigationController
     2. MenuViewController.
     NavigationController is also a Container type of view controller controlling HomeViewController and its child
     view controllers: SelectionViewController and LocationViewController.
     
     "Container view controllers display content owned by other view controllers. These other view controllers are
     explicitly associated with the container, forming a parent-child relationship. The combination of container and
     content view controllers creates a hierarchy of view controller objects with a single root view controller." [Apple]
     */
    
    var homeNavigationController: UINavigationController!
    var homeViewController: HomeViewController!
    
    var currentState: SlideOutState = .menuCollapsed {
        didSet {
            let shouldShowShadow = currentState != .menuCollapsed
            showShadowForHomeViewController(shouldShowShadow)
        }
    }
    
    var menuViewController: MenuViewController?
    
    // This defines how much the center view will show on the right when the menu is shown on the left.
    let centerPanelExpandedOffset: CGFloat = 60
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Create a HomeViewController object using UIStoryboard's private extension class method and
         store its object reference into the instance variable homeViewController.
         */
        homeViewController = UIStoryboard.homeViewController()
        
        // Designate self as the delegate to implement and execute the HomeViewControllerDelegate protocol methods.
        homeViewController.delegate = self
        
        /*
         Create a UINavigationController object and set its root view controller to be the homeViewController.
         Embedding the homeViewController within a navigation controller enables navigation to downstream
         view controllers and navigating back to upstream view controllers.
         */
        homeNavigationController = UINavigationController(rootViewController: homeViewController)
        view.addSubview(homeNavigationController.view)
        
        // Add homeNavigationController as a child view controller
        addChildViewController(homeNavigationController)
        
        // didMoveToParentViewController is called after a view controller is added to or removed from a container view controller.
        homeNavigationController.didMove(toParentViewController: self)
        
        /*
         The pan gesture is also known as drag or slide gesture. The user pans (drags or slides) the homeNavigationController
         object to reveal the menu (MenuViewController's view). Therefore, whichever view the homeNavigationController is
         showing can be slided to the right to reveal the menu (MenuViewController's view).
         
         Create a UIPanGestureRecognizer object, which will call the handlePanGesture: method when the user pans (drags or slides)
         the homeNavigationController object. Store its object reference into local variable panGestureRecognizer.
         */
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.handlePanGesture(_:)))
        
        // Attach the pan gesture recognizer object to the homeNavigationController object.
        homeNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    /*
     ---------------------------------------------------
     MARK: - HomeViewControllerDelegate Protocol Methods
     ---------------------------------------------------
     */
    func toggleMenuView() {
        
        let notAlreadyExpanded = (currentState != .menuExpanded)
        
        if notAlreadyExpanded {
            addMenuViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseMenuView() {
        
        switch (currentState) {
        case .menuExpanded:
            toggleMenuView()
        default:
            break
        }
    }
    
    /*
     --------------------------------
     MARK: - Add Menu View Controller
     --------------------------------
     */
    func addMenuViewController() {
        
        if (menuViewController == nil) {
            
            /*
             Create a MenuViewController object using UIStoryboard's private extension class method and
             store its object reference into the instance variable menuViewController.
             */
            menuViewController = UIStoryboard.menuViewController()
            
            // Designate homeViewController as the delegate to implement and execute the MenuViewControllerDelegate protocol methods.
            menuViewController!.delegate = homeViewController
            
            view.insertSubview(menuViewController!.view, at: 0)
            
            // Add menuViewController as a child view controller
            addChildViewController(menuViewController!)
            
            // didMoveToParentViewController is called after a view controller is added to or removed from a container view controller.
            menuViewController!.didMove(toParentViewController: self)
        }
    }
    
    /*
     ---------------------------
     MARK: - Animate Pan Gesture
     ---------------------------
     */
    func animateLeftPanel(shouldExpand: Bool) {
        
        if (shouldExpand) {
            currentState = .menuExpanded
            
            animateCenterPanelXPosition(targetPosition: homeNavigationController.view.frame.width - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .menuCollapsed
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.homeNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func showShadowForHomeViewController(_ shouldShowShadow: Bool) {
        
        if (shouldShowShadow) {
            homeNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            homeNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    /*
     --------------------------
     MARK: - Handle Pan Gesture
     --------------------------
     */
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        let gestureIsDraggingFromRightToLeft = (recognizer.velocity(in: view).x < 0)
        
        switch(recognizer.state) {
        case .began:
            if (currentState == .menuCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addMenuViewController()
                    showShadowForHomeViewController(true)
                }
            }
        case .changed:
            if menuViewController != nil && ((gestureIsDraggingFromRightToLeft && recognizer.view?.center.x > 187.5) || (gestureIsDraggingFromLeftToRight && recognizer.translation(in: view).x >= 0)) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
        case .ended:
            if menuViewController != nil {
                // Animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
}

/*
 ------------------------------------
 MARK: - Storyboard Private Extension
 ------------------------------------
 */
private extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func menuViewController() -> MenuViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
    }
    
    class func homeViewController() -> HomeViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
    }
    
}
