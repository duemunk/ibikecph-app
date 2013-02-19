//
//  SMEventsHeader.h
//  iBike
//
//  Created by Ivan Pavlovic on 29/01/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

@interface SMEventsHeader : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

+ (CGFloat)getHeight;

- (void)setupHeaderWithData:(NSDictionary*)data;

@end
