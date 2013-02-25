//
//  SMGPSTrackButton.m
//  iBike
//
//  Created by Petra Markovic on 2/25/13.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import "SMGPSTrackButton.h"

static void *kGPSTrackButtonStateObservingContext = &kGPSTrackButtonStateObservingContext;

@implementation SMGPSTrackButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.gpsTrackState = SMGPSTrackButtonStateFollowingWithHeading;
    }
    return self;
}

- (void)awakeFromNib {
    [self setImage:[UIImage imageNamed:@"icon_locate_me_active"] forState:SMGPSTrackButtonStateFollowingWithHeading];
    [self setImage:[UIImage imageNamed:@"icon_locate_me_active"] forState:SMGPSTrackButtonStateFollowing];
    [self setImage:[UIImage imageNamed:@"icon_locate_me_active"] forState:SMGPSTrackButtonStateNotFollowing_fromfollow];
    [self setImage:[UIImage imageNamed:@"icon_locate_me_active"] forState:SMGPSTrackButtonStateNotFollowing_fromfollowwithheading];
    [self setImage:[UIImage imageNamed:@"icon_locate_me"] forState:(SMGPSTrackButtonStateFollowing | UIControlStateDisabled)];

    NSAssert(SMGPSTrackButtonStateFollowingWithHeading & UIControlStateApplication, @"Custom state not within UIControlStateApplication");
    NSAssert(SMGPSTrackButtonStateFollowing & UIControlStateApplication, @"Custom state not within UIControlStateApplication");
    NSAssert(SMGPSTrackButtonStateNotFollowing_fromfollow & UIControlStateApplication, @"Custom state not within UIControlStateApplication");
    NSAssert(SMGPSTrackButtonStateNotFollowing_fromfollowwithheading & UIControlStateApplication, @"Custom state not within UIControlStateApplication");

    [self addObserver:self forKeyPath:@"gpsTrackState" options:NSKeyValueObservingOptionOld context:kGPSTrackButtonStateObservingContext];
}

- (UIControlState)state {
    NSInteger returnState = [super state];
    return (returnState | self.gpsTrackState);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    debugLog(@"gps track button state has changed: 0x%0x", self.gpsTrackState);
    if (context == kGPSTrackButtonStateObservingContext) {
        NSInteger oldState = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        if (oldState != self.gpsTrackState) {
            [self layoutSubviews];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
