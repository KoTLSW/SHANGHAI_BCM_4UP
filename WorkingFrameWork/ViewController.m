//
//  ViewController.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
// FGQ8152C1REJ68Y10

#import "ViewController.h"
#import "Table.h"
#import "Plist.h"
#import "Param.h"
#import "TestAction.h"
#import "MKTimer.h"
#import "AppDelegate.h"
#import "Folder.h"
#import "GetTimeDay.h"
#import "FileCSV.h"
#import "visa.h"
#import "SerialPort.h"
#import "Common.h"
#import "TestStep.h"
#import "BYDSFCManager.h"
#import "ManagerPdca.h"
#import "Alert.h"


//文件名称
NSString * param_Name = @"Param";

@interface ViewController()<NSTextFieldDelegate>
{
    Table * tab1;
    Table * tab2;
    
    Folder   * fold;
    FileCSV  * csvFile;
    
    NSThread * thread;
    
    Plist * plist;
    Param * param;
    SerialPort *   serialport;        //控制板类
    SerialPort *   humiturePort;      //温湿度控制类
    NSArray    *   itemArr1;
    NSArray    *   itemArr2;
    
    TestAction * action1;
    TestAction * action2;
    TestAction * action3;
    TestAction * action4;
    
    
     Alert      *   alert;            //显示窗口
    ManagerPdca * pdca;               //上传PDCA
    
    //定时器相关
     MKTimer * mkTimer;
     int      ct_cnt;                  //记录cycle time定时器中断的次数
    
    
    
    IBOutlet NSTextField *NS_TF1;                     //产品1输入框
    IBOutlet NSTextField *NS_TF2;                     //产品2输入框
    IBOutlet NSTextField *NS_TF3;                     //产品3输入框
    IBOutlet NSTextField *NS_TF4;                     //产品4输入框
    
    
    IBOutlet NSTextView *Log_View;                    //Log日志
    
    IBOutlet NSTextField *  Status_TF;                //显示状态栏
    IBOutlet NSTextField *  testFieldTimes;           //时间显示输入框
    IBOutlet NSTextField *  humiture_TF;              //温湿度显示lable
    IBOutlet NSTextField *  TestCount_TF;             //测试的次数
    IBOutlet NSButton    *  IsUploadPDCA_Button;      //上传PDCA的按钮
    IBOutlet NSButton    *  IsUploadSFC_Button;       //上传SFC的按钮
    IBOutlet NSTextField *  Version_TF;               //软件版本
    
    IBOutlet NSPopUpButtonCell *comanyItem;
    
    
    IBOutlet NSTextView *A_LOG_TF;
    IBOutlet NSTextView *B_LOG_TF;
    IBOutlet NSTextView *C_LOG_TF;
    IBOutlet NSTextView *D_LOG_TF;
    
    IBOutlet NSTextView *A_FailItem;
    IBOutlet NSTextView *B_FailItem;
    IBOutlet NSTextView *C_FailItem;
    IBOutlet NSTextView *D_FailItem;
    
    
    IBOutlet NSButton *choose_dut1;
    IBOutlet NSButton *choose_dut2;
    IBOutlet NSButton *choose_dut3;
    IBOutlet NSButton *choose_dut4;
    
    
    IBOutlet NSPopUpButton *NestID_Change;
    IBOutlet NSTextField   *product_Config;
    IBOutlet NSButton      *config_change;
    IBOutlet NSTextField   *loopTest_Label;
    IBOutlet NSTextField   *Operator_TF;
    IBOutlet NSButton      *change_OpID;
    IBOutlet NSButton      *nulltest_button;
    IBOutlet NSButton      *startbutton;
    IBOutlet NSButton      *ComfirmButton;
    IBOutlet NSButton      *ReloadButton;
    IBOutlet NSButton      *singlebutton;
    IBOutlet NSPopUpButton *num_PopButton;
    
    int index;
    //创建相关的属性
    NSString * foldDir;               //config属性总文件
    NSString * totalFold;             //所有文件总文件
    NSString * totalPath;             //包含到cr的文件路径
    
    //温湿度相关属性
    NSString             * humitureString;
    NSString             * temptureString;
    
    //测试结束通知中返回的对象===数据中含有P代表成功，含有F代表失败
    NSString             * notiString_A;
    NSString             * notiString_B;
    NSString             * notiString_C;
    NSString             * notiString_D;
    NSString             * testingFixStr;         //正在测试的治具
    
    //产品通过的的次数和测试的总数
    int                   passNum;             //通过的测试次数
    int                   totalNum;            //通过的测试总数
    int                   nullNum;             //空测试完成的次数
    int                   fix_A_num;
    int                   fix_B_num;
    int                   fix_C_num;
    int                   fix_D_num;
  

    
    int                   testnum;            //传送过来产品的总个数

    NSMutableDictionary        * config_Dic;  //相关的配置参数属
    
    BOOL                        singleTest;         //产品单个测试
    NSString                  * fixtureID;         //fixture的值
    
    //===================新增的项
    TestStep                  * testStep;
    BYDSFCManager             * sfcManager;
    NSDictionary              * A_resultDic;  //接收A通道的测试数据
    NSDictionary              * B_resultDic;  //接收B通道的测试数据
    NSDictionary              * C_resultDic;  //接收C通道的测试数据
    NSDictionary              * D_resultDic;  //接收D通道的测试数据
    
    //===================NG的产品
     NSMutableArray           * snArr;         //SN的字符串数组
     NSMutableArray           * SnArr_TF;      //SN TextField数组
    
    //===================通过可变数组的大小，判断当前有几个在测试
    NSMutableArray            *ChooseNumArray; //测试个数
    //===================工位数据生成地址单独设置
    BOOL                      isUpLoadSFC;
    BOOL                      isUpLoadPDCA;
    
    BOOL                      isLoopTest;      //循环测试
    BOOL                      isComfirmOK;     //单个模式选项是否确认
    
}



@end

@implementation ViewController


//软件测试整个流程  //door close--->SN---->config-->监测start--->下压气缸---->抛出SN-->直接运行


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //整型变量定义区
    index    = 0;
    passNum  = 0;
    totalNum = 0;
    nullNum  = 0;
    
    fix_A_num = 0;
    fix_B_num = 0;
    fix_C_num = 0;
    fix_D_num = 0;
    testnum   = 0;
    testingFixStr = @"";
    //BOOL变量
    singleTest   = NO;
    isUpLoadSFC  = NO;
    isUpLoadPDCA = YES;
    isLoopTest   = NO;
    isComfirmOK  = NO;
    //新增内容
    testStep = [TestStep Instance];
    
    config_Dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    plist = [Plist shareInstance];
    param = [[Param alloc]init];
    [param ParamRead:param_Name];
    snArr = [[NSMutableArray alloc]initWithCapacity:10];
    SnArr_TF = [[NSMutableArray alloc]initWithCapacity:10];
    ChooseNumArray =[[NSMutableArray alloc]initWithCapacity:10];
    
    [config_Dic setValue:param.sw_ver forKey:kSoftwareVersion];
    [Version_TF setStringValue:param.sw_ver];
    
    
     alert       = [Alert shareInstance];
    //第一响应
    [NS_TF1 acceptsFirstResponder];
    //加载界面
    itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid" Key:@"AllItems"];
    tab1 = [[Table  alloc]init:Tab1_View DisplayData:itemArr1];
    alert = [Alert shareInstance];
    
    //初始化温湿度和主控板
     humiturePort = [[SerialPort alloc]init];
    [humiturePort setTimeout:1 WriteTimeout:1];
     serialport   = [[SerialPort alloc]init];
    [serialport setTimeout:1 WriteTimeout:1];
 
    //软件初始化
    A_resultDic = [[NSDictionary alloc]init];
    B_resultDic = [[NSDictionary alloc]init];
    C_resultDic = [[NSDictionary alloc]init];
    D_resultDic = [[NSDictionary alloc] init];
    
    //开启定时器
    mkTimer = [[MKTimer alloc]init];
    //创建总文件
    fold    = [[Folder alloc]init];
    csvFile = [[FileCSV alloc]init];
    
    //保存路径
    totalPath = [NSString stringWithFormat:@"%@/%@/%@_%@",param.foldDir,[[GetTimeDay shareInstance] getCurrentDay],param.sw_name,param.sw_ver];
    [fold Folder_Creat:totalPath];
    [[NSUserDefaults standardUserDefaults] setValue:totalPath forKey:kTotalFoldPath];
    [[NSUserDefaults standardUserDefaults] synchronize];


    
    //上传相关文件
    testStep   = [TestStep Instance];
    sfcManager = [BYDSFCManager Instance];
    pdca       = [[ManagerPdca alloc]init];
    
    //监听测试结束，重新等待SN
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSnChangeNoti:) name:@"SNChangeNotice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectTestModeNotice:) name:kTestModeNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSfc_PDCAUpload:) name:kSfcUploadNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSfc_PDCAUpload:) name:kPdcaUploadNotice object:nil];
    //监测空测试完
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectFinshNullTest) name:kFinshNullTestNotice object:nil];
    //监测空测值异常
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectDifferNullTest) name:kDifferNullTestNotice object:nil];
    
    
    
    //开启4条线程
    [self createThreadWithNum:1];
    [self createThreadWithNum:2];
    [self createThreadWithNum:3];
    [self createThreadWithNum:4];

    //是否绑定过
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"IsBind"]) {
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
        [thread start];
    }
}



#pragma mark 改变测试条件

- (IBAction)change_Station_Button:(id)sender {
    
    if ([sender isEqual:NestID_Change]) {
        
        NSLog(@"点击 NestID_Change");

        [config_Dic setValue: NestID_Change.titleOfSelectedItem forKey:kProductNestID];
    }
    
    if ([sender isEqual:config_change])
    {
        
        if (config_change.state)
        {
            product_Config.editable = YES;
        }
        else
        {
            product_Config.editable = NO;
        }

        [config_Dic setValue: product_Config.stringValue forKey:kConfig_pro];
       
    }
}


#pragma mark 保存配置文件的状态
-(void)saveConfigStation
{
    [config_Dic setValue: NestID_Change.titleOfSelectedItem forKey:kProductNestID];
    [config_Dic setValue: [product_Config.stringValue length]>0?product_Config.stringValue:@"" forKey:kConfig_pro];
    [config_Dic setValue: [Operator_TF.stringValue length]>0?Operator_TF.stringValue:@"" forKey:kOperator_ID];
    
}


#pragma mark 开始测试
- (IBAction)start_Action:(id)sender
{
    
    if (singleTest) {
        
        if (isComfirmOK) {
            
            index = 8;
            startbutton.enabled = NO;
        }
        else
        {
            [Status_TF setStringValue:@"请点击Comfirm确认选项"];
            
        }
    }else
    {
    
        index = 8;
        startbutton.enabled = NO;
    }
}


- (IBAction)chooseCompanyAction:(id)sender {
    
    NSLog(@"comanyItem.titleOfSelectedItem: %@", comanyItem.titleOfSelectedItem);
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTestCompanyNotice object:comanyItem.titleOfSelectedItem];
}



#pragma mark 通道测试完成通知
//=============================================
-(void)selectSnChangeNoti:(NSNotification *)noti
{
    
     totalNum++;

    if ([noti.object containsString:@"1"]) {
        
        fix_A_num = 101;
        notiString_A = noti.object;
        A_resultDic =  [noti.userInfo mutableCopy];
        
        NSLog(@"A_resultDic：%@",noti.userInfo);
        if ([noti.object containsString:@"X"]) {
            
            totalNum--;
        }
        
        NSLog(@"fixture_A 测试已经完成了");
    }
    if ([noti.object containsString:@"2"]) {
        
        fix_B_num = 102;
        notiString_B = noti.object;
        B_resultDic  = noti.userInfo;
         NSLog(@"B_resultDic：%@",B_resultDic);

        NSLog(@"fixture_B 测试已经完成了");
        if ([noti.object containsString:@"X"]) {
            
            totalNum--;
        }
    }
    if ([noti.object containsString:@"3"]) {
        
         fix_C_num = 103;
         notiString_C = noti.object;
         C_resultDic = noti.userInfo;
        
        NSLog(@"fixture_C 测试已经完成了");
        
        if ([noti.object containsString:@"X"]) {
            
            totalNum--;
        }
    }
    if ([noti.object containsString:@"4"]) {
        
        fix_D_num = 104;
        notiString_D = noti.object;
        D_resultDic = noti.userInfo;
        NSLog(@"fixture_D 测试已经完成了");
        
        if ([noti.object containsString:@"X"]) {
            
            totalNum--;
        }
    }

}


//=============================================


-(void)Working
{
    
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
#pragma mark index = 0,初始化控制板串口
        if (index == 0) {
            
            
            [NSThread sleepForTimeInterval:0.5];
            
            BOOL  isOpen = [serialport Open:param.contollerBoard]||[serialport Open:param.contollerBoard_two];
            
            if (param.isDebug)
            {
                
                  NSLog(@"index = 0,debug中，模拟控制板初始化");
                 [self UpdateTextView:@"index = 0,模拟控制板初始化" andClear:NO andTextView:Log_View];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [Status_TF setStringValue:@"index = 0,Debug:控制板初始化"];
                 });
                
                 index = 1;
            }
            else if(isOpen)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=0,Controller Board connect success"];
                });
                
                [self UpdateTextView:@"index = 0,FIX-O connect success" andClear:NO andTextView:Log_View];
                
                [NSThread sleepForTimeInterval:0.2];
                
                [serialport WriteLine:@"Fixture ID?"];
                
                [NSThread sleepForTimeInterval:0.5];
                
                fixtureID = [serialport ReadExisting];
                
                if ([fixtureID containsString:@"\r\n"]) {
                    
                    fixtureID = [[fixtureID componentsSeparatedByString:@"\r\n"] objectAtIndex:1];
                    fixtureID = [fixtureID stringByReplacingOccurrencesOfString:@"*_*" withString:@""];
                }
                sfcManager.station_id = fixtureID;
                
                if ([fixtureID length]>0) {
                    
                     index = 1;
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Status_TF setStringValue:@"请检查治具电源"];
                    });
                }
                
                //开始测试时，气缸弹出来
                while (YES) {
                    
                    [NSThread sleepForTimeInterval:0.2];
                    [serialport WriteLine:@"reset"];
                    [NSThread sleepForTimeInterval:0.5];
                    NSString * backstring = [serialport ReadExisting];
                    
                    if ([backstring containsString:@"OK"]) {
                        
                        break;
                    }
                    
                }
            }
            else
            {
                NSLog(@"控制板打开失败");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"Controller Board connect fail"];
                });
                [self UpdateTextView:@"index = 0,控制板打开失败" andClear:NO andTextView:Log_View];
            }
        }
#pragma mark index=1,初始化温湿度板子
        if (index == 1) {
            
                      
            if (param.isDebug)
            {
                NSLog(@"index = 1,debug 模式中");
                [self UpdateTextView:@"index = 1,debug 模式中,模拟温湿度板子初始化" andClear:NO andTextView:Log_View];
                index = 2;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index = 0,Debug:温湿度初始化"];
                });

            }
            else if (!humiturePort.IsOpen)
            {
                 BOOL  isOpen = [humiturePort Open:param.humiture_uart_port_name]||[humiturePort Open:param.humiture_uart_port_name_two];
                
                 if (isOpen) {
                     
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Status_TF setStringValue:@"index=1,Humiture connect success"];
                    });
                    [self UpdateTextView:@"index=1:温湿度连接成功" andClear:NO andTextView:Log_View];
                     
                     
                    //获取温湿度的值
                    [NSThread sleepForTimeInterval:0.5];
                    [humiturePort WriteLine:@"Read"];
                    [NSThread sleepForTimeInterval:0.5];
                    NSString  * back_humitureStr = [[humiturePort ReadExisting] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    back_humitureStr= [back_humitureStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                    
                     //显示温湿度
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [humiture_TF setStringValue:back_humitureStr];
                    });
                     
                     if ([back_humitureStr containsString:@","])
                     {
                         
                         NSArray  * arr = [back_humitureStr componentsSeparatedByString:@","];
                
                         //存储温湿度
                         [config_Dic setValue:[arr[1] stringByReplacingOccurrencesOfString:@"%" withString:@""] forKey:kHumit];
                         [config_Dic setValue:arr[0] forKey:kTemp];
                         [self UpdateTextView:@"index = 1,温湿度连接成功" andClear:NO andTextView:Log_View];
                         index = 2;
                     }


                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Status_TF setStringValue:@"index=1,Humiture connect Fail"];
                    });
                }
            }
            else
            {
                NSLog(@"温湿度打开成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=1,Humiture connect success"];
                });
                
                //获取温湿度的值
                [NSThread sleepForTimeInterval:0.5];
                [humiturePort WriteLine:@"Read"];
                [NSThread sleepForTimeInterval:0.5];
                NSString  * back_humitureStr = [humiturePort ReadExisting];
                
                //显示温湿度
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [humiture_TF setStringValue:back_humitureStr];
                });
                
                if ([back_humitureStr containsString:@","])
                {
                    
                    NSArray  * arr = [back_humitureStr componentsSeparatedByString:@","];
                    
                
                    //存储温湿度
                    [config_Dic setValue:arr[0] forKey:kTemp];
                    [config_Dic setValue:[arr[1] stringByReplacingOccurrencesOfString:@"%" withString:@""] forKey:kHumit];
                    
                     index = 2;
                
                }
                
            
            }
        }
#pragma mark index = 2,请选择测试项
        if (index == 2){
              index = 3;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [Status_TF setStringValue:@"index = 3,开始检测SN"];
            });
        }
#pragma mark index = 3,检测SN1的输入值
        if (index == 3) {
            
            [NSThread sleepForTimeInterval:0.5];
            sfcManager.station_id = fixtureID;
            testnum = 0;
            
            if (param.isDebug&&singleTest) {
                
                if (choose_dut1.state) {
                    
                    [self ShowcompareNumwithTextField:NS_TF1 Index:3 SnIndex:1];
                    //action1.dut_sn = NS_TF1.stringValue;
                    action1.isTest = YES;
                }
                else
                {
                    index = 4;
                    action1.isTest = NO;
                }
                
            }
            else if (param.isDebug){
                
                if ([NS_TF1.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
                    //action1.dut_sn = [NS_TF1 stringValue];
                    index = 4;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [Status_TF setStringValue:@"index = 3,SN1 is OK"];
                    });
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index = 3,SN1 is Wrong"];
                    
                });
            }
            else if (singleTest){
                if (choose_dut1.state) {
                    
                    if (isUpLoadSFC)
                    {
                        [self compareSNToServerwithTextField:NS_TF1 Index:3 SnIndex:1];
                    }
                    else
                    {
                        [self ShowcompareNumwithTextField:NS_TF1 Index:3 SnIndex:1];
                    }
                   // action1.dut_sn = NS_TF1.stringValue;
                    action1.isTest = YES;
                }
                else
                {
                    index = 4;
                    action1.isTest = NO;
                }
            }
            else{
                
                if (isUpLoadSFC) {
                    [self compareSNToServerwithTextField:NS_TF1 Index:3 SnIndex:1];
                }
                else
                {
                    [self ShowcompareNumwithTextField:NS_TF1 Index:3 SnIndex:1];
                }
                
                //action1.dut_sn = NS_TF1.stringValue;
                action1.isTest = YES;
            }
            
            //读取下串口数据
            [serialport ReadExisting];
            
        }
#pragma mark index = 4,检测SN2的输入值
        if (index == 4) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            if (param.isDebug&&singleTest) {
                
                if (choose_dut2.state)
                {
                    [self ShowcompareNumwithTextField:NS_TF2 Index:4 SnIndex:2];
                   // action2.dut_sn = NS_TF2.stringValue;
                    action2.isTest = YES;
                }
                else
                {
                    index = 5;
                    action2.isTest = NO;
                }
            }
            else if (param.isDebug) {
                
                if ([NS_TF2.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
                    //action2.dut_sn = [NS_TF2 stringValue];
                    index = 5;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [Status_TF setStringValue:@"index = 4,SN2 is OK"];
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index = 4,SN2 is Wrong"];
                });
            }
            else if (singleTest) {
                
                if (choose_dut2.state)
                {
                    
                    if (isUpLoadSFC) {
                         [self compareSNToServerwithTextField:NS_TF2 Index:4 SnIndex:2];
                    }
                    else
                    {
                         [self ShowcompareNumwithTextField:NS_TF2 Index:4 SnIndex:2];
                    }
                   
                   // action2.dut_sn = NS_TF2.stringValue;
                    action2.isTest = YES;
                }
                else
                {
                    index = 5;
                    action2.isTest = NO;
                }
            }
            else
            {
                if (isUpLoadSFC) {
                    
                     [self compareSNToServerwithTextField:NS_TF2 Index:4 SnIndex:2];
                }
                else
                {
                      [self ShowcompareNumwithTextField:NS_TF2 Index:4 SnIndex:2];
                    
                }
                
                //action2.dut_sn = NS_TF2.stringValue;
                action2.isTest = YES;
            }
            //读取下串口数据
            [serialport ReadExisting];
            
        }
#pragma mark index = 5,检测SN3的输入值
        if (index == 5) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            if (param.isDebug&&singleTest) {
                
                if (choose_dut3.state) {
                    [self ShowcompareNumwithTextField:NS_TF3 Index:5 SnIndex:3];
                    //action3.dut_sn = NS_TF3.stringValue;
                    action3.isTest = YES;
                }
                else
                {
                    index = 6;
                    action3.isTest = NO;
                }
            }
           else if (param.isDebug) {
                
                if ([NS_TF3.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
                    //action3.dut_sn = [NS_TF3 stringValue];
                    index = 6;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [Status_TF setStringValue:@"index = 5,SN3 is OK"];
                    });
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index = 5,SN3 is wrong"];
                });
            }
            else if (singleTest)
            {
                if (choose_dut3.state) {
                    
                    if (isUpLoadSFC) {
                        
                      [self compareSNToServerwithTextField:NS_TF3 Index:5 SnIndex:3];
                    }
                    else
                    {
                      [self ShowcompareNumwithTextField:NS_TF3 Index:5 SnIndex:3];
                    }
                    
                    //action3.dut_sn = NS_TF3.stringValue;
                    action3.isTest = YES;
                }
                else
                {
                    index = 6;
                    action3.isTest = NO;
                }
            }
            else
            {
                
                if (isUpLoadSFC) {
                    
                    [self compareSNToServerwithTextField:NS_TF3 Index:5 SnIndex:3];
                }
                else
                {
                    [self ShowcompareNumwithTextField:NS_TF3 Index:5 SnIndex:3];
                }
                
                
                //action3.dut_sn = NS_TF3.stringValue;
                action3.isTest = YES;
            }
            //读取下串口数据
            [serialport ReadExisting];
            
        }
#pragma mark index = 6,检测SN4的输入值
        if (index == 6) {
            
            [NSThread sleepForTimeInterval:0.5];
           
            if (param.isDebug&&singleTest) {
                
                if (choose_dut4.state) {
                    [self ShowcompareNumwithTextField:NS_TF4 Index:6 SnIndex:4];
                    //action4.dut_sn = NS_TF4.stringValue;
                    action4.isTest = YES;
                }
                else
                {
                    index = 7;
                    action4.isTest = NO;
                }
                
            }
           else if (param.isDebug)
            {
                
                if ([NS_TF4.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
                    //action4.dut_sn = [NS_TF4 stringValue];
                    index = 7;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [Status_TF setStringValue:@"index = 6,SN4 is OK"];
                    });
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index = 6,SN4 is Wrong"];
                });
            }
            else if (singleTest) {
                
                if (choose_dut4.state) {
                    
                    if (isUpLoadSFC) {
                        
                        [self compareSNToServerwithTextField:NS_TF4 Index:6 SnIndex:4];
                    }
                    else
                    {
                         [self ShowcompareNumwithTextField:NS_TF4 Index:6 SnIndex:4];
                    }
                    //action4.dut_sn = NS_TF4.stringValue;
                    action4.isTest = YES;
                }
                else
                {
                    index = 7;
                    action4.isTest = NO;
                }
            }
            else
            {
                if (isUpLoadSFC) {
                     [self compareSNToServerwithTextField:NS_TF4 Index:6 SnIndex:4];
                }
                else
                {
                    [self ShowcompareNumwithTextField:NS_TF4 Index:6 SnIndex:4];
                }
                
                 //action4.dut_sn = NS_TF4.stringValue;
                 action4.isTest = YES;
            }
            
            //读取下串口数据
            [serialport ReadExisting];
            
            
        }
#pragma mark index=7,判断当前配置文件和changeID等配置
        if (index == 7) { //判断当前配置文件和changeID等配置
            
            [NSThread sleepForTimeInterval:0.3];
            [self saveConfigStation];

            if (config_change.state) {
                
                NSLog(@"Please cancell Config Button");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=7,Cancell Change Button"];
                });
            }
            
            
            if (!config_change.state) {
                
                //配置好了，将相关参数传送
                if (action1!=nil) {
                    action1.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
                    action1.Config_pro = product_Config.stringValue;
                    action1.NestID     = NestID_Change.titleOfSelectedItem;
                }
                if (action2!=nil) {
                    action2.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
                    action2.Config_pro = product_Config.stringValue;
                    action2.NestID     = NestID_Change.titleOfSelectedItem;
                }
                if (action3!=nil) {
                    action3.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
                    action3.Config_pro = product_Config.stringValue;
                    action3.NestID     = NestID_Change.titleOfSelectedItem;
                }
                if (action4!=nil) {
                    action4.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
                    action4.Config_pro = product_Config.stringValue;
                    action4.NestID     = NestID_Change.titleOfSelectedItem;
                }
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [tab1 ClearTable];
                    
                    [DUT_Result1_TF setStringValue:@""];
                    [DUT_Result2_TF setStringValue:@""];
                    [DUT_Result3_TF setStringValue:@""];
                    [DUT_Result4_TF setStringValue:@""];
                     startbutton.enabled = YES;
                    [Status_TF setStringValue:@"Index = 8,Click Start Button"];
                    
                });
                [self UpdateTextView:@"index=7,参数已经配置好" andClear:NO andTextView:Log_View];
                index = 1000;
            }
        }
#pragma mark index=8,双击start按钮/或者点击界面上的start按钮
        if (index == 8) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            if (!startbutton.enabled)
            {
                [serialport WriteLine:@"start"];
            }
            
             [NSThread sleepForTimeInterval:0.5];
              NSString  * backstring = [serialport ReadExisting];
            
            if (param.isDebug) {
                NSLog(@"index = 8,debug 模式中");
                [self UpdateTextView:@"index = 8,debug 模式中,监测双击启动" andClear:NO andTextView:Log_View];
                index = 9;
            }
            else if ([[backstring uppercaseString] containsString:@"START"]&&[backstring containsString:@"*_*\r\n"])
            {
                NSLog(@"检测START，软件开始测试");
                [self UpdateTextView:@"index = 8,检测到Start" andClear:NO andTextView:Log_View];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index=8,Start OK"];
                    
                });
                
                [self UpdateTextView:@"index=8,Start OK" andClear:NO andTextView:Log_View];
                
                index = 9;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=8,Start NG,请启动"];
                });
                
                [self UpdateTextView:@"Start NG,请启动" andClear:NO andTextView:Log_View];
            }
        }
 #pragma mark index=9,发送开始测试的通知
        if (index == 9){
            
            //给SN赋值
            action1.dut_sn = NS_TF1.stringValue;
            action2.dut_sn = NS_TF2.stringValue;
            action3.dut_sn = NS_TF3.stringValue;
            action4.dut_sn = NS_TF4.stringValue;
            

            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSThreadStart_Notification" object:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                startbutton.enabled = NO;
                ReloadButton.hidden = YES;
            
            });
            
            [testFieldTimes setStringValue:@"0"];
            [mkTimer setTimer:0.1];
            [mkTimer startTimerWithTextField:testFieldTimes];
            ct_cnt = 1;
            [self UpdateTextView:@"index = 9,程序开始测试" andClear:NO andTextView:Log_View];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:@"index=10, Testing......"];
            });
            index = 1000;
    
        }
#pragma mark index=101,A治具测试结束，发送指令信号灯
        if (fix_A_num == 101) {
            
            [NSThread sleepForTimeInterval:0.3];
            
            testingFixStr = @"ASN1";
            
            if (param.isDebug)
            {
                
                NSLog(@"治具A测试完毕，灯光操作完成");
                [self UpdateTextView:@"fix_A_num = 101,治具A灯光操作已经完成" andClear:NO andTextView:Log_View];
                testnum++;
                fix_A_num =0;
                
                if ([notiString_A containsString:@"P"]) {
                    passNum++;
                }
                if (testnum==[ChooseNumArray count]||testnum== 4) {
                    
                    index = 105;
                    NSLog(@"A====%d",testnum);
                }
                
                
                //上传PDCA
                if (![notiString_A containsString:@"X"]&&isUpLoadPDCA==YES) {
                    
                    [pdca UploadPDCA_Dafen:1 Dic:A_resultDic Arr:itemArr1 BOOL:[notiString_A containsString:@"P"]?YES:NO];
                }

            }
            else
            {
                
                //上传PDCA
                if (![notiString_A containsString:@"X"]&&isUpLoadPDCA==YES) {
                    
                    [pdca UploadPDCA_Dafen:1 Dic:A_resultDic Arr:itemArr1 BOOL:[notiString_A containsString:@"P"]?YES:NO];
                }

                [self LightAndShowResultWithFix:notiString_A TestingFixStr:testingFixStr Dictionary:A_resultDic];
            }
            
        }
#pragma mark index=102,B治具测试结束，发送指令信号灯
        if (fix_B_num == 102) {
            
            [NSThread sleepForTimeInterval:0.3];
            testingFixStr = @"BSN2";
            
            if (param.isDebug) {
                
                 NSLog(@"治具B测试完毕，灯光操作完成");
                [self UpdateTextView:@"fix_B_num = 102,治具B灯光操作已经完成" andClear:NO andTextView:Log_View];
                testnum++;
                fix_B_num =0;
                
                if ([notiString_B containsString:@"P"]) {
                    
                    passNum++;
                }
                
                if (testnum==[ChooseNumArray count]||testnum== 4) {
                    index = 105;
                    NSLog(@"B====%d",testnum);
                }
            }
            else
            {
                
                //上传PDCA
                if (![notiString_B containsString:@"X"]&&isUpLoadPDCA==YES) {
                   
                    NSLog(@"B_resultDic：上传PDCA的时间");
                   [pdca UploadPDCA_Dafen:2 Dic:B_resultDic Arr:itemArr1 BOOL:[notiString_B containsString:@"P"]?YES:NO];
                }
                
                [self LightAndShowResultWithFix:notiString_B TestingFixStr:testingFixStr Dictionary:B_resultDic];
            }
            
           
            
        }
#pragma mark index=103,C治具测试结束，发送指令信号灯
        if (fix_C_num == 103) {
            
            [NSThread sleepForTimeInterval:0.3];
            testingFixStr = @"CSN3";
            
            if (param.isDebug) {
                
                NSLog(@"治具C测试完毕，灯光操作完成");
                [self UpdateTextView:@"fix_C_num = 103,治具C灯光操作已经完成" andClear:NO andTextView:Log_View];
                testnum++;
                fix_C_num=0;
                if ([notiString_C containsString:@"P"]) {
                    
                    passNum++;
                }
                
                if (testnum==[ChooseNumArray count]||testnum== 4) {
                    index = 105;
                    NSLog(@"C====%d",testnum);
                }
            }
            else
            {
                //上传PDCA
                if (![notiString_C containsString:@"X"]&&isUpLoadPDCA==YES) {
                
                    [pdca UploadPDCA_Dafen:3 Dic:C_resultDic Arr:itemArr1 BOOL:[notiString_C containsString:@"P"]?YES:NO];
                }
                
                [self LightAndShowResultWithFix:notiString_C TestingFixStr:testingFixStr Dictionary:C_resultDic];
            }
        }
#pragma mark  index=104,C治具测试结束，发送指令信号灯
        if (fix_D_num == 104) { //扫描SN
            
            [NSThread sleepForTimeInterval:0.3];
            testingFixStr = @"DSN4";
            
            if (param.isDebug) {
                NSLog(@"治具D测试完毕，灯光操作完成");
                [self UpdateTextView:@"fix_D_num = 104,治具D灯光操作已经完成" andClear:NO andTextView:Log_View];
                testnum++;
                fix_D_num=0;
                if (testnum==[ChooseNumArray count]||testnum== 4) {
                    index = 105;
                    NSLog(@"C====%d",testnum);
                }
            }
            else
            {
                //上传PDCA
                if (![notiString_D containsString:@"X"]&&isUpLoadPDCA==YES) {
                    
                    [pdca UploadPDCA_Dafen:4 Dic:D_resultDic Arr:itemArr1 BOOL:[notiString_D containsString:@"P"]?YES:NO];
                }
                
                [self LightAndShowResultWithFix:notiString_D TestingFixStr:testingFixStr Dictionary:D_resultDic];
                
            }
            
        }
#pragma mark index=105,所有测试结束
        if (index == 105) {
            
            [NSThread sleepForTimeInterval:0.5];
            if (param.isDebug) {
                NSLog(@"整个测试已经结束，回到初始状态");
            }
            else
            {
                //发送reset的命令
                [serialport WriteLine:@"reset"];
                [NSThread sleepForTimeInterval:0.5];
                
                if ([[serialport ReadExisting] containsString:@"OK"]) {
                    
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [Status_TF setStringValue:@"治具复位OK"];
                     });
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [TestCount_TF setStringValue:[NSString stringWithFormat:@"%d/%d",passNum,totalNum]];
                startbutton.enabled = NO;
                ComfirmButton.enabled = YES;
                
                //清空所有NStextView的值
                [self UpdateTextView:@"" andClear:YES andTextView:Log_View];
                [self UpdateTextView:@"" andClear:YES andTextView:A_LOG_TF];
                [self UpdateTextView:@"" andClear:YES andTextView:B_LOG_TF];
                [self UpdateTextView:@"" andClear:YES andTextView:C_LOG_TF];
                [self UpdateTextView:@"" andClear:YES andTextView:D_LOG_TF];
                
                if (!isLoopTest) {
                    //清空SN
                    NS_TF1.stringValue = @"";
                    NS_TF2.stringValue = @"";
                    NS_TF3.stringValue = @"";
                    NS_TF4.stringValue = @"";
                }
                
                
                NSTextField *TF = [self.view viewWithTag:1];
                [TF becomeFirstResponder];
                //========定时器结束========
                [mkTimer endTimer];
                 ct_cnt = 0;
                
            });
            
            //判断当前温湿度的绝对值是否超过%3
            float temp_value = fabsf([[[NSUserDefaults standardUserDefaults] objectForKey:kTemp] floatValue]-[[config_Dic objectForKey:kTemp] floatValue]);
            float humit_value =fabsf([[[NSUserDefaults standardUserDefaults] objectForKey:kHumit] floatValue]-[[config_Dic objectForKey:kHumit] floatValue]);
            
            if (nulltest_button.hidden&&(temp_value>20||humit_value>20||action1.isShow||action2.isShow||action3.isShow||action4.isShow)) {
                //释放各种串口，端口
                if (action1!=nil)[action1 threadEnd];
                if (action2!=nil)[action2 threadEnd];
                if (action3!=nil)[action3 threadEnd];
                if (action4!=nil)[action4 threadEnd];
                [alert ShowCancelAlert:@"注意:温湿度变化过大，请重新空测" Window:[NSApplication sharedApplication].keyWindow];
            }
            
            if (isLoopTest)
            {
                
                index = 7;
            }
            else
            {
                index = 1;
            }
        }
#pragma mark index=1000,测试结束
        if (index == 1000) { //等待测试结束，并返回测试的结果
            [NSThread sleepForTimeInterval:0.001];
        }
    }
    
    
}


#pragma mark 测试模式:空测，单测，循环
-(void)selectTestModeNotice:(NSNotification *)noti
{
        //空测
        if ([noti.object isEqualToString:@"NullTest"])
        {
            
            nulltest_button.hidden = NO;
            itemArr1 = [plist PlistRead:@"Station_Cr_3_Humid" Key:@"AllItems"];
            tab1 = [tab1 init:Tab1_View DisplayData:itemArr1];
            
            //PDCA默认为不上传
            IsUploadPDCA_Button.state = NO;
            isUpLoadPDCA = NO;
            [action1 setCsvTitle:plist.titile];
            [action2 setCsvTitle:plist.titile];
            [action3 setCsvTitle:plist.titile];
            [action4 setCsvTitle:plist.titile];
        }
        //循环
        else if ([noti.object isEqualToString:@"LoopTest"])
        {
            isLoopTest = YES;
            itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid" Key:@"AllItems"];
            tab1 = [tab1 init:Tab1_View DisplayData:itemArr1];

            
        }
        //正常
        else if ([noti.object isEqualToString:@"NormalTest"])
        {
            isLoopTest = NO;
            if (nulltest_button.hidden) {
                
                itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid" Key:@"AllItems"];
                tab1 = [tab1 init:Tab1_View DisplayData:itemArr1];
            }
        }
        //其它
        else{
            NSLog(@"其它测试模式");
            itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid" Key:@"AllItems"];
            tab1 = [tab1 init:Tab1_View DisplayData:itemArr1];

        }
        
    
        //创建个线程
        if (action1==nil) {
            [self createThreadWithNum:1];
        }
        if (action2==nil) {
            [self createThreadWithNum:2];
        }
        if (action3==nil) {
            [self createThreadWithNum:3];
        }
        if (action4==nil) {
            [self createThreadWithNum:4];
        }

}

#pragma mark 监听SFC和PDCA的上传状态
-(void)selectSfc_PDCAUpload:(NSNotification *) noti
{
    if ([noti.name isEqualToString:kPdcaUploadNotice]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IsUploadPDCA_Button.state = YES;
                
                isUpLoadPDCA = YES;
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IsUploadPDCA_Button.state = NO;
                
                isUpLoadPDCA = NO;
               
            });
        }
    }
    
    if ([noti.name isEqualToString:kSfcUploadNotice]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IsUploadSFC_Button.state = YES;
                
                isUpLoadSFC = YES;
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IsUploadSFC_Button.state = NO;
                
                isUpLoadSFC = NO;
            });
        }
        
    }
}





#pragma mark 空测试结束，退出软件
-(void)selectFinshNullTest
{
    //将当前温湿度的数值存储在本地
    [[NSUserDefaults standardUserDefaults] setValue:[config_Dic objectForKey:kHumit] forKey:kHumit];
    [[NSUserDefaults standardUserDefaults] setValue:[config_Dic objectForKey:kTemp]  forKey:kTemp];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(!(action1.isShow||action2.isShow||action3.isShow||action3.isShow))
    {
        nullNum++;
        
        if (nullNum == 4) {
            
            exit(0);
        }
    }
    
}


#pragma mark 刷新界面数据
-(void)selectDifferNullTest
{
    passNum = 0;
    totalNum = 0;
    nullNum  = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        
         [TestCount_TF setStringValue:@"0/0"];
    });
}



//将空测试出来的值写到plist文件中去
- (IBAction)NullTestDone_Button:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"WriteNullValue" object:nil];
}


#pragma mark 确认选项
- (IBAction)makesureDut:(id)sender {

    singlebutton.state = NO;
    singleTest = YES;
    isComfirmOK  = YES;
    
    //makesure之后不可点击
    choose_dut1.enabled = NO;
    choose_dut2.enabled = NO;
    choose_dut3.enabled = NO;
    choose_dut4.enabled = NO;
    ComfirmButton.hidden = YES;
    
    [ChooseNumArray removeAllObjects];

    if (singleTest) {

       index = 3;
        
    }
    
   

    if (choose_dut1.state) {
        
        [self createThreadWithNum:1];
        
        [ChooseNumArray addObject:@"Test"];

    }
//    else //销毁线程
//    {
//        if (action1 !=nil) {
//            [action1 threadEnd];
//            action1 = nil;
//        }
//        
//    }
    
    if (choose_dut2.state) {
        
        [self createThreadWithNum:2];
        
        [ChooseNumArray addObject:@"Test"];
    }
//    else
//    {
//        if (action2 !=nil) {
//            
//            [action2 threadEnd];
//            action2 = nil;
//            
//        }
//    }
    if (choose_dut3.state) {
        
        [self createThreadWithNum:3];
        
        [ChooseNumArray addObject:@"Test"];
    }
//    else
//    {
//        if (action3 !=nil) {
//            
//            [action3 threadEnd];
//            action3 = nil;
//        }
//    }

    if (choose_dut4.state) {
        
        [self createThreadWithNum:4];
        
        [ChooseNumArray addObject:@"Test"];
    }
//    else
//    {
//        if (action4 !=nil) {
//            
//            [action4 threadEnd];
//            action4 = nil;
//        }
//
//    
//    }
}


#pragma mark 选择测试项
- (IBAction)single_test:(id)sender {
    
    if (singlebutton.state) {
        
        ComfirmButton.hidden = NO;
        choose_dut1.enabled = YES;
        choose_dut2.enabled = YES;
        choose_dut3.enabled = YES;
        choose_dut4.enabled = YES;
    
    }
    else
    {
        choose_dut1.enabled  = NO;
        choose_dut2.enabled  = NO;
        choose_dut3.enabled  = NO;
        choose_dut4.enabled  = NO;
        ComfirmButton.hidden = YES;
    
    
    }
    
}





#pragma mark 控制光标 成为第一响应者

-(void)controlTextDidChange:(NSNotification *)obj{
    
    NSTextField *tf = (NSTextField *)obj.object;
    
    if (tf.tag == 4) {
        
        [tf setEditable:YES];
    }
    
    if (tf.stringValue.length == [num_PopButton.titleOfSelectedItem intValue]) {
        
        NSTextField *nextTF;
        if (tf.tag == 4) {
            
           nextTF = [self.view viewWithTag:tf.tag-3];
        }
        else
        {
            nextTF = [self.view viewWithTag:tf.tag+1];
        }
       
    
        if (nextTF) {
            
            
            if (nextTF.tag == 4) {
                
                [nextTF setEditable:YES];
                
            }
            [tf resignFirstResponder];
            [nextTF becomeFirstResponder];
            
        }
    }
}






//更新upodateView
-(void)UpdateTextView:(NSString*)strMsg andClear:(BOOL)flagClearContent andTextView:(NSTextView *)textView
{
    if (flagClearContent)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [textView setString:@""];
                       });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           if ([[textView string]length]>0)
                           {
                               NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               NSRange range = NSMakeRange([textView.textStorage.string length] , messageString.length);
                               [textView insertText:messageString replacementRange:range];
                               
                           }
                           else
                           {
                                NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               [textView setString:[NSString stringWithFormat:@"%@\n",messageString]];
                           }
                           
                               [textView setTextColor:[NSColor redColor]];
                           
                       });
    }
}


#pragma mark 生成线程
-(void)createThreadWithNum:(int)num
{
    
    if (num == 1 && action1 == nil) {
        action1  = [[TestAction alloc] initWithTable:tab1 withFixParam:param withType:num];
        action1.resultTF  = DUT_Result1_TF;//显示结果的lable
        action1.Log_View  = A_LOG_TF;
        action1.Fail_View = A_FailItem;
        action1.dutTF     = NS_TF1;
       [action1 setCsvTitle:plist.titile];
        
    }
    
    if (num == 2 && action2 == nil) {
        action2  = [[TestAction alloc] initWithTable:tab1 withFixParam:param withType:num];
        action2.resultTF  = DUT_Result2_TF;//显示结果的lable
        action2.Log_View  = B_LOG_TF;
        action2.Fail_View =B_FailItem;
        action2.dutTF     = NS_TF2;
        [action2 setCsvTitle:plist.titile];
    }
    
    if (num == 3 && action3 == nil) {
        action3 = [[TestAction alloc]initWithTable:tab1 withFixParam:param withType:num];
        action3.resultTF   = DUT_Result3_TF;//显示结果的lable
        action3.Log_View   = C_LOG_TF;
        action3.Fail_View  = C_FailItem;
        action3.dutTF      = NS_TF3;
        [action3 setCsvTitle:plist.titile];
        
    }
    
    if (num ==4 && action4 == nil){
        action4 = [[TestAction alloc] initWithTable:tab1 withFixParam:param withType:num];
        action4.resultTF  = DUT_Result4_TF;//显示结果的lable
        action4.Log_View  = D_LOG_TF;
        action4.Fail_View = D_FailItem;
        action4.dutTF     = NS_TF4;
        [action4 setCsvTitle:plist.titile];
    }
    
}


#pragma mark 释放仪器仪表
-(void)viewWillDisappear
{

    if (action1 != nil) {
        
        [action1 threadEnd];
         action1 = nil;
    }
    if (action2 != nil) {
        
        [action2 threadEnd];
         action2 = nil;
    }
    if (action3 != nil) {
        
        [action3 threadEnd];
        action3 = nil;
    }
    if (action4 != nil) {
        
        [action4 threadEnd];
         action4 = nil;
    }
    
    [serialport Close];
    [humiturePort Close];



}


#pragma mark 正常测试时，数据校验
-(void)compareSNToServerwithTextField:(NSTextField *)tf Index:(int)testIndex SnIndex:(int)snIndex
{
   
    if ([tf.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d Enter OK",testIndex,snIndex]];
        });
        
        NSString  * startTime = [[GetTimeDay shareInstance] getCurrentDayTime];
        testStep.strSN  = tf.stringValue;
        
        if ([testStep StepSFC_CheckUploadSN:YES Option:@"isPassOrNot" testResult:nil startTime:startTime testArgument:nil])
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [Status_TF setStringValue:[NSString stringWithFormat:@"SN%d 检验OK",snIndex]];
                
            });
            
            index = testIndex+1;;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [tf  setStringValue:@"上一个工站检测NG"];
                
            });
        }
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
     
            [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d NG,Enter right SN",testIndex,snIndex]];
        });
    }
}


#pragma mark 正常测试时，无SFC请求时
-(void)ShowcompareNumwithTextField:(NSTextField *)tf Index:(int)testIndex SnIndex:(int)snIndex
{
    
    if ([tf.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d Enter OK",testIndex,snIndex]];
        });
        
        index = testIndex+1;;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d NG,Enter right SN",testIndex,snIndex]];
        });
    
    }
}


#pragma mark 点亮指示灯，并显示测试的结果
-(void)LightAndShowResultWithFix:(NSString *)notiString TestingFixStr:(NSString *)testingFix Dictionary:(NSDictionary *)resultDic
{
    
    NSString  * SnString = [testingFix substringFromIndex:1];
    
    if (isUpLoadSFC) {
        
        NSString* startTime = [[GetTimeDay shareInstance] getCurrentDayTime];
        
        if ([testStep StepSFC_CheckUploadSN:YES Option:@"uploadLog" testResult:[notiString containsString:@"P"]?@"Pass":@"Fail" startTime:startTime testArgument:[resultDic objectForKey:@"dic"]])
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [Status_TF setStringValue:[NSString stringWithFormat:@"%@ SFC upload success",SnString]];
            });
            
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 [Status_TF setStringValue:[NSString stringWithFormat:@"%@ SFC upload fail",SnString]];
            });
        }
    }
    
    
    NSString  * string = [testingFix substringToIndex:1];
    
    
    //发送指示灯
    if ([notiString containsString:@"P"]) {
        
        passNum++;
        
        [serialport WriteLine:[NSString stringWithFormat:@"FIX_%@ pass",string]];
        
        [NSThread sleepForTimeInterval:0.5];
        
        if ([[serialport ReadExisting] containsString:@"OK"]) {
            
             NSLog(@"FIX_%@，亮绿灯",string);
            [self UpdateTextView:[NSString stringWithFormat:@"%@治具测试OK，绿灯亮",string] andClear:NO andTextView:Log_View];
        }

    }
    else
    {
        
         [serialport WriteLine:[NSString stringWithFormat:@"FIX_%@ fail",string]];
        
         [NSThread sleepForTimeInterval:0.5];
        
        if ([[serialport ReadExisting] containsString:@"OK"]) {
            
            NSLog(@"FIX_%@,亮红灯",string);
           [self UpdateTextView:[NSString stringWithFormat:@"%@治具测试NG，红灯亮",string] andClear:NO andTextView:Log_View];
        }
    }
    
    
    if ([string containsString:@"A"])fix_A_num=0;
    if ([string containsString:@"B"])fix_B_num=0;
    if ([string containsString:@"C"])fix_C_num=0;
    if ([string containsString:@"D"])fix_D_num=0;
    testnum++;
//    if (testnum==[ChooseNumArray count]||testnum== 4) {
//        
//        index = 105;
//        
//        NSLog(@"%@====%d",string,testnum);
//    }
    
    if (testnum== 4) {
        
        index = 105;
        
        NSLog(@"%@====%d",string,testnum);
    }

    
}



-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
