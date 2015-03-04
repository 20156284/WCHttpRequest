//
//  WCHttpRequest.m
//  WCHttpRequest
//
//  Created by Will on 4/3/2015.
//  Copyright (c) 2015年 Will. All rights reserved.
//

#import "WCHttpRequest.h"

@implementation WCHttpRequest

-(NSString*)createPostString:(NSDictionary *)dict
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc]init];
    
    NSArray *keys;
    id key, value;
    
    keys = [dict allKeys];
    for (int i = 0; i < [keys count]; i++)
    {
        key = [keys objectAtIndex: i];
        value = [dict objectForKey: key];
        if(i==[keys count]-1){
            [urlWithQuerystring appendFormat:@"%@=%@",key,value];
        }
        else
        {
            [urlWithQuerystring appendFormat:@"%@=%@&",key,value];
        }
    }
    
    return urlWithQuerystring;
}


-(void)requestWithType:(HttpRequestType )requsetType requestURL:(NSString *)requestURL paramDict:(NSDictionary *)theParamDict succeedBlock:(SucceedBlock)succeedBlock errorBlock:(ErrorBlock)errorBlock
{
    NSURL *url;
    connection = [[NSURLConnection alloc]init];
    
    currentLength = 0;
    contentLength = 0;
    
    if (requsetType == HttpRequestTypeGET) {
        NSString *strNewUrl = [NSString stringWithFormat:@"%@?%@",requestURL,[self createPostString:theParamDict]];
        url = [NSURL URLWithString:strNewUrl];
        
        request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        /* 设置缓存的大小为0.5M*/
        [urlCache setMemoryCapacity:0.5*1024*1024];
        
        //从请求中获取缓存输出
        NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
        //判断是否有缓存
        if (response != nil){
            NSLog(@"如果有缓存输出，从缓存中获取数据");
            //            [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            
            [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        }
        
        
        
        NSCachedURLResponse *cachedURLResponse = [urlCache cachedResponseForRequest:request];
        if (cachedURLResponse) {
            NSLog(@"---这个请求已经存在缓存");
        } else {
            NSLog(@"---这个请求没有缓存");
        }
        
        //        [request setValue:@"bytes=500-600" forHTTPHeaderField:@"Range"];
        //        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    else
    {
        url = [NSURL URLWithString:requestURL];
        
        request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"POST"];
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        /* 设置缓存的大小为10M*/
        [urlCache setMemoryCapacity:10*1024*1024];
        
        //从请求中获取缓存输出
        NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
        //判断是否有缓存
        if (response != nil){
            NSLog(@"如果有缓存输出，从缓存中获取数据");
            [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        }
        
        NSData *data = [[self createPostString:theParamDict] dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
    }
    
    connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    succeedBlock_ = [succeedBlock copy];
    errorBlock_ = [errorBlock copy];
}


#pragma mark- NSURLConnectionDataDelegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    data_ = [NSMutableData data];
    contentLength = [response expectedContentLength];
    NSLog(@"%lld", contentLength);
    
    //    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //    if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
    //        NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
    //        contentLength = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
    //        NSLog(@"%lld", contentLength);
    //        NSLog(@"%@", httpResponseHeaderFields);
    //    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //累加接收到的数据
    currentLength+=data.length;
    [data_ appendData:data];
    NSLog(@"接受数据");
    NSLog(@"数据长度为 = %lu", (unsigned long)[data length]);
    //    float tt = currentLength;
    //    float t2 = contentLength;
    //
    //    NSLog(@"下载了%f％",tt/t2 *100);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        NSString *result = [[NSString alloc] initWithData:data_  encoding:NSUTF8StringEncoding];
    //        NSLog(@"%@",result);
    //        completeBlock_(data_);
    //    });
    currentLength = 0;
    contentLength = 0;
    succeedBlock_(data_);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    errorBlock_(error);
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    NSLog(@"将缓存输出");
    return(cachedResponse);
}




-(void)Stop
{
    [connection cancel];
}

-(void)Start
{
}

@end
