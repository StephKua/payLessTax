//
//  CameraViewController.swift
//  PayLessTax
//
//  Created by Skkz on 28/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//


import UIKit
import Fusuma
import Firebase
import SwiftyJSON

class CameraViewController: UIViewController, FusumaDelegate {
    
    var API_KEY = "AIzaSyBBqgYGug-ksuN5Yefmcf8ACSj_isZ-5Ls"
    
    var firebaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://paylesstax-8352b.appspot.com")
    var base64string: NSString!
    var userName: String!
    var finalValue: Float!
    var date: String!
    var invoiceNo: String!
    var total: String!
    
    var fusuma = FusumaViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()
        fusuma.delegate = self
        fusuma.hasVideo = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        getUserName()
        
    }


    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(image: UIImage) {
        let imageName = NSUUID().UUIDString
        let imageRef = FIRStorage.storage().reference().child("Images").child("\(imageName).png")
        if let uploadData = UIImageJPEGRepresentation(image, 0.1){
            imageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    let imageDict = ["imageURL": imageUrl, "userID": User.currentUserId()!, "userName": self.userName]
                    self.firebaseRef.child("Images").child(imageName).setValue(imageDict)
                    self.firebaseRef.child("users").child(User.currentUserId()!).child("uploaded").child(imageName).setValue(true)
                    let commentDict = ["imageUID": imageName]
                    self.firebaseRef.child("Comments").setValue(commentDict)
                    
                }
            })
        }
        
        self.tabBarController?.selectedIndex = 0
        print("Image selected")
        
        let binaryImageData = base64EncodeImage(image)
        createRequest(binaryImageData)
    }
    
    func getUserName() {
        let firebaseRef = FIRDatabase.database().reference()
        let userRef = firebaseRef.child("users")
        
        userRef.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            
            if let tweetDict = snapshot.value as? [String : AnyObject]{
                print (snapshot.key)
                if (snapshot.key == User.currentUserId()) {
                    if let tweetText = tweetDict["username"] as? String{
                        self.userName = tweetText
                    }
                }
            }
        })
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage) {
        print("Called just after FusumaViewController is dismissed.")
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
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func resizeImage(imageSize: CGSize, image: UIImage) -> NSData {
        UIGraphicsBeginImageContext(imageSize)
        image.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func base64EncodeImage(image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.length > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSizeMake(800, oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    func createRequest(imageData: String) {
        // Create our request URL
        let request = NSMutableURLRequest(
            URL: NSURL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(
            NSBundle.mainBundle().bundleIdentifier ?? "",
            forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest: [String: AnyObject] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        // Serialize the JSON
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonRequest, options: [])
        
        // Run the request on a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.runRequestOnBackgroundThread(request)
        });
        
    }
    
    
    func runRequestOnBackgroundThread(request: NSMutableURLRequest) {
        
        let session = NSURLSession.sharedSession()
        
        // run the request
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            self.analyzeResults(data!)
        })
        task.resume()
    }
    
    func analyzeResults(dataToParse: NSData) {
        
        // Update UI on the main thread
        dispatch_async(dispatch_get_main_queue(), {
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            print(json)
            let errorObj: JSON = json["error"]
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                print("Error code \(errorObj["code"]): \(errorObj["message"])")
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]
                
                // Get label annotations
                let labelAnnotations: JSON = responses["textAnnotations"]
                print(labelAnnotations)
                let textValue = labelAnnotations[0]["description"].stringValue
                print(textValue)
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    for index in 1..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    
                    for (index, label) in labels.enumerate() {
//
                        let label = label.lowercaseString
//                        
                        if label.containsString("total") {
                            self.total = labels[index+1]
                        }
                        
                        
                        if label.containsString("date") {
                            self.date = labels[index+1]
                        }
                        
                        if label.containsString("inv") || label.containsString("bill") {
                            self.invoiceNo = labels[index+1]
                        }
                    }
                    
//                    for label in floatLabels {
//                        guard let floatLabel = Float(label) else { continue }
//                        print("running convert to float \(floatLabel)")
//                        labelValue.append(floatLabel)
//                    }
//                    
//                    let sortedValue = labelValue.sort({ (float1, float2) -> Bool in
//                        return float1 < float2
//                    })
//                    
//                    self.finalValue = sortedValue[sortedValue.count-1]
//                    print(sortedValue)
                let total = self.total ?? "b"
                    let date = self.date ?? "b"
                    let Inv = self.invoiceNo ?? "b"
                    self.confirmInfo(total, date: date, InvNo: Inv)
                } else {
                    print("No labels found")
                }
            }
        })
    }
    
    func confirmInfo(total: String, date: String, InvNo: String) {
        print("checking")
        let alert = UIAlertController(title: "Confirmation Message", message: "Total: \(total)\nDate: \(date)\nInvoice No: \(InvNo)", preferredStyle: .Alert)
        let yes = UIAlertAction(title: "Yes", style: .Default) { (action) in
            self.fusumaClosed()
        }
        let no = UIAlertAction(title: "No", style: .Default) { (action) in
            let edit = UIAlertController(title: "Confirm with Correct Info", message: nil, preferredStyle: .Alert)
            edit.addTextFieldWithConfigurationHandler({ (textField) in
                textField.placeholder = "Total"
                textField.keyboardType = .DecimalPad
            })
            let okay = UIAlertAction(title: "Confirm", style: .Default, handler: { (action) in
                self.fusumaClosed()
            })
            edit.addAction(okay)
        }
        
        alert.addAction(yes)
        alert.addAction(no)
        self.presentViewController(alert, animated: true) { 
            print("Yays")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}



