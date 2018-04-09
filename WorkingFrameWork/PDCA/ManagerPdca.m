//
//  ManagerPdca.m
//  BCM
//
//  Created by mac on 07/04/2018.
//  Copyright © 2018 macjinlongpiaoxu. All rights reserved.
//

#import "ManagerPdca.h"
#import "Common.h"
#import "PDCA.h"
#import "Item.h"


@interface ManagerPdca()
{
  
    NSThread   * thread;
    
    int        index;
    int        fix_num0;
    int        fix_num1;
    int        fix_num2;
    int        fix_num3;
    int        fix_num4;
    
    PDCA      * pdca;
    
    NSDictionary   * ItemDic_A;
    NSDictionary   * ItemDic_B;
    NSDictionary   * ItemDic_C;
    NSDictionary   * ItemDic_D;
    
    int       test_total_num;
    int       pdca_upload_num;
    
    
    BOOL      isStartPDCA;
    BOOL      isEndPDCA;
}
@end



@implementation ManagerPdca

-(id)init
{
    if (self = [super init]) {
        
        isStartPDCA = NO;
        isEndPDCA   = NO;
        
        index = 0;
        fix_num0 = 0;
        fix_num1 = 0;
        fix_num2 = 0;
        fix_num3 = 0;
        fix_num4 = 0;
        test_total_num   = 0;
        pdca_upload_num  = 0;
        
        pdca = [[PDCA alloc] init];
        ItemDic_A = [[NSDictionary alloc] init];
        ItemDic_B = [[NSDictionary alloc] init];
        ItemDic_C = [[NSDictionary alloc] init];
        ItemDic_D = [[NSDictionary alloc] init];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPdcaVaule:) name:kTestPDCAValueNotice object:nil];

        
        thread = [[NSThread alloc]initWithTarget:self selector:@selector(working) object:nil];

    }

    return self;
}






-(void)selectPdcaVaule:(NSNotification *)noti
{
    
    test_total_num++;
    

    if ([noti.object containsString:@"start time"]) {
        
        index = 1;
    
    }

    if ([noti.object containsString:@"1"]) {
        
        fix_num1 = 101;
        ItemDic_A = noti.userInfo;
    }
    if ([noti.object containsString:@"2"]) {
        
        fix_num2 = 102;
        ItemDic_B = noti.userInfo;
    }
    
    if ([noti.object containsString:@"3"]) {
        
        fix_num3 = 103;
        ItemDic_C = noti.userInfo;
    }
    
    if ([noti.object containsString:@"4"]) {
        
        fix_num4 = 104;
        ItemDic_D = noti.userInfo;
    }

}




-(void)working
{
  
    while ([[NSThread currentThread] isCancelled]== NO)
    {
        
        if (index == 0) {
            
            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"等待上传PDCA中");
        }
        
        if (index == 1) {   //开始上传测试时间
            
            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"开始上传PDCA");
            if (!isStartPDCA) {
                
                [pdca PDCA_GetStartTime];
                
                isStartPDCA = YES;
            }
        }
        
        if (fix_num1==101) {
            
            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"上传治具A的PDCA数据");
            [self UploadPDCA:1 Dic:ItemDic_A];
            pdca_upload_num++;
            fix_num1 =0;
            
            if (pdca_upload_num == test_total_num) {
                
                isStartPDCA = NO;
                index = 1000;
            }
          
        }
        if (fix_num2==102) {
            
            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"上传治具B的PDCA数据");
            
            [self UploadPDCA:2 Dic:ItemDic_A];
            pdca_upload_num++;
            fix_num2 = 0;
            
            if (pdca_upload_num == test_total_num) {
                
                isStartPDCA = NO;
                index = 1000;
            }

        }
        if (fix_num3==103) {
            
            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"上传治具C的PDCA数据");
            [self UploadPDCA:3 Dic:ItemDic_A];
            pdca_upload_num++;
            fix_num3 = 0;
            
            if (pdca_upload_num == test_total_num) {
                isStartPDCA = NO;
                index = 1000;
            }

        }
        if (fix_num4==104) {
            
            [NSThread sleepForTimeInterval:0.5];
             NSLog(@"上传治具D的PDCA数据");
            [self UploadPDCA:4 Dic:ItemDic_A];
            pdca_upload_num++;
            fix_num4 = 0;
            
            if (pdca_upload_num == test_total_num) {
                isStartPDCA = NO;
                
                pdca_upload_num=0;
                test_total_num = 0;

                index = 1000;
            }

        }
        
        if (index == 1000) {
            
            [NSThread sleepForTimeInterval:0.1];
        }
        
        
    }


}


#pragma mark----PDCA相关
//================================================
//上传pdca
//================================================
-(void)UploadPDCA:(int)num Dic:(NSDictionary *)dic
{
    //可以从json文件中获取所需要的值
    NSError  * error;
    NSData  * data=[NSData dataWithContentsOfFile:@"/vault/data_collection/test_station_config/gh_station_info.json"];
    NSDictionary * jsonDic=[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] objectForKey:@"ghinfo"];
    NSString * ReStaName =[jsonDic objectForKey:@"STATION_TYPE"];
    
    
    
    NSString * result=  @"";
    NSString * value =  @"";
    
    BOOL pass_fail = YES;
    
    
    NSString   * dut_sn =  [dic objectForKey:@"dut_sn"];
    
    if ([dut_sn length]>17) {
        
        dut_sn = [dut_sn substringToIndex:17];
    }
    [pdca PDCA_Init:dut_sn SW_name:ReStaName SW_ver:[dic objectForKey:@"sw_ver"]];           //上传sn，sw_name,sw_ver
    
    NSArray   * itemArr = [dic objectForKey:@"dic"];
    
    for(int i=0;i<[itemArr count];i++)
    {
        Item *testitem=itemArr[i];
        if (num == 1) {result = testitem.result1,value   = testitem.value1;}
        if (num == 2) {result = testitem.result2,value   = testitem.value2;}
        if (num == 3) {result = testitem.result3,value   = testitem.value3;}
        if (num == 4) {result = testitem.result4,value   = testitem.value4;}
        
        
        if(testitem.isTest)  //需要测试的才需要上传
        {
            
            if((testitem.isShow == YES)&&(testitem.isTest))    //需要显示并且需要测试的才上传
            {
                
                if( ![result isEqualToString:@"PASS"] )
                {
                    pass_fail = NO;
                    
                }
                
                [pdca PDCA_UploadValue:testitem.testName
                                 Lower:testitem.min
                                 Upper:testitem.max
                                  Unit:testitem.units
                                 Value:value
                             Pass_Fail:pass_fail
                 ];
                
                
            }
        }
    }
    
    [pdca PDCA_Upload:pass_fail];     //上传汇总结果
    
    //============================压缩文件======================================/
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

     NSString  * folder =  [dic objectForKey:@"totalPath"];
     NSString   * eachCsvDir =  [dic objectForKey:@"eachCsvDir"];
     NSString   * zipFileName = [[eachCsvDir componentsSeparatedByString:@"/"] lastObject];
     NSString   * cmd = [NSString stringWithFormat:@"cd %@; zip -r %@.zip %@",folder,zipFileName,zipFileName];
     NSArray    * argument = [NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"%@", cmd], nil];
     [task setArguments: argument];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    [task launch];
    
    

    //获取压缩文件的具体地址
    NSString *ZIP_path = [NSString stringWithFormat:@"%@/%@.zip",folder,zipFileName];
    sleep(1);
    int FileCount = 0;
    while (true) {
        
        if([[NSFileManager defaultManager] fileExistsAtPath:ZIP_path]){
            
            NSLog(@"file has been existed");
            break;
        }
        else
        {
            NSLog(@"file has been not existed");
            FileCount++;
            sleep(0.5);
            if (FileCount>=3) {
                break;
            }
            
        }
        
    }
    
    //上传压缩文件到服务器
    [pdca AddBlob:zipFileName FilePath:ZIP_path];
    
    
    //上传结束时间
    [pdca PDCA_GetEndTime];
    
    //============================压缩文件======================================/
    
}


#pragma mark===================结束上传PDCA的线程
-(void)end_Thread
{
    [thread cancel];
}

-(void)start_Thread
{
    [thread start];
}



@end
