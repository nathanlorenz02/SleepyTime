//
//  ViewController.swift
//  SleepyTime
//
//  Created by Nathan Lorenz on 2017-10-15.
//  Copyright © 2017 Nathan Lorenz. All rights reserved.
//

import UIKit
import UserNotifications
import MessageUI
import SafariServices
import AudioToolbox

var strings: [String] = []

class ViewController: UIViewController, MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate, UITextFieldDelegate {
    
     var timer = Timer()
     var timer2 = Timer()
     let userDefaults = UserDefaults.standard
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateClock), userInfo: nil, repeats: true)
        
        timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.bedTimeSet), userInfo: nil, repeats: true)
        
        let data: String? = userDefaults.object(forKey: "keyBed") as! String?
        if(data != nil) {
            bedTimeSetLbl.text = data
        } else {
            bedTimeSetLbl.text = "You don't have your bedtime set."
        }
        
        
    }
    
    @objc func updateClock()
    {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = "\(timeFormatter.string(from: Date() as Date))"
        clockLbl.text = String(timeString)
        
    }
    
    @objc func bedTimeSet()
    {
        let data = bedTimeSetLbl.text
        userDefaults.set(data, forKey: "keyBed")
    }
    
    @IBOutlet weak var clockLbl: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateClock), userInfo: nil, repeats: true)
        
        
        //Asks to send notfications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
            if didAllow
            {
                
            }
            else
            {
                
            }
            
        })
        
       
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.dissmissKeyboard))
            toolbar.setItems([doneButton], animated: false)
            toolbar.isUserInteractionEnabled = true
            hrTextField.inputAccessoryView = toolbar
            minTextField.inputAccessoryView = toolbar
        
        remindMeButtonOutlet.layer.cornerRadius = 8
        turnOffOutlet.layer.cornerRadius = 8
        
        // Move view up for keyboard
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
       
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 4
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    
    @objc func dissmissKeyboard()
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hrTextField.resignFirstResponder()
        minTextField.resignFirstResponder()
        return true
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    
   
    @IBOutlet weak var bedTimeSetLbl: UILabel!
    @IBOutlet weak var remindMeButtonOutlet: UIButton!
    @IBOutlet weak var turnOffOutlet: UIButton!
    
    @IBOutlet weak var hrTextField: UITextField!
    @IBOutlet weak var minTextField: UITextField!
    
    
    @IBOutlet weak var timeOfDaySeg: UISegmentedControl!
    
    
    
    

    
    
    @IBAction func stopNotifications(_ sender: Any)
    {
       UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        bedTimeSetLbl.text = "You don't have your bedtime set."
        hrTextField.text = ""
        minTextField.text = ""

        
    }
    
    
    
    
    @IBAction func remindMeButton(_ sender: Any)
    {
        
        
        if hrTextField.text == "" || minTextField.text == ""
        {
            hrTextField.text = "9"
            minTextField.text = "00"
            timeOfDaySeg.selectedSegmentIndex = 1
            
        }
            
        else
        {
            
          
            if timeOfDaySeg.selectedSegmentIndex == 0
            {
                let stringhr: String = hrTextField.text!
                let inthr: Int = Int(stringhr)!
                
                let stringmin: String = minTextField.text!
                let intmin: Int = Int(stringmin)!
                
                
                var dateComponents = DateComponents()
                dateComponents.hour = inthr
                dateComponents.minute = intmin
                
                if inthr > 13 || intmin > 59
                {
                    let alert = UIAlertController(title: "This action cannot be preformed.", message: "Choose a time between 1-12 for the hour, and 1-59 for the minute, then select A.M. or P.M.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let content = UNMutableNotificationContent()
                    content.body =  "It's time to start heading to bed for a good nights sleep."
                    
                    
                    
                    let request = UNNotificationRequest(
                        identifier: "notfication", content: content, trigger: trigger
                    )
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                    bedTimeSetLbl.text = "Your BedTime is set for \(hrTextField.text!):\(minTextField.text!)AM"
                    
                }
                
                
            }
            else
            {
                let stringhr: String = hrTextField.text!
                let inthr: Int = Int(stringhr)!
                
                let stringmin: String = minTextField.text!
                let intmin: Int = Int(stringmin)!
                
                
                var dateComponents = DateComponents()
                dateComponents.hour = inthr + 12
                dateComponents.minute = intmin
                
                
                if inthr > 12 || intmin > 59
                {
                    let alert = UIAlertController(title: "This action cannot be preformed.", message: "Choose a time between 1-12 for the hour, and 1-59 for the minute, then select A.M. or P.M.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let content = UNMutableNotificationContent()
                    content.title = "It is BedTime"
                    content.body =  "It is time to go to bed to get a full, good nights sleep."
                    
                    
                    let request = UNNotificationRequest(
                        identifier: "notfication", content: content, trigger: trigger
                    )
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                    bedTimeSetLbl.text = "Your BedTime is set for \(hrTextField.text!):\(minTextField.text!)PM"
                }

                
            }
            

        }
    
        
        hrTextField.text = ""
        minTextField.text = ""
        timeOfDaySeg.selectedSegmentIndex = 0
       
        
    }
    
    
   
    
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let systemVersion = UIDevice.current.systemVersion
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        
        mailComposeVC.setToRecipients(["allswiftdeveloper@gmail.com"])
        mailComposeVC.setSubject("Reported Problem - SleepyTime")
        mailComposeVC.setMessageBody("System Information\n\n iOS \(systemVersion) \n Version 1.0.0 \n\n Hi Team!\n\n", isHTML: false)
        
        return mailComposeVC
    }
    
    func showSendMailErrorAlert()
    {
        let alert = UIAlertController(title: "Could not Send Mail", message: "Unable to send email. Please check your email configuration, and try again.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        switch result {
        case MFMailComposeResult.cancelled:
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed:
            self.showSendMailErrorAlert()
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent:
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    @IBOutlet weak var reportButton: UIButton!
    
    @IBAction func reportProblem(_ sender: Any)
    {
        
        let infoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        infoAlert.addAction(UIAlertAction(title: "Report a Problem", style: .destructive, handler: self.mailHandler))
        infoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        infoAlert.popoverPresentationController?.sourceView = reportButton
    
        self.present(infoAlert, animated: true, completion: nil)
       

        
        
    }
    
    
    
    func mailHandler(alert: UIAlertAction!)
    {
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true)
        }
        else
        {
            self.showSendMailErrorAlert()
        }
    }
    
    
    
    
    


}
