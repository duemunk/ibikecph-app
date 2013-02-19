//
//  SMAnnotation.h
//  iBike
//
//  Created by Ivan Pavlovic on 04/02/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import "./MapView/Map/RMAnnotation.h"
#import "SMCalloutView.h"

@class SMAnnotation;

@protocol SMAnnotationActionDelegate <NSObject>
- (void)annotationActivated:(SMAnnotation*)annotation;
@end

@interface SMAnnotation : RMAnnotation <SMCalloutDelegate>

@property (nonatomic, weak) id<SMAnnotationActionDelegate> delegate;

@property (nonatomic, strong) SMCalloutView * calloutView;
@property BOOL calloutShown;


@property (nonatomic, strong) NSArray * nearbyObjects;
@property (nonatomic, strong) NSString * subtitle;

@property (nonatomic, strong) CLLocation * routingCoordinate;

- (void)showCallout;
- (void)hideCallout;

@end
