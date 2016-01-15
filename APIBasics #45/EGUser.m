//
//  EGUser.m
//  APIBasics #45
//
//  Created by Евгений Глухов on 16.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import "EGUser.h"

@implementation EGUser

- (instancetype)initWithResponse:(NSDictionary*) responseObject ;
{
    self = [super init];
    
    if (self) {
        // Парсинг responseObject - ответа с сервера
        self.userId = [responseObject objectForKey:@"uid"];
        self.name = [responseObject objectForKey:@"first_name"];
        self.surname = [responseObject objectForKey:@"last_name"];
        self.isOnline = [[responseObject objectForKey:@"online"] boolValue];
        
        self.country = [responseObject objectForKey:@"country"];
        self.city = [responseObject objectForKey:@"city"];
        
        NSString* urlString_50 = [responseObject objectForKey:@"photo_50"];
        NSString* urlString_100 = [responseObject objectForKey:@"photo_100"];
        NSString* urlString_200 = [responseObject objectForKey:@"photo_200"];
        
        self.image50URL = [NSURL URLWithString:urlString_50];
        self.image100URL = [NSURL URLWithString:urlString_100];
        self.image200URL = [NSURL URLWithString:urlString_200];
        
        
    }
    
    return self;
    
}

@end
