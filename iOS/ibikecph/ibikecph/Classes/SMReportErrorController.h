//
//  SMReportErrorController.h
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 05/02/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SMReportErrorController : SMTranslatedViewController <UIPickerViewDataSource, UIPickerViewDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate> {
    
    __weak IBOutlet UIButton *btnSelectRouteSegment;
    __weak IBOutlet SMCustomCheckbox *switchContactMe;
    __weak IBOutlet UIScrollView *scrlView;
    __weak IBOutlet UIView *fadeView;
    __weak IBOutlet UIPickerView *pckrView;
    __weak IBOutlet UITableView *tblView;
    __weak IBOutlet UIView *reportSentView;
    __weak IBOutlet UITextField *reportEmail;
    
    BOOL pickerOpen;
    NSInteger currentSelection;
    __weak IBOutlet UIView *bottomView;
}

@property (nonatomic, strong) NSArray * routeDirections;
@property (nonatomic, strong) NSString * source;
@property (nonatomic, strong) NSString * destination;

@end
