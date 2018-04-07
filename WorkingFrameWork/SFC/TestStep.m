
//  TestStep.m
//  FCMTest
//
//  Created by GS on 15-5-7.
//  Copyright (c) 2015年 GS. All rights reserved.
//

#import "TestStep.h"


@interface TestStep (){
    Lock                   *  _lock;
    
}
@end



static TestStep* test=nil;

@implementation TestStep
@synthesize strSN=_strSN;
@synthesize strErrorMessage=_strErrorMessage;
@synthesize timeDate=_timeDate;






-(id)init
{
    if (self=[super init])
    {
    
        _strSN=[[NSString alloc] init];
        _strErrorMessage=[[NSString alloc] init];
        _timeDate=[[TimeDate alloc]init];
    }
    return self;
}

//
+(TestStep*)Instance
{
    if (test==nil)
    {
        test=[[TestStep alloc] init];
    }
    return test;
}

-(void)dealloc
{
   
}



- (void)addGlobalLock
{
    _lock = [Lock shareInstance];
    
}



//初始化测试信息
-(void)StepInitTest
{
    isTestResultPass=YES;
    
    [[BYDSFCManager Instance] setSFCErrorType:SFC_Default];
}

-(BOOL)StepSFC_isConnectServer:(BOOL)isUploadSFC
{
    [_lock lock];
    
    BOOL flag=YES;
    
    if(isUploadSFC)
    {
        flag=NO;
    }
    
    [_lock unlock];
    
    return flag;
    
}

//SFC检测上传sn
-(BOOL)StepSFC_CheckUploadSN:(BOOL)isUploadSFC Option:(NSString*)option testResult:(NSString*)testResult startTime:(NSString*)startTime testArgument:(NSArray*)array
{
    [_lock lock];
    
    BOOL flag=YES;
    
    //检测是否需要上传SFC
    if(isUploadSFC)
    {
        flag=NO;
        
        if ([option isEqualToString:@"isPassOrNot"]) {
            [[BYDSFCManager Instance] setSFCCheckType:e_SN_CHECK];
            [[BYDSFCManager Instance] Option:option checkSerialNumber:_strSN testResult:nil startTime:startTime testArgument:nil];
        }
        else if ([option isEqualToString:@"isConnectServer"]){
            [[BYDSFCManager Instance] setSFCCheckType:e_SEVER_CHECK];
            [[BYDSFCManager Instance] Option:option checkSerialNumber:nil testResult:nil startTime:startTime testArgument:nil];
        }else{
            [[BYDSFCManager Instance] setSFCCheckType:e_LOG_CHECK];
            [[BYDSFCManager Instance] Option:option checkSerialNumber:_strSN testResult:testResult startTime:startTime testArgument:array];
        }
        
        switch ([[BYDSFCManager Instance] SFCErrorType])
        {
            case SFC_ErrorNet:_strErrorMessage=@"网络链接错误";
                break;
            case SFC_TimeOut_Error:_strErrorMessage=@"SFC超时错误";
                break;

            case SFC_Error:_strErrorMessage=@"网络返回异常";
                  break;
            case SFC_Success:
            {
                flag=YES;
            }
                break;
            case SFC_Default:
            default:_strErrorMessage=@"其它错误";
                break;
        }
    
        time(&tmStart);
    }
    
    [_lock unlock];
    
    return flag;
}



//SFC检测上传结果
-(BOOL)StepSFC_CheckUploadResult:(BOOL)isUploadSFC  andIsTestPass:(BOOL)isTestPass andFailMessage:(NSString*)strMessage
{
     [_lock lock];
    
    BOOL flagUploadResult=YES;

    if(isUploadSFC)
    {
        time(&tmStop);
        
        if(isTestPass)
        {
            int count= 0;
            do
            {
                flagUploadResult=[[BYDSFCManager Instance] checkComplete:_strSN result:@"PASS"
                                        startTime:tmStart endTime:tmStop   failMessage:@""];
                [NSThread sleepForTimeInterval:0.5];
                count++;
            }
            while (count<3 && !flagUploadResult);

        }
        else
        {
            flagUploadResult=[[BYDSFCManager Instance] checkComplete:_strSN result:@"FAIL"
                            startTime:tmStart endTime:tmStop failMessage:strMessage];
        }
    }
    
    [_lock unlock];
    
    return flagUploadResult;
}




//延时
-(void)DelayTime:(int)time
{
    HiperTimer* timer=[[HiperTimer alloc] init];
    [timer Start];
    while ([timer durationMillisecond]<time);
   
}




//获取特定位置，并截取字符串
-(NSString *)getStringFromString:(NSString *)textString
{

    NSRange range=[textString rangeOfString:@"0000:"];

    
    NSString * str2=[textString substringWithRange:NSMakeRange(range.location+6, 8)];



    return str2;
}




//将16进制的字符串转化为byte数组
-(NSData*) hexToBytes:(NSString *)hexString {
    
    NSMutableData* data = [NSMutableData data];
    
    int idx;
    
    for (idx = 0; idx+2 <= hexString.length; idx+=2) {
        
        NSRange range = NSMakeRange(idx, 2);
        
        NSString* hexStr = [hexString substringWithRange:range];
        
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        
        unsigned int intValue;
        
        [scanner scanHexInt:&intValue];
        
        [data appendBytes:&intValue length:1];
        
    }
    
    return data;
    
}



@end
