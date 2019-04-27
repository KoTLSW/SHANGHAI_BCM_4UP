//
//  Param.m
//  BT_MIC_SPK
//
//  Created by h on 16/5/29.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Param.h"

//=============================================
@implementation Param
//=============================================


- (void)ParamRead:(NSString*)filename
{
    //首先读取plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    self.station                = [dictionary objectForKey:@"station"];
    self.sw_name                = [dictionary objectForKey:@"sw_name"];
    self.sw_ver                 = [dictionary objectForKey:@"sw_ver"];
    
    
    //温湿度传感器
    self.humiture_uart_port_name=[dictionary objectForKey:@"humiture_uart_port_name"];
    self.humiture_uart_port_name_two = [dictionary objectForKey:@"humiture_uart_port_name_two"];
    self.humiture_uart_baud     =[[dictionary objectForKey:@"humiture__uart_baud"] integerValue];
    
    
    //是否需要波形发生器
    self.isDebug               =[[dictionary objectForKey:@"isDebug"] boolValue];
    self.waveFrequence         =[dictionary objectForKey:@"waveFrequence"];
    self.waveOffset            =[dictionary objectForKey:@"waveOffset"];
    self.waveVolt              =[dictionary objectForKey:@"waveVolt"];
    
    //s_build
    self.s_build               =[dictionary objectForKey:@"s_build"];
    
    //获取数据
    self.contollerBoard        =[dictionary objectForKey:@"contollerBoard"];
    self.contollerBoard_two    =[dictionary objectForKey:@"contollerBoard_two"];
    self.contollerBoard_uart_baud = [dictionary objectForKey:@"contollerBoard_uart_baud"];
    
    
    
    //治具字典
    self.Fix1                  =[dictionary objectForKey:@"Fix1"];
    self.Fix2                  =[dictionary objectForKey:@"Fix2"];
    self.Fix3                  =[dictionary objectForKey:@"Fix3"];
    self.Fix4                  =[dictionary objectForKey:@"Fix4"];
    
    //文件夹的路径
    self.foldDir               =[dictionary objectForKey:@"foldDir"];
    self.SingleFolder          =[dictionary objectForKey:@"SingleFolder"];
    
    //偏差
    self.deviation             =[dictionary objectForKey:@"deviation"];
    
    
}
//=============================================
- (void)ParamWrite:(NSString*)filename
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //添加内容
    [dictionary setObject:_csv_path forKey:@"csv_path"];

    
    [dictionary writeToFile:plistPath atomically:YES];
}
//=============================================更改plist文件中的内容
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //添加内容
    [dictionary setObject:content forKey:key];
    [dictionary writeToFile:plistPath atomically:YES];
    
}


//=============================================更改plist文件中的内容
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key SubKey:(NSString *)subkey
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSMutableDictionary *subDic = [dictionary objectForKey:key];
    
    [subDic setObject:content forKey:subkey];
    [dictionary setObject:subDic forKey:key];
    [dictionary writeToFile:plistPath atomically:YES];
}

@end
//=============================================





