//
//  EGServerManager.m
//  APIBasics #45
//
//  Created by Евгений Глухов on 13.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import "EGServerManager.h"
#import "AFNetworking.h"
#import "EGUser.h"
#import "EGWall.h"

@interface EGServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

@end

@implementation EGServerManager

+ (EGServerManager*) sharedManager {
    
    static EGServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[EGServerManager alloc] init];
        
    });
    
    return manager;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        
    }
    return self;
}

- (void) getFriendsFromServerWithOffset:(NSInteger)offset count:(NSInteger)count onSuccess:(void (^)(NSMutableArray* ))success onFailure:(void (^)(NSError *, NSInteger))failure {
    
    // параметры, которые передаем с запросе
//    user_id 7853346
//    order hints (по рейтингу друзья)
//    count количество возвращаемых
//    offset начиная с какого берем
//    fields photo_50
//    name_case nom
    
// init - key - friendsFromServer;
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"7853346", @"user_id",
                            @"hints", @"order",
                            @(count), @"count",
                            @(offset), @"offset",
                            @"photo_100,online", @"fields",
                            @"nom", @"name_case", nil];
    
    [self.requestOperationManager GET:@"friends.get" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary* responseObject) {
        
        NSArray* friendsArray = [responseObject objectForKey:@"response"];
        
        NSMutableArray* objectsArray = [NSMutableArray array];
        
        for (NSDictionary* dict in friendsArray) {
            
            EGUser* friend = [[EGUser alloc] initWithResponse:dict];
            
            [objectsArray addObject:friend];
            
        }
        
        if (success) {
            
            success(objectsArray);
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        failure(error, operation.response.statusCode);
        
    }];
    
}

- (void) getUserInfoForProfileWithId:(NSString*) userID onSuccess:(void(^)(EGUser* user)) success onFailure:(void(^)(NSError*, NSInteger)) failure {
    
    // параметры, которые передаем с запросе
    //    user_ids userID
    //    fields photo_200,city,country,photo_50
    //    name_case nom
    
    // Добавить статус online или offline
    
    // init - key - userInfoForProfile
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:userID, @"user_ids",
                            @"photo_200,photo_50,city,country,online", @"fields",
                            @"nom", @"name_case", nil];
    
    [self.requestOperationManager GET:@"users.get" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary* responseObject) {
        
        NSArray* userInfo = [responseObject objectForKey:@"response"];
        
        for (NSDictionary* dict in userInfo) {
            
            EGUser* user = [[EGUser alloc] initWithResponse:dict];
            
            if (success) {
                
                success(user);
                
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
        
    }];
    
}

- (void) getCitiesById:(NSArray *)citiesID onSuccess:(void (^)(NSMutableArray *))success onFailure:(void (^)(NSError *, NSInteger))failure {
    
    // параметры, которые передаем с запросе
    //    city_ids список цифр через запятую для ответа.

    NSString* citiesIDString;
    NSMutableArray* returningCities = [NSMutableArray array];
    
    if ([citiesID count] == 1) {
        
        citiesIDString = (NSString*)[citiesID firstObject];
        
    } else if ([citiesID count] > 1) {
        
        // строка из чисел (пример - 3,54,25,1)
        citiesIDString = [citiesID componentsJoinedByString:@","];
        
        
    } else {
        
        citiesIDString = @"No city";
        
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:citiesIDString, @"city_ids", nil];
    
    [self.requestOperationManager GET:@"database.getCitiesById" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary* responseObject) {
        
        NSArray* objects = [responseObject objectForKey:@"response"];
        
        NSString* title;
        
        if ([objects count] == 0) {
            
            title = @"не указан";
            
        } else {
            
            title = [[objects firstObject] objectForKey:@"name"];
            
        }
        
        [returningCities addObject:title];
        
        if (success) {
            success(returningCities);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
       
        
    }];
    
    
}

- (void) getCountriesById:(NSArray *)countriesID onSuccess:(void (^)(NSMutableArray *))success onFailure:(void (^)(NSError *, NSInteger))failure {
    
    // параметры, которые передаем с запросе
    //    city_ids список цифр через запятую для ответа.
    
    NSString* countriesIDString;
    NSMutableArray* returningCountries = [NSMutableArray array];
    
    if ([countriesID count] == 1) {
        
        countriesIDString = (NSString*)[countriesID firstObject];
        
    } else if ([countriesID count] > 1) {
        
        // строка из чисел (пример - 3,54,25,1)
        countriesIDString = [countriesID componentsJoinedByString:@","];
        
        
    } else {
        
        countriesIDString = @"No country";
        
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:countriesIDString, @"country_ids", nil];
    
    [self.requestOperationManager GET:@"database.getCountriesById" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary* responseObject) {
        
        NSArray* objects = [responseObject objectForKey:@"response"];
        
        NSString* title;
        
        if ([objects count] == 0) {
            
            title = @"не указан";
            
        } else {
            
            title = [[objects firstObject] objectForKey:@"name"];
            
        }
        
        [returningCountries addObject:title];
        
        if (success) {
            success(returningCountries);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        
    }];
    
}

- (void) getUserSubscriptions:(NSString*) userID withSubsCount:(NSInteger) count onSuccess:(void(^)(NSMutableArray* subscriptionsInfo)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    // параметры, которые передаем с запросе
    //    user_id userID
    //    fields photo_100,name
    //    extended 1
    //    count 20
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:userID, @"user_id",
                            @"photo_100,name", @"fields",
                            @(1), @"extended",
                            @(0), @"offset",
                            @(count), @"count", nil];
    
    [self.requestOperationManager GET:@"users.getSubscriptions" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary* responseObject) {
        
        NSArray* userInfo = [responseObject objectForKey:@"response"];
        
        NSMutableArray* subsAndPhoto = [NSMutableArray array];
        
        for (NSDictionary* dict in userInfo) {
            
            NSString* name = [dict objectForKey:@"name"];
            id photo = [dict objectForKey:@"photo_100"];
            
            NSDictionary* resultDict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", photo, @"photo_100", nil];
            
            [subsAndPhoto addObject:resultDict];
            
        }
        
        if (success) {
            
            success(subsAndPhoto);
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        
    }];

    
}

- (void) getUserFollowers:(NSString*) userID withFolCount:(NSInteger) count onSuccess:(void(^)(NSMutableArray* followersInfo)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    // параметры, которые передаем с запросе
    //    user_id userID
    //    fields photo_100
    //    count 50
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:userID, @"user_id",
                            @"photo_100", @"fields",
                            @(0), @"offset",
                            @(count), @"count", nil];
    
    [self.requestOperationManager GET:@"users.getFollowers" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary* responseObject) {
        
        NSMutableArray* userInfo = [[responseObject objectForKey:@"response"] objectForKey:@"items"];
        
        NSMutableArray* follsAndPhoto = [NSMutableArray array];
        
        for (NSDictionary* dict in userInfo) {
            
            NSString* name = [dict objectForKey:@"first_name"];
            NSString* surname = [dict objectForKey:@"last_name"];
            id photo = [dict objectForKey:@"photo_100"];
            
            NSString* initials = [NSString stringWithFormat:@"%@ %@", name, surname];
            
            NSDictionary* resultDict = [NSDictionary dictionaryWithObjectsAndKeys:initials, @"initials", photo, @"photo_100", nil];
            
            [follsAndPhoto addObject:resultDict];
            
        }
        
        if (success) {
            
            success(follsAndPhoto);
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        
    }];
    
}

- (void) getUserWall:(NSString*) userID withWallOffset:(NSInteger) offset wallCount:(NSInteger) count onSuccess:(void(^)(NSMutableArray* wallArray)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    //    параметры, которые передаем с запросе
    //    owner_id userID
    //    offset @(offset)
    //    count @(count)
    //    filter owner
    //    extended 1
    //    fields name,photo_50
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:userID, @"owner_id",
                            @(offset), @"offset",
                            @(count), @"count",
                            @"owner", @"filter",
                            @(0), @"extended",
                            @"photo_50,name", @"fields", nil];
    
    [self.requestOperationManager GET:@"wall.get" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary* responseObject) {
        
        NSMutableArray* userInfo = [responseObject objectForKey:@"response"];
        
        NSMutableArray* wallArray = [NSMutableArray array];
        
        if ([userInfo count] <= 1) {
            
            NSDictionary* errorDict = [NSDictionary dictionaryWithObject:@"error" forKey:@"wallError"];
            
            EGWall* wall = [[EGWall alloc] initWithDictionary:errorDict];
            
            [wallArray addObject:wall];
            
        } else {
        
            for (NSDictionary* dict in userInfo) {
                
                if (![dict isEqual:[userInfo firstObject]]) {
                    
                    EGWall* postInfo = [[EGWall alloc] initWithDictionary:dict];
                    
                    [wallArray addObject:postInfo];
                        
                }
                
            }
            
        }
        
        if (success) {
            
            success(wallArray);
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        NSLog(@"FAILED TO GET USER WALL");
        
    }];
    
}

@end
