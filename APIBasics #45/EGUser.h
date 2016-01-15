//
//  EGUser.h
//  APIBasics #45
//
//  Created by Евгений Глухов on 16.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EGUser : NSObject

@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* surname;
@property (assign, nonatomic) BOOL isOnline;
@property (strong, nonatomic) NSURL* image50URL;
@property (strong, nonatomic) NSURL* image100URL;

@property (strong, nonatomic) NSURL* image200URL;

// country & city - NSMutableArray так как нам приходит id города/страны + название.

@property (strong, nonatomic) NSString* country;
@property (strong, nonatomic) NSString* city;


- (instancetype)initWithResponse:(NSDictionary*) responseObject;

// Класс создан для удобства обработки JSON из GET запроса

@end
