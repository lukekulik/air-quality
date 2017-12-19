//  Created by Luke K. on 20/10/15.
//  Copyright © 2015 Luke K. All rights reserved.
//

import Cocoa
import NotificationCenter
import CoreLocation
import Alamofire
//import SwiftyJSON

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


//var minimumVisibleRowCount: Int = 3
//git test

class TodayViewController: NSViewController, NCWidgetProviding, NCWidgetListViewDelegate, NCWidgetSearchViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet var listViewController: NCWidgetListViewController!
   // @IBOutlet var listViewController2: NCWidgetListViewController!
    var searchController: NCWidgetSearchViewController?
    var acqScore_local:String = "??"
    var acqScoreAsync:String = "--"
    
    fileprivate var locationManager = CLLocationManager()
    var LatitudeGPS = NSString()
    var LongitudeGPS = NSString()
    
    
    //push notifications if it's really bad?
    let defaults = UserDefaults.standard
    
    override var nibName: String? {
        return "TodayViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("viewDidLoad initialized")
        
        self.updateLocation()
        locationManager.stopUpdatingLocation() // Stop Location Manager - keep here to run just once
        NSLog((locationManager.location!.coordinate.latitude).description)
        
        ////
        ////        LatitudeGPS = String(format: "%.6f", manager.location!.coordinate.latitude)
//        locationManagerX(locationManager, didUpdateLocations: <#T##[AnyObject]#>)
        
//        locationManager.delegate = self
//        NSLog((locationManager.location?.description)!)
//      locationManager.requestWhenInUseAuthorization()
//         locationManager.requestLocation()
        
        if !((self.defaults.string(forKey: "score")) == nil)
        {
        acqScore2=self.defaults.string(forKey: "score")!
        safety=self.defaults.string(forKey: "icon")! // mess with variable names and locality.!
        time2=self.defaults.string(forKey: "timer")!
            NSLog("Defaults loaded - score: \(acqScore2), icon: \(safety), time: \(time2)")
        }
        
        //locationManagerX(locationManager, )
        self.listViewController.contents = [self.acqScore_local]
        
        widgetPerformUpdate(completionHandler: { (error) -> () in // pointless string
//            if 1 == 1 {
            
                self.updateData()
                let row =  ["1"]//,"2"]
//                NSLog("Data Updated from \(lastScore) to \(self.acqScoreAsync)")
                self.listViewController.contents=row
//            }
        })
    }
    //add a little icon showing that we're up to date
    func widgetPerformUpdate(completionHandler: @escaping ((NCUpdateResult) -> Void)) {
        // Refresh the widget's contents in preparation for a snapshot.
        // Call the completion handler block after the widget's contents have been
        // refreshed. Pass NCUpdateResultNoData to indicate that nothing has changed
        // or NCUpdateResultNewData to indicate that there is new data since the
        // last invocation of this method.
        NSLog("Updating...")
        jsonParser("",completion: { (error) -> () in
//            NSLog(self.acqScoreAsync)
//            NSLog(self.acqScore) //better check needed here - more robust
            if error == nil  && !(acqScore2==self.acqScore_local){
                NSLog("New data found")
                self.updateData()
                
                self.defaults.set(acqScore2, forKey: "score")
                self.defaults.set(safety, forKey: "icon")
                self.defaults.set(time2, forKey: "timer")
                self.defaults.synchronize()
                NSLog("New defaults written - score: \(self.defaults.string(forKey: "score")!), icon: \(self.defaults.string(forKey: "icon")!), time: \(self.defaults.string(forKey: "timer")!)")

                completionHandler(.newData)
                
            } else {
                
                if (self.acqScoreAsync==self.acqScore_local) {
                    NSLog("No new data found")
                    completionHandler(.noData)
                }
                else{
                    NSLog("Empty array received or data corrupted")
                    completionHandler(.noData)
                }
            }
        })
    }
    
    func jsonParser(_ latLong: String, completion: @escaping (_ error: NSError?) -> ()) {
        
        let noError:NSError? = nil
        let serviceError:NSError? = nil // nasty workaround

        Alamofire.request(URL(string: "http://waqi.aqicn.org/mapi/?term=\(city)")!,
                          method: .get).responseJSON(){
            response in
            
            if response.result.isSuccess {
                let data = response.result.value
                let swiftyJSONObject = JSON(data)
                
                if !swiftyJSONObject.isEmpty {
                    acqScore2=(swiftyJSONObject[0]["aqi"].description)
                    let dateX = NSDate(timeIntervalSince1970: Double(swiftyJSONObject[0]["utime"].description)!)
                    let formatter = DateFormatter()
//                    formatter.timeStyle = .ShortStyle
                    time2 = formatter.stringFromDate(dateX)
                    completion(noError)
                }
                else {
                    NSLog("Empty array received")
                    completion(serviceError)
                }
            }
        }
    }

    func updateData()
    {
        let oldVal = self.acqScore_local
        self.acqScore_local=acqScore2
        
        let score=Int(self.acqScore_local)
        
        if score<50
        {
            safety="😊"
        }
        
        if score>50
        {
            safety="😕"
        }
        
        if score>100
        {
            safety="😷"
        }
        
        if score>300
        {
            safety="😱"
        }
        
        if score>500
        {
            safety="🚨"
        }
    
        acqScore2 = self.acqScore_local
        //🇨🇳 china bad
        
        NSLog("Data Updated from \(oldVal) to \(self.acqScore_local)") //this is wrong

    }
    
    
    

    
    func updateLocation() {
        //        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //self.locationManager.distanceFilter = 10
        //       self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
////        locationManager.stopUpdatingLocation() // Stop Location Manager - keep here to run just once
////        
////        LatitudeGPS = String(format: "%.6f", manager.location!.coordinate.latitude)
////        LongitudeGPS = String(format: "%.6f", manager.location!.coordinate.longitude)
////        NSLog("Latitude - \(LatitudeGPS)")
//        NSLog(locations.description)
//        //        NSLog(manager.location!.al)
//        //                   NSLog(placemark.postalCode!)
//        //                    NSLog(placemark.administrativeArea!)
//        //                    NSLog(placemark.country!)
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    //    let locationManager = CLLocationManager()
    //
    ////    locationManager.delegate = self
    //    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    //    locationManager.requestWhenInUseAuthorization()
    //    locationManager.startUpdatingLocation()
    //
    //    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    //        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)-&gt;Void in
    //            if error {
    //                NSLog("Reverse geocoder failed with error" + error.localizedDescription)
    //                return
    //            }
    //
    //            if placemarks.count &gt; 0 {
    //                let pm = placemarks[0] as CLPlacemark
    //                self.displayLocationInfo(pm)
    //            } else {
    //                NSLog("Problem with the data received from geocoder")
    //            }
    //        })
    //    }
    //
    //    func displayLocationInfo(placemark: CLPlacemark) {
    //        if placemark != nil {
    //            //stop updating location to save battery life
    //            locationManager.stopUpdatingLocation()
    //            NSLog(placemark.locality!)
    //            NSLog(placemark.postalCode!)
    //            NSLog(placemark.administrativeArea!)
    //            NSLog(placemark.country!)
    //        }
    //    }

    
    override func dismissViewController(_ viewController: NSViewController) {
        super.dismissViewController(viewController)
        
        // The search controller has been dismissed and is no longer needed.
        if viewController == self.searchController {
            self.searchController = nil
        }
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInset: EdgeInsets) -> EdgeInsets {
        // Override the left margin so that the list view is flush with the edge.
        var newInsets = defaultMarginInset
        newInsets.left = 0
        return newInsets
    }
    
    var widgetAllowsEditing: Bool {
        // Return true to indicate that the widget supports editing of content and
        // that the list view should be allowed to enter an edit mode.
        return false
    }
    
    func widgetDidBeginEditing() {
        // The user has clicked the edit button.
        // Put the list view into editing mode.
        self.listViewController.editing = true
    }
    
    func widgetDidEndEditing() {
        // The user has clicked the Done button, begun editing another widget,
        // or the Notification Center has been closed.
        // Take the list view out of editing mode.
        self.listViewController.editing = false
    }
    
    // MARK: - NCWidgetListViewDelegate
    
    func widgetList(_ list: NCWidgetListViewController, viewControllerForRow row: Int) -> NSViewController {
        // Return a new view controller subclass for displaying an item of widget
        // content. The NCWidgetListViewController will set the representedObject
        // of this view controller to one of the objects in its contents array.
        return ListRowViewController()
    }
    
    func widgetListPerformAddAction(_ list: NCWidgetListViewController) {
        // The user has clicked the add button in the list view.
        // Display a search controller for adding new content to the widget.
        self.searchController = NCWidgetSearchViewController()
        self.searchController!.delegate = self
        
        // Present the search view controller with an animation.
        // Implement dismissViewController to observe when the view controller
        // has been dismissed and is no longer needed.
        self.present(inWidget: self.searchController!)
    }
    
    func widgetList(_ list: NCWidgetListViewController, shouldReorderRow row: Int) -> Bool {
        // Return true to allow the item to be reordered in the list by the user.
        return false
    }
    
    func widgetList(_ list: NCWidgetListViewController, didReorderRow row: Int, toRow newIndex: Int) {
        // The user has reordered an item in the list.
    }
    
    func widgetList(_ list: NCWidgetListViewController, shouldRemoveRow row: Int) -> Bool {
        // Return true to allow the item to be removed from the list by the user.
        return false
    }
    
    func widgetList(_ list: NCWidgetListViewController, didRemoveRow row: Int) {
        // The user has removed an item from the list.
    }
    
    // MARK: - NCWidgetSearchViewDelegate
    
    func widgetSearch(_ searchController: NCWidgetSearchViewController, searchForTerm searchTerm: String, maxResults max: Int) {
        // The user has entered a search term. Set the controller's searchResults property to the matching items.
        searchController.searchResults = []
    }
    
    func widgetSearchTermCleared(_ searchController: NCWidgetSearchViewController) {
        // The user has cleared the search field. Remove the search results.
        searchController.searchResults = nil
    }
    
    func widgetSearch(_ searchController: NCWidgetSearchViewController, resultSelected object: Any) {
        // The user has selected a search result from the list.
    }
    

    
}
