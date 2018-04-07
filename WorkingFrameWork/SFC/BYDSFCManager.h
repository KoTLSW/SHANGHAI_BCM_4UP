//
//  BYDSFCManager.h
//  PDCA_Demo
//
//  Created by CW-IT-MB-046 on 14-12-25.
//  Copyright (c) 2014年 CW-IT-MB-046. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYDSFCUnit.h"
#import "Plist.h"



// 指定的检查类型
enum eSFC_Check_Type
{
    e_SEVER_CHECK,                   //服务器查询
    e_SN_CHECK,                      //SN检验
    e_LOG_CHECK,                     //上传数据结果
    e_COMPLETE_RESULT_CHECK,
    
};

//
enum eSFC_Back_Type
{
    SFC_Success,                //SFC返回成功
    SFC_Error,                  //网络返回错误
    SFC_Exist_Error,
    SFC_TimeOut_Error,          //超市等待
    SFC_ErrorNet,               //网络异常
    SFC_Default,
};

@interface BYDSFCManager : NSObject
{
    BYDSFCUnit* _unit;
    Plist     * plist;
    NSString* _errorMessage;
    BOOL _isCheckPass;
    enum eSFC_Back_Type  _SFCErrorType;
    enum eSFC_Check_Type _SFCCheckType;
    NSString* _strSN;
    NSString* _strUpdateBDA;

}


@property(readwrite)enum eSFC_Back_Type  SFCErrorType;
@property(readwrite)enum eSFC_Check_Type SFCCheckType;
@property(readwrite,copy)NSString   * strSN;
@property(nonatomic,strong)NSString * ServerFCKey;
@property(readonly, nonatomic) NSString* errorMessage;
@property(readwrite, copy) NSString * station_id;
@property(readwrite,copy)  NSString * config_pro;



+(BYDSFCManager*)Instance;



- (NSString *) createURL:(enum eSFC_Check_Type)sfcCheckType
                      sn:(NSString *)sn
              testResult:(NSString *)result
               startTime:(NSString *)tmStartStr
            testArgument:(NSArray  *)array
                 endTime:(NSString *)tmEndStr
               bdaSerial:(NSString*)strbdaSerial
           faiureMessage:(NSString *)failMsg;
/*!
 * @abstract    错误消息
 */


/*!eSFC_Check_Type
 * @abstract    在SFC系统中检测指定的Serial Number产品是否已经通过测试
 * @param   sn  产品序列号
 */
- (BOOL) Option:(NSString*)option checkSerialNumber:(NSString *)sn testResult:(NSString*)testResult startTime:(NSString*)startTime testArgument:(NSArray*)array;


/*!
 * @abstract    上传最终测试结果至SFC系统
 * @param   sn      产品序列号
 * @param   result  最终测试结果
 * @param   tmStart 开始测试时的时间
 * @param   tmEnd   结束测试时的时间
 * @param   failMsg 错误信息
 
 */
- (BOOL) checkComplete:(NSString *)sn
                result:(NSString *)result
             startTime:(time_t)tmStart
               endTime:(time_t)tmEnd
           failMessage:(NSString *)failMsg;




-(void)getUnitValue;


@end
