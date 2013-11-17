//
//  JFDownloadManager.h
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 28.2.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIImage.h>
#import "NSString+JF.h"
#import "NSMutableURLRequest+JF.h"
#import "JFUtilNetwork.h"

#define kJFDownloadDomain @"JFDownload"

@protocol JFDownloadDelegate;

@class JFDownload;

typedef void (^JFDownloadFinishBlock)(JFDownload *download);

/**
 Download helper
 */
@interface JFDownload : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, readonly) NSData                *response;
/// @return NSURLResponse casted to NSHTTPURLResponse
@property (readonly, nonatomic) NSHTTPURLResponse     *httpResponse;
@property (readonly, nonatomic) NSError               *error;
@property (readonly, nonatomic) NSInteger             *downloadId;
@property (nonatomic, retain) id                      target;
@property (assign, nonatomic) SEL                     sel;
@property (assign, nonatomic) BOOL                    finished;
@property (assign, nonatomic) BOOL                    resultOnMainThread;
@property (strong, nonatomic) id                      carryObject;
@property (strong, nonatomic) NSOperationQueue        *queue;
@property (assign, nonatomic) id <JFDownloadDelegate> delegate;
@property (nonatomic, retain) NSOperationQueue        *delegateQueue;

@property (strong, nonatomic) NSDictionary *userInfo;

@property (assign, nonatomic) BOOL showProgressIndicator;

- (JFDownload *)downloadDataWithRequest:(NSURLRequest *)request;

+ (JFDownload *)performRequest:(NSURLRequest *)request withSuccessBlock:(JFDownloadFinishBlock)successBlock andFailedBlock:(JFDownloadFinishBlock)failedBlock;

- (void)reload;

- (id)initWithFinishBlock:(JFDownloadFinishBlock)finishBlock;

- (id)initWithURL:(NSString *)url andFinishBlock:(JFDownloadFinishBlock)finishBlock;

- (NSOperationQueue *)startAsync;

- (instancetype)startInQueue:(NSOperationQueue *)queue;

- (instancetype)addOperationDependency:(NSOperation *)op;

- (UIImage *)image;

- (NSDictionary *)jsonResponse;

- (NSURLRequest *)request;

- (instancetype)setResultOnMainThread;

- (instancetype)setShouldShowProgressIndicator:(BOOL)show;

- (instancetype)setDownloadDelegate:(id <JFDownloadDelegate>)delegate;

/// NOTICE!!! - synchronous call
+ (void)ping:(NSString *)url withBlockCallback:(JFDownloadFinishBlock)block;

@end

@protocol JFDownloadDelegate <NSObject>

- (void)downloadStarted:(JFDownload *)download;

- (void)downloadEnded:(JFDownload *)download;

- (void)downloadFailed:(JFDownload *)download withError:(NSError *)error;

@end
