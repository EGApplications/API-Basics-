//
//  EGSubscriptionsViewController.m
//  APIBasics #45
//
//  Created by Евгений Глухов on 25.12.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import "EGSubscriptionsViewController.h"
#import "EGServerManager.h"
#import "UIImageView+AFNetworking.h"

@interface EGSubscriptionsViewController ()

@property (strong, nonatomic) NSMutableArray* subInfoArray;

@end

@implementation EGSubscriptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.subInfoArray = [NSMutableArray array];
    
    // Грузим данные по API через синглтон. Дикшинари фоток и названий сообществ

    [self getUserSubscriptions:20];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API methods

- (void) getUserSubscriptions:(NSInteger) count {
    
    [[EGServerManager sharedManager] getUserSubscriptions:self.user.userId withSubsCount:count onSuccess:^(NSMutableArray *subscriptionsInfo) {
        
        self.subInfoArray = subscriptionsInfo;
        
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        NSLog(@"FAILED TO LOAD subscriptionsInfo");
        
    }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if ([self.subInfoArray count] != 0) {
        
        return 1;
        
    } else {
        
        return 0;
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.subInfoArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    NSDictionary* subInfo = [self.subInfoArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = (NSString*)[subInfo objectForKey:@"name"];
    
    NSString* urlString = (NSString*)[subInfo objectForKey:@"photo_100"];
    
    NSURL* imageURL = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:imageURL];
    
    cell.imageView.image = nil;
    
    __weak UITableViewCell* weakCell = cell;
    
    [cell.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 55.f;
    
}

@end
