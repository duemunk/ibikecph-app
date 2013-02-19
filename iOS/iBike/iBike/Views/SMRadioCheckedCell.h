//
//  SMRadioCheckedCell.h
//  iBike
//
//  Created by Ivan Pavlovic on 07/02/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMRadioCheckedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *radioTitle;
@property (weak, nonatomic) IBOutlet UITextView *radioTextBox;

+ (CGFloat)getHeight;

@end
