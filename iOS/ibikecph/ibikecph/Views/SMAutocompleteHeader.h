//
//  SMAutocompleteHeader.h
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 14/03/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMAutocompleteHeader : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
+ (CGFloat)getHeight;

@end
