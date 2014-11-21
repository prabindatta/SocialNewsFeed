//
//  ViewController.m
//  SocialNewsFeed
//
//  Created by Prabin Kumar Datta on 21/11/14.
//  Copyright (c) 2014 Prabin Kumar Datta. All rights reserved.
//

#define URL(X)              [NSString stringWithFormat:@"http://emstagingeu.herokuapp.com/api/v1/feeds/feeds/?page=%ld",X]
#define AUTHORIZATION       "Token  09204e2bc87ece0990195bf55085780a411bed50"


#import "ViewController.h"
#import "AFNetworking/AFNetworking.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //NSLog(@"%@",URL(1));
    
    // Load Data - WebService
    [self fetchInfofromWebService:1];
    
    // Load Table
    
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
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Load Contents


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    return cell;
}

@end
