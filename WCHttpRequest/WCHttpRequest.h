//
//  WCHttpRequest.h
//  WCHttpRequest
//
//  Created by Will on 4/3/2015.
//  Copyright (c) 2015年 Will. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SucceedBlock)(NSData *data);
typedef void(^ErrorBlock)(NSError *error);

typedef NS_ENUM(NSInteger, HttpRequestType)
{
    HttpRequestTypeGET,
    HttpRequestTypePOST,
};

@interface WCHttpRequest : NSObject<NSURLConnectionDataDelegate>
{
    NSMutableData *data_;
    SucceedBlock succeedBlock_;
    ErrorBlock errorBlock_;
    NSURLConnection *connection;
    NSMutableURLRequest *request;
    long long contentLength;
    long long currentLength;
}


-(void)requestWithType:(HttpRequestType)requsetType requestURL:(NSString *)requestURL paramDict:(NSDictionary *)theParamDict succeedBlock:(SucceedBlock)succeedBlock errorBlock:(ErrorBlock)errorBlock;

-(void)Start;

-(void)Stop;

@end