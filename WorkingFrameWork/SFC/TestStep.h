//
//  TestStep.h
//  FCMTest
//
//  Created by GS on 15-5-7.
//  Copyright (c) 2015年 GS. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <Regex/Regex.h>
//#import "PDCA.h"
#import "BYDSFCManager.h"
#import "HiperTimer.h"
#import "BYDSFCManager.h"
#import "TimeDate.h"
#import "Lock.h"

@interface TestStep : NSObject
{
    //定义条码变量
    NSString* _strSN;
    
    NSString* _strBDASerail;
    //
    NSString* _strErrorMessage;
    //The symbol of test result
    BOOL isTestResultPass;
    //
    BOOL flagCreateADCBlob;
    
    TimeDate  * timeDate;
    //
    time_t tmStart, tmStop;
    
}

//声明sn
@property(readwrite,copy)NSString* strSN;
//

@property(readwrite,copy)TimeDate* timeDate;
//声明错误信息
@property(readwrite,copy)NSString* strErrorMessage;


//
+(TestStep*)Instance;

- (void)addGlobalLock;

//初始化测试信息
-(void)StepInitTest; 


//SFC检测上传sn
-(BOOL)StepSFC_CheckUploadSN:(BOOL)isUploadSFC Option:(NSString*)option testResult:(NSString*)testResult startTime:(NSString*)startTime testArgument:(NSArray*)array;

-(BOOL)StepSFC_isConnectServer:(BOOL)isUploadSFC;


//SFC检测上传结果
-(BOOL)StepSFC_CheckUploadResult:(BOOL)isUploadSFC  andIsTestPass:(BOOL)isTestPass andFailMessage:(NSString*)strMessage;




@end
