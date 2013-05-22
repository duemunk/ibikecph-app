//
//  SMRequestOSRM.m
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 06/02/2013.
//  Copyright (c) 2013 City of Copenhagen. All rights reserved.
//

#import "SMRequestOSRM.h"
#import "NSString+URLEncode.h"
#import "SMGPSUtil.h"

@interface SMRequestOSRM()
@property (nonatomic, strong) NSURLConnection * conn;
@property (nonatomic, strong) NSString * currentRequest;

@property (nonatomic, strong) CLLocation * startLoc;
@property (nonatomic, strong) CLLocation * endLoc;
@property NSInteger locStep;

@property NSInteger currentZ;
@property (nonatomic, strong) NSDictionary * originalJSON;
@property (nonatomic, strong) NSString * originalChecksum;
@property (nonatomic, strong) NSString * originalStartHint;
@property (nonatomic, strong) NSString * originalDestinationHint;

@property (nonatomic, strong) NSArray * originalViaPoints;
@property CLLocationCoordinate2D originalStart;
@property CLLocationCoordinate2D originalEnd;
@end

@implementation SMRequestOSRM

#define DEFAULT_Z 18
#define MINIMUM_Z 10

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
    self.originalJSON = nil;
    self.originalStart = start;
    self.originalEnd = end;
    self.originalViaPoints = viaPoints;
    self.originalDestinationHint = hint;
    self.originalStartHint = nil;
    self.originalChecksum = chksum;
    [self getRouteFrom:start to:end via:viaPoints checksum:chksum andStartHint:nil destinationHint:hint andZ:DEFAULT_Z];
}

- (void)getRouteFrom:(CLLocationCoordinate2D)start to:(CLLocationCoordinate2D)end via:(NSArray *)viaPoints checksum:(NSString*)chksum andStartHint:(NSString*)startHint destinationHint:(NSString*)hint andZ:(NSInteger)z{
    self.currentZ = z;
    self.currentRequest = @"getRouteFrom:to:via:";
    
    NSMutableString * s1 =[NSMutableString stringWithFormat:@"%@/viaroute?z=%d&alt=false", OSRM_SERVER, z];
    
    if (startHint) {
        s1 = [NSString stringWithFormat:@"%@&loc=%.6f,%.6f&hint=%@", s1, start.latitude, start.longitude, startHint];
    } else {
        s1 = [NSString stringWithFormat:@"%@&loc=%.6f,%.6f", s1, start.latitude, start.longitude];
    }
    
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
    
    debugLog(@"%@", s);
    
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
        NSString * str = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        debugLog(@"%@", str);
        id r = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];//[[[SBJsonParser alloc] init] objectWithData:self.responseData];
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
            
            if (!r || ([r isKindOfClass:[NSDictionary class]] == NO) || ([[r objectForKey:@"status"] intValue] != 0)) {
                if (self.currentZ == DEFAULT_Z) {
                    if (self.originalJSON) {
                        if ([self.delegate conformsToProtocol:@protocol(SMRequestOSRMDelegate)]) {
                            [self.delegate request:self finishedWithResult:self.originalJSON];
                        }
                    } else {
                        [self getRouteFrom:self.originalStart to:self.originalEnd via:self.originalViaPoints checksum:self.originalChecksum andStartHint:self.originalStartHint destinationHint:self.originalDestinationHint andZ:MINIMUM_Z];
                    }
                } else {
                    if ([self.delegate conformsToProtocol:@protocol(SMRequestOSRMDelegate)]) {
                        [self.delegate request:self finishedWithResult:r];
                    }                    
                }
            } else {
                if (self.currentZ == DEFAULT_Z) {
                    if ([self.delegate conformsToProtocol:@protocol(SMRequestOSRMDelegate)]) {
                        [self.delegate request:self finishedWithResult:r];
                    }
                } else {
                    self.originalJSON = r;
                    self.originalChecksum = [NSString stringWithFormat:@"%@", [[r objectForKey:@"hint_data"] objectForKey:@"checksum"]];
                    self.originalStartHint = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", [[[r objectForKey:@"hint_data"] objectForKey:@"locations"] objectAtIndex:0]]];
                    self.originalDestinationHint = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", [[[r objectForKey:@"hint_data"] objectForKey:@"locations"] lastObject]]];
                    if ([r objectForKey:@"route_geometry"]) {
                        NSMutableArray * points = [SMGPSUtil decodePolyline:[r objectForKey:@"route_geometry"]];
                        CLLocationCoordinate2D start = ((CLLocation*)[points objectAtIndex:0]).coordinate;
                        CLLocationCoordinate2D end = ((CLLocation*)[points lastObject]).coordinate;
                        [self getRouteFrom:start to:end via:self.originalViaPoints checksum:[NSString stringWithFormat:@"%@", [[r objectForKey:@"hint_data"] objectForKey:@"checksum"]] andStartHint:self.originalStartHint destinationHint:self.originalDestinationHint andZ:DEFAULT_Z];
                    } else {
                        [self getRouteFrom:self.originalStart to:self.originalEnd via:self.originalViaPoints checksum:self.originalChecksum andStartHint:self.originalStartHint destinationHint:self.originalDestinationHint andZ:DEFAULT_Z];
                    }
                }
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
