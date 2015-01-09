//
//  NewsFeedCell.h
//  SocialNewsFeed
//
//  Created by Prabin Kumar Datta on 25/11/14.
//  Copyright (c) 2014 Prabin Kumar Datta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImage/UIImageView+WebCache.h"

@interface NewsFeedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *newsProileImageView;
@property (weak, nonatomic) IBOutlet UILabel *newsUserName;
@property (weak, nonatomic) IBOutlet UILabel *newsText;
@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;

@end
