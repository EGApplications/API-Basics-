//
//  EGWall.h
//  APIBasics #45
//
//  Created by Евгений Глухов on 02.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EGWall : NSObject

@property (strong, nonatomic) NSString* commentsCount;
@property (strong, nonatomic) NSString* likesCount;
@property (strong, nonatomic) NSString* repostsCount;
@property (strong, nonatomic) NSString* postDate;
@property (strong, nonatomic) NSString* postText;
@property (strong, nonatomic) NSString* attachmentType;

// далее свойства, которые зависят от attachmentType, которое может быть video, photo, link, doc

@property (strong, nonatomic) NSString* postTitle;

// video
@property (strong, nonatomic) NSDictionary* attachmentData;
@property (strong, nonatomic) NSURL* postImageURL;
// image key
// link - image_src key
// photo - src key

@property (strong, nonatomic) UIImage* userImage;
@property (strong, nonatomic) UIImage* postImage;

@property (strong, nonatomic) NSString* wallError; // Если стена не доступна!


- (instancetype)initWithDictionary:(NSDictionary*) dict;

@end
