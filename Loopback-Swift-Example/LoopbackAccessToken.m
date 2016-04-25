//
//  LoopbackAccessToken.m
//  Loopback-Swift-Example
//
//  Created by Andres El Ropero on 4/25/16.
//  Copyright © 2016 kevingoedecke. All rights reserved.
//

#import "LoopbackAccessToken.h"

static NSString * const kLBAccessTokenKeyTokenString = @"LBAccessTokenKeyTokenString";
static NSString * const kLBAccessTokenKeyUserID = @"LBAccessTokenKeyUserID";
static NSString * const kLBAccessTokenKeyCreateDate = @"LBAccessTokenKeyCreateDate";

@implementation LoopbackAccessToken

- (instancetype)initWithUserID:(NSString *)userID tokenString:(NSString *)tokenString createDate:(NSDate *)createDate
{
    self = [super init];
    if (self) {
        _userID = userID;
        _tokenString = tokenString;
        _createDate = createDate;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *userID = (NSString *)[aDecoder decodeObjectForKey:kLBAccessTokenKeyUserID];
    NSString *tokenString = (NSString *)[aDecoder decodeObjectForKey:kLBAccessTokenKeyTokenString];
    NSDate *createDate = (NSDate *)[aDecoder decodeObjectForKey:kLBAccessTokenKeyCreateDate];
    
    if (userID && tokenString && createDate) {
        return [self initWithUserID:userID tokenString:tokenString createDate:createDate];
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_userID forKey:kLBAccessTokenKeyUserID];
    [aCoder encodeObject:_tokenString forKey:kLBAccessTokenKeyTokenString];
    [aCoder encodeObject:_createDate forKey:kLBAccessTokenKeyCreateDate];
}

@end
