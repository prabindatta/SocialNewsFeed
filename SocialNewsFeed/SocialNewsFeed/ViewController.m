//
//  ViewController.m
//  SocialNewsFeed
//
//  Created by Prabin Kumar Datta on 21/11/14.
//  Copyright (c) 2014 Prabin Kumar Datta. All rights reserved.
//

#define URL(X)              [NSString stringWithFormat:@"http://emstagingeu.herokuapp.com/api/v1/feeds/feeds/?page=%ld",X]
#define AUTHORIZATION       "Token  09204e2bc87ece0990195bf55085780a411bed50"
#define FONT_SIZE           17.0f
#define CELL_CONTENT_WIDTH  230.0f
#define CELL_CONTENT_MARGIN_TOP 32.0f
#define CELL_CONTENT_MARGIN_BOT 12.0f


#import "ViewController.h"
#import "NewsFeedCell.h"

#import "AFNetworking/AFNetworking.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ViewController ()
{
    NSDictionary *items;
    NSInteger currentPage;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //NSLog(@"%@",URL(1));
    
    // Loader
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Load Data - WebService
    currentPage = 1;
    [self fetchInfofromWebService:currentPage];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebServices
- (void)fetchInfofromWebService:(NSInteger)pageId
{
//    NSMutableURLRequest *rasterRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
//    [rasterRequest setValue:@AUTHORIZATION forHTTPHeaderField:@"Authorization"];
//    
//    AFHTTPRequestOperation *imageOperation = [[AFHTTPRequestOperation alloc] initWithRequest:rasterRequest];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setValue:@AUTHORIZATION forHTTPHeaderField:@"Authorization"];
    [manager GET:URL((long)pageId) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        [self loadWebContents:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Load Contents

- (void)loadWebContents:(NSDictionary *)dicJsonResponse
{
    NSLog(@"%@",dicJsonResponse);
    items = dicJsonResponse;
    
    // Re-Load Table
    [self.mTableView reloadData];
    
    // Remove Progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[items objectForKey:@"results"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"text"];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
    
    UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    CGRect rect = [text boundingRectWithSize:constraint
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:@{NSFontAttributeName:font}
                                         context:nil];
    
    CGFloat height = roundf(rect.size.height + CELL_CONTENT_MARGIN_TOP + CELL_CONTENT_MARGIN_BOT);
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    
    NewsFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell)
    {
        cell = [[NewsFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *imageUrlStr = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"image"];
    NSString *username = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"user_name"];
    NSString *text = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"text"];
    
    if(imageUrlStr || ![imageUrlStr isEqualToString:@""])
        [cell.newsImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"loading.png"]];
    if(username)
        cell.newsUserName.text = username;
    if (text) {
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
        
        UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        CGRect rect = [text boundingRectWithSize:constraint
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
        
        CGFloat height = roundf(rect.size.height +(CELL_CONTENT_MARGIN_TOP + CELL_CONTENT_MARGIN_BOT));
        
//        CGRect frame = cell.newsText.frame;
//        frame.origin.y -= 10;
//        frame.size.height = height;
        [cell.newsText setFrame:CGRectMake(80, 20, CELL_CONTENT_WIDTH, height)];
        cell.newsText.text = text;
    }
    
    return cell;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSIndexPath *firstVisibleIndexPath = [[self.mTableView indexPathsForVisibleRows] objectAtIndex:0];
    NSInteger visibleRows = [[self.mTableView indexPathsForVisibleRows] count];
    NSIndexPath *lastVisibleIndexPath = [[self.mTableView indexPathsForVisibleRows] objectAtIndex:(visibleRows-1)];
    
    if(firstVisibleIndexPath.row == 0)
    {
        NSLog(@"Previous: %@",[items objectForKey:@"previous"]);
        NSString *previous = [items objectForKey:@"previous"];
        if (![previous isKindOfClass:[NSNull class]]) {
            // Loader
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            // Load Data - WebService
            [self fetchInfofromWebService:--currentPage];
        }
        
    }
    
    if(lastVisibleIndexPath.row == ([[items objectForKey:@"results"] count] -1))
    {
        NSLog(@"Previous: %@",[items objectForKey:@"next"]);
        NSString *next = [items objectForKey:@"next"];
        if (![next isKindOfClass:[NSNull class]]) {
            // Loader
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            // Load Data - WebService
            [self fetchInfofromWebService:++currentPage];
        }
    }
}

@end
