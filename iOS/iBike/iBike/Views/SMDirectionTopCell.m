//
//  SMDirectionTopCell.m
//  iBike
//
//  Created by Petra Markovic on 2/6/13.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import "SMDirectionTopCell.h"

#import "SMUtil.h"

@implementation SMDirectionTopCell

- (void)renderViewFromInstruction:(SMTurnInstruction *)turn {
    [self.lblDescription setText:[turn descriptionString]];
    [self.lblWayname setText:turn.wayName];
    
    CGSize size = [self.lblDescription.text sizeWithFont:[UIFont systemFontOfSize:DIRECTION_FONT_SIZE] constrainedToSize:CGSizeMake(INSTRUCTIONS_LABEL_WIDTH, 40.0f) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = self.lblDescription.frame;
    frame.size.height = size.height;
    [self.lblDescription setFrame:frame];
//    debugLog(@"%@ %@", self.lblDescription.text, NSStringFromCGSize(size));

    size = [self.lblWayname.text sizeWithFont:[UIFont boldSystemFontOfSize:WAYPOINT_FONT_SIZE] constrainedToSize:CGSizeMake(INSTRUCTIONS_LABEL_WIDTH, 40.0f) lineBreakMode:NSLineBreakByWordWrapping];
    frame = self.lblWayname.frame;
    frame.size.height = size.height;
    frame.origin.y = self.lblDescription.frame.origin.y + self.lblDescription.frame.size.height + 2.0f;
    [self.lblWayname setFrame:frame];
//    debugLog(@"%@ %@", self.lblWayname.text, NSStringFromCGSize(size));

    [self.lblDistance setText:turn.fixedLengthWithUnit]; // fixed distance
//    [self.lblDistance setText:formatDistance(turn.lengthInMeters)]; // dynamic distance
    
    
    [self.imgDirection setImage:[turn largeDirectionIcon]];
}

+ (CGFloat)getHeight {
    return 60.0f;
}

+ (CGFloat)getHeightForDescription:(NSString*) desc andWayname:(NSString*) wayname {
    CGFloat height = 12.0f;
    CGSize size = [desc sizeWithFont:[UIFont systemFontOfSize:WAYPOINT_FONT_SIZE] constrainedToSize:CGSizeMake(INSTRUCTIONS_LABEL_WIDTH, 40.0f) lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height;
    size = [wayname sizeWithFont:[UIFont boldSystemFontOfSize:15.0f] constrainedToSize:CGSizeMake(INSTRUCTIONS_LABEL_WIDTH, 40.0f) lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + 2.0f + 12.0f;
    return MAX(75.0f, height);
}

@end
