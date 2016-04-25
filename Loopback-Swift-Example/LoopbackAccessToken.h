//
//  LoopbackAccessToken.h
//  Loopback-Swift-Example
//
//  Created by Andres El Ropero on 4/25/16.
//  Copyright © 2016 kevingoedecke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopbackAccessToken : NSObject<NSCoding>

@property (copy, nonatomic) NSString *tokenString;
@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSDate *createDate;

- (instancetype)initWithUserID:(NSString *)userID tokenString:(NSString *)tokenString createDate:(NSDate *)createDate;

@end
