//
//  ViewController.m
//  APIBasics #45
//
//  Created by Евгений Глухов on 13.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import "EGFriendsViewController.h"
#import "EGServerManager.h"
#import "EGUser.h"
#import "UIImageView+AFNetworking.h"
#import "EGDetailViewController.h"

@interface EGFriendsViewController ()

@property (strong, nonatomic) NSMutableArray* friendsArray;
@property (strong, nonatomic) UIImageView* placeholderImageView;

@end

@implementation EGFriendsViewController

#pragma mark - constants

static const NSInteger countOfFriendsToDownload = 50;

#pragma mark - Main methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.friendsArray = [NSMutableArray array];
    
    UIImage* placeholderImage = [UIImage imageNamed:@"vkPlaceholder.png"];
    
    self.placeholderImageView = [[UIImageView alloc] initWithImage:placeholderImage];
    
    self.placeholderImageView.image = [self imageWithImage:placeholderImage convertToSize:CGSizeMake(55, 55)];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    UIView* bgView = [[UIView alloc] initWithFrame:self.view.frame];
    
    CGFloat r = 183;
    CGFloat g = 210;
    CGFloat b = 255;
    
    CGFloat red = (float)r/255;
    CGFloat green = (float)g/255;
    CGFloat blue = (float)b/255;
    
    bgView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    [self.tableView setOpaque:NO];
    
    [self.tableView setBackgroundView:bgView];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self getFriendsFromServer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    CGFloat r = 183;
    CGFloat g = 210;
    CGFloat b = 255;
    
    CGFloat red = (float)r/255;
    CGFloat green = (float)g/255;
    CGFloat blue = (float)b/255;
    
    UIColor* navColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault]; // Убирает картинку, которую ставим в профиле в navigationBar
    
    [self.navigationController.navigationBar setBarTintColor:navColor];
    
}

#pragma mark - Own methods

// Метод изменяет размер картинки на нужный
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark - API methods

- (void) getFriendsFromServer {
    
    // Вызов синглтона
    
    [[EGServerManager sharedManager] getFriendsFromServerWithOffset:[self.friendsArray count] count:countOfFriendsToDownload onSuccess:^(NSMutableArray *friends) {
        
        [self.friendsArray addObjectsFromArray:friends];
        
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
       
        NSLog(@"ERROR - %@, STATUS_CODE - %ld", [error localizedDescription], statusCode);
        
    }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.friendsArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* friendIdentifier = @"friendCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:friendIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:friendIdentifier];
        
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    EGUser* friend = [self.friendsArray objectAtIndex:indexPath.row];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend.name, friend.surname];
    
    if (friend.isOnline) {
        
        cell.detailTextLabel.text = @"online";
        cell.detailTextLabel.textColor = [UIColor greenColor];
        
    } else {
        
        cell.detailTextLabel.text = @"offline";
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
    }
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:friend.image100URL];
    
    cell.imageView.image = nil;
    
    __weak UITableViewCell* weakCell = cell;
    
    [cell.imageView setImageWithURLRequest:request placeholderImage:self.placeholderImageView.image success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        
        weakCell.imageView.image = image; // вывод картинки
        
        [weakCell layoutSubviews];
        
        // Делаем закругленную аватарку
        weakCell.imageView.layer.cornerRadius = weakCell.imageView.frame.size.height / 2;
        
        weakCell.imageView.layer.masksToBounds = YES;
        
        weakCell.imageView.layer.borderWidth = 0;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
       
        NSLog(@"FAILED TO LOAD THE IMAGE");
        
    }];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 55;
    
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showProfile"]) {
        
        EGDetailViewController* vc = (EGDetailViewController*)segue.destinationViewController;
        
        NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        
        EGUser* clickedFriend = [self.friendsArray objectAtIndex:indexPath.row];
        
        vc.user = clickedFriend;
        
    }
    
}

@end
