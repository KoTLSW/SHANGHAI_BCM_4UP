//
//  AgilentB2987A.h
//  Communication
//
//  Created by mac on 2017/9/11.
//  Copyright © 2017年 maceastwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "visa.h"
#import "HiperTimer.h"

enum AgilentB2987AMessureMode
{
    AgilentB2987A_RES,
    AgilentB2987A_CURR,
    AgilentB2987A_VOLT,
    AgilentB2987A_DEFAULT=AgilentB2987A_RES,
};

enum AgilentB2987ACommunicateType
{
    AgilentB2987A_LAN_Type,           //网口通信
    AgilentB2987A_USB_Type,           //USB通信
    AgilentB2987A_CommunicateType_DEFAULT=AgilentB2987A_USB_Type,
};

@interface AgilentB2987A : NSObject
{
    
    char instrDescriptor[VI_FIND_BUFLEN];
    
    //2015.1.19
    //    BOOL _isOpen;
    
    ViUInt32 numInstrs;
    ViFindList findList;
    ViSession defaultRM, instr;
    ViStatus status;
    ViUInt32 retCount;
    ViUInt32 writeCount;
    NSString * str;
    
}

@property (nonatomic,assign) BOOL isOpen;

@property(nonatomic,strong)NSString *agilentSerial;


//扫描和打开设备
-(BOOL) FindAndOpen:(NSString *)serial;

//关闭设备
-(void) CloseDevice;

//获取GPIB设备列表
-(NSMutableArray *)getArrayAboutGPIBDevice;
//设置测量模式
//-(void)SetMessureMode:(enum AgilentE4980AMessureMode)mode;

-(void)SetMessureMode:(enum AgilentB2987AMessureMode)mode andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType;

//往仪器中写入字符串
-(BOOL) WriteLine:(NSString*)writeString;

//读取数据=====readDataCount 字节数
-(NSString*) ReadData:(int)readDataCount;

-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType;

-(NSString*)ReadData:(int)readDataCount andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType;

+(NSArray *)getArratWithCommunicateType:(enum AgilentB2987ACommunicateType)communicateType;


-(BOOL) Find:(NSString *)serial andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType;

-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType;




@end
