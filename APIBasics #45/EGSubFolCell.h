//
//  EGSubFolCell.h
//  APIBasics #45
//
//  Created by Евгений Глухов on 25.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EGSubFolCell : UITableViewCell

// Ячейка отображения двух лейблов под профилем (subscriptions & followers)

@property (weak, nonatomic) IBOutlet UILabel *subscriptionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;


@end
