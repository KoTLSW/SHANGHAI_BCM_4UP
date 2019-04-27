//
//  Param.h
//  BT_MIC_SPK
//
//  Created by h on 16/5/29.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Param : NSObject
//=============================================
@property(readwrite,copy)NSString*   csv_path;
@property(readwrite,copy)NSString*   dut_type;
@property(readwrite,copy)NSString*   ui_title;
@property(readwrite,copy)NSString*   tester_version;

@property(readwrite,copy)NSString*   station;
@property(readwrite,copy)NSString*   stationID;
@property(readwrite,copy)NSString*   fixtureID;
@property(readwrite,copy)NSString*   lineNo;

@property(readwrite,copy)NSString*  sw_name;
@property(readwrite,copy)NSString*  sw_ver;

//温湿度传感器相关
@property(readwrite,copy)NSString*  humiture_uart_port_name;
@property(readwrite,copy)NSString*  humiture_uart_port_name_two;
@property(readwrite)NSInteger       humiture_uart_baud;
//是否需要波形发生器
@property(nonatomic,assign)BOOL isDebug;
@property(nonatomic,strong)NSString * waveFrequence;//频率
@property(nonatomic,strong)NSString * waveVolt;//电压
@property(nonatomic,strong)NSString * waveOffset;//偏移
//sbuid
@property(nonatomic,strong)NSString * s_build;
//文件夹的路径
@property(nonatomic,strong)NSString * foldDir;




//10.28号
@property(nonatomic,strong)NSDictionary  * Fix1;
@property(nonatomic,strong)NSDictionary  * Fix2;
@property(nonatomic,strong)NSDictionary  * Fix3;
@property(nonatomic,strong)NSDictionary  * Fix4;


//18/03/05    板子控制器
@property(nonatomic,strong)NSString      * Freq;
@property(nonatomic,strong)NSString      * contollerBoard;
@property(nonatomic,strong)NSString      * contollerBoard_two;
@property(nonatomic,strong)NSString      * contollerBoard_uart_baud;

//18/03/26
@property(nonatomic,strong)NSString      * SingleFolder;

//18/09/19
@property(nonatomic,strong)NSString      * deviation;


//=============================================
- (void)ParamRead:(NSString*)filename;
- (void)ParamWrite:(NSString*)filename;
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key;
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key SubKey:(NSString *)subkey;
//- (void)TmConfigWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key;
//=============================================
@end
