//
//  SMRequestOSRM.m
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 06/02/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import "SMRequestOSRM.h"
#import "SBJson.h"
#import "NSString+URLEncode.h"

@interface SMRequestOSRM()
@property (nonatomic, strong) NSURLConnection * conn;
@property (nonatomic, strong) NSString * currentRequest;

@property (nonatomic, strong) CLLocation * startLoc;
@property (nonatomic, strong) CLLocation * endLoc;
@property NSInteger locStep;

@end

@implementation SMRequestOSRM

- (id)initWithDelegate:(id<SMRequestOSRMDelegate>)dlg {
    self = [super init];
    if (self) {
        [self setDelegate:dlg];
        self.locStep = 0;
    }
    return self;
}

- (void)findNearestPointForLocation:(CLLocation*)loc {
    self.currentRequest = @"findNearestPointForLocation:";
    self.coord = loc;
    NSString * s = [NSString stringWithFormat:@"%@/nearest?loc=%.6f,%.6f", OSRM_SERVER, loc.coordinate.latitude, loc.coordinate.longitude];
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    if (self.conn) {
        [self.conn cancel];
        self.conn = nil;
    }
    self.responseData = [NSMutableData data];
    NSURLConnection * c = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.conn = c;
    [self.conn start];
}

// via may be null
- (void)getRouteFrom:(CLLocationCoordinate2D)start to:(CLLocationCoordinate2D)end via:(NSArray *)viaPoints {
    [self getRouteFrom:start to:end via:viaPoints checksum:nil destinationHint:nil];    
}

- (void)getRouteFrom:(CLLocationCoordinate2D)start to:(CLLocationCoordinate2D)end via:(NSArray *)viaPoints checksum:(NSString*)chksum {
    [self getRouteFrom:start to:end via:viaPoints checksum:chksum destinationHint:nil];
}

- (void)getRouteFrom:(CLLocationCoordinate2D)start to:(CLLocationCoordinate2D)end via:(NSArray *)viaPoints checksum:(NSString*)chksum destinationHint:(NSString*)hint {
    self.currentRequest = @"getRouteFrom:to:via:";
    
    NSMutableString * s1 =[NSMutableString stringWithFormat:@"%@/viaroute?alt=false&loc=%.6f,%.6f", OSRM_SERVER, start.latitude, start.longitude];
    if (viaPoints) {
        for (CLLocation *point in viaPoints)
            [s1 appendFormat:@"&loc=%f.6,%.6f", point.coordinate.latitude, point.coordinate.longitude];
    }
    NSString *s = @"";
    
    if (chksum) {
        if (hint) {
            s = [NSString stringWithFormat:@"%@&loc=%.6f,%.6f&hint=%@&instructions=true&checksum=%@", s1, end.latitude, end.longitude, hint, chksum];
        } else {
            s = [NSString stringWithFormat:@"%@&loc=%.6f,%.6f&instructions=true&checksum=%@", s1, end.latitude, end.longitude, chksum];
        }
    } else {
        s = [NSString stringWithFormat:@"%@&loc=%.6f,%.6f&instructions=true", s1, end.latitude, end.longitude];
    }
    
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    if (self.conn) {
        [self.conn cancel];
        self.conn = nil;
    }
    self.responseData = [NSMutableData data];
    NSURLConnection * c = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.conn = c;
    [self.conn start];
}


- (void)findNearestPointForStart:(CLLocation*)start andEnd:(CLLocation*)end {
    self.currentRequest = @"findNearestPointForStart:andEnd:";
    NSString * s;
    if (self.locStep == 0) {
        self.startLoc = start;
        self.endLoc = end;
        s = [NSString stringWithFormat:@"%@/nearest?loc=%.6f,%.6f", OSRM_SERVER, start.coordinate.latitude, start.coordinate.longitude];
    } else {
        s = [NSString stringWithFormat:@"%@/nearest?loc=%.6f,%.6f", OSRM_SERVER, end.coordinate.latitude, end.coordinate.longitude];
    }
    self.locStep += 1;
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    if (self.conn) {
        [self.conn cancel];
        self.conn = nil;
    }
    self.responseData = [NSMutableData data];
    NSURLConnection * c = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.conn = c;
    [self.conn start];
}

#pragma mark - url connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self.responseData length] > 0) {
        id r = [[[SBJsonParser alloc] init] objectWithData:self.responseData];
        if ([self.currentRequest isEqualToString:@"findNearestPointForStart:andEnd:"]) {
            if (self.locStep > 1) {
                if ([r objectForKey:@"mapped_coordinate"] && [[r objectForKey:@"mapped_coordinate"] isKindOfClass:[NSArray class]] && ([[r objectForKey:@"mapped_coordinate"] count] > 1)) {
                    self.endLoc = [[CLLocation alloc] initWithLatitude:[[[r objectForKey:@"mapped_coordinate"] objectAtIndex:0] doubleValue] longitude:[[[r objectForKey:@"mapped_coordinate"] objectAtIndex:1] doubleValue]];
                }
                if ([self.delegate conformsToProtocol:@protocol(SMRequestOSRMDelegate)]) {
                    [self.delegate request:self finishedWithResult:@{@"start" : self.startLoc, @"end" : self.endLoc}];
                }
                self.locStep = 0;
            } else {
                if ([r objectForKey:@"mapped_coordinate"] && [[r objectForKey:@"mapped_coordinate"] isKindOfClass:[NSArray class]] && ([[r objectForKey:@"mapped_coordinate"] count] > 1)) {
                    self.startLoc = [[CLLocation alloc] initWithLatitude:[[[r objectForKey:@"mapped_coordinate"] objectAtIndex:0] doubleValue] longitude:[[[r objectForKey:@"mapped_coordinate"] objectAtIndex:1] doubleValue]];
                }
                [self findNearestPointForStart:self.startLoc andEnd:self.endLoc];
            }
        } else {
            if ([self.delegate conformsToProtocol:@protocol(SMRequestOSRMDelegate)]) {
                [self.delegate request:self finishedWithResult:r];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.delegate conformsToProtocol:@protocol(SMRequestOSRMDelegate)]) {
        [self.delegate request:self failedWithError:error];
    }
}

@end
