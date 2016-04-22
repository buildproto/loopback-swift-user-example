//
//  SharedLoginManager.h
//  SSOTester
//
//  Created by Andres El Ropero on 4/12/16.
//  Copyright © 2016 Proto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBSDKAccessToken;

@interface SharedLoginManager : NSObject

+ (SharedLoginManager *)sharedInstance;

- (void)storeFacebookAccessToken:(FBSDKAccessToken *)token;
- (void)clearFacebookAccessToken;
- (FBSDKAccessToken *)loadFacebookAccessToken;

@end
