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
                self.displayUserInformation()
            }
            })
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    @IBAction func LogoutButton(sender: UIButton) {
        self.logoutCurrentUser()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountViewController.observeTokenChange(_:)), name: FBSDKAccessTokenDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loadSharedAccessToken()
        // ^ This is getting called twice after FB login. FYI
    }
    
    func lookupCurrentUser() {
        BackendUtilities.sharedInstance.clientRepo.findCurrentUserWithSuccess({ (client) -> Void in
            if let _ = client    {
                print("Found user \(client)")
                self.currentUser = client as! Client
                self.displayUserInformation()
            }
            else {
                print("User not defined in server response")
                // Clear the token, and try again (maybe the FB token will be valid)
                SharedLoginManager.sharedInstance().clearLoopbackAccessToken()
                self.loadSharedAccessToken()
            }
        }) { (error: NSError!) -> Void in
            print("Error fetching current user")
            // Clear the token, and try again (maybe the FB token will be valid)
            SharedLoginManager.sharedInstance().clearLoopbackAccessToken()
            self.loadSharedAccessToken()
        }
    }
    
    
    ////////////
    // 1) Check for loopback token, if it exists try to resurrect server session with it
    // 2) If no loopback token, lookup FB token, try to login with that
    // 3) else, no session
    func loadSharedAccessToken() {
        if let token = SharedLoginManager.sharedInstance().loadLoopbackAccessToken() {
            print("Found shared loopback token: \(token)")
            BackendUtilities.sharedInstance.adapter.accessToken = token.tokenString
            BackendUtilities.sharedInstance.clientRepo.currentUserId = token.userID
            
            // TODO: If not online, should expire the token client side at some point
            
            // Verify session by looking up our user
            self.lookupCurrentUser()
        }
        else if let token = SharedLoginManager.sharedInstance().loadFacebookAccessToken() {
            print("Found shared FB access token: \(token)")
            FBSDKAccessToken.setCurrentAccessToken(token)
            FBSDKAccessToken.refreshCurrentAccessToken({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) in
                print("refreshed FB token, result: \(result) error \(error)")
                //NB, from the docs: On a successful refresh, the currentAccessToken will be updated so you typically only need to observe the FBSDKAccessTokenDidChangeNotification notification.
            })
            // And now try to log in with that token
            self.onFacebookTokenReceived(token.tokenString)
        }
        else {
            print("No shared tokens found")
            FBSDKAccessToken.setCurrentAccessToken(nil)
        }
    }
    
    func displayUserInformation()  {
        if currentUser._id != nil {
            AccessTokenLabel.text = BackendUtilities.sharedInstance.adapter.accessToken
            UserIDLabel.text = currentUser._id.stringValue
            EmailLabel.text = currentUser.email
        }
        else {
            AccessTokenLabel.text = "N/A"
            UserIDLabel.text = "N/A"
            EmailLabel.text = "N/A"
        }
    }
    
    func logoutCurrentUser() {
        
        // Tell the server we're logging out
        BackendUtilities.sharedInstance.clientRepo.logoutWithSuccess({ () -> Void in
            // Reset local Client class object
            NSLog("Successfully logged out")

            // Clear the shared token (has to happen after we tell the server)
            SharedLoginManager.sharedInstance().clearLoopbackAccessToken()
            
            // Display logout confirmation
            let alertController = UIAlertController(title: "Logout", message:
                "Successfully logged out", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            self.currentUser = Client()
            self.displayUserInformation()
        }) { (error: NSError!) -> Void in
            NSLog("Error logging out")

            // Clear the shared token anyway
            SharedLoginManager.sharedInstance().clearLoopbackAccessToken()
        }

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
            SharedLoginManager.sharedInstance().storeFacebookAccessToken(result.token)
            self.onFacebookTokenReceived(result.token.tokenString)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        //self.logoutCurrentUser()
    }
    
    func observeTokenChange(notification: NSNotification) {
        
        guard let _ = FBSDKAccessToken.currentAccessToken()
            else {
                SharedLoginManager.sharedInstance().clearFacebookAccessToken()
                print("FB user access token changed, and is now nil")
                return
        }
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
    
    func onFacebookTokenReceived(tokenString: String) {
        // Link account to server
        let adapter = LBRESTAdapter(URL: NSURL(string: "http://localhost:3000"))
        // ^ The main adapter is initialized with /api
        adapter.accessToken = BackendUtilities.sharedInstance.adapter.accessToken
        var route: String?
        if let _ = adapter.accessToken {
            route = "/link/facebook-token/callback"
        }
        else {
            route = "/auth/facebook-token/callback"
        }
        print("accessToken: \(adapter.accessToken)")
        adapter.contract.addItem(SLRESTContractItem(pattern: route, verb: "GET"), forMethod: "mobile-facebook-link")
        let parameters: Dictionary = ["fb_access_token": tokenString]
        adapter.invokeStaticMethod("mobile-facebook-link", parameters: parameters, bodyParameters: nil, outputStream: nil, success: { (result) in
            print("success: got result: \(result)")
            if let jsonResult = result as? Dictionary<String, AnyObject> {
                if let accessToken = jsonResult["access_token"] as? String, userId = jsonResult["userId"] {
                    
                    // Should the createDate get reset here?
                    if let token = LoopbackAccessToken(userID: userId.stringValue, tokenString: BackendUtilities.sharedInstance.adapter.accessToken, createDate: NSDate()) {
                        // Store the token
                        SharedLoginManager.sharedInstance().storeLoopbackAccessToken(token)
                    }
                    
                    // Update LB adapter state
                    BackendUtilities.sharedInstance.adapter.accessToken = accessToken
                    BackendUtilities.sharedInstance.clientRepo.currentUserId = userId.stringValue
                    // Lookup the user
                    self.lookupCurrentUser()
                }
            }
            
        }, failure: { (error) in
                print("error: got error \(error)")
        })

    }
}

