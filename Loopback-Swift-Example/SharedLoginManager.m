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
#import "LoopbackAccessToken.h"
#import "UICKeychainStore.h"

static NSString * const kSharedKeychainKeyFacebookAccessToken = @"FacebookAccessToken";
static NSString * const kSharedKeychainServiceFacebook = @"Facebook";

static NSString * const kSharedKeychainKeyLoopbackAccessToken = @"LoopbackAccessToken";
static NSString * const kSharedKeychainServiceLoopback = @"Loopback"; // Subhub? Didn't want to commit yet


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

#pragma mark - Facebook
- (void)storeFacebookAccessToken:(FBSDKAccessToken *)token
{
    if (token) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
        [UICKeyChainStore setData:data forKey:kSharedKeychainKeyFacebookAccessToken service:kSharedKeychainServiceFacebook];
        NSLog(@"archived and saved %@ token with string: %@", kSharedKeychainServiceFacebook, token.tokenString);
    }
}

- (void)clearFacebookAccessToken
{
    [UICKeyChainStore removeItemForKey:kSharedKeychainKeyFacebookAccessToken service:kSharedKeychainServiceFacebook];
}

- (FBSDKAccessToken *)loadFacebookAccessToken
{
    NSData *data = [UICKeyChainStore dataForKey:kSharedKeychainKeyFacebookAccessToken service:kSharedKeychainServiceFacebook];
    if (data) {
        FBSDKAccessToken *token = (FBSDKAccessToken *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"unarchived %@ token with string: %@", kSharedKeychainServiceFacebook, token.tokenString);
        return token;
    }
    return nil;
}

#pragma mark - Loopback
- (void)storeLoopbackAccessToken:(LoopbackAccessToken *)token
{
    if (token) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
        [UICKeyChainStore setData:data forKey:kSharedKeychainKeyLoopbackAccessToken service:kSharedKeychainServiceLoopback];
        NSLog(@"archived and saved %@ token with string: %@", kSharedKeychainServiceLoopback, token.tokenString);
    }
}

- (void)clearLoopbackAccessToken
{
    [UICKeyChainStore removeItemForKey:kSharedKeychainKeyLoopbackAccessToken service:kSharedKeychainServiceLoopback];
}

- (LoopbackAccessToken *)loadLoopbackAccessToken
{
    NSData *data = [UICKeyChainStore dataForKey:kSharedKeychainKeyLoopbackAccessToken service:kSharedKeychainServiceLoopback];
    if (data) {
        LoopbackAccessToken *token = (LoopbackAccessToken *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"unarchived %@ token with string: %@", kSharedKeychainServiceLoopback, token.tokenString);
        return token;
    }
    return nil;
}

@end
