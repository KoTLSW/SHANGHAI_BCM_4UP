//
//  BYDSFCManager.m
//  PDCA_Demo
//
//  Created by CW-IT-MB-046 on 14-12-25.
//  Copyright (c) 2014年 CW-IT-MB-046. All rights reserved.
//

#import "BYDSFCManager.h"

static BYDSFCManager* bydSFC=nil;

@implementation BYDSFCManager
@synthesize SFCErrorType=_SFCErrorType;
@synthesize errorMessage = _errorMessage;
@synthesize SFCCheckType=_SFCCheckType;
@synthesize ServerFCKey=_ServerFCKey;    //


- (id) init
{
    if (self = [super init])
    {
        _unit = [[BYDSFCUnit alloc] init];
        //读取param服务器的相关消息
        plist =[[Plist alloc]init];
        
        if (plist != nil)
        {
            _ServerFCKey=@"ServerFC";
            [self getUnitValue];
        }
    
        _errorMessage = @"";
        _strSN=[[NSString alloc] init];
        _strUpdateBDA=[[NSString alloc] init];
    }
    
    return self;
}


//Create static instance
+(BYDSFCManager*)Instance
{
    if(bydSFC==nil)
    {
        bydSFC=[[BYDSFCManager alloc] init];
    }
    
    return bydSFC;
}

//create an url
- (NSString *) createURL:(enum eSFC_Check_Type)sfcCheckType
                      sn:(NSString *)sn
              testResult:(NSString *)result
               startTime:(NSString *)tmStartStr
            testArgument:(NSArray  *)array
                 endTime:(NSString *)tmEndStr
               bdaSerial:(NSString *)strbdaSerial
           faiureMessage:(NSString *)failMsg
{

    //NSMutableString* urlString = [NSMutableString stringWithFormat:@"http://192.168.XX.XX:8090/handle.act?c="];
    
    NSMutableString* urlString = [NSMutableString stringWithFormat:@"http://%@:%@/handle.act?c=",_unit.MESServerIP, _unit.netPort];          // ip and port
    
    switch (sfcCheckType)
    {
        case e_SEVER_CHECK:
        {            
            [urlString appendFormat:@"%@", @"CHECK"];
        }
            break;
        case e_SN_CHECK:
        {
            [urlString appendFormat:@"INPUT&%@=%@&",SFC_TEST_STATION_NAME,_unit.stationName];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_STATION_ID, self.station_id];
            [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@",SFC_TEST_START_TIME,tmStartStr];

        }
            break;
        case e_LOG_CHECK:
        {
            [urlString appendFormat:@"LOG&%@=%@&",SFC_TEST_STATION_NAME,_unit.stationName];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_STATION_ID, self.station_id];
            
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_RESULT, result];
            [urlString appendFormat:@"%@=%@",SFC_TEST_START_TIME,tmStartStr];
     
            
            if ([self.config_pro length]>0) {
                
                [urlString appendFormat:@"&p1=%@",self.config_pro];
            }
            else
            {
                [urlString appendFormat:@"&p1=null"];
            }
            
            for(int i = 0; i < [array count]; i++)
            {
                [urlString appendFormat:@"&p%d=%@",i+2,array[i]];
            }
            
            [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
            
            break;
        default:
            break;
    }

    return urlString;
}


- (BOOL) submit:(NSString *)urlString
{
    BOOL flag = NO;
    _isCheckPass = NO;
// [[TestLog Instance] WriteLogResult:[GetTimeDay GetCurrentTime] andText:urlString];
    NSString* url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    if (!urlRequest)
    {
        _errorMessage = [_errorMessage stringByAppendingString:@"error: Cann't connect the server.\r\n"];
        flag = NO;
        return flag;
    }
    
    
    [urlRequest setTimeoutInterval:10];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [urlRequest setNetworkServiceType:NSURLNetworkServiceTypeBackground];
    [urlRequest setHTTPMethod:@"GET"];
    
    
    // 单独处理请求任务
    NSThread* thrdSumbit = [[NSThread alloc] initWithTarget:self
            selector:@selector(handleHttpRequest:)object:urlRequest];
   
    if ([NSURLConnection canHandleRequest:urlRequest])
    {
        [thrdSumbit start];
    }
    
    // set timeout, timeout = 5s
    float time = 0;
    while (time < 5)
    {
        if (_isCheckPass)
        {
            if (_SFCErrorType==SFC_Success)
            {
                flag=YES;
            }

            break;
        }
        
        [NSThread sleepForTimeInterval:0.01];
        time += 0.1;
    }
    
    if (time>=5 &&_SFCErrorType!=SFC_Success)
    {
        _SFCErrorType=SFC_TimeOut_Error;
    }
    return flag;
}

- (void) handleHttpRequest:(NSURLRequest *)urlRequest
{
    _isCheckPass = NO;
    [NSThread sleepForTimeInterval:0.3];
    NSData * byteRequest = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    NSString* backFromHttpStr = [[NSString alloc] initWithData:byteRequest encoding:NSUTF8StringEncoding];
    NSLog(@"HttpBackValue:%@",backFromHttpStr);
    
    NSMutableString* strLogFile=[[NSMutableString alloc] initWithFormat:@"HttpBackValue:%@\r\n",backFromHttpStr];
    NSLog(@"%@",strLogFile);

    if ([backFromHttpStr length]<1)
    {
        _SFCErrorType=SFC_ErrorNet;
    }
    else if([backFromHttpStr containsString:@"OK"])
    {
        _SFCErrorType= SFC_Success;
    
    }
    else
    {
        _SFCErrorType = SFC_Error;
    }
    
    
    _isCheckPass = YES;
    [NSThread exit];
}

- (NSString *) timeToStr:(time_t)time
{
    struct tm* tm = localtime(&time);
    return [NSString stringWithFormat:@"%d-%d-%d %d:%d:%d", (tm->tm_year + 1900), (tm->tm_mon + 1),
            tm->tm_mday, tm->tm_hour, tm->tm_min, tm->tm_sec];
}


- (BOOL) Option:(NSString*)option checkSerialNumber:(NSString *)sn testResult:(NSString*)testResult startTime:(NSString*)startTime testArgument:(NSArray *)array
{
    
    NSString* url;
    
    if ([option isEqualToString:@"isConnectServer"]) {
        url = [self createURL:e_SEVER_CHECK sn:nil testResult:nil
                    startTime:startTime testArgument:nil endTime:nil bdaSerial:nil faiureMessage:nil];
    }
    else if ([option isEqualToString:@"isPassOrNot"]){
        
        url = [self createURL:e_SN_CHECK sn:sn testResult:nil
                    startTime:startTime testArgument:nil endTime:nil bdaSerial:nil faiureMessage:nil];
    }
    else
    {
        url = [self createURL:e_LOG_CHECK sn:sn testResult:testResult
                    startTime:startTime testArgument:array endTime:nil bdaSerial:nil faiureMessage:nil];
    }
    
    NSLog(@"Check SerialNumber url:%@",url);
    return [self submit:url];
}

- (BOOL) checkComplete:(NSString *)sn
                result:(NSString *)result
             startTime:(time_t)tmStart
               endTime:(time_t)tmEnd
           failMessage:(NSString *)failMsg
{
    NSString* url = [self createURL:e_COMPLETE_RESULT_CHECK
                                 sn:sn testResult:result
                          startTime:[self timeToStr:tmStart]
                       testArgument:nil
                            endTime:[self timeToStr:tmEnd]
                            bdaSerial:nil
                      faiureMessage:failMsg];
    NSLog(@"CheckComplete url:%@",url);
    return [self submit:url];
}


-(void)getUnitValue{

    NSDictionary  * dic= [plist PlistRead:@"Param"];
    NSDictionary  * subDic = [dic objectForKey:_ServerFCKey];
    _unit.MESServerIP  = [subDic objectForKey:@"Server_IP"];
    _unit.netPort      = [subDic objectForKey:@"Net_Port"];
    _unit.stationName  = [subDic objectForKey:@"Station_Name"];
}


@end
