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
#import "Param.h"
#import <Cocoa/Cocoa.h>

@interface ManagerPdca()
{
    PDCA       * pdca;
    Param      * param;
    NSString   * dut_sn;
    
}
@end



@implementation ManagerPdca

-(id)init
{
    if (self = [super init]) {
         param = [[Param alloc]init];
        [param ParamRead:@"Param"];

    }

    return self;
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
    
    
    dut_sn =  [dic objectForKey:@"dut_sn"];
    
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

                if(![result isEqualToString:@"PASS"])
                {
                    pass_fail = NO;
                    
                }
                
                [pdca PDCA_UploadValue:testitem.testName
                                 Lower:testitem.min
                                 Upper:testitem.max
                                  Unit:testitem.units
                                 Value:value
                             Pass_Fail:pass_fail];
                
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
    
    
    NSString   * zipFileName1 =[[NSString stringWithFormat:@"%@_%@",param.sw_name,param.sw_ver] stringByAppendingString:@"_ZIP_Log"];
    
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
    [pdca AddBlob:zipFileName1 FilePath:ZIP_path];
    
    //上传结束时间
    [pdca PDCA_GetEndTime];
    
    //============================压缩文件======================================/
}





-(void)UploadPDCA_Dafen:(int)num Dic:(NSDictionary *)dic Arr:(NSArray *)array BOOL:(BOOL)isPass
{
    /**
     * info :
     *  cfailItems     ----->    all the failItems
     *  param.sw_ver   ------>  we can get the param infomation form the (Param.plist) file, like this: param.sw_ver, param.isDebug...
     *  theSN   =   importSN.stringValue
     *  itemArr ---------> All test Items  , the way to get , itemArr = [plist PlistRead:@"Station_0" Key:@"AllItems"];
     *  testItem -------->  form Item class  ,  testItem = [itemArr objectAtIndex:i],we can get different testItem ; than we have all the item infomation like this : testItem.testName/ testItem.units / testItem.min / testItem.value /testItem.max / testItem.result
     *
     */
    
    NSError  * error;
    NSData  * data=[NSData dataWithContentsOfFile:@"/vault/data_collection/test_station_config/gh_station_info.json"];
    NSDictionary * jsonDic=[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] objectForKey:@"ghinfo"];
    NSString * ReStaName =[jsonDic objectForKey:@"STATION_TYPE"];
    
     dut_sn =  [dic objectForKey:@"dut_sn"];
    
    if ([dut_sn length]>17) {
        
        dut_sn = [dut_sn substringToIndex:17];
    }
    
    //------------------------------- nothing to change -------------------------------------------------
    
    IP_UUTHandle UID;
    Boolean APIcheck;
    IP_TestSpecHandle testSpec;
    
    IP_API_Reply reply = IP_UUTStart(&UID);
    
    if(!IP_success(reply))
    {
        
        [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(reply) encoding:1]];
    }
    
    IP_reply_destroy(reply);
    
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, [ [NSString stringWithFormat:@"%@",param.sw_ver] cStringUsingEncoding:1]  ));
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWARENAME, [ReStaName cStringUsingEncoding:1]  ));
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONLIMITSVERSION, [[NSString stringWithFormat:@"%@",param.sw_ver] cStringUsingEncoding:1]));
    
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_SERIALNUMBER, [dut_sn cStringUsingEncoding:1] ));
    //压缩并上传文件
    
    
    //============================压缩文件======================================/
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSString   * folder =  [dic objectForKey:@"totalPath"];
    NSString   * eachCsvDir =  [dic objectForKey:@"eachCsvDir"];
    NSString   * zipFileName = [[eachCsvDir componentsSeparatedByString:@"/"] lastObject];
    
    
    NSString   * zipFileName1 =[[NSString stringWithFormat:@"%@_%@",param.sw_name,param.sw_ver] stringByAppendingString:@"_ZIP_Log"];
    
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
    
    NSLog(@"打印数据zipFileName1=%@====ZIP_path=%@",zipFileName1,ZIP_path);
    
     IP_addBlob(UID, [zipFileName1 cStringUsingEncoding:1], [ZIP_path cStringUsingEncoding:1]);
    //============================压缩文件======================================/
    
    
    
    NSArray   * valueArr  = [[dic objectForKey:@"value"] componentsSeparatedByString:@","];
    NSArray   * resultArr = [[dic objectForKey:@"result"] componentsSeparatedByString:@","];

    //----------------------- change the loop 2017.5.25 _MK ------------------------------------
    for(int i=0;i<[array count];i++)
    {
        
        Item *testitem=array[i];
        
        //---------------------------------------
        NSString * testitemNameStr       = testitem.testName;
        NSString * testitemMinStr        = testitem.min;
        NSString * testitemMaxStr        = testitem.max;
        NSString * testitemUnitStr       = testitem.units;
        NSString * testitemValueStr      = valueArr[i];
        NSString * testItemResultStr     = resultArr[i];
        
        
        if ([testitemUnitStr isEqualToString:@"GΩ"])
        {
            testitemUnitStr = @"GOHM";
        }
        if ([testitemUnitStr isEqualToString:@"MΩ"])
        {
            testitemUnitStr = @"MOHM";
        }
        if ([testitemUnitStr isEqualToString:@"KΩ"])
        {
            testitemUnitStr = @"KOHM";
        }
        if ([testitemUnitStr isEqualToString:@"Ω"])
        {
            testitemUnitStr = @"OHM";
        }
        if ([testitemUnitStr isEqualToString:@"%"])
        {
            testitemUnitStr = @"PERCENT";
        }
        if ([testitemUnitStr isEqualToString:@"℃"])
        {
            testitemUnitStr = @"CELSIUS";
        }
        if ([testitemUnitStr isEqualToString:@"--"])
        {
            testitemUnitStr = @"N/A";
        }
        if(testitemMaxStr==nil || [testitemMaxStr isEqualToString:@"--"])
        {
            testitemMaxStr=@"N/A";
        }
        if(testitemMinStr==nil || [testitemMinStr isEqualToString:@"--"])
        {
            testitemMinStr=@"N/A";
        }
        if ([testitemValueStr containsString:@">1TOhm"])
        {
            testitemValueStr=@"1000";
        }
        if ([testitemValueStr isEqualToString:@">100GOhm"])
        {
            testitemValueStr=@"100000";
        }
        if ([testitemValueStr isEqualToString:@"<1fF"])
        {
            testitemValueStr=@"Small than 1fF";
        }
        
        testitemNameStr = [testitemNameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemMinStr = [testitemMinStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemMaxStr = [testitemMaxStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemUnitStr = [testitemUnitStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemValueStr=[testitemValueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        //------------------------------------------
        
        testSpec=IP_testSpec_create();
        
        //--------------------- title---------------------------
        APIcheck=IP_testSpec_setTestName(testSpec, [testitemNameStr cStringUsingEncoding:1], [testitemNameStr length]);
        
        //----------------- limits ------------------------------
        APIcheck=IP_testSpec_setLimits(testSpec, [testitemMinStr cStringUsingEncoding:1], [testitemMinStr length], [testitemMaxStr cStringUsingEncoding:1], [testitemMaxStr length]);
        
        //----------------- unit ---------------------------
        APIcheck=IP_testSpec_setUnits(testSpec, [testitemUnitStr cStringUsingEncoding:1], [testitemUnitStr length]);
        
        //----------------- priority --------------------------------
        APIcheck=IP_testSpec_setPriority(testSpec, IP_PRIORITY_REALTIME);
        
        IP_TestResultHandle puddingResult=IP_testResult_create();
        
        if(NSOrderedSame==[testitemValueStr compare:@"Pass" options:NSCaseInsensitiveSearch] || NSOrderedSame==[testitemValueStr compare:@"Fail" options:NSCaseInsensitiveSearch])
        {
            testitemValueStr=@"";
        }
        
        const char *value=[testitemValueStr cStringUsingEncoding:1];
        
        int valueLength=(int)[testitemValueStr length];
        
        int result=IP_FAIL;
        
    
        if ([[testItemResultStr uppercaseString] containsString:@"PASS"]) {
            
            result=IP_PASS;
        }
        
        
        if (stringisnumber(testitemValueStr))
        {
            APIcheck=IP_testResult_setValue(puddingResult, value,valueLength);
        }
        
        
        APIcheck=IP_testResult_setResult(puddingResult, result);
        
        if(!result)
        {
            NSString *failDes=@"";
            
            //==========errorcode@errormessage================
            if(isPass)
            {
                failDes=[failDes stringByAppendingString:@"N/A" ];
            }
            
            else
            {
                failDes=[failDes stringByAppendingString:@"error"];
            }
            
            failDes=[failDes stringByAppendingString:@","];
            
            APIcheck=IP_testResult_setMessage(puddingResult, [failDes cStringUsingEncoding:1], [failDes length]);
        }
        
        reply=IP_addResult(UID, testSpec, puddingResult);
        
        if(!IP_success(reply))
        {
            
            [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(reply) encoding:1]];
        }
        
        IP_reply_destroy(reply);
        
        IP_testResult_destroy(puddingResult);
        
        IP_testSpec_destroy(testSpec);
    }
    
    

    //------------------------ nothing change --------------------------------------
    IP_API_Reply doneReply=IP_UUTDone(UID);
    if(!IP_success(doneReply)){
        [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(doneReply) encoding:1]];
        
        //        exit(-1);
        IP_API_Reply amiReply = IP_amIOkay(UID, [dut_sn cStringUsingEncoding:1]);
        if (!IP_success(amiReply))
        {
            IP_reply_destroy(amiReply);
        }
    }
    
    IP_reply_destroy(doneReply);
    
    IP_API_Reply commitReply;
    
    if(!isPass)
    {
        commitReply=IP_UUTCommit(UID, IP_FAIL);
    }
    else
    {
        commitReply=IP_UUTCommit(UID, IP_PASS);
    }
    
    if(!IP_success(commitReply)){}
    IP_reply_destroy(commitReply);
    IP_UID_destroy(UID);
}







void handleReply( IP_API_Reply reply )
{
    if ( !IP_success( reply ) )
    {
        NSRunAlertPanel(@"Confirm",@"Upload PDCA data error", @"YES", nil,nil);
        NSLog(@"Upload PDCA data error");
        //exit(-1);
    }
    IP_reply_destroy(reply);
}


BOOL stringisnumber(NSString *stringvalues)
{
    
    NSMutableArray *arrM=[[NSMutableArray alloc]init];
    NSString *temp;
    NSInteger p=0;
    NSInteger g=0;
    if ([stringvalues length])
    {
        for(int i=0;i<[stringvalues length];i++)
        {
            temp=[[stringvalues substringFromIndex:i] substringToIndex:1];
            [arrM addObject:temp];
            if (![@"-1234567890." rangeOfString:temp].length)
            {
                return FALSE;
            }
        }
        for (NSString *str in arrM)
        {
            if ([str containsString:@"."])
            {
                p++;
            }
            if ([str containsString:@"-"]) {
                g++;
            }
        }
        if (g>1 || p>1)
        {
            return FALSE;
        }
    }
    else
    {
        return FALSE;
    }
    return TRUE;
}


#pragma mark-------提示框的内容
-(void)showAlertMessage:(NSString *)showMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{

        
        
        NSAlert * alert1 = [NSAlert new];
        alert1.messageText = @"Comfirm";
        alert1.informativeText = showMessage;
        [alert1 addButtonWithTitle:@"YES"];
        //第一种方式，以modal的方式出现
        [alert1 runModal];
    });
    
}



@end
