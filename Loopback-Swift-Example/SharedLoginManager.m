//
//  SharedLoginManager.m
//  SSOTester
//
//  Created by Andres El Ropero on 4/12/16.
//  Copyright © 2016 Proto. All rights reserved.
//

#import "SharedLoginManager.h"

// 3rd Party
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

// Helpers
#import "UICKeychainStore.h"

static NSString * const kSharedKeychainKeyFacebookAccessToken = @"FacebookAccessToken";
static NSString * const kSharedKeychainServiceFacebook = @"Facebook";

@implementation SharedLoginManager

+ (SharedLoginManager *)sharedInstance
{
    static SharedLoginManager *__sharedInstance = nil;
    static dispatch_once_t __onceToken;
    dispatch_once(&__onceToken, ^{
        __sharedInstance = [[self alloc] init];
    });
    return __sharedInstance;
}

#pragma mark - Facebook Helpers
- (void)storeFacebookAccessToken:(FBSDKAccessToken *)token
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
    [UICKeyChainStore setData:data forKey:kSharedKeychainKeyFacebookAccessToken service:kSharedKeychainServiceFacebook];
    NSLog(@"archived and saved token with string: %@", token.tokenString);
}

- (void)clearFacebookAccessToken
{
    [UICKeyChainStore removeItemForKey:kSharedKeychainKeyFacebookAccessToken service:kSharedKeychainServiceFacebook];
}

- (FBSDKAccessToken *)loadFacebookAccessToken
{
    NSData *data = [UICKeyChainStore dataForKey:kSharedKeychainKeyFacebookAccessToken service:kSharedKeychainServiceFacebook];
    FBSDKAccessToken *token = (FBSDKAccessToken *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"unarchived token with string: %@", token.tokenString);
    return token;
}

@end
