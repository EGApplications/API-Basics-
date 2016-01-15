//
//  EGDetailViewController.m
//  APIBasics #45
//
//  Created by Евгений Глухов on 17.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import "EGDetailViewController.h"
#import "EGSubscriptionsViewController.h"
#import "EGFollowersViewController.h"
#import "EGServerManager.h"
#import "EGDetailCell.h"
#import "EGSubFolCell.h"
#import "EGWallCell.h"
#import "EGWall.h"
#import "UIImageView+AFNetworking.h"

@interface EGDetailViewController ()

@property (strong, nonatomic) NSMutableArray* userInfoArray;
@property (assign, nonatomic) BOOL dataLoaded;
@property (strong, nonatomic) NSMutableArray* wallArray;
@property (strong, nonatomic) UIActivityIndicatorView* indicator;
@property (strong, nonatomic) UIView* loadingView;

@end

// высота ячейки, отведенная под отступы
const static NSInteger wallPostsCount = 10;
const static NSInteger contsPostImageWidth = 300; // ширина картинки - постоянная (нужна для подсчета нового размера картинки с сохранением пропорций)

@implementation EGDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wallArray = [NSMutableArray array];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    
    view.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    CGRect frame = view.frame;
    
    indicator.color = [UIColor blueColor];
    
    indicator.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    
    [view addSubview:indicator];
    
    [self.view insertSubview:view atIndex:0];
    
    self.loadingView = view;
    self.indicator = indicator;
    
    [self.indicator startAnimating];
    
    [self getUserInfoForProfile]; // User info + user wall
    
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popToRootAction:)];
    
    leftSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.tableView addGestureRecognizer:leftSwipe];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Own methods

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

// Метод обрезает картинку, возвращает обрезанный размер
- (UIImage *)croppingImageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    
    return cropped;
}

// Метод делает размытый фон для Image
- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage andBlurredRadius:(CGFloat) radius {
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    return retVal;
}

// Убираем HTML теги
- (NSString*) removeHTMLTags:(NSString*) string {
    
    NSRange r;
    
    if (string != nil) {
    
        while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
            
            string = [string stringByReplacingCharactersInRange:r withString:@" "];
        }
        
    }
    
    return string;
    
}

// дизайн первой строки (строка профиля)
- (void) designNavigationBarWithCell:(UITableViewCell*) cell {
    
    EGDetailCell* weakCell = (EGDetailCell*)cell;
    
    UIImage* bgProfileImage = [self imageWithImage:weakCell.profileImage.image convertToSize:CGSizeMake(CGRectGetWidth(weakCell.frame), CGRectGetHeight(weakCell.frame) + 20 + self.navigationController.navigationBar.frame.size.height)];
    
    UIImageView* bgProfileImageView = [[UIImageView alloc] initWithImage:bgProfileImage];
    
    CGRect bgProfileRect = CGRectMake(CGRectGetMinX(weakCell.frame), CGRectGetMinY(weakCell.frame) + self.navigationController.navigationBar.frame.size.height + 20, CGRectGetWidth(weakCell.frame), CGRectGetHeight(weakCell.frame));
    
    UIImage* bgCroppedProfileImage = [self croppingImageByImageName:bgProfileImage toRect:bgProfileRect];
    
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    UIImageView* weakCellBackgroundView = [[UIImageView alloc] initWithImage:bgCroppedProfileImage];
    
    [weakCellBackgroundView setFrame:weakCell.frame];
    
    blurView.frame = weakCellBackgroundView.bounds;
    
    [weakCellBackgroundView addSubview:blurView];
    
    [weakCell setBackgroundView:weakCellBackgroundView];
    
    CGRect navBarRect = CGRectMake(CGRectGetMinX(bgProfileImageView.frame), CGRectGetMinY(bgProfileImageView.frame), CGRectGetWidth(weakCell.frame), CGRectGetHeight(self.navigationController.navigationBar.frame) + 20);
    
    UIImage* navBarImage = [self croppingImageByImageName:bgProfileImage toRect:navBarRect];
    
    UIImage* blurredNavBarImage = [self blurredImageWithImage:navBarImage andBlurredRadius:17.f];
    
    [self.navigationController.navigationBar setBackgroundImage:blurredNavBarImage forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
}

#pragma mark - Gestures (Actions)
// Можно вернуться к списку друзей при помощи свайпа
- (void) popToRootAction:(UISwipeGestureRecognizer*) gesture {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - API methods

- (void) getUserInfoForProfile {
    
    // Создаем и выполняем группу. Пока все данные из нее не загрузятся, мы ее выполняем, после в dispatch_group_notify перезагружаем таблицу (теперь все звгружено)
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    
    [[EGServerManager sharedManager] getUserInfoForProfileWithId:self.user.userId onSuccess:^(EGUser* user) {
        
        self.user = user;
        
        [[EGServerManager sharedManager] getCitiesById:@[self.user.city] onSuccess:^(NSMutableArray *cities) {
            
            if ([cities count] == 0) {
                
                self.user.city = @"";
                
            } else {
                
                self.user.city = (NSString*)[cities firstObject];
                
            }
            
            [[EGServerManager sharedManager] getCountriesById:@[self.user.country] onSuccess:^(NSMutableArray *countries) {
                
                if ([countries count] == 0) {
                    
                    self.user.country = @"";
                    
                } else {
                    
                    self.user.country = (NSString*)[countries firstObject];
                    
                }
                
                [[EGServerManager sharedManager] getUserWall:self.user.userId withWallOffset:[self.wallArray count] wallCount:wallPostsCount onSuccess:^(NSMutableArray *wallArray) {
                    
                    self.wallArray = wallArray; // Оформить заполнение wallCell
                    
                    NSInteger objects = 0;
                    
                    for (EGWall* wallPost in self.wallArray) {
                        
                            NSData* dataPostImage = [[NSData alloc] initWithContentsOfURL:wallPost.postImageURL];
                            
                            wallPost.postImage = [UIImage imageWithData:dataPostImage];
                            
                            if (self.user.image50URL != nil) {
                        
                                NSData* dataUserImage = [[NSData alloc] initWithContentsOfURL:self.user.image50URL];
                                wallPost.userImage = [UIImage imageWithData:dataUserImage];
                                
                                objects++;
                                
                            }
                        
                        // выйти из группы после прогрузки картинок к 10-ти постам или если стена заблокирована.
                        if (objects == wallPostsCount || [wallPost.wallError isEqualToString:@"error"]) {
                            
                            dispatch_group_leave(group);
                            
                        }
                        
                    }
                    
                } onFailure:^(NSError *error, NSInteger statusCode) {
                    
                    NSLog(@"FAILED TO LOAD USER WALL");
                    
                }];
                
            } onFailure:^(NSError *error, NSInteger statusCode) {
                
                
                
            }];
            
            
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
            
            
        }];
        
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        NSLog(@"FAILED MF");
        
    }];
    

    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Вызывается после того, как выполнятся все действия в группе (group) и она завершится строкой dispatch_group_leave(group);
        
        self.dataLoaded = YES;
        
        [self.indicator stopAnimating];
        
        [self.loadingView removeFromSuperview];
        
        [self.tableView reloadData];
        
    });
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.dataLoaded && [self.wallArray count] > 0) {
        
        return 2;
        
    } else if (self.dataLoaded) {
        
        return 1;
        
    } else {
        
        return 0;
        
    }
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString* title;
    
    if ([self.wallArray count] == 1 && section == 1) {
        
        title = @"Стена закрыта";
        
    }
    
    return title;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (section == 0 && self.dataLoaded) {
        
        return 2; // первая секция профиль + строка подписки/подписчики
        
    } else if (section == 1 && self.dataLoaded) {
        
        return [self.wallArray count]; // записи на стене.
        
    } else {
        
        return 0;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"detailCell";
    static NSString* identifierSubFol = @"subFolCell";
    static NSString* identifierWall = @"wallCell";
    static NSString* identifierError = @"errorCell";
    
    if (indexPath.section == 0) {
    
        if (indexPath.row == 0) {
        
            EGDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            cell.userName.text = self.user.name;
            cell.userSurname.text = self.user.surname;
            cell.userCountry.text = self.user.country;
            cell.userCity.text = self.user.city;
            
            if (self.user.isOnline == YES) {
                
                cell.userStatus.text = @"online";
                cell.userStatus.textColor = [UIColor greenColor];
                
            } else {
                
                cell.userStatus.text = @"offline";
                cell.userStatus.textColor = [UIColor grayColor];
                
            }
            
            __weak EGDetailCell* weakCell = cell;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:self.user.image200URL];
            
            [cell.profileImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                
                weakCell.profileImage.image = image; // вывод картинки
                
                [weakCell layoutSubviews];
                
                // Делаем закругленную аватарку
                weakCell.profileImage.layer.cornerRadius = weakCell.profileImage.frame.size.height / 2;
                
                weakCell.profileImage.layer.masksToBounds = YES;
                
                weakCell.profileImage.layer.borderWidth = 1;
                
                // Делаем фон для первой строки таблицы (размытая аватарка)
                [weakCell setBackgroundColor:[UIColor clearColor]];
                [weakCell.backgroundView setBackgroundColor:[UIColor clearColor]];
                
                [self designNavigationBarWithCell:weakCell];
                
                
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
                
            }];
            
            return cell;
            
        } else {
            
            EGSubFolCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierSubFol];
            
            cell.subscriptionsLabel.text = @"Subscriptions";
            cell.followersLabel.text = @"Followers";
            
            cell.subscriptionsLabel.userInteractionEnabled = YES;
            cell.followersLabel.userInteractionEnabled = YES;
            
            UITapGestureRecognizer* tapSubGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subscriptionsLabelAction:)];
            
            UITapGestureRecognizer* tapFolGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersLabelAction:)];
            
            [cell.subscriptionsLabel addGestureRecognizer:tapSubGesture];
            [cell.followersLabel addGestureRecognizer:tapFolGesture];
            
            return cell;
            
        }
        
    } else {
        
        EGWall* wallPost = [self.wallArray objectAtIndex:indexPath.row];
        
        if ([wallPost.wallError isEqualToString:@"error"]) {
            
            UITableViewCell* errorCell = [tableView dequeueReusableCellWithIdentifier:identifierError];
            
            if (!errorCell) {
                
                errorCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierError];
                
            }
            
            errorCell.textLabel.text = @"Доступ к записям ограничен";
            
            return errorCell;
            
        } else {
            
            EGWallCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierWall];
            
            cell.nameSurnameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.name, self.user.surname];
            cell.postDateLabel.text = wallPost.postDate;
            cell.postTextLabel.text = [self removeHTMLTags:wallPost.postText];
            cell.postTitleLabel.text = [self removeHTMLTags:wallPost.postTitle];
            cell.commentsCountLabel.text = wallPost.commentsCount;
            cell.repostsCountLabel.text = wallPost.repostsCount;
            cell.likesCountLabel.text = wallPost.likesCount;
            
            cell.avatarImage.image = wallPost.userImage;
            
            cell.avatarImage.layer.cornerRadius = cell.avatarImage.frame.size.height / 2;
            
            cell.avatarImage.layer.masksToBounds = YES;
            
            cell.avatarImage.layer.borderWidth = 0;
            
            if (wallPost.postImage != nil) {
                
                // Считаем scale
                CGFloat proportionalHeight = (float)(wallPost.postImage.size.height / wallPost.postImage.size.width) * contsPostImageWidth;
                
                cell.postImage.image = [self imageWithImage:wallPost.postImage convertToSize:CGSizeMake(contsPostImageWidth, proportionalHeight)];
                
            } else {
                
                cell.postImage.image = wallPost.postImage;
                
            }
            
            return cell;
            
        }
        
        
    }
    
    return nil;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
        
        return 406.f;
            
        } else {
            
            return 45.f;
            
        }
        
    } else {
        // indexPath.section = 1
    
        CGFloat rowHeight = 160.f;
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = rowHeight;
        
        return UITableViewAutomaticDimension; // Возвращается высота, в зависимости от содержимого ячейки (от наполнения)
        
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
    
}

#pragma mark - Gestures

- (void) subscriptionsLabelAction:(UITapGestureRecognizer*) gesture {
    
    [self performSegueWithIdentifier:@"showSubscriptions" sender:gesture];
    
}

- (void) followersLabelAction:(UITapGestureRecognizer*) gesture {
    
    [self performSegueWithIdentifier:@"showFollowers" sender:gesture];
    
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showSubscriptions"]) {
        
        EGSubscriptionsViewController* vc = segue.destinationViewController;
        vc.user = self.user;
        
        
    } else {
        // showFollowers
        
        EGFollowersViewController* vc = segue.destinationViewController;
        vc.user = self.user;
        
    }
    
}

@end
