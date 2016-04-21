//
//  AccountViewController.swift
//  Loopback-Swift-Example
//
//  Created by Kevin Goedecke on 12/9/15.
//  Copyright © 2015 kevingoedecke. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, FBSDKLoginButtonDelegate {
    var currentUser: Client
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    required init(coder aDecoder: NSCoder) {
        currentUser = Client()
        super.init(coder: aDecoder)!
    }
    
    @IBOutlet weak var AccessTokenLabel: UILabel!
    @IBOutlet weak var UserIDLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    
    @IBAction func ChangeEmailButton(sender: UIButton) {
        let alertController = InputAlertController.getInputAlertController("Email?", message: "Please enter your email", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                self.currentUser.email = field.text
                self.currentUser.saveWithSuccess({ () -> Void in
                    NSLog("sucessfully saved")
                    }, failure: { (error: NSError!) -> Void in
                        NSLog("error saving")
                })
                self.loadUserInformation()
            }
            })
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    @IBAction func LogoutButton(sender: UIButton) {
        BackendUtilities.sharedInstance.clientRepo.logoutWithSuccess({ () -> Void in
            // Reset local Client class object
            NSLog("Successfully logged out")
            
            // Display logout confirmation
            let alertController = UIAlertController(title: "Logout", message:
                "Successfully logged out", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            self.currentUser = Client()
            self.loadUserInformation()
            }) { (error: NSError!) -> Void in
                NSLog("Error logging out")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        BackendUtilities.sharedInstance.clientRepo.findCurrentUserWithSuccess({ (client) -> Void in
            NSLog("Found user")
            if let _ = client    {
                self.currentUser = client as! Client
                self.loadUserInformation()
            }
            else    {
            }
            }) { (error: NSError!) -> Void in
                NSLog("Error fetching current user")
        }
        
    }
    
    func loadUserInformation()  {
        AccessTokenLabel.text = BackendUtilities.sharedInstance.adapter.accessToken
        UserIDLabel.text = currentUser._id as? String
        EmailLabel.text = currentUser.email
        
    }

    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            
            // Link account to server
            let adapter: LBRESTAdapter = LBRESTAdapter(URL: NSURL(string: "http://localhost:3000"))
            adapter.accessToken = BackendUtilities.sharedInstance.adapter.accessToken
            print("accessToken: \(adapter.accessToken)")
            adapter.contract.addItem(SLRESTContractItem(pattern: "/link/facebook-token/callback", verb: "GET"), forMethod: "mobile-facebook-link")
            let parameters: Dictionary = ["fb_access_token": result.token.tokenString]
            adapter.invokeStaticMethod("mobile-facebook-link", parameters: parameters, bodyParameters: nil, outputStream: nil, success: { (result) in
                    print("success: got result: \(result)")
                }, failure: { (error) in
                    print("error: got error \(error)")
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
}

