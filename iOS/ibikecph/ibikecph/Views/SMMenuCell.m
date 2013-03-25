//
//  SMMenuCell.m
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 15/03/2013.
//  Copyright (c) 2013 City of Copenhagen. All rights reserved.
//

#import "SMMenuCell.h"

@implementation SMMenuCell

+ (CGFloat)getHeight {
    return 45.0f;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        [cellBG setImage:[UIImage imageNamed:@"favListRow"]];
    } else {
        [cellBG setImage:[UIImage imageNamed:@"favListRow"]];
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [cellBG setImage:[UIImage imageNamed:@"favListRow"]];
    } else {
        [cellBG setImage:[UIImage imageNamed:@"favListRow"]];
    }
}

- (IBAction)editCell:(id)sender {
    if (self.delegate) {
        [self.delegate editFavorite:self];
    }
}



@end
