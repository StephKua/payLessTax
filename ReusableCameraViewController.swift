//
//  ReusableCameraViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 29/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Fusuma
class ReusableCameraViewController: UIViewController, FusumaDelegate {

    var fusumaVC = FusumaViewController() { didSet {
        fusumaVC.delegate = self
        fusumaVC.hasVideo = true
        }
    }
// Testing fusuma //
    func fusumaDismissedWithImage(image: UIImage) {
        print("Called just after FusumaViewController is dismissed.")
        self.fusumaClosed()
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        print("VIdeo Completed")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
    }
    
    func fusumaClosed() {
        print("Goodbye")
    }
    
    func fusumaImageSelected(image: UIImage) {
        
    }
}
