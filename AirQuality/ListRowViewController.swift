//
//  ListRowViewController.swift
//  acqStory
//
//  Created by Luke K. on 20/10/15.
//  Copyright © 2015 Luke K. All rights reserved.
//

import Cocoa

var safety=""
var city = "Bleriotlaan" // this line Bleriotlaan
var time2 = "--:--"
var acqScore2 = "1"
class ListRowViewController: NSViewController {
    
    // MARK: Properties
    
    @IBOutlet var cityName: NSTextField!
    @IBOutlet var updateTime: NSTextField!
    @IBOutlet var safetyLevel: NSTextField!
    @IBOutlet var score: NSTextField!
    @IBOutlet var uvAlert: NSTextField!

    override var nibName: String? {
        return "ListRowViewController"
    }
    
    override func loadView() {
        super.loadView()
        NSLog("LoadView initialized")
        updateTime.stringValue = time2
        safetyLevel.stringValue = safety
        cityName.stringValue = city
        score.stringValue = acqScore2
        uvAlert.stringValue = "" // should be "UV" otherwise (if index > 2)

        
        // Insert code here to customize the view
        
        
    }
    
}
