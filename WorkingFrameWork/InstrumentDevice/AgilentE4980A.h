//
//  AgilentE4980A.h
//  Communication
//
//  Created by mac on 2017/9/8.
//  Copyright © 2017年 maceastwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "visa.h"
#import "HiperTimer.h"
enum AgilentE4980AMessureMode
{
    AgilentE4980A_RX,      //串联模式
    AgilentE4980A_CPD,     //利用并联等效电路测得的电容值
    AgilentE4980A_CPQ,     //利用并联等效电路测得的电容值
    AgilentE4980A_CSD,     //利用串联等效电路测得的电容值
    AgilentE4980A_CSQ,     //利用串联等效电路测得的电容值
                           //D为损耗因数，Q为品质因数
    AgilentE4980A_DEFAULT=AgilentE4980A_RX,
};

enum AgilentE4980ACommunicateType
{
    AgilentE4980A_LAN_Type,  //网口通信
    AgilentE4980A_GPIB_Type, //串口通信
    AgilentE4980A_USB_Type,  //USB通信
    AgilentE4980A_Communicate_DEFAULT = AgilentE4980A_USB_Type,
};

//enum AgilentCommunicateType
//{
//    MODE_LAN_Type,  //网口通信
//    MODE_GPIB_Type, //串口通信
//
//};

@interface AgilentE4980A : NSObject
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


//设置测试频率
-(void)setFrequency:(NSString *)freq;

//扫描和打开设备
-(BOOL) FindAndOpen:(NSString *)serial;

//关闭设备
-(void) CloseDevice;

//获取GPIB设备列表
-(NSMutableArray *)getArrayAboutGPIBDevice;
//设置测量模式
-(void)SetMessureMode:(enum AgilentE4980AMessureMode)mode;

-(void)SetMessureMode:(enum AgilentE4980AMessureMode)mode andCommunicateType:(enum AgilentE4980ACommunicateType)communicateType;

//往仪器中写入字符串
-(BOOL) WriteLine:(NSString*)writeString;

//读取数据=====readDataCount 字节数
-(NSString*) ReadData:(int)readDataCount;

-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum AgilentE4980ACommunicateType)communicateType;

-(NSString*)ReadData:(int)readDataCount andCommunicateType:(enum AgilentE4980ACommunicateType)communicateType;

+(NSArray *)getArratWithCommunicateType:(enum AgilentE4980ACommunicateType)communicateType;


-(BOOL) Find:(NSString *)serial andCommunicateType:(enum AgilentE4980ACommunicateType)communicateType;

-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum AgilentE4980ACommunicateType)communicateType;


@end
