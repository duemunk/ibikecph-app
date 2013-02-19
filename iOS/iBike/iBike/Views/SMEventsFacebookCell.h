//
//  SMEventsFacebookCell.h
//  iBike
//
//  Created by Ivan Pavlovic on 29/01/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

@interface SMEventsFacebookCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellBG;
@property (weak, nonatomic) IBOutlet AsyncImageView *eventImg;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

+ (CGFloat)getHeight;

@end
