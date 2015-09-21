//
//  ViewController.swift
//  iOSNotification
//
//  Created by Kadasiddha on 19/09/15.
//  Copyright (c) 2015 Kadasiddha. All rights reserved.
//

import UIKit
import AudioToolbox


class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func showNotification(sender: AnyObject) {
        let chaChingSound: SystemSoundID = createChaChingSound()
        AudioServicesPlaySystemSound(chaChingSound)
        
        // Add the image.png in your Xcode project
        SNotificationView.displayNotificationViewWithImage(UIImage(named:"image.png"), title: "Sample Notification", message: "This is sample notification", autoHide: true, didTouch: {    SNotificationView.hideNotificationViewOnComplete(nil)
            
        })

    }
    
    
    //Create sound 
    // You need to add the Glass.mp3 in your Xcode project
    func createChaChingSound() -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "Glass", "mp3", nil)
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        return soundID
    }

}

