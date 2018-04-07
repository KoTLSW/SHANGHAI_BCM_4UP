//
//  TestAction.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "TestAction.h"



#define SNChangeNotice  @"SNChangeNotice"
NSString  *param_path=@"Param";

@interface TestAction ()
{
    
    //************ testItems ************
    double num;
    NSMutableArray  *txtLogMutableArr;
    NSString        *agilentReadString;
    NSDictionary    *dic;
    NSString        *SonTestName;
    NSString        *testResultStr;                           //测试结果
    NSMutableArray  *testResultArr;                           // 返回的结果数组
    NSMutableArray  *testItemTitleArr;                        //每个测试标题都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemValueArr;                        //每个测试结果都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemMinLimitArr;                     //每个测试项最小值数组
    NSMutableArray  *testItesmMaxLimitArr;                    //每个测试项最大值数组
    NSMutableArray  *testItemUnitArr;

    
    NSThread        * thread;                                   //开启的线程
    AgilentE4980A   * agilentE4980A;                            //LCR表
    AgilentB2987A   * agilentB2987A;                            //静电计
    SerialPort      * serialport;                               //串口通讯类
    UpdateItem      * updateItem;                               //
    Plist           * plist;                                    //plist文件处理类
    enum AgilentB2987ACommunicateType  AgilentB2987A_USB_Type;
    Param           * param;                                    // param参数类
    
    
    
    int        delayTime;
    int        index;                                         // 测试流程下标
    int        item_index;                                    // 测试项下标
    int        row_index;                                     // table 每一行下标
    Item     * testItem;                                      //测试项
    Item     * showItem;                                      //显示的测试项
    
    
    NSString * fixtureBackString;                             //治具返回来的数据
    NSString * testvalue;                                   //测试项的字符串
   
    
    AppDelegate  * app;                                       //存储测试的次数
    Folder       * fold;                                      //文件夹的类
    FileCSV      * csv_file;                                  //csv文件的类
    FileCSV      * total_file;                                //写csv总文件
    FileTXT      * txt_file;                                  //txt文件
    
    //************* timer *************
    NSString            * start_time;                         //启动测试的时间
    NSString            * end_time;                           //结束测试的时间
    GetTimeDay          * timeDay;                            //创建日期类
    
    //csv数据相关处理
    NSMutableArray * ItemArr;                                 //存测试对象的数组
    NSMutableArray * TestValueArr;                            //存储测试结果的数组
    //NSMutableString     * contentString;                    //测试项的vaule值
    NSMutableString     * txtContentString;                   //打印txt文件中的log
    NSMutableString     * listFailItemString;                 //测试失败的项目
    NSMutableString     * ErrorMessageString;                 //失败测试项的原因
    
    //检测PDCA和SFC的BOOL//测试结果PASS、FAIL
    BOOL      isPDCA;
    BOOL      isSFC;
    PDCA    *  pdca;
    BOOL       PF;
    
    //存储生成文件的具体地址
    NSString   * eachCsvDir;
    NSString   * singleFloder;
    int          fix_type;
    
    //所有的测试项均存入字典中
    NSMutableDictionary  * store_Dic;                          //所有的测试项存入字典中

    BOOL    nulltest;                                          //产品进行空测试
    float   nullTimes;                                         //空测试的次数
    double  B_E_Sum;                                           //产品测试nullTimes的总和
    double  B2_E2_Sum;                                         //产品测试B2_E2
    double  B4_E4_Sum;                                         //产品测试B4_E4
    double  ABC_DEF_Sum;                                       //产品测试ABC_DEF
    double  Cap_Sum;                                           //治具的容抗值
    
    //处理SFC相关的类
    BYDSFCManager          * sfcManager;                         //处理sfc的类
    TestStep               * teststep;                           //处理上传的方法
    NSString               * FixtureID;                          //治具的ID
    
    BOOL                   is_LRC_Collect;                       //LCR表是否连接
    BOOL                   is_JDY_Collect;                       //静电仪是否连接
    NSMutableString               * dcrAppendString;             //DCR拼接的数据
    BOOL                   addDcr;                               //40组DCR数据
   
    
}
@end

@implementation TestAction

/**相关的说明
  1.Fixture ID 返回的值    Fixture ID?\r\nEW011X*_*\r\n       其中x代表治具中A,B,C,D

 
 
*/





-(id)initWithTable:(Table *)tab withFixDic:(NSDictionary *)fix withFileDir:foldDir withType:(int)type_num
{
    if (self =[super init]) {
        
        self.tab =tab;
        fix_type = type_num;
        
        index = 0;
        item_index   = 0;
        row_index    = 0;
        nullTimes    = 0;
        B_E_Sum      = 0;
        B2_E2_Sum    = 0;
        B4_E4_Sum    = 0;
        ABC_DEF_Sum  = 0;
        Cap_Sum      = 0;
        
        PF =  YES;
        addDcr = NO;
        
        //初始化各类数组和可变字符串
        ItemArr         = [[NSMutableArray alloc]initWithCapacity:10];
        TestValueArr    = [[NSMutableArray alloc] initWithCapacity:10];
        txtContentString=[[NSMutableString alloc]initWithCapacity:10];
        listFailItemString=[[NSMutableString alloc]initWithCapacity:10];
        ErrorMessageString=[[NSMutableString alloc]initWithCapacity:10];
        dcrAppendString = [[NSMutableString alloc] initWithCapacity:10];
        store_Dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        
        
        param = [[Param alloc]init];
       [param ParamRead:param_path];
        plist = [Plist shareInstance];
        
        //初始化各种串口
        timeDay     =  [GetTimeDay shareInstance];
        pdca        =  [[PDCA alloc]init];
        sfcManager  =  [BYDSFCManager Instance];
        serialport  =  [[SerialPort alloc]init];
        updateItem  =  [[UpdateItem alloc] init];
        
        agilentE4980A = [[AgilentE4980A alloc]init];
        agilentB2987A = [[AgilentB2987A alloc]init];
        
        [serialport setTimeout:1 WriteTimeout:1];
        
        //初始化文件的类
        csv_file  = [[FileCSV alloc] init];
        //csv_file  = [FileCSV shareInstance];
        [csv_file addGlobalLock];
        txt_file  = [[FileTXT  alloc]init];
        total_file= [[FileCSV alloc] init];
        [total_file addGlobalLock];
        fold     =  [[Folder  alloc] init];
        
         teststep = [TestStep Instance];
        [teststep addGlobalLock];
        
        
        //初始化各种数据及其设备消息
        self.fixture_uart_port_name = [fix objectForKey:@"fixture_uart_port_name"];
        self.fixture_uart_baud      = [fix objectForKey:@"fixture_uart_baud"];
        self.instr_2987             = [fix objectForKey:@"b2987_adress"];
        self.instr_4980             = [fix objectForKey:@"e4980_adress"];
        
        singleFloder                = [fix objectForKey:@"singleFloder"];
    
        
        
        
        //从param.plist文件中获取相关的值
        updateItem.fix_ABC_DEF_Res  = [fix objectForKey:@"fix_ABC_DEF_Res"];
        updateItem.fix_B2_E2_Res    = [fix objectForKey:@"fix_B2_E2_Res"];
        updateItem.fix_B4_E4_Res    = [fix objectForKey:@"fix_B4_E4_Res"];
        updateItem.fix_B_E_Res      = [fix objectForKey:@"fix_B_E_Res"];
        updateItem.fix_Cap          = [fix objectForKey:@"fix_Cap"];
        
        
        //=========================================监听通知
       
        //监听启动
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NSThreadStart_Notification:) name:@"NSThreadStart_Notification" object:nil];
        //监听测试结束通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NSThreadEnd_Notification:) name:@"NSThreadEnd_Notification" object:nil];
        //监听空测试
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(selectNullTestNoti:) name:kNullTestNotice object:nil];
        //监听PDCA
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCAandSCFNoti:) name:kPdcaUploadNotice object:nil];
        //监听SFC
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCAandSCFNoti:) name:kSfcUploadNotice object:nil];
        //写入空测的值
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeNullValueToPlist:) name:@"WriteNullValue" object:nil];
        //Test数据选择
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectTestDataNoti:) name:kTest40DataNotice object:nil];
        
        
        

        
        //获取全局变量
        app = [NSApplication sharedApplication].delegate;
        thread = [[NSThread alloc]initWithTarget:self selector:@selector(TestAction) object:nil];
        [thread start];
    }
    
    return self;
}




-(void)TestAction
{
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
        
#pragma mark--------连接治具
        if (index == 0) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            if (param.isDebug) {
                 NSLog(@"%@==index= 0,连接治具%@,debug模式中",[NSThread currentThread],self.fixture_uart_port_name);
                [txtContentString appendFormat:@"%@:index=0,进入debug模式\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=0,进入debug模式" andClear:YES andTextView:self.Log_View];
                 index =1;
            }
            else
            {
                
                BOOL isCollect = [serialport Open:self.fixture_uart_port_name];
                if (isCollect) {
                     //发送指令获取ID的值
                    [NSThread sleepForTimeInterval:0.2];
                    [serialport WriteLine:@"Fixture ID?"];
                    [NSThread sleepForTimeInterval:0.5];
                     FixtureID = [serialport ReadExisting];
                    if ([FixtureID containsString:@"\r\n"]&&[FixtureID containsString:@"\r\n"]) {
                        
                        FixtureID = [[FixtureID componentsSeparatedByString:@"\r\n"] objectAtIndex:1];
                        FixtureID = [FixtureID stringByReplacingOccurrencesOfString:@"*_*" withString:@""];
                    }
                    
                     NSLog(@"index= 0,连接治具%@",self.fixture_uart_port_name);
                    [txtContentString appendFormat:@"%@:index=0,治具已经连接\n",[timeDay getFileTime]];
                    [self UpdateTextView:@"index=0,治具已经连接" andClear:NO andTextView:self.Log_View];
                    
                    index =1;
                }
            }
            
//#warning  debug
//            index = 2;
           
        }
        
#pragma mark--------连接LCR表4980 和 静电仪器2987A
        if (index == 1) {
            
            [NSThread sleepForTimeInterval:0.5];
            if (param.isDebug) {
                
                NSLog(@"index= 1,仿仪器出口已连接%@,debug模式中",self.instrument_name);
                [txtContentString appendFormat:@"%@:index=1,debug模式中\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=1,进入debug模式" andClear:NO andTextView:self.Log_View];
                index =1000;
            }
            else
            {
               
                if (!is_LRC_Collect) {
                    
                    is_LRC_Collect = [agilentE4980A Find:self.instr_4980 andCommunicateType:AgilentE4980A_Communicate_DEFAULT]&&[agilentE4980A OpenDevice:nil andCommunicateType:AgilentE4980A_USB_Type];
                }
                
                if (!is_LRC_Collect){
                    NSLog(@"LCR-4980 Not Connected");
                    [self UpdateTextView:@"index=1,LCR-4980 Not Connected" andClear:NO andTextView:self.Log_View];
                }
                else{
                     NSLog(@"LCR-4980 Connected");
                     [self UpdateTextView:@"index=1,LCR-4980 Connected" andClear:NO andTextView:self.Log_View];
                }
                
                
                if (!is_JDY_Collect) {
                    
                    is_JDY_Collect = [agilentB2987A Find:self.instr_2987 andCommunicateType:AgilentB2987A_USB_Type]&&[agilentB2987A OpenDevice:self.instr_2987 andCommunicateType:AgilentB2987A_USB_Type];
                }
                
                if (!is_JDY_Collect){
                
                    NSLog(@"JDY-2987 Not Connected");
                    [self UpdateTextView:@"index=1,JDY-2987 Not Connected" andClear:NO andTextView:self.Log_View];
                }
                else
                {
                    NSLog(@"LCR-2987 Connected");
                    [self UpdateTextView:@"index=1,LCR-2987 Connected" andClear:NO andTextView:self.Log_View];
                    
                }
                
                if (is_LRC_Collect&&is_JDY_Collect) {
                     //NSLog(@"index= 1,仿仪器出口已连接%@",self.instrument_name);
                     [txtContentString appendFormat:@"%@:index=1,测试仪器已连接\n",[timeDay getFileTime]];
                     [self UpdateTextView:@"index=1,测试仪器已连接" andClear:NO andTextView:self.Log_View];
                    
                    index = 1000;
                }
                
#warning debug模式下，无仪器时
                
               // index =2;
            }
        }
#pragma mark--------获取输入框中的SN
        if (index == 2) {
            //通过通知抛过来SN，以及气缸的状态
            [NSThread sleepForTimeInterval:0.5];
             NSLog(@"index =2,等待SN");
            if (_dut_sn.length == 17||_dut_sn.length==21)
            {
                NSLog(@"index= 2,检测SN,并打印SN的值%@",_dut_sn);
                index =3;
                //启动测试的时间,csv里面用
                start_time = [[GetTimeDay shareInstance] getFileTime];
                [txtContentString appendFormat:@"%@:index=2,SN已经检验成功\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=2,SN已经检验成功" andClear:NO andTextView:self.Log_View];
                
            }
        }
        
#pragma mark--------检测SN是否上传
        if (index == 3) {
            
            [NSThread sleepForTimeInterval:0.2];
            if (param.isDebug)
            {
                NSLog(@"index = 3,检测SN是否上传,debug");
                [txtContentString appendFormat:@"%@:index=3,debug模式\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=3,进入debug模式,检测SN上传" andClear:NO andTextView:self.Log_View];
                
                index = 4;
            }
            else
            {
                index = 4;//进入正常测试中
                //开启PDCA的时间
                if (isPDCA) {
                    [pdca PDCA_GetStartTime];
                }
                
            }
            
        }
        
        
#pragma mark--------进入正常测试中
        if (index == 4) {
            
            [NSThread sleepForTimeInterval:0.3];
            
            NSLog(@"index= 4,进入测试%@",self.fixture_uart_port_name);
            [txtContentString appendFormat:@"%@:index=4,正式进入测试\n",[timeDay getFileTime]];
            NSLog(@"打印tab中数组中的值%lu",(unsigned long)[self.tab.testArray count]);
            
            testItem = [[Item alloc]initWithItem:self.tab.testArray[item_index]];
            
            BOOL isPass =[self TestItem:testItem];
            
            if (isPass) {//测试成功
                
                [self UpdateTextView:[NSString stringWithFormat:@"index=4:%@ 测试OK",testItem.testName] andClear:NO andTextView:self.Log_View];
                
            }
            else//测试结果失败
            {
                 [self UpdateTextView:[NSString stringWithFormat:@"index=4:%@ 测试NG",testItem.testName] andClear:NO andTextView:self.Log_View];
                 [self UpdateTextView:[NSString stringWithFormat:@"FailItem:%@\n",testItem.testName] andClear:NO andTextView:self.Fail_View];
                
            }
    
            //刷新界面
            [txtContentString appendFormat:@"%@:index=4,准备刷新界面\n",[timeDay getFileTime]];
            [self.tab flushTableRow:testItem RowIndex:row_index with:fix_type];
            [txtContentString appendFormat:@"%@:index=4,刷新界面成功\n",[timeDay getFileTime]];

            
            item_index++;
            row_index++;
            //走完测试流程,进入下一步
            if (item_index == [self.tab.testArray count])
            {
                //给设备复位
                [txtContentString appendFormat:@"%@:index=4,测试项测试结束\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=4,测试项测试结束" andClear:NO andTextView:self.Log_View];
                index = 5;
                
            }
            
        }
        
#pragma mark--------生成本地数据
        if (index == 5) {
           //测试结束的时间,csv里面用
            end_time = [[GetTimeDay shareInstance] getFileTime];
            [NSThread sleepForTimeInterval:0.2];
            NSString * path = [[NSUserDefaults standardUserDefaults] objectForKey:kTotalFoldPath];
            NSString * totalPath  = [NSString stringWithFormat:@"%@/%@/%@",path,self.NestID,[self.Config_pro length]>0?self.Config_pro:@"NoConfig"];
            NSLog(@"打印总文件的位置%d=========%@",fix_type,totalPath);
            
            [fold Folder_Creat:totalPath];
            NSString   * configCSV = [self backTotalFilePathwithFloder:totalPath];
            
            if (total_file!=nil) {
                
                BOOL need_title = [total_file CSV_Open:configCSV];
                [txtContentString appendFormat:@"%@:index=5,打开总csv文件->%@\n",[timeDay getFileTime],configCSV];
                [self SaveCSV:total_file withBool:need_title];
                [txtContentString appendFormat:@"%@:index=5,添加数据到totalCSV文件->%@\n",[timeDay getFileTime],configCSV];
                [self UpdateTextView:@"index=5,往总文件中添加数据" andClear:NO andTextView:self.Log_View];
            }
            
            
            
            
            //2.============================生成BCMSingleLog中的文件
            @synchronized (self)
            {
                 end_time = [[GetTimeDay shareInstance] getFileTime];
                 [fold Folder_Creat:param.SingleFolder];
                 NSString * eachCsvFile = [NSString stringWithFormat:@"%@/%@_%@_%u.csv",param.SingleFolder,self.dut_sn,end_time,arc4random()%100];
                 if (csv_file!=nil)
                 {
                    BOOL need_title = [csv_file CSV_Open:eachCsvFile];
                    [self SaveCSV:csv_file withBool:need_title];
                    [txtContentString appendFormat:@"%@:index=5,生成生成Single_Log文件%@\n",[timeDay getFileTime],eachCsvFile];
                    [self UpdateTextView:@"index=5,生成Single_Log文件" andClear:NO andTextView:self.Log_View];
                 }
            }
            
            
            //3.============================生成总文件夹下面的单个文件
            @synchronized (self)
            {
                //生成单个产品的value值csv文件
                [NSThread sleepForTimeInterval:0.2];
                eachCsvDir = [NSString stringWithFormat:@"%@/%@_%@",totalPath,self.dut_sn,[timeDay getCurrentMinuteAndSecond]];;
                [fold Folder_Creat:eachCsvDir];
                NSString * eachCsvFile = [NSString stringWithFormat:@"%@/%@_%@_%u.csv",eachCsvDir,self.dut_sn,end_time,arc4random()%100];
                if (csv_file!=nil)
                {
                    BOOL need_title = [csv_file CSV_Open:eachCsvFile];
                    [self SaveCSV:csv_file withBool:need_title];
                    [txtContentString appendFormat:@"%@:index=5,生成单个csv文件%@\n",[timeDay getFileTime],eachCsvFile];
                    [self UpdateTextView:@"index=5,生成单个CSV文件" andClear:NO andTextView:self.Log_View];
                }
                
                
            }
            
            
            //生成log文件
            NSString * logFile = [NSString stringWithFormat:@"%@/log.txt",eachCsvDir];
            if (txt_file!=nil)
            {
                
                [txt_file TXT_Open:logFile];
                [txt_file TXT_Write:txtContentString];
            }
            
            
            
            
           //===============================
            [NSThread sleepForTimeInterval:0.2];
            NSLog(@"index= 5,本地数据生成完成%@",self.fixture_uart_port_name);
            [self UpdateTextView:@"index=5,本地数据生成完成" andClear:NO andTextView:self.Log_View];
            index = 6;
        }
        
#pragma mark--------上传PDCA和SFC
        if (index == 6)
        {
            //PDCA测试结束
            if (isPDCA) {
                [pdca PDCA_GetEndTime];
            }
            
            //上传PDCA和SFC
            [NSThread sleepForTimeInterval:0.3];
            [txtContentString appendFormat:@"%@:index=6,准备上传PDCA\n",[timeDay getFileTime]];
            [self UpdateTextView:@"index=6,准备上传PDCA" andClear:NO andTextView:self.Log_View];
           if (isPDCA) {
                
              [self UploadPDCA];
              NSLog(@"将数据上传到PDCA服务器");
            }
            
            [txtContentString appendFormat:@"%@:index=6,准备上传SFC\n",[timeDay getFileTime]];
            [self UpdateTextView:@"index=6,准备上传SFC" andClear:NO andTextView:self.Log_View];

            
            index = 7;
        }
        
        
        //将结果显示在界面上
        if (index == 7)
        {
            //清空字符串
            txtContentString =[NSMutableString stringWithString:@""];
            listFailItemString = [NSMutableString stringWithString:@""];
            ErrorMessageString = [NSMutableString stringWithString:@""];
            dcrAppendString    = [NSMutableString stringWithString:@""];
            [ItemArr removeAllObjects];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resultTF setStringValue:PF?@"PASS":@"FAIL"];
                
               if (PF)
               {
                   
                 [self.resultTF setTextColor:[NSColor greenColor]];
                   
                    NSMutableDictionary  * resultdic = [[NSMutableDictionary alloc]initWithCapacity:10];
                   [resultdic setObject:TestValueArr forKey:@"dic"];
                   
                   
                   [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dP",fix_type] userInfo:resultdic];
                }
                else
                {
                
                 [self.resultTF setTextColor:[NSColor redColor]];
                    
                    NSMutableDictionary  * resultdic = [[NSMutableDictionary alloc]initWithCapacity:10];
                    [resultdic setObject:TestValueArr forKey:@"dic"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dF",fix_type] userInfo:resultdic];
                }
                
            });
            index = 8;
        }
        
        //刷新结果，重新等待SN
        if (index == 8)
        {
            
            [NSThread sleepForTimeInterval:0.1];
            
            //发送复位的指令
            [serialport WriteLine:@"reset"];
            [NSThread sleepForTimeInterval:0.5];
            [serialport ReadExisting];
            
            
            
            //清空SN
             _dut_sn=@"";
            if (nulltest) {
                nullTimes++;
            }
           
            index = 1000;
            item_index =0;
            row_index = 0;
            PF = YES;
            [TestValueArr removeAllObjects];
            
        }
     
#pragma mark===================发送消息，防止休眠
        if (index == 1000)
        {
            [NSTimer scheduledTimerWithTimeInterval:500 target:self selector:@selector(timewake) userInfo:nil repeats:YES];
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}


//================================================
//测试项指令解析
//================================================
-(BOOL)TestItem:(Item*)testitem
{
    BOOL ispass=NO;
    NSDictionary  * dict;
    NSString      * subTestDevice;
    NSString      * subTestCommand;
    double          DelayTime;
    NSString      * startTime;
    NSString      * endTime;
    startTime = [timeDay getCurrentSecond];
    
    for (int i=0; i<[testitem.testAllCommand count]; i++)
    {
        dict =[testitem.testAllCommand objectAtIndex:i];
        subTestDevice = dict[@"TestDevice"];
        subTestCommand=dict[@"TestCommand"];
        DelayTime = [dict[@"TestDelayTime"] floatValue]/1000.0;
        NSLog(@"治具%@发送指令%@",subTestDevice,subTestCommand);
    
        //治具中收发指令
        if ([subTestDevice isEqualToString:@"Fixture"])
        {
          [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
           int indexTime = 0;
            while (YES) {
                
                [txtContentString appendFormat:@"%@:index=4,%@治具发送指令->%@\n",[timeDay getFileTime],self.fixture_uart_port_name,subTestCommand];
                
                
                 [serialport WriteLine:subTestCommand];
                
                 [NSThread sleepForTimeInterval:0.5];
                 fixtureBackString = [serialport ReadExisting];
                
                 [self UpdateTextView:[NSString stringWithFormat:@"fixtureBackString:%@",fixtureBackString] andClear:NO andTextView:self.Log_View];
                
                 [txtContentString appendFormat:@"%@:index=4,%@治具接收返回值->%@\n",[timeDay getFileTime],self.fixture_uart_port_name,fixtureBackString];
                
                if ([fixtureBackString containsString:@"OK"]&&[fixtureBackString containsString:@"*_*"])
                {
                    break;
                }
                if (indexTime>=3) {
                    
                    break;
                }
                
                indexTime++;
                
            }
        }
        //LCR表
        else if ([subTestDevice isEqualToString:@"LCR"])
        {
            
             [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
            if ([subTestCommand isEqualToString:@"RES"])
            {

                [agilentE4980A SetMessureMode:AgilentE4980A_RX andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];

            }
            else if([subTestCommand isEqualToString:@"CPD"])
            {
                [agilentE4980A SetMessureMode:AgilentE4980A_CPD andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];

            }
            else if ([subTestCommand isEqualToString:@"CPQ"])
            {
                [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];

            }
            else if ([subTestCommand isEqualToString:@"CSD"])
            {
                [agilentE4980A SetMessureMode:AgilentE4980A_CSD andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
            }
            else if ([subTestCommand containsString:@"CSQ"])
            {
                
                [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                
            }
            else if ([subTestCommand containsString:@"Read"])
            {
                [agilentE4980A WriteLine:@":FETC?" andCommunicateType:AgilentE4980A_USB_Type];
                [NSThread sleepForTimeInterval:0.5];
                agilentReadString=[agilentE4980A ReadData:16 andCommunicateType:AgilentE4980A_USB_Type];
                NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                num = [arrResult[0] floatValue];
            }
            else
            {
                NSLog(@"Other situation");
            
            }
            
        }
        //静电仪
        else if ([subTestDevice isEqualToString:@"DMM"])
        {
            
             [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
            if ([testitem.testName isEqualToString:@"B4_E4_DCR"]) {
                
                if (param.isDebug) {
                    
                    if ([subTestCommand containsString:@"Read"]) {
                       
                        int i = 40;
                        while (i>0) {
                            
                            i--;
                            [NSThread sleepForTimeInterval:0.4];
                            [dcrAppendString appendString:@",22222222"];
                        }
                    }
                    testvalue = @"11111111111";
                    
                }
                else if ([subTestCommand containsString:@"RES"]) {
                    
                     [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type];
                }
                else if ([subTestCommand containsString:@"Read"]) {
                    
                    if (addDcr) {
                        double num1;
                        int readtimes = 40;
                        while (readtimes>0) {
                            
                            readtimes--;
                            [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                            [NSThread sleepForTimeInterval:0.4];
                            agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                            NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                            num1 = [arrResult[0] floatValue];
                            [dcrAppendString appendString:[NSString stringWithFormat:@"%.3f,",num1*1E-9]];
                        }
                        
                        NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                        num = [arrResult[0] floatValue];
                        
                    }
                    else
                    {
                        
                        int readtimes = 0;
                        while (YES) {
                            
                            readtimes++;
                            
                            [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                            [NSThread sleepForTimeInterval:0.2];
                            agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                            
                            if ([agilentReadString length]>0||readtimes>=2) {
                                
                                break;
                            }
                        }
                        
                        NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                        num = [arrResult[0] floatValue];
                        
                    }
                    

                }
            }
            else
            {
                if (param.isDebug) {
                    
                    testvalue = @"11111111111";
                }
                else if ([subTestCommand containsString:@"RES"]) {
                    
                    [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type];
                }
                else if ([subTestCommand containsString:@"Read"]) {
                    
                    int readtimes = 0;
                    while (YES) {
                        
                        readtimes++;
                        
                        [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                        [NSThread sleepForTimeInterval:0.2];
                        agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                        
                        if ([agilentReadString length]>0||readtimes>=2) {
                            
                            break;
                        }
                    }
                    
                    NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                    num = [arrResult[0] floatValue];

                }
            }
            
        }
        //延迟时间
        else if ([subTestDevice isEqualToString:@"SW"])
        {
            [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
            if (!param.isDebug)
            {
                 NSLog(@"软件休眠时间");
                [NSThread sleepForTimeInterval:DelayTime];
                [txtContentString appendFormat:@"%@:index=4,%@软件延时处理\n",[timeDay getFileTime],subTestDevice];
            }

        }
        else
        {
            NSLog(@"其它的情形");
        }
        
    }
    
    
    
#pragma mark--------对数据进行处理
    if ([testitem.units containsString:@"GOhm"]) {//GOhm
        if (![testitem.testName containsString:@"B2987_CHECK"]) {

            if (!nulltest)
            {
                if ([testitem.testName isEqualToString:@"B_E_DCR"]||[testitem.testName isEqualToString:@"B2_E2_DCR"]||[testitem.testName isEqualToString:@"B4_E4_DCR"]||[testitem.testName isEqualToString:@"ABC_DEF_DCR"]) {
                    
                     testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
                    [self storeValueToDic_with_name:testitem.testName];
                }
            }
            else//空测试的情况
            {
                double Rfixture   = num*1E-9;
                
                if([testitem.testName isEqualToString:@"B4_E4_DCR"])
                {
                    NSLog(@"打印空测的值%f",Rfixture);
                
                }
                
                if ([testitem.testName isEqualToString:@"B_E_DCR"]||[testitem.testName isEqualToString:@"B2_E2_DCR"]||[testitem.testName isEqualToString:@"B4_E4_DCR"]||[testitem.testName isEqualToString:@"ABC_DEF_DCR"]) {
                    
                    testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
                    [self add_RFixture_Value_To_Sum_Testname:testitem.testName RFixture:Rfixture];
                }
            }

            
        }
        else
        {
              testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
        }
        
    }
    else if ([testitem.units containsString:@"MOhm"])//MOhm
    {
        if (!nulltest) {
            
            if ([testitem.testName isEqualToString:@"B2_E2_ACR_1000"]||[testitem.testName isEqualToString:@"B4_E4_ACR_1000"]) {
                
                testvalue=[NSString stringWithFormat:@"%.3f",1E-6/(num*2*3.14159*testitem.freq.integerValue)];
                
                NSLog(@"打印测试的频率值%@",testitem.freq);
                
               [self storeValueToDic_With_Item:testitem];       //存储其它测试项的值
            }
        }
        else //空测试情况
        {
            
            double Cdut,Cfix,Rdut;
            NSString *smallCap=@"<1fF";
            NSString *largeACR=@">100GOhm";
            Cdut=0.0;
            Rdut=9999.00;
            Cfix=num*1E+12;
            testvalue=[NSString stringWithFormat:@"%.3f",1E-6/(num*2*3.14159*testitem.freq.integerValue)];
            
            if ([testitem.testName isEqualToString:@"B2_E2_ACR_1000"])
            {
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"B2_E2_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"B2_E2_ACR_1000_Rdut"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"B2_E2_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B2_E2_ACR_1000_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"B2_E2_ACR_1000_Cfix"];
            }
            
            if ([testitem.testName isEqualToString:@"B4_E4_ACR_1000"])
            {
                Cap_Sum+=Cfix;
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"B4_E4_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"B4_E4_ACR_1000_Rdut"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"B4_E4_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B4_E4_ACR_1000_Rdut"];
                }
                
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"B4_E4_ACR_1000_Cfix"];
            }
            
            
        }
        
        
    }
    else if ([testitem.units containsString:@"Ohm"])//Ohm
    {
        testvalue = [NSString stringWithFormat:@"%.2f",num];
        if (param.isDebug)
        {
            double i=arc4random()%10+100.000000;
            testvalue=[NSString stringWithFormat:@"%.2f",i];
        }
    }
    else if ([testitem.testName containsString:@"TEMP"])
    {
        if (param.isDebug) {
            
            testvalue = @"26";
        }
        else
        {
            testvalue =[self.Config_Dic objectForKey:kTemp];
        }
        
     
    }
    else if ([testitem.testName containsString:@"HUMID"])
    {
        if (param.isDebug) {
            
            testvalue = @"56%";
        }
        else
        {
            testvalue =[self.Config_Dic objectForKey:kHumit];
        }
    }
    
    else
    {
        NSLog(@"Other test Item");
    
    }
    

#pragma mark--------对测试项进行赋值
    if ([testitem.testName containsString:@"_Vmeas"] || [testitem.testName containsString:@"_Rref"] || [testitem.testName containsString:@"_Cfix"] || [testitem.testName containsString:@"_Vs"] || [testitem.testName containsString:@"_Cref"] || [testitem.testName containsString:@"_Rdut"] || [testitem.testName containsString:@"_Cdut"] || [testitem.testName containsString:@"_Rfix"])
    {
        testvalue=[NSString stringWithFormat:@"%@",store_Dic[[NSString stringWithFormat:@"%@",testitem.testName]]];
        
        NSLog(@"打印多长的时间==========%@",testvalue);
        
        
    
    }
    
    
   
    
//判断值得大小
#pragma mark--------对测试出来的结果进行判断和赋值
    //上下限值对比
    if (([testvalue floatValue]>[testitem.min floatValue]&&[testvalue floatValue]<=[testitem.max floatValue]) || ([testitem.max isEqualToString:@"--"]&&[testvalue floatValue]>=[testitem.min floatValue]) || ([testitem.max isEqualToString:@"--"] && [testitem.min isEqualToString:@"--"]) || ([testitem.min isEqualToString:@"--"]&&[testvalue floatValue]<=[testitem.max floatValue])|| [testvalue isEqualToString:@">100GOhm"]|| [testvalue isEqualToString:@"<1fF"]||[testvalue isEqualToString:@">1TOhm"])
    {
        if (fix_type == 1) {
            testitem.value1 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result1 = @"PASS";
        }
        else if (fix_type == 2)
        {
            testitem.value2 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result2 = @"PASS";
        }
        else if (fix_type == 3)
        {
            testitem.value3 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result3 = @"PASS";
        }
        else if (fix_type == 4)
        {
            testitem.value4 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result4 = @"PASS";
        }
        
        testitem.messageError=nil;
        ispass = YES;
    }
    else
    {
        if (fix_type == 1) {
            testitem.value1 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result1 = @"Fail";
        }
        else if (fix_type == 2)
        {
            testitem.value2 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result2 = @"Fail";
        }
        else if (fix_type == 3)
        {
            testitem.value3 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result3 = @"FAIL";
        }
        else if (fix_type == 4)
        {
            testitem.value4 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result4 = @"FAIL";
        }
        testitem.messageError=[NSString stringWithFormat:@"%@ Fail",testitem.testName];
        ispass = NO;
        PF = NO;
    }
    
    //对时间进行赋值
    endTime = [timeDay getCurrentSecond];
    testitem.startTime = startTime;
    testitem.endTime   = endTime;
    
    
    
    
    //处理相关的测试项
    [TestValueArr addObject:testvalue];
    [ItemArr addObject:testitem];      //将测试项加入数组中

    return ispass;
}


//================================================
//保存csv
//================================================
-(void)SaveCSV:(FileCSV *)csvFile withBool:(BOOL)need_title
{
    NSString * line    =  @"";
    NSString * result =  @"";
    NSString * value  =  @"";
    
    for(int i=0;i<[ItemArr count];i++)
    {
        Item *testitem=ItemArr[i];
        
        if (fix_type == 1) {result = testitem.result1,value   =testitem.value1;}
        if (fix_type == 2) {result = testitem.result2,value   =testitem.value2;}
        if (fix_type == 3) {result = testitem.result3,value   =testitem.value3;}
        if (fix_type == 4) {result = testitem.result4,value   =testitem.value4;}
        
        if(testitem.isTest)  //需要测试的才需要上传
        {
            if((testitem.isShow == YES)&&(testitem.isTest))    //需要显示并且需要测试的才保存
            {
                
                line=[line stringByAppendingString:[NSString stringWithFormat:@"%@,",value]];
                
            }
        }
    }
    line = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    NSString *test_result;
    if (PF)
    {
        test_result = @"PASS";
    }
    else
    {
        test_result = @"FAIL";
    }
    //line字符串前面增加SN和测试结果
    NSString *  contentStr = [NSMutableString stringWithFormat:@"\n%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",start_time,end_time,[self.Config_Dic objectForKey:kSoftwareVersion],self.NestID,@"Cr",self.Config_pro,self.dut_sn,test_result,FixtureID,[self.Config_Dic objectForKey:kOperator_ID],line];
    
    NSMutableString  * contentString = [NSMutableString stringWithString:contentStr];
    
    
    //如果addDcr=YES,加数据加到contentString中
    if (addDcr) {
        
          [contentString appendString:[NSString stringWithFormat:@"%@",dcrAppendString]];
        
    }
    
    
    
    
   if(need_title == YES)[csvFile CSV_Write:self.csvTitle];
    
    [csvFile CSV_Write:contentString];
    
}


-(void)setCsvTitle:(NSString *)csvTitle
{
    _csvTitle = csvTitle;
}

-(void)setDut_sn:(NSString *)dut_sn
{
    _dut_sn = dut_sn;
}

-(void)setFoldDir:(NSString *)foldDir
{
    _foldDir = foldDir;
}

-(void)setToFold:(NSString *)toFold
{
    _toFold = toFold;
}




#pragma mark=========================通知类消息
//监测开始测试的消息

-(void)NSThreadStart_Notification:(NSNotification *)noti
{
    
    index = 2;
    
}

-(void)NSThreadEnd_Notification:(NSNotification *)noti
{
    
    index = 1000;
}


//监测空测试时的消息
-(void)selectNullTestNoti:(NSNotification *)noti
{
    if ([noti.object isEqualToString:@"YES"]) {
        
         nulltest = YES;
    }
    else{
    
         nulltest = NO;
    }
   
}

-(void)selectPDCAandSCFNoti:(NSNotification *)noti
{
    
    if ([noti.name isEqualToString:kPdcaUploadNotice]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            isPDCA = YES;
        }
        else
        {
            isPDCA = NO;
        }
    }
    if ([noti.name isEqualToString:kSfcUploadNotice]) {
       
        if ([noti.object isEqualToString:@"YES"]) {
            
            isSFC = YES;
        }
        else
        {
            isSFC = NO;
        }
    }
    
    NSLog(@"%hhd======%hhd",isPDCA,isSFC);
}

-(void)writeNullValueToPlist:(NSNotification *)noti
{
    
    
    updateItem.fix_B_E_Res     = [NSString stringWithFormat:@"%f",B_E_Sum/nullTimes];
    updateItem.fix_B2_E2_Res   = [NSString stringWithFormat:@"%f",B2_E2_Sum/nullTimes];
    updateItem.fix_B4_E4_Res   = [NSString stringWithFormat:@"%f",B4_E4_Sum/nullTimes];
    updateItem.fix_ABC_DEF_Res = [NSString stringWithFormat:@"%f",ABC_DEF_Sum/nullTimes];
    updateItem.fix_Cap         = [NSString stringWithFormat:@"%f",Cap_Sum/nullTimes];
    
    if (fix_type == 1&&nullTimes>=2) {
        [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix1];
         NSLog(@"%d-----%@==%@===%@===%@===%@",fix_type,updateItem.fix_ABC_DEF_Res,updateItem.fix_B2_E2_Res,updateItem.fix_B4_E4_Res,updateItem.fix_B_E_Res,updateItem.fix_Cap);
    }
    if (fix_type==2&&nullTimes>=2) {
        [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix2];
         NSLog(@"%d-----%@==%@===%@===%@===%@",fix_type,updateItem.fix_ABC_DEF_Res,updateItem.fix_B2_E2_Res,updateItem.fix_B4_E4_Res,updateItem.fix_B_E_Res,updateItem.fix_Cap);
    }
    if (fix_type==3&&nullTimes>=2) {
        [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix3];
         NSLog(@"%d-----%@==%@===%@===%@===%@",fix_type,updateItem.fix_ABC_DEF_Res,updateItem.fix_B2_E2_Res,updateItem.fix_B4_E4_Res,updateItem.fix_B_E_Res,updateItem.fix_Cap);
    }
    if (fix_type==4&&nullTimes>=2) {
        [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix4];
         NSLog(@"%d-----%@==%@===%@===%@===%@",fix_type,updateItem.fix_ABC_DEF_Res,updateItem.fix_B2_E2_Res,updateItem.fix_B4_E4_Res,updateItem.fix_B_E_Res,updateItem.fix_Cap);
    }
    
    exit(0);
}


#pragma mark--------------选择测试40个测试数据
-(void)selectTestDataNoti:(NSNotification *)noti
{

    
    if ([noti.name isEqualToString:kTest40DataNotice]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            addDcr = YES;
        }
        else
        {
            addDcr = NO;
        }
    }
}


#pragma mark----PDCA相关
//================================================
//上传pdca
//================================================
-(void)UploadPDCA
{
    //可以从json文件中获取所需要的值
    NSString * result=  @"";
    NSString * value =  @"";
    
    [pdca PDCA_Init:self.dut_sn SW_name:self.sw_name SW_ver:self.sw_ver];   //上传sn，sw_name,sw_ver
    
    for(int i=0;i<[ItemArr count];i++)
    {
        Item *testitem=ItemArr[i];
        
        
        
        if (fix_type == 1) {result = testitem.result1,value   =testitem.value1;}
        if (fix_type == 2) {result = testitem.result1,value   =testitem.value2;}
        if (fix_type == 3) {result = testitem.result1,value =testitem.value3;}
        if (fix_type == 4) {result = testitem.result1,value  =testitem.value4;}
        
        
        if(testitem.isTest)  //需要测试的才需要上传
        {
            
            if((testitem.isShow == YES)&&(testitem.isTest))    //需要显示并且需要测试的才上传
            {
                
                BOOL pass_fail=YES;
                
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
    
    [pdca PDCA_Upload:PF];     //上传汇总结果
    
    //============================压缩文件======================================/
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    
    NSString  * zipFileName = [[eachCsvDir componentsSeparatedByString:@"/"] lastObject];
    NSString *cmd = [NSString stringWithFormat:@"cd %@; zip -rm %@.zip %@",self.foldDir,zipFileName,zipFileName];
    NSArray *argument = [NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"%@", cmd], nil];
    [task setArguments: argument];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    [task launch];
    
    
    
    //获取压缩文件的具体地址
     NSString *ZIP_path = [NSString stringWithFormat:@"%@/%@.zip",self.foldDir,zipFileName];
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
    //============================压缩文件======================================/
 
}


#pragma mark-----------------多次测试和的值
-(void)add_RFixture_Value_To_Sum_Testname:(NSString *)testname RFixture:(double)RFixture
{
    NSString *largeRes= @">1TOhm";
    if ([testname isEqualToString:@"B_E_DCR"])         B_E_Sum   = B_E_Sum + RFixture;
    if ([testname isEqualToString:@"B2_E2_DCR"])       B2_E2_Sum = B2_E2_Sum + RFixture;
    if ([testname isEqualToString:@"B4_E4_DCR"])       B4_E4_Sum = B4_E4_Sum + RFixture;
    if ([testname isEqualToString:@"ABC_DEF_DCR"])     ABC_DEF_Sum =ABC_DEF_Sum + RFixture;
    
    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",RFixture] forKey:[NSString stringWithFormat:@"%@_Rfix",testname]];
}



#pragma mark----------------GΩ情况下调用方法，testname为测试项的名称
-(void)storeValueToDic_with_name:(NSString *)testname
{
    double Rdut,Rfixture;
    NSString *largeRes=@">1TOhm";
    Rfixture=num*1E-9;

    if ([testname isEqualToString:@"B_E_DCR"]) {
        Rfixture = [updateItem.fix_B_E_Res floatValue];
    }
    if ([testname isEqualToString:@"B2_E2_DCR"]) {
        Rfixture = [updateItem.fix_B2_E2_Res floatValue];
    }
    if ([testname isEqualToString:@"B4_E4_DCR"]) {
         Rfixture = [updateItem.fix_B4_E4_Res floatValue];
    }
    if ([testname isEqualToString:@"ABC_DEF_DCR"]) {
         Rfixture = [updateItem.fix_ABC_DEF_Res floatValue];
    }
    
    Rdut=(num*1E-9*Rfixture)/(Rfixture-num*1E-9);
    
    
    if (param.isDebug) {
        
        Rdut = arc4random()%100;
    }
    
    if (num*1E-9 >= Rfixture || Rdut > 1000 || num*1E-9 < 0)
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    }
    else
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    }
    
     [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:[NSString stringWithFormat:@"%@_Rfix",testname]];

    
}


#pragma mark----------------MΩ情况下调用的方法，
-(void)storeValueToDic_With_Item:(Item *)item
{
    double Cdut,Cfix,Rdut;
    NSString *smallCap=@"<1fF";
    NSString *largeACR=@">100GOhm";
    Cfix=[updateItem.fix_Cap floatValue];
    Cdut=num*1E+12-Cfix;
    Rdut=1E+6/(Cdut*2*3.14159*item.freq.integerValue);
    
    if (Cdut <= 0)
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:[NSString stringWithFormat:@"%@_Cdut",item.testName]];
        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:[NSString stringWithFormat:@"%@_Rdut",item.testName]];
    }
    else
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%f",Cdut] forKey:[NSString stringWithFormat:@"%@_Cdut",item.testName]];
        [store_Dic setValue:[NSString stringWithFormat:@"%f",Rdut] forKey:[NSString stringWithFormat:@"%@_Rdut",item.testName]];
        
    }
    
    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:[NSString stringWithFormat:@"%@_Cfix",item.testName]];

}


#pragma mark-------------返回总文件
-(NSString *)backTotalFilePathwithFloder:(NSString *)FoldStr
{
    if (fix_type==1) {
        
       return [NSString stringWithFormat:@"%@/%@_A.csv",FoldStr,[timeDay getCurrentDay]];
    }
    else if (fix_type==2)
    {
       return [NSString stringWithFormat:@"%@/%@_B.csv",FoldStr,[timeDay getCurrentDay]];
    }
    else if (fix_type==3)
    {
       return [NSString stringWithFormat:@"%@/%@_C.csv",FoldStr,[timeDay getCurrentDay]];
    }
    else
    {
       return [NSString stringWithFormat:@"%@/%@_D.csv",FoldStr,[timeDay getCurrentDay]];
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
                               [textView setString:[NSString stringWithFormat:@"%@",strMsg]];
                           }
                           
                           [textView setTextColor:[NSColor redColor]];
                       });
    }
}



//线程开始
-(void)threadStart
{
    
    [thread start];
    
}




//线程结束
-(void)threadEnd
{
    [thread cancel];
    [agilentB2987A CloseDevice];
    [agilentE4980A CloseDevice];
    [serialport Close];
    
    agilentB2987A = nil;
    agilentE4980A = nil;
    serialport = nil;
}


#pragma mark ===============唤醒2987A
-(void)timewake
{
     [agilentB2987A WriteLine:@"*RST" andCommunicateType:AgilentB2987A_USB_Type];
}





@end
