//
//  EGDetailViewController.h
//  APIBasics #45
//
//  Created by Евгений Глухов on 17.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "EGUser.h"

@interface EGDetailViewController : UITableViewController

// Контроллер отображает профиль пользователя + последние 10 записей хозяина страницы

@property (strong, nonatomic) EGUser* user;



@end
