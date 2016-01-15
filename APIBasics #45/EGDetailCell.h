//
//  EGDetailCell.h
//  APIBasics #45
//
//  Created by Евгений Глухов on 19.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EGDetailCell : UITableViewCell

// Ячейка профиля пользователя

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userSurname;
@property (weak, nonatomic) IBOutlet UILabel *userCountry;
@property (weak, nonatomic) IBOutlet UILabel *userCity;
@property (weak, nonatomic) IBOutlet UILabel *userStatus;

@end
