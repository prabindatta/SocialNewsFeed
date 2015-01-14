//
//  ViewController.m
//  SocialNewsFeed
//
//  Created by Prabin Kumar Datta on 21/11/14.
//  Copyright (c) 2014 Prabin Kumar Datta. All rights reserved.
//

#define URL(X)              [NSString stringWithFormat:@"http://staging.earthmiles.co.uk/api/v1/feeds/feeds/?page=%ld",X]
#define AUTHORIZATION       "Token  09204e2bc87ece0990195bf55085780a411bed50"
#define FONT_SIZE           12.0f
#define CELL_CONTENT_WIDTH  280.0f
#define CELL_CONTENT_MARGIN_TOP 48.0f
#define CELL_CONTENT_IMG_GAP 20.0f
#define CELL_CONTENT_IMG 220.0f
#define CELL_CONTENT_MARGIN_BOT 44.0f


#import "ViewController.h"
#import "NewsFeedCell.h"
//#import "NewsFeedImgCell.h

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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setValue:@AUTHORIZATION forHTTPHeaderField:@"Authorization"];
    [manager GET:URL((long)pageId) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        NSDictionary *jsonDict = (NSDictionary*)responseObject;
        [self loadWebContents:jsonDict];
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

-(CGFloat) calculateFeedImageContentHeight:(NSString *)imgUrlStr forImgWidth:(NSInteger)width forImgHeight:(NSInteger)height
{
    return 0;
    if (![imgUrlStr isEqualToString:@""]) {
        if(height)
        {
            if(width)
                return height*220/width;
            else
                return 220.0f;
        }
        else
            return 220.0f;
    }
    return 0.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"text"];
    NSString *newsImgUrlStr = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"image_content"];
    NSInteger newsImgWidth = [[[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"image_content_height"] integerValue];;
    NSInteger newsImgHeight = [[[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"image_content_width"] integerValue];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
    
    UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
    CGRect rect = [text boundingRectWithSize:constraint
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:@{NSFontAttributeName:font}
                                         context:nil];
    
    CGFloat heightImgContent = [self calculateFeedImageContentHeight:newsImgUrlStr forImgWidth:newsImgWidth forImgHeight:newsImgHeight];
    
    CGFloat height = roundf(rect.size.height + heightImgContent + CELL_CONTENT_MARGIN_TOP + CELL_CONTENT_IMG_GAP + CELL_CONTENT_MARGIN_BOT);
    
    if(newsImgUrlStr && ![newsImgUrlStr isEqualToString:@""])
        height+= CELL_CONTENT_IMG;
    
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
    
    NSString *profileImgUrlStr = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"image"];
    NSString *username = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"user_name"];
    NSString *newsTxt = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"text"];
    NSString *newsImgUrlStr = [[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"image_content"];
    
    if(profileImgUrlStr || ![profileImgUrlStr isEqualToString:@""])
        [cell.newsProileImageView sd_setImageWithURL:[NSURL URLWithString:profileImgUrlStr] placeholderImage:[UIImage imageNamed:@"loading.png"]];
    if(username)
        cell.newsUserName.text = username;
    if (newsTxt) {
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
        
        UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
        CGRect rect = [newsTxt boundingRectWithSize:constraint
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
        
        CGRect frame = cell.newsText.frame;
        frame.size.width = CELL_CONTENT_WIDTH;
        frame.size.height = rect.size.height;
        [cell.newsText setFrame:frame];
        cell.newsText.text = newsTxt;
    }
    
    NSInteger newsImgWidth = [[[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"image_content_height"] integerValue];;
    NSInteger newsImgHeight = [[[[items objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"image_content_width"] integerValue];
    CGFloat heightImgContent = [self calculateFeedImageContentHeight:newsImgUrlStr forImgWidth:newsImgWidth forImgHeight:newsImgHeight];
    
    CGRect frame = cell.newsText.frame;
    frame.size.height = heightImgContent;
    [cell.newsImageView setFrame:frame];

    if(newsImgUrlStr && ![newsImgUrlStr isEqualToString:@""])
    {
        [cell.newsImageView setHidden:NO];
        [cell.newsImageView sd_setImageWithURL:[NSURL URLWithString:newsImgUrlStr] placeholderImage:[UIImage imageNamed:@"loading.png"]];
    }
    else{
        [cell.newsImageView setHidden:YES];
        [cell.newsImageView setImage:nil];
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
