//
//  JFDownloadManager.m
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 28.2.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import "JFDownload.h"

typedef enum
{
    JFMediaTypeData,
    JFMediaTypeString,
    JFMediaTypeImage,
    JFMediaTypePList
} JFMediaType;

@interface JFDownload ()

@property (nonatomic, retain) NSURLConnection     *connection;
@property (nonatomic, retain) NSMutableData       *p_data;
@property (nonatomic, retain) NSURLResponse       *p_response;
@property (nonatomic, retain) NSError             *p_error;
@property (nonatomic, retain) NSMutableURLRequest *p_request;
@property (nonatomic, assign) JFMediaType         mediaType;
@property (nonatomic, assign) BOOL                finishBlockMode;
@property (copy, nonatomic) JFDownloadFinishBlock successBlock;
@property (copy, nonatomic) JFDownloadFinishBlock failedBlock;

@end

@implementation JFDownload

+ (JFDownload *)performRequest:(NSURLRequest *)request withSuccessBlock:(JFDownloadFinishBlock)successBlock andFailedBlock:(JFDownloadFinishBlock)failedBlock
{
    JFDownload *download = [JFDownload new];
    [download downloadDataWithRequest:request];
    download.successBlock = successBlock;
    download.failedBlock  = failedBlock;
    return download;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.p_data = [NSMutableData data];
    }
    return self;
}

- (id)initWithFinishBlock:(JFDownloadFinishBlock)finishBlock
{
    self = [self init];
    if (self) {
        self.successBlock    = finishBlock;
        self.finishBlockMode = YES;
    }
    return self;
}

- (id)initWithURL:(NSString *)url andFinishBlock:(JFDownloadFinishBlock)finishBlock
{
    self = [self init];
    if (self) {
        self.successBlock    = finishBlock;
        self.finishBlockMode = YES;
        [self downloadDataWithRequest:[NSURLRequest requestWithURL:[url URL]]];
    }
    return self;
}

- (JFDownload *)downloadDataWithRequest:(NSURLRequest *)request
{
    _mediaType = JFMediaTypeData;
    self.p_request  = [request mutableCopy];
//    [self.p_request setValue:self.appDelegate.idForVendor forHTTPHeaderField:@"deviceId"];
//    [self.p_request setValue:self.appDelegate.idForVendor forHTTPHeaderField:@"deviceToken"];
//    NSDictionary  *headers = request.allHTTPHeaderFields;
//    for (NSString *header in headers) {
//        [self.p_request setValue:[headers objectForKey:header] forHTTPHeaderField:header];
//    }
//    self.p_request.HTTPMethod = request.HTTPMethod;
//    self.p_request.HTTPBody   = request.HTTPBody;
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];

    return self;
}

- (JFDownload *)downloadImageFromURL:(NSURL *)url
{
    _mediaType = JFMediaTypeImage;
    self.p_request = [NSMutableURLRequest requestWithURL:url];
#warning delegate
//    if (self.appDelegate.authToken && self.appDelegate.authHeader) {
//        [self.p_request setValue:self.appDelegate.authToken forHTTPHeaderField:self.appDelegate.authHeader];
//    }
    self.connection = [[NSURLConnection alloc] initWithRequest:self.p_request delegate:self startImmediately:NO];
    return self;
}

- (void)reload
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.p_request];
    [self downloadDataWithRequest:self.p_request];
}

- (NSData *)response
{
    return _p_data;
}

- (void)main
{
#warning delegate
//    if (self.appDelegate.isOffline) {
//        [self finish];
//    }
    NSException *exception;
    @try {
        [self.connection start];
//        [[NSString stringWithFormat:@"Download started: %@", self.request] log];
        while (!_finished) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    @catch (NSException *exception) {
//        [[NSString stringWithFormat:@"Download %@ forcely ended with exception: %@", self.request, exception] log];
        NSError *error = [NSError errorWithDomain:kJFDownloadDomain code:-1 userInfo:@{@"exception" : exception}];
        [self downloadFailedWithError:error];
    }
    @finally {

    }

}

- (void)cancel
{
    @synchronized (self) {
        self.finished = YES;
        [[self connection] cancel];
        [self setConnection:nil];
        [super cancel];
        [JFUtilNetwork hideNetworkIndicator];
    }
}

- (JFDownload *)downloadImageFromURLString:(NSString *)urlString
{
    [self downloadImageFromURL:[NSURL URLWithString:[urlString escaped]]];
    return self;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response == nil)
        [self downloadStarted];
    _p_data.length = 0;
    return request;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        return YES;
    }
    else if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        return YES;
    }
    return NO;

}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];

    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

/*
-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge.protectionSpace.host isEqualToString:SSL_TRUST_HOST]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
    }

    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.p_response = response;
    NSInteger statusCode = self.httpResponse.statusCode;
    if (statusCode == 500 || statusCode == 404 || statusCode == 405 || statusCode == 403) {
        NSString *descriptionKey = [NSString stringWithFormat:@"%@.errorCode.%ld", kJFDownloadDomain, statusCode];
        NSString *description;
        if ([description respondsToSelector:@selector(localized)]) {
            description = [descriptionKey localized];
        }
        else {
            description = NSLocalizedString(descriptionKey, @"");
        }
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[NSLocalizedDescriptionKey] = description;
        userInfo[@"statusCode"]             = @(statusCode);
        NSError *error = [NSError errorWithDomain:kJFDownloadDomain code:-2 userInfo:userInfo];
        [self downloadFailedWithError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_p_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self finish];
}

- (void)finish
{
    [self downloadEnded];
}

//-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//{
//    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"admin" password:@"pass" persistence:NSURLCredentialPersistenceForSession];
//    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
//}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.p_error  = error;
    self.finished = YES;

//    if (error.code == NSURLErrorNotConnectedToInternet) {
//        dispatch_sync(dispatch_get_main_queue(), ^{
#warning no internet connection message
//            [self showAlertWithTitle:nil message:@"Internet je nedostupan. Molimo provjerite vaše internet postavke i pokušajte ponovno." andCancelButtonTitle:@"U redu" andDelegate:nil];
//        });
//    }
    [self downloadFailedWithError:error];
}

- (NSError *)error
{
    return _p_error;
}

- (NSHTTPURLResponse *)httpResponse
{
    return (NSHTTPURLResponse *) _p_response;
}

- (UIImage *)image
{
    return [[UIImage alloc] initWithData:self.response scale:[[UIScreen mainScreen] scale]];
}

- (NSDictionary *)jsonResponse
{
    return [NSJSONSerialization JSONObjectWithData:self.response options:NSJSONReadingMutableContainers error:nil];
}

- (NSURLRequest *)request
{
    return _p_request;
}

- (NSOperationQueue *)startAsync
{
    self.queue = [NSOperationQueue new];
    [_queue addOperation:self];
//    [[NSString stringWithFormat:@"Download queued: %@", self.request] log];
    return self.queue;
}

- (instancetype)startInQueue:(NSOperationQueue *)queue
{
    [queue setSuspended:YES];
    [queue addOperation:self];
//    [[NSString stringWithFormat:@"Download queued: %@", self.request] log];
    [queue setSuspended:NO];
    return self;
}

- (instancetype)addOperationDependency:(NSOperation *)op
{
    [self addDependency:op];
    return self;
}

- (instancetype)setResultOnMainThread
{
    self.resultOnMainThread = YES;
    return self;
}

- (instancetype)setDownloadDelegate:(id <JFDownloadDelegate>)delegate
{
    self.delegate = delegate;
    return self;
}

- (instancetype)setShouldShowProgressIndicator:(BOOL)show
{
    self.showProgressIndicator = show;
    return self;
}

+ (void)ping:(NSString *)url withBlockCallback:(JFDownloadFinishBlock)block
{
    NSError             *error;
    NSURLResponse       *response;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url URL]];
    request.timeoutInterval = 1;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    JFDownload *download = [JFDownload new];
    download.p_error    = error;
    download.p_response = response;
    block (download);
}

#pragma mark - delegate helpers
- (void)downloadStarted
{
    [JFUtilNetwork showNetworkIndicator];
    self.finished = NO;
    if ([self.delegate respondsToSelector:@selector(downloadStarted:)]) {
        dispatch_async (dispatch_get_main_queue(), ^{
            [self.delegate downloadStarted:self];
        });
    }
}

- (void)downloadEnded
{
    [JFUtilNetwork hideNetworkIndicator];
    self.finished = YES;
    if (!self.resultOnMainThread) {
        self.successBlock (self);
    }
    else {
        dispatch_sync (dispatch_get_main_queue(), ^{
            self.successBlock (self);
        });
    }
    if ([self.delegate respondsToSelector:@selector(downloadEnded:)]) {
        dispatch_sync (dispatch_get_main_queue(), ^{
            [self.delegate downloadEnded:self];
        });
    }
}

- (void)downloadFailedWithError:(NSError *)error
{
    [JFUtilNetwork hideNetworkIndicator];
    self.finished = YES;
    self.p_error  = error;
    if (!self.resultOnMainThread) {
        self.failedBlock (self);
    }
    else {
        dispatch_sync (dispatch_get_main_queue(), ^{
            self.failedBlock (self);
        });
    }
    if ([self.delegate respondsToSelector:@selector(downloadFailed:withError:)]) {
        [self.delegate downloadFailed:self withError:error];
    }
}

@end
