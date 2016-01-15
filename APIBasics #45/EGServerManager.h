//
//  EGServerManager.h
//  APIBasics #45
//
//  Created by Евгений Глухов on 13.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGUser.h"

@interface EGServerManager : NSObject

// Синглтон, реализующий методы, запрашивающие информацию с сервера ВК

+ (EGServerManager*) sharedManager;

- (void) getFriendsFromServerWithOffset:(NSInteger) offset count:(NSInteger) count onSuccess:(void(^)(NSMutableArray* friends)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getUserInfoForProfileWithId:(NSString*) userID onSuccess:(void(^)(EGUser* user)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getCitiesById:(NSArray*) citiesID onSuccess:(void(^)(NSMutableArray* cities)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getCountriesById:(NSArray*) countriesID onSuccess:(void(^)(NSMutableArray* countries)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getUserSubscriptions:(NSString*) userID withSubsCount:(NSInteger) count onSuccess:(void(^)(NSMutableArray* subscriptionsInfo)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getUserFollowers:(NSString*) userID withFolCount:(NSInteger) count onSuccess:(void(^)(NSMutableArray* followersInfo)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getUserWall:(NSString*) userID withWallOffset:(NSInteger) offset wallCount:(NSInteger) count onSuccess:(void(^)(NSMutableArray* wallArray)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
