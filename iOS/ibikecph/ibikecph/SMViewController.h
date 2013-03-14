//
//  SMViewController.h
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 22/01/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMContacts.h"
#import "SMContactsHeader.h"
#import "SMEnterRouteController.h"
#import "SMEvents.h"

#import "RMMapView.h"
#import "SMAnnotation.h"
#import "SMNearbyPlaces.h"
#import "SMRequestOSRM.h"

#import "SMGPSTrackButton.h"

typedef enum {
    screenMenu,
    screenMap,
    screenContacts
} CurrentScreenType;

@interface SMViewController : SMTranslatedViewController <RMMapViewDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, SMContactsDelegate, SMContactsHeaderDelegate, EnterRouteDelegate, SMEventsDelegate, UIGestureRecognizerDelegate, SMAnnotationActionDelegate, SMNearbyPlacesDelegate, SMRequestOSRMDelegate>  {
    __weak IBOutlet UIScrollView *scrlView;
    IBOutlet UIView *menuView;
    IBOutlet UIView *addressView;
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UIView *eventsView;
    
    CurrentScreenType currentScreen;
    
    __weak IBOutlet UITableView *tblEvents;
    __weak IBOutlet UITableView *tblContacts;
    __weak IBOutlet UITableView *tblMenu;
    __weak IBOutlet UIView *fadeView;
    __weak IBOutlet UILabel *debugLabel;

    __weak IBOutlet SMGPSTrackButton *buttonTrackUser;
}

/**
 * properties for table
 */
@property (nonatomic, strong) NSArray * contactsArr;
@property (nonatomic, strong) NSArray * eventsArr;


@end
