//
//  Item.h
//  MKPlist_Sample
//
//  Created by Michael on 16/11/7.
//  Copyright © 2016年 Michael. All rights reserved.
//


/**
 * table.xib文件 的 column identifier 项
 * 测试项
 */
//=============================================
//与table.xib 的 column identifier 对应
#define TABLE_COLUMN_ID               @"id"
//#define TABLE_COLUMN_RETRYTIMES     @"retryTimes"
#define TABLE_COLUMN_TESTNAME         @"testName"
#define TABLE_COLUMN_UNITS            @"units"
#define TABLE_COLUMN_MIN              @"min"
#define TABLE_COLUMN_MAX              @"max"
#define TABLE_COLUMN_FREQ             @"freq"
#define TABLE_COLUMN_VALUE_1          @"value1"
#define TABLE_COLUMN_RESULT_1         @"result1"
#define TABLE_COLUMN_VALUE_2          @"value2"
#define TABLE_COLUMN_RESULT_2         @"result2"
#define TABLE_COLUMN_VALUE_3          @"value3"
#define TABLE_COLUMN_RESULT_3         @"result3"
#define TABLE_COLUMN_VALUE_4          @"value4"
#define TABLE_COLUMN_RESULT_4         @"result4"





//#define TABLE_COLUMN_ISTEST         @"isTest"
//=============================================

#import <Foundation/Foundation.h>

@interface Item : NSObject

/**
 * table.m文件 的 model项
 * 测试项
 */
//=============================================
//在这里设置 table delegate 方法里边的数据模型
@property(readwrite,copy) NSString *id;
@property(readwrite,copy) NSNumber  * retryTimes;
@property(readwrite,copy) NSString  * testName;
@property(readwrite,copy) NSString  * units;
@property(readwrite,copy) NSString  * min;
@property(readwrite,copy) NSString  * max;
@property(nonatomic,strong)NSString * startTime;
@property(nonatomic,strong)NSString * endTime;
@property(nonatomic,strong)NSString * freq;


@property(nonatomic,strong)NSString * value1;
@property(nonatomic,strong)NSString * value2;
@property(nonatomic,strong)NSString * value3;
@property(nonatomic,strong)NSString * value4;

@property(readwrite,copy)  NSString * result1;
@property(readwrite,copy)  NSString * result2;
@property(readwrite,copy)  NSString * result3;
@property(readwrite,copy)  NSString * result4;

@property(readwrite)       BOOL       isTest;
@property(readwrite)       BOOL       isShow;
@property(nonatomic,strong)NSString *messageError;

@property(nonatomic,strong)NSString  * testFailItems;

@property(readwrite,copy)NSArray  * testAllCommand;


-(id)initWithItem:(Item *)item;

@end
