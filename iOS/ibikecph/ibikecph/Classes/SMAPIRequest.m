//
//  SMAPIRequest.m
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 03/04/2013.
//  Copyright (c) 2013 City of Copenhagen. All rights reserved.
//

#import "SMAPIRequest.h"

@interface SMAPIRequest()
@property (nonatomic, strong) NSDictionary * serviceParams;
@property (nonatomic, strong) NSDictionary * serviceURL;

@property (nonatomic, strong) NSURLConnection * conn;
@property (nonatomic, strong) NSMutableData * responseData;
@property (nonatomic, weak) UIView * waitingView;
@end

@implementation SMAPIRequest

- (id)initWithDelegeate:(id<SMAPIRequestDelegate>)dlg {
    self = [super init];
    if (self) {
        [self setDelegate:dlg];
    }
    return self;
}


- (void)executeRequest:(NSDictionary*)request withParams:(NSDictionary*)params {
    [self setServiceParams:params];
    [self setServiceURL:request];

    if ([[request objectForKey:@"transferMethod"] isEqualToString:@"GET"] || [[request objectForKey:@"transferMethod"] isEqualToString:@"PUT"]) {
        [self executeGetRequestWithParams:params andURL:[NSString stringWithFormat:@"%@/%@", API_SERVER, [request objectForKey:@"service"]]];
    } else {
        [self executePostRequestWithParams:params andURL:request];
    }    
}

/**
 * Executes GET type request (GET/DELETE) with givern parameters and service URL
 */
- (void) executeGetRequestWithParams:(NSDictionary*) params andURL:(NSDictionary*) service {
    if (service) {
        NSString * urlString = [NSString stringWithFormat:@"%@/%@", API_SERVER, [service objectForKey:@"service"]];
        BOOL first = NO;
        NSRange range = [urlString rangeOfString:@"?"];
        if (range.location == NSNotFound) {
            first = YES;
        }
        
        
        NSMutableArray * d = [[NSMutableArray alloc] initWithCapacity:[[params allKeys] count]];
        for (NSString * key in [params allKeys]) {
            if ([[params objectForKey:key] isKindOfClass:[NSString class]]) {
                [d addObject:[NSString stringWithFormat:@"%@=%@", key, [[params objectForKey:key] urlEncode]]];
            } else {
                [d addObject:[NSString stringWithFormat:@"%@=%@", key, [[params objectForKey:key] stringValue]]];
            }
        }        
        NSString * urlP = [d componentsJoinedByString:@"&"];
        
        if (first) {
            urlString = [urlString stringByAppendingFormat:@"?%@", urlP];
        } else {
            urlString = [urlString stringByAppendingFormat:@"&%@", urlP];
        }
        
        debugLog(@"*** %@", urlString);
        
        NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [req setHTTPMethod:[service objectForKey:@"transferMethod"]];
        for (NSDictionary * d in [service objectForKey:@"headers"]) {
            [req setValue:[d objectForKey:@"values"] forHTTPHeaderField:[d objectForKey:@"key"]];
        }

        if (self.conn) {
            [self.conn cancel];
            self.conn = nil;
        }
        self.responseData = [NSMutableData data];
        NSURLConnection * c = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
        self.conn = c;
        [self.conn start];
        
    } else {
        return;
    }
}

/**
 * Executes POST type request (POST/PUT) with given parameters and service URL
 */
- (void) executePostRequestWithParams:(NSDictionary*) params andURL:(NSDictionary*) service {
    if (service) {
        NSData * d = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        
        NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_SERVER, [service objectForKey:@"service"]]]];
        [req setHTTPMethod:[service objectForKey:@"transferMethod"]];
        [req setHTTPBody:d];
        for (NSDictionary * d in [service objectForKey:@"headers"]) {
            [req setValue:[d objectForKey:@"value"] forHTTPHeaderField:[d objectForKey:@"key"]];
        }
        
        if (self.conn) {
            [self.conn cancel];
            self.conn = nil;
        }
        self.responseData = [NSMutableData data];
        NSURLConnection * c = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
                
        self.conn = c;
        [self.conn start];
        
    } else {
        return;
    }
}

- (void) showTransparentWaitingIndicatorInView:(UIView*) view {
    UIView * v = [[UIView alloc] initWithFrame:view.frame];
    CGRect frame = v.frame;
    frame.origin = CGPointZero;
    [v setFrame:frame];
    [v setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.7f]];
    
    UIActivityIndicatorView * av = [[UIActivityIndicatorView alloc] init];
    [av setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    frame.origin.x = floorf ((frame.size.width - av.frame.size.width) / 2.0f);
    frame.origin.y = floorf ((frame.size.height - av.frame.size.height) / 2.0f);
    frame.size = av.frame.size;
    [av setFrame: frame];
    [av setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [av startAnimating];
    
    [v addSubview:av];
    [v setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    if (self.waitingView) {
        [self.waitingView removeFromSuperview];
    }
    [self setWaitingView:v];
    [view addSubview:self.waitingView];
    
    [v setAlpha:0.0f];
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.waitingView setAlpha:1.0f];
    }];
    
}

#pragma mark - url connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.waitingView) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.waitingView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.waitingView removeFromSuperview];
        }];        
    }
    NSError *error = NULL;
    NSString * s = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSDictionary * d = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:failedWithError:)]) {
            [self.delegate request:self failedWithError:error];
        }
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:completedWithResult:)]) {
        [self.delegate request:self completedWithResult:d];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.waitingView) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.waitingView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.waitingView removeFromSuperview];
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:failedWithError:)]) {
        [self.delegate request:self failedWithError:error];
    }
    
}


@end
