//
//  EGWall.m
//  APIBasics #45
//
//  Created by Евгений Глухов on 02.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import "EGWall.h"

@implementation EGWall

- (instancetype)initWithDictionary:(NSDictionary*) dict;
{
    self = [super init];
    if (self) {
        
        if ([dict count] != 1) {
        
            self.commentsCount = [[[dict objectForKey:@"comments"] objectForKey:@"count"] stringValue];
            
            self.likesCount = [[[dict objectForKey:@"likes"] objectForKey:@"count"] stringValue];
            self.repostsCount = [[[dict objectForKey:@"reposts"] objectForKey:@"count"] stringValue];
            
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
            
            [dateFormater setDateFormat:@"dd MMM yyyy "];
            
            NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"date"] floatValue]];
            
            self.postDate = [dateFormater stringFromDate:dateTime];
            self.postText = (NSString*)[dict objectForKey:@"text"];
            self.attachmentType = (NSString*)[[dict objectForKey:@"attachment"] objectForKey:@"type"];
            
            // Далее обрабатываем только выборочные ключи, в зависимости от того, какой тип записи получаем.
            if ([self.attachmentType isEqualToString:@"video"]) {
                
                self.attachmentData = [[dict objectForKey:@"attachment"] objectForKey:@"video"];
                self.postTitle = [self.attachmentData objectForKey:@"title"];
                self.postImageURL = [NSURL URLWithString:[self.attachmentData objectForKey:@"image_big"]];
                
            } else if ([self.attachmentType isEqualToString:@"link"]) {
                
                self.attachmentData = [[dict objectForKey:@"attachment"] objectForKey:@"link"];
                self.postTitle = [self.attachmentData objectForKey:@"title"];
                self.postImageURL = [NSURL URLWithString:[self.attachmentData objectForKey:@"image_src"]];
                
                if (self.postImageURL == nil) {
                    
                    self.postText = (NSString*)[self.attachmentData objectForKey:@"url"];
                    
                }
                
                
            } else if ([self.attachmentType isEqualToString:@"photo"]) {
                
                self.attachmentData = [[dict objectForKey:@"attachment"] objectForKey:@"photo"];
                self.postTitle = [self.attachmentData objectForKey:@"text"];
                self.postImageURL = [NSURL URLWithString:[self.attachmentData objectForKey:@"src_big"]];
                
            } else if ([self.attachmentType isEqualToString:@"audio"]){
                // audio
                
                self.postImageURL = nil;
                self.attachmentData = [[dict objectForKey:@"attachment"] objectForKey:@"audio"];
                
                NSString* artist = [self.attachmentData objectForKey:@"artist"];
                NSString* title = [self.attachmentData objectForKey:@"title"];
                
                self.postTitle = [NSString stringWithFormat:@"%@ - %@", artist, title];
                
            } else if ([self.attachmentType isEqualToString:@"doc"]) {
                // doc
                
                self.attachmentData = [[dict objectForKey:@"attachment"] objectForKey:@"doc"];
                self.postTitle = [self.attachmentData objectForKey:@"title"];
                self.postImageURL = [NSURL URLWithString:[self.attachmentData objectForKey:@"thumb_s"]];
                
            } else {
                
                self.postImageURL = nil;
                // self.attachmentType = nil;
                
            }
            
        } else {
            
            self.wallError = [dict objectForKey:@"wallError"]; // присвоили строку error
            
        }
        
    }
    return self;
}

@end
