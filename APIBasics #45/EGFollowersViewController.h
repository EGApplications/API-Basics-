//
//  EGFollowersViewController.h
//  APIBasics #45
//
//  Created by Евгений Глухов on 25.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGUser.h"

@interface EGFollowersViewController : UITableViewController

// Контроллер, отображающий подписчиков

@property (strong, nonatomic) EGUser* user;

@end
