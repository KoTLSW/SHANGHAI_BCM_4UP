//
//  Plist.m
//  MKPlist_Sample
//
//  Created by Michael on 16/11/7.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "Plist.h"

@implementation Plist


+(Plist *)shareInstance;
{
    static Plist * plist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        plist = [[Plist alloc] init];
    });

    return plist;
}



-(NSMutableArray *)PlistRead:(NSString *)fileName Key:(NSString *)key
{
    NSMutableArray *testItems = [[NSMutableArray alloc] init];
    //首先读取plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //定义相关的字符串
    NSMutableString * titileString = [[NSMutableString alloc]initWithCapacity:10];
    NSMutableString * upperString  = [[NSMutableString alloc]initWithCapacity:10];
    NSMutableString * lowerString  = [[NSMutableString alloc] initWithCapacity:10];
    
    
    //根据传入的关键字找到对应节点
    NSArray *arrayData = [dictionary objectForKey:key];
    
    if (arrayData != nil && ![arrayData isEqual:@""])
    {
        for (NSDictionary *dic in arrayData)
        {
            //读取 plist 文件中的固定数据
            Item *item = [[Item alloc] init];
            
            item.freq       = [dic objectForKey:@"Freq"];
            item.id         = [dic objectForKey:@"ID"];
            item.retryTimes = [dic objectForKey:@"RetryTimes"];
            item.testName   = [dic objectForKey:@"TestName"];
            item.units      = [dic objectForKey:@"Units"];
            item.min        = [dic objectForKey:@"Min"];
            item.max        = [dic objectForKey:@"Max"];
            item.value1      = [dic objectForKey:@"Value1"];
            item.value2      = [dic objectForKey:@"Value2"];
            item.value3      = [dic objectForKey:@"Value3"];
            item.value4      = [dic objectForKey:@"Value4"];
            
            item.result1     = [dic objectForKey:@"Result1"];
            item.result2     = [dic objectForKey:@"Result2"];
            item.result3     = [dic objectForKey:@"Result3"];
            item.result4     = [dic objectForKey:@"Result4"];
            
            item.isTest     = [[dic objectForKey:@"IsTest"] boolValue];
            item.isShow     = [[dic objectForKey:@"IsShow"] boolValue];
            item.testAllCommand =[dic objectForKey:@"AllNeedCommands"];
            item.startTime  = @"";
            item.endTime    = @"";
            
            //加入到title中
            [titileString appendFormat:@"%@,",item.testName];
            [upperString appendFormat:@"%@,",item.max];
            [lowerString appendFormat:@"%@,",item.min];

            [testItems addObject:item];
        }
        
        //先移除空格,最后的逗号用“\n”符号替代
        [upperString replaceCharactersInRange:NSMakeRange(upperString.length-1, 1) withString:@"\n"];
        [lowerString replaceCharactersInRange:NSMakeRange(lowerString.length-1, 1) withString:@""];
        
        //拼接到暴露外界的字符串上
         _titile = [NSMutableString stringWithFormat:@"%@%@%@",[@"Start_Time,End_Time,Version,NestID,Product_Type,Config,SN,TestResut,FixtureID,Operator_ID," stringByAppendingString:titileString],[@"\nMAX,,,,,,,,,,"  stringByAppendingString:upperString],[@"MIN,,,,,,,,,,"  stringByAppendingString:lowerString]];

    }
    
    return testItems;
}



//=============================================
- (void)PlistWrite:(NSString*)filename UpdateItem:(UpdateItem *)updateItem Key:(NSString *)key
{
    //读取plist
    [NSThread sleepForTimeInterval:0.1];
    
    @synchronized (self)
    {
        NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSMutableDictionary *subDic = [dictionary objectForKey:key];
        [subDic setObject:updateItem.fix_ABC_DEF_Res forKey:kFixtureFix_ABC_DEF_Res];
        [subDic setObject:updateItem.fix_B2_E2_Res   forKey:kFixtureFix_B2_E2_Res];
        [subDic setObject:updateItem.fix_B4_E4_Res   forKey:kFixtureFix_B4_E4_Res];
        [subDic setObject:updateItem.fix_B_E_Res     forKey:kFixtureFix_B_E_Res];
        [subDic setObject:updateItem.fix_Cap         forKey:kFixtureFix_Cap];
        [dictionary setObject:subDic forKey:key];
        [dictionary writeToFile:plistPath atomically:YES];
    }
    
}

//=============================================
-(NSDictionary *)PlistRead:(NSString *)fileName
{
    //首先读取plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
   
    return dictionary;
}


@end
