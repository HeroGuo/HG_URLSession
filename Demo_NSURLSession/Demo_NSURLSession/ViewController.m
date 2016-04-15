//
//  ViewController.m
//  Demo_NSURLSession
//
//  Created by gjh on 16/4/14.
//  Copyright © 2016年 gjh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataTask];
    [self downloadQuick];
    [self downloadWithDelegate];
}


/*!
 *  @author GJH, 16-04-14
 *
 *  Post  请求 登录的时候  更安全
 *
 *  @since 1.0.0
 */
-(void)dataTask
{
    NSURLSession *session = [NSURLSession sharedSession];
    //    设置请求方式
    NSURL       *url  = [NSURL URLWithString:@"http://120.25.226.186:32812/login2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //    设置请求的方式
    request.HTTPMethod = @"POST";
    
    //    设置请求体 请求头和请求体一般使用？ 隔开
    request.HTTPBody = [@"username=HiroGuo&pwd=HiroGuo&type=JSON" dataUsingEncoding:NSUTF8StringEncoding];
    //    任务创建
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //    解析数据 不确定使用id接受
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"dict-->%@",dict);
    }];
    //  任务默认是关闭状态 需要开启
    [task resume];
}



/*!
 *  @author GJH, 16-04-14
 *
 *  快速下载
 *  优点：可以直接下载数据，不用担心内存耗尽
 *  缺点：不方便监视进度信息
 *
 *  @since 1.0.0
 */
-(void)downloadQuick
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://www.up3d.com/face/model/Gnomes.STL"];
    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //   location: 临时文件路径（下载好的文件），纪录着下载的路径，以及文件名称等等
        //   session优点：不会失内存爆掉，系统会边下载边写进沙盒temp
        //   因为文件可能随时被清理掉所以建议将数据移动到caches中
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        NSString *savePath = [caches stringByAppendingPathComponent:response.suggestedFilename];
        //    移动位置
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager moveItemAtPath:location.path toPath:savePath error:nil])
        {
            NSLog(@"download Success !savePath:%@",savePath);
        }
    }];
    [downLoadTask resume];
}


/*!
 *  @author GJH, 16-04-14
 *
 *  下载时监听进度
 *  需要使用delegate
 *
 *  @since 1.0.0
 */
-(void)downloadWithDelegate
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //    创建下载路径
    NSURL *url = [NSURL URLWithString:@"https://www.up3d.com/face/model/Gnomes.STL"];
    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithURL:url];
    [downLoadTask resume];
}

#pragma -mark 3个代理方法
// 下载完成后调用
-(void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location
{
    // location : 临时文件的路径（下载好的文件）.记录着下载的文件的路径,及建议文件名称等
    //session的优点:不会使内存爆掉,系统会边下载边写到沙盒的temp中.
    //因为temp中的数据随时会被清除(可能刚写入就被删除),所以要将数据移动/拷贝到caches中.
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *savePath = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSLog(@"location.path:%@,savePath:%@",location.path,savePath);
    if ([manager moveItemAtPath:location.path toPath:savePath error:nil]) {
        NSLog(@"downLoad Success ! savePAth:%@",savePath);
    }
}

// 恢复下载时调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

/*!
 *  @author GJH, 16-04-14
 *
 *  每当下载完一个节点后调用  被调用多次
 *
 *  @param bytesWritten              本次调用写的数据量
 *  @param totalBytesWritten         累计已写到沙盒中的数据量
 *  @param totalBytesExpectedToWrite 应该下载文件的总长度
 *
 *  @since 1.0.0
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat didDownLoadRate = 1.0* totalBytesWritten /totalBytesExpectedToWrite;
    NSLog(@"downLoad progess = %f",didDownLoadRate);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
