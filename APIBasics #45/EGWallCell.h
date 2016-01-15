//
//  EGWallCell.h
//  APIBasics #45
//
//  Created by Евгений Глухов on 08.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EGWallCell : UITableViewCell

// Ячейка стены пользователя

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nameSurnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIImageView *commentsImage;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *repostsCountImage;
@property (weak, nonatomic) IBOutlet UILabel *repostsCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likesCountImage;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;


@end
