//
//  SMSearchHistory.m
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 10/05/2013.
//  Copyright (c) 2013 City of Copenhagen. All rights reserved.
//

#import "SMSearchHistory.h"
#import "SMAppDelegate.h"

@interface SMSearchHistory()
@property (nonatomic, strong) SMAPIRequest * apr;
@property (nonatomic, weak) SMAppDelegate * appDelegate;
@end

@implementation SMSearchHistory

+ (NSArray*)getSearchHistory {
    SMAppDelegate * appd = (SMAppDelegate*)[UIApplication sharedApplication].delegate;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: @"searchHistory.plist"]]) {
        NSMutableArray * arr = [NSArray arrayWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: @"searchHistory.plist"]];
        NSMutableArray * arr2 = [NSMutableArray array];
        if (arr) {
            for (NSDictionary * d in arr) {
                [arr2 addObject:@{
                 @"name" : [d objectForKey:@"name"],
                 @"address" : [d objectForKey:@"address"],
                 @"startDate" : [NSKeyedUnarchiver unarchiveObjectWithData:[d objectForKey:@"startDate"]],
                 @"endDate" : [NSKeyedUnarchiver unarchiveObjectWithData:[d objectForKey:@"endDate"]],
                 @"source" : [d objectForKey:@"source"],
                 @"subsource" : [d objectForKey:@"subsource"],
                 @"lat" : [d objectForKey:@"lat"],
                 @"long" : [d objectForKey:@"long"],
                 @"order" : @1
                 }];
            }
            [arr2 sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
                NSDate * d1 = [obj1 objectForKey:@"startDate"];
                NSDate * d2 = [obj2 objectForKey:@"startDate"];
                return [d2 compare:d1];
            }];
            
            [appd setSearchHistory:arr2];
            return arr2;
        }
    }
    
    [appd setSearchHistory:@[]];
    return @[];
}

+ (BOOL)saveToSearchHistory:(NSDictionary*)dict {
    SMAppDelegate * appd = (SMAppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableArray * arr = [NSMutableArray array];
    for (NSDictionary * srch in appd.searchHistory) {
        if ([[srch objectForKey:@"address"] isEqualToString:[dict objectForKey:@"address"]] == NO) {
            [arr addObject:srch];
        }
    }
    [arr addObject:dict];
    
    [arr sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        NSDate * d1 = [obj1 objectForKey:@"startDate"];
        NSDate * d2 = [obj2 objectForKey:@"startDate"];
        return [d2 compare:d1];
    }];
    
    NSMutableArray * r = [NSMutableArray array];
    for (NSDictionary * d in arr) {
        [r addObject:@{
         @"name" : [d objectForKey:@"name"],
         @"address" : [d objectForKey:@"address"],
         @"startDate" : [NSKeyedArchiver archivedDataWithRootObject:[d objectForKey:@"startDate"]],
         @"endDate" : [NSKeyedArchiver archivedDataWithRootObject:[d objectForKey:@"endDate"]],
         @"source" : [d objectForKey:@"source"],
         @"subsource" : [d objectForKey:@"subsource"],
         @"lat" : [d objectForKey:@"lat"],
         @"long" : [d objectForKey:@"long"]
         }];
    }
    [appd setSearchHistory:arr];
    BOOL x = [r writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: @"searchHistory.plist"] atomically:YES];
    return x;
}


+ (SMSearchHistory *)instance {
	static SMSearchHistory *instance;
	if (instance == nil) {
		instance = [[SMSearchHistory alloc] init];
        instance.appDelegate = (SMAppDelegate*)[UIApplication sharedApplication].delegate;
	}
	return instance;
}

- (SMSearchHistory *)initWithDelegate:(id<SMSearchHistoryDelegate>)delegate {
    self = [super init];
    if (self) {
        self.appDelegate = (SMAppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)fetchSearchHistoryFromServer {
    SMAPIRequest * ap = [[SMAPIRequest alloc] initWithDelegeate:self];
    [self setApr:ap];
    [self.apr setRequestIdentifier:@"fetchList"];
    [self.apr executeRequest:API_LIST_HISTORY withParams:@{@"auth_token": [self.appDelegate.appSettings objectForKey:@"auth_token"]}];
}

- (void)addSearchToServer:(NSDictionary*)srchData {
    SMAPIRequest * ap = [[SMAPIRequest alloc] initWithDelegeate:self];
    [self setApr:ap];
    [self.apr setRequestIdentifier:@"addHistory"];
    [self.apr executeRequest:API_ADD_FAVORITE withParams:@{
     @"auth_token":[self.appDelegate.appSettings objectForKey:@"auth_token"], @
     "route": @{
     @"from_name": @"",
     @"from_latitude": @0,
     @"from_longitude": @0,
     @"to_name": [srchData objectForKey:@"address"],
     @"to_lattitude": [NSString stringWithFormat:@"%f", [[srchData objectForKey:@"lat"] doubleValue]],
     @"to_longitude": [NSString stringWithFormat:@"%f", [[srchData objectForKey:@"long"] doubleValue]],
     @"start_date" : @"" }}
     ];    
}


#pragma mark - api delegate

-(void)request:(SMAPIRequest *)req failedWithError:(NSError *)error {
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:translateString(@"Error") message:[error description] delegate:nil cancelButtonTitle:translateString(@"OK") otherButtonTitles:nil];
    [av show];
}

- (void)request:(SMAPIRequest *)req completedWithResult:(NSDictionary *)result {
//    if ([result objectForKey:@"error"]) {
//    } else if ([[result objectForKey:@"success"] boolValue]) {
//        if ([req.requestIdentifier isEqualToString:@"fetchList"]) {
//            if (self.delegate && [self.delegate respondsToSelector:@selector(searchHistoryOperationFinishedSuccessfully:withData:)]) {
//                [self.delegate searchHistoryOperationFinishedSuccessfully:self withData:result];
//            }
//            
//        } else if ([req.requestIdentifier isEqualToString:@"addHistory"]) {
//            
//        }
//    } else {
//        UIAlertView * av = [[UIAlertView alloc] initWithTitle:translateString(@"Error") message:[result objectForKey:@"info"] delegate:nil cancelButtonTitle:translateString(@"OK") otherButtonTitles:nil];
//        [av show];
//    }
}


@end
