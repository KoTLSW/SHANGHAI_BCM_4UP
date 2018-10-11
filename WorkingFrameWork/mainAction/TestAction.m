//
//  TestAction.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "TestAction.h"
#import "Alert.h"
#import "AppDelegate.h"



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
    
    NSMutableArray  *testResultArr;                           // 返回的结果数组
    NSMutableArray  *testItemTitleArr;                        //每个测试标题都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemValueArr;                        //每个测试结果都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemMinLimitArr;                     //每个测试项最小值数组
    NSMutableArray  *testItesmMaxLimitArr;                    //每个测试项最大值数组
    NSMutableArray  *testItemUnitArr;
    NSMutableArray  *TestItemArr;                             //软件测试总结果
    NSMutableString *testAppendString;                        //软件测试所有值
    NSMutableString *testResultAppendStr;                     //存取测试对象的结果
    NSMutableString  *TestItemResult;                          //存取测试对象的结果

    
    NSThread        * thread;                                   //开启的线程
    AgilentE4980A   * agilentE4980A;                            //LCR表
    AgilentB2987A   * agilentB2987A;                            //静电计
    SerialPort      * serialport;                               //串口通讯类
    UpdateItem      * updateItem;                               //
    Plist           * plist;                                    //plist文件处理类
    enum AgilentB2987ACommunicateType  AgilentB2987A_USB_Type;
    //Param           * param;                                    // param参数类
    
    
    
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
    NSMutableString     * txtContentString;                   //打印txt文件中的log
    NSMutableString     * listFailItemString;                 //测试失败的项目
    NSMutableString     * ErrorMessageString;                 //失败测试项的原因
    
    //检测PDCA和SFC的BOOL//测试结果PASS、FAIL
    BOOL       PF;
    
    //存储生成文件的具体地址
    NSString   * eachCsvDir;
    NSString   * totalPath;
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
    NSMutableString        * dcrAppendString;                    //DCR拼接的数据
    BOOL                   addDcr;                               //40组DCR数据
    NSString               * companyName;                        //公司名称
    
    BOOL                    Instrument;                          //仪器是否连接OK
    BOOL                    isDebug;                             //debug模式
    
    //新增加测试时时的Log值
    NSString            * testLogPath;                           //生成的时时LOG值
    NSString            * deviation;                             //偏差
    NSMutableArray      * RfixArray;                             //5次测量的大电阻参考值
    Alert               * alert;

   
    
}
@end

@implementation TestAction

/**相关的说明
  1.Fixture ID 返回的值    Fixture ID?\r\nEW011X*_*\r\n       其中x代表治具中A,B,C,D

 
 
*/

-(id)initWithTable:(Table *)tab withFixParam:(Param *)param withType:(int)type_num
{
    isDebug      = param.isDebug;
    deviation    = param.deviation;
    alert        = [Alert shareInstance];

    if (self == [super init]) {
        
        singleFloder = param.SingleFolder;
        NSDictionary  * fix;
        if (type_num == 1) fix = param.Fix1;
        if (type_num == 2) fix = param.Fix2;
        if (type_num == 3) fix = param.Fix3;
        if (type_num == 4) fix = param.Fix4;
        
        
        //初始化各种数据及其设备消息
        self.fixture_uart_port_name = [fix objectForKey:@"fixture_uart_port_name"];
        self.fixture_uart_baud      = [fix objectForKey:@"fixture_uart_baud"];
        self.instr_2987             = [fix objectForKey:@"b2987_adress"];
        self.instr_4980             = [fix objectForKey:@"e4980_adress"];
        
        testLogPath                 = [NSString stringWithFormat:@"%@/%@",[[NSUserDefaults standardUserDefaults] objectForKey:kTotalFoldPath],@"TestLog.txt"];
        companyName = @"Lens";
        
        
        //初始化各种的整型变量
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
        addDcr  = NO;
        Instrument = NO;
        self.isShow = NO;
        
        //初始化各类数组和可变字符串
        ItemArr             = [[NSMutableArray alloc]initWithCapacity:10];
        TestItemArr         = [[NSMutableArray  alloc] initWithCapacity:10];
        txtContentString    =[[NSMutableString alloc]initWithCapacity:10];
        listFailItemString  =[[NSMutableString alloc]initWithCapacity:10];
        ErrorMessageString  =[[NSMutableString alloc]initWithCapacity:10];
        dcrAppendString     = [[NSMutableString alloc] initWithCapacity:10];
        store_Dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        testAppendString    = [[NSMutableString alloc] initWithCapacity:10];
        testResultAppendStr = [[NSMutableString alloc] initWithCapacity:10];
        RfixArray           = [[NSMutableArray alloc] initWithCapacity:10];
        
    
        //初始化各种串口
        plist = [Plist shareInstance];
        timeDay     =  [GetTimeDay shareInstance];
        sfcManager  =  [BYDSFCManager Instance];
        serialport  =  [[SerialPort alloc]init];
        updateItem  =  [[UpdateItem alloc] init];
        agilentE4980A = [[AgilentE4980A alloc]init];
        agilentB2987A = [[AgilentB2987A alloc]init];
        [serialport setTimeout:1 WriteTimeout:1];
        
        //赋值
        
        updateItem.fix_ABC_DEF_Res  = [fix objectForKey:@"fix_ABC_DEF_Res"];
        updateItem.fix_B2_E2_Res    = [fix objectForKey:@"fix_B2_E2_Res"];
        updateItem.fix_B4_E4_Res    = [fix objectForKey:@"fix_B4_E4_Res"];
        updateItem.fix_B_E_Res      = [fix objectForKey:@"fix_B_E_Res"];
        updateItem.fix_Cap          = [fix objectForKey:@"fix_Cap"];
        
        //初始化文件处理类
        csv_file  = [[FileCSV alloc] init];
        [csv_file addGlobalLock];
        txt_file  = [FileTXT shareInstance];
        [txt_file TXT_Open:testLogPath];
        total_file= [[FileCSV alloc] init];
        [total_file addGlobalLock];
        fold     =  [[Folder  alloc] init];
        teststep = [TestStep Instance];
        [teststep addGlobalLock];
        
        
        //=======================定义通知
        //监听启动
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NSThreadStart_Notification:) name:@"NSThreadStart_Notification" object:nil];
        //监听空测试
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(selectNullTestNoti:) name:kTestModeNotice object:nil];
        //写入空测的值
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeNullValueToPlist:) name:@"WriteNullValue" object:nil];
        //Test数据选择
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectTestDataNoti:) name:kTest40DataNotice object:nil];

        //监听公司名称的变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectCompanyNotice:) name:kTestCompanyNotice object:nil];
    
        
        //获取全局变量
        thread = [[NSThread alloc]initWithTarget:self selector:@selector(TestAction) object:nil];
        [thread start];
    }
    
    return  self;
}





-(void)TestAction
{
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
        
#pragma mark--------连接治具
        if (index == 0) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            if (isDebug) {
                NSLog(@"%@==index= 0,debug:connect fixture OK%@,",[NSThread currentThread],self.fixture_uart_port_name);
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Enter Debug Mode",index]];
                [self UpdateTextView:@"index=0,Enter Debug Mode" andClear:YES andTextView:self.Log_View];
                index =1;
             }
            else
            {
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,fixture start connect",index]];
                BOOL isCollect = [serialport Open:self.fixture_uart_port_name];
                if (isCollect) {
                     //发送指令获取ID的值
                     [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,fixture connect success",index]];
                    [NSThread sleepForTimeInterval:0.2];
                    [serialport WriteLine:@"Fixture ID?"];
                    [NSThread sleepForTimeInterval:0.5];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Fixture ID?",index]];
                     FixtureID = [serialport ReadExisting];
                    if ([FixtureID containsString:@"\r\n"]&&[FixtureID containsString:@"\r\n"]) {
                        
                        FixtureID = [[FixtureID componentsSeparatedByString:@"\r\n"] objectAtIndex:1];
                        FixtureID = [FixtureID stringByReplacingOccurrencesOfString:@"*_*" withString:@""];
                        index =1;
                    }
                    
                     NSLog(@"index= 0,连接治具%@",self.fixture_uart_port_name);
                     [self UpdateTextView:@"index=0,治具已经连接" andClear:NO andTextView:self.Log_View];
                    
                }
            }
        }
        
#pragma mark--------连接LCR表4980 和 静电仪器2987A
        if (index == 1) {
            
            [NSThread sleepForTimeInterval:0.5];
            if (isDebug) {
                
                NSLog(@"index= 1,debug:Instrument has connect%@,debug",self.instrument_name);
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,debug,InStrument connect success",index]];
                [self UpdateTextView:@"index=2,进入debug模式,仪表已连接" andClear:NO andTextView:self.Log_View];
                index =1000;
            }
            else
            {
               
                if (!is_LRC_Collect) {
                    
                    is_LRC_Collect = [agilentE4980A Find:self.instr_4980 andCommunicateType:AgilentE4980A_Communicate_DEFAULT]&&[agilentE4980A OpenDevice:nil andCommunicateType:AgilentE4980A_USB_Type];
                }
                
                if (!is_LRC_Collect){
                    NSLog(@"LCR-4980 Not Connected");
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,LCR Connect Fail",index]];
                    [self UpdateTextView:@"index=1,LCR-4980 Not Connected" andClear:NO andTextView:self.Log_View];
                }
                else{
                    NSLog(@"LCR-4980 Connected");
                    [self UpdateTextView:@"index=1,LCR-4980 Connected" andClear:NO andTextView:self.Log_View];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,LCR Connect Success",index]];
                }
                
                
                if (!is_JDY_Collect) {
                    
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Start Connect DMM",index]];
                    is_JDY_Collect = [agilentB2987A Find:self.instr_2987 andCommunicateType:AgilentB2987A_USB_Type]&&[agilentB2987A OpenDevice:self.instr_2987 andCommunicateType:AgilentB2987A_USB_Type];
                    
                }
                
                if (!is_JDY_Collect){
                    
                    NSLog(@"JDY-2987 Not Connected");
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Connect DMM FAIL",index]];
                    [self UpdateTextView:@"index=1,JDY-2987 Not Connected" andClear:NO andTextView:self.Log_View];
                }
                else
                {
                    NSLog(@"LCR-2987 Connected");
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Connect DMM success",index]];
                    [self UpdateTextView:@"index=1,LCR-2987 Connected" andClear:NO andTextView:self.Log_View];
                    
                }
                
                if (is_LRC_Collect&&is_JDY_Collect)
                {
                    [self UpdateTextView:@"index=1,测试仪器已连接" andClear:NO andTextView:self.Log_View];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Instrument Connect success",index]];
                    
                    Instrument = YES;
                }
            }
        }
#pragma mark--------获取输入框中的SN
        if (index == 2)
        {
            //通过通知抛过来SN，以及气缸的状态
            [NSThread sleepForTimeInterval:0.5];
             NSLog(@"index =2,等待SN");
            
            if (_dut_sn.length == 17||_dut_sn.length==21)
            {
                
                testAppendString       = [NSMutableString string];
                testResultAppendStr    = [NSMutableString string];
                
                NSLog(@"index= 2,检测SN,并打印SN的值%@",_dut_sn);
                //启动测试的时间,csv里面用
                start_time = [[GetTimeDay shareInstance] getFileTime];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,SN is OK",index]];
                [self UpdateTextView:@"index=2,SN已经检验成功" andClear:NO andTextView:self.Log_View];
                
                index =3;
            }
        }
        
#pragma mark--------检测SN是否上传
        if (index == 3)
        {
            [NSThread sleepForTimeInterval:0.2];
            if (isDebug)
            {
                NSLog(@"index = 3,检测SN是否上传,debug");
                [txtContentString appendFormat:@"%@:index=3,debug模式\n",[timeDay getFileTime]];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Debug Mode",index]];
                [self UpdateTextView:@"index=3,进入debug模式,检测SN上传" andClear:NO andTextView:self.Log_View];
                
                index = 4;
            }
            else
            {
                index = 4;//进入正常测试中
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,SN is OK",index]];
            }
        }
        
        
#pragma mark--------进入正常测试中
        if (index == 4)
        {
            
            [NSThread sleepForTimeInterval:0.3];
            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Testing",index]];
            NSLog(@"打印tab中数组中的值%lu",(unsigned long)[self.tab.testArray count]);

            
            
            testItem = [[Item alloc] initWithItem:self.tab.testArray[item_index]];
            
            BOOL isPass =[self TestItem:testItem];
            
            [TestItemArr addObject:testItem];
            
            if (isPass)
            {//测试成功
                
                [self UpdateTextView:[NSString stringWithFormat:@"index=4:%@ 测试OK",testItem.testName] andClear:NO andTextView:self.Log_View];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,%@Test:Pass",index,testItem.testName]];
                
            }
            else//测试结果失败
            {
                [self UpdateTextView:[NSString stringWithFormat:@"index=4:%@ 测试NG",testItem.testName] andClear:NO andTextView:self.Log_View];
                [self UpdateTextView:[NSString stringWithFormat:@"FailItem:%@\n",testItem.testName] andClear:NO andTextView:self.Fail_View];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,%@Test:Fail",index,testItem.testName]];
            }
    
            //刷新界面
            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=4,%@-->Flush",testItem.testName]];
            [self.tab flushTableRow:testItem RowIndex:row_index with:fix_type];

            
            item_index++;
            row_index++;
            //走完测试流程,进入下一步
            if (item_index == [self.tab.testArray count])
            {
                //给设备复位
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,%@-->Test Finshed",index,testItem.testName]];
                [self UpdateTextView:@"index=4,测试项测试结束" andClear:NO andTextView:self.Log_View];
                index = 5;
                
            }
        }
        
#pragma mark--------生成本地数据
        if (index == 5)
        {
           //测试结束的时间,csv里面用
            end_time = [[GetTimeDay shareInstance] getFileTime];
            [NSThread sleepForTimeInterval:0.2];
            NSString * path = [[NSUserDefaults standardUserDefaults] objectForKey:kTotalFoldPath];
            [fold Folder_Creat:path];
            NSString   * totalCSV = [self backTotalFilePathwithFloder:path];
           //穴位总数据
            if (total_file!=nil) {
                
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Total File Path:%@",index,totalCSV]];
                BOOL need_title = [total_file CSV_Open:totalCSV];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Open Total File Path",index]];
                [self SaveCSV:total_file withBool:need_title];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Add Data to TotalCSV",index]];
                [self UpdateTextView:@"index=5,往总文件中添加数据" andClear:NO andTextView:self.Log_View];
            }
            
            
            
           //Config下面总数据
            totalPath  = [NSString stringWithFormat:@"%@/%@/%@/%@",path,companyName,self.NestID,[self.Config_pro length]>0?self.Config_pro:@"NoConfig"];
            NSLog(@"打印Config文件的位置%d=========%@",fix_type,totalPath);
            [fold Folder_Creat:totalPath];
             NSString   * configCSV = [self backTotalFilePathwithFloder:totalPath];
            if (total_file!=nil) {
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Config File Path:%@",index,configCSV]];
                BOOL need_title = [total_file CSV_Open:configCSV];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Open Config File",index]];
                [self SaveCSV:total_file withBool:need_title];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Add Data to Config File",index]];
                [self UpdateTextView:@"index=5,Config总文件中添加数据" andClear:NO andTextView:self.Log_View];
            }
            
            
            //2.============================生成总文件夹下面的单个文件
            @synchronized (self)
            {
                //生成单个产品的value值csv文件
                [NSThread sleepForTimeInterval:0.2];
                eachCsvDir = [NSString stringWithFormat:@"%@/%@_%@",totalPath,self.dut_sn,[timeDay getCurrentMinuteAndSecond]];
                [fold Folder_Creat:eachCsvDir];
                 NSString * eachCsvFile = [NSString stringWithFormat:@"%@/%@_%@_%u.csv",eachCsvDir,self.dut_sn,end_time,arc4random()%100];
                if (csv_file!=nil)
                {
                    BOOL need_title = [csv_file CSV_Open:eachCsvFile];
                    [self SaveCSV:csv_file withBool:need_title];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Add Data to Single CSV",index]];
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
            [self writeTestLog:fix_type withString:@"index=5,Local Data has Finshed"];
            [self UpdateTextView:@"index=5,本地数据生成完成" andClear:NO andTextView:self.Log_View];
            index = 6;
        }
        
#pragma mark--------上传PDCA和SFC
        if (index == 6)
        {            
            //上传PDCA和SFC
            [NSThread sleepForTimeInterval:0.3];
            [self UpdateTextView:@"index=6,准备上传PDCA" andClear:NO andTextView:self.Log_View];
            index = 7;
            
        }
        
        
        //将结果显示在界面上
        if (index == 7)
        {
            //清空字符串
            NSMutableDictionary  * resultdic = [[NSMutableDictionary alloc] initWithCapacity:10];
            txtContentString =[NSMutableString stringWithString:@""];
            listFailItemString = [NSMutableString stringWithString:@""];
            ErrorMessageString = [NSMutableString stringWithString:@""];
            dcrAppendString    = [NSMutableString stringWithString:@""];
            [ItemArr removeAllObjects];
        
            //设置传送的数据
            [resultdic setObject:_dut_sn forKey:@"dut_sn"];
            [resultdic setObject:eachCsvDir forKey:@"eachCsvDir"];
            [resultdic setObject:totalPath forKey:@"totalPath"];
            [resultdic setObject:testAppendString forKey:@"value"];
            [resultdic setObject:testResultAppendStr forKey:@"result"];
        
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resultTF setStringValue:PF?@"PASS":@"FAIL"];
                
               if (PF)
               {
                   
                  [self.resultTF setTextColor:[NSColor greenColor]];
                  [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=7,write data to Dictionary%@",resultdic]];
                  [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dP",fix_type] userInfo:resultdic];
                  [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=7,Push Dictionary%@",resultdic]];
                }
                else
                {
                
                 [self.resultTF setTextColor:[NSColor redColor]];
                
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=7,write data to Dictionary%@",resultdic]];
                 [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dF",fix_type] userInfo:resultdic];
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=7,Push Dictionary%@",resultdic]];
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
            
            
            //仪器仪表释放掉
           [agilentB2987A CloseDevice];
           [agilentE4980A CloseDevice];
           is_LRC_Collect = NO;
           is_JDY_Collect = NO;
           Instrument     = NO;
            
            //清空SN
             _dut_sn=@"";
            if (nulltest) {
                nullTimes++;
            }
           
            index = 1000;
            item_index =0;
            row_index = 0;
            PF = YES;
            
            
        }
     
#pragma mark===================发送消息，防止休眠
        if (index == 1000)
        {
            [NSThread sleepForTimeInterval:0.01];
            if (!isDebug) {
                 index = 1;
            }
           
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
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=4,%@ send command:%@",subTestDevice,subTestCommand]];
                
                 [serialport WriteLine:subTestCommand];
                
                 [NSThread sleepForTimeInterval:0.5];
                 fixtureBackString = [serialport ReadExisting];
                
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=5,get backValue:%@",fixtureBackString]];
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
                [self writeTestLog:fix_type withString:@"LCR Set RES begin"];
                [agilentE4980A SetMessureMode:AgilentE4980A_RX andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR Set RES finsh"];
                
            }
            else if([subTestCommand isEqualToString:@"CPD"])
            {
                [self writeTestLog:fix_type withString:@"LCR Set CPD begin"];
                [agilentE4980A SetMessureMode:AgilentE4980A_CPD andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR Set CPD finsh"];
                
            }
            else if ([subTestCommand isEqualToString:@"CPQ"])
            {
                [self writeTestLog:fix_type withString:@"LCR Set CPQ begin"];
                [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR Set CPQ finsh"];
                
            }
            else if ([subTestCommand isEqualToString:@"CSD"])
            {
                [self writeTestLog:fix_type withString:@"LCR Set CSD begin"];
                [agilentE4980A SetMessureMode:AgilentE4980A_CSD andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR Set CSD finsh"];
                
            }
            else if ([subTestCommand containsString:@"CSQ"])
            {
                [self writeTestLog:fix_type withString:@"LCR Set CSQ begin"];
                [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR Set CSQ finsh"];
                
            }
            else if ([subTestCommand containsString:@"Read"])
            {
                [self writeTestLog:fix_type withString:@"LCR Read"];
                [agilentE4980A WriteLine:@":FETC?" andCommunicateType:AgilentE4980A_USB_Type];
                [NSThread sleepForTimeInterval:0.5];
                agilentReadString=[agilentE4980A ReadData:16 andCommunicateType:AgilentE4980A_USB_Type];
                NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                num = [arrResult[0] floatValue];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"LCR Read Value:%f",num]];
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
                
                if (isDebug) {
                    
                    [self writeTestLog:fix_type withString:@"DMM Start Read"];
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
                    [self writeTestLog:fix_type withString:@"DMM Set RES begin"];
                    [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type];
                    [self writeTestLog:fix_type withString:@"DMM Set RES finsh"];
                }
                else if ([subTestCommand containsString:@"Read"]) {
                    
                    if (addDcr) {
                        double num1;
                        int readtimes = 40;
                        [self writeTestLog:fix_type withString:@"静电仪开始读取40组数据"];
                        while (readtimes>0) {
                            
                            readtimes--;
                            [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                            [NSThread sleepForTimeInterval:0.4];
                            agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                            NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                            num1 = [arrResult[0] floatValue];
                            [dcrAppendString appendString:[NSString stringWithFormat:@"%.3f,",num1*1E-9]];
                        }
                        [self writeTestLog:fix_type withString:@"静电仪读取40组数据成功"];
                        NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                        num = [arrResult[0] floatValue];
                        
                    }
                    else
                    {
                        
                        int readtimes = 0;
                        [self writeTestLog:fix_type withString:@"静电仪开始正常读取数据"];
                        while (YES) {
                            
                            readtimes++;
                            
                            [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                            [NSThread sleepForTimeInterval:0.4];
                            agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                            
                            if ([agilentReadString length]>0||readtimes>=2) {
                                
                                break;
                            }
                        }
                        
                        NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                        num = [arrResult[0] floatValue];
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"静电仪读取数据:%f",num]];
                        
                    }
                }
            }
            else
            {
                if (isDebug) {
                    
                    testvalue = @"11111111111";
                }
                else if ([subTestCommand containsString:@"RES"]) {
                    [self writeTestLog:fix_type withString:@"DMM Set “RES” begin"];
                    [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type];
                    [self writeTestLog:fix_type withString:@"DMM Set “RES” finsh"];
                }
                else if ([subTestCommand containsString:@"Read"]) {
                    
                    [self writeTestLog:fix_type withString:@"DMM Start Read"];
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
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"DMM Read Data:%f",num]];
                    
                }
            }
        }
        //延迟时间
        else if ([subTestDevice isEqualToString:@"SW"])
        {
            [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
            if (!isDebug)
            {
                 NSLog(@"软件休眠时间");
                [NSThread sleepForTimeInterval:DelayTime];
                [txtContentString appendFormat:@"%@:index=4,%@ delay time\n",[timeDay getFileTime],subTestDevice];
            }

        }
        else
        {
            NSLog(@"其它的情形");
        }
        
    }
    
    
    
#pragma mark--------对数据进行处理
    if ([testitem.testName containsString:@"Fixture ID"]) {
        
        testvalue =  [FixtureID length]>0?FixtureID:@"null";
    }
    else if ([testitem.testName containsString:@"Slot ID"])
    {
        testvalue = [NSString stringWithFormat:@"%d",fix_type];
    }
    else if ([testitem.units containsString:@"GOhm"]) {//GOhm
        if (![testitem.testName containsString:@"B2987_CHECK"]) {

            if (!nulltest)
            {
                if ([testitem.testName isEqualToString:@"B_E_DCR"]||[testitem.testName isEqualToString:@"B2_E2_DCR"]||[testitem.testName isEqualToString:@"H203_BC_B4_E4_DCR_X"]||[testitem.testName isEqualToString:@"ABC_DEF_DCR"]) {
                     testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
                    if ([testitem.testName isEqualToString:@"H203_BC_B4_E4_DCR_X"]&&[testvalue floatValue]<0) {
                        
                       testvalue = @"1001";
                    }
                    [self storeValueToDic_with_name:testitem.testName];
                }
            }
            else//空测试的情况
            {
                
                if (isDebug) {
                    num = [[NSString stringWithFormat:@"%u00000000000",arc4random()%3] doubleValue];
                }

                
                double Rfixture   = num*1E-9;
                
                if([testitem.testName isEqualToString:@"H203_BC_B4_E4_DCR_X"])
                {
                    NSLog(@"打印空测的值%f",Rfixture);
                }
                
                if ([testitem.testName isEqualToString:@"B_E_DCR"]||[testitem.testName isEqualToString:@"B2_E2_DCR"]||[testitem.testName isEqualToString:@"H203_BC_B4_E4_DCR_X"]||[testitem.testName isEqualToString:@"ABC_DEF_DCR"]) {
                    
                    testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
                    [self add_RFixture_Value_To_Sum_Testname:testitem.testName RFixture:Rfixture];
                }
                
                NSLog(@"item_index:%d=======testitem.testName:%@=========testvalue:%@",item_index,testitem.testName,testvalue);
            }
        }
        else
        {
              testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
        }
        
    }
    else if ([testitem.units containsString:@"MOhm"])//MOhm
    {
        if (!nulltest)
        {

            if ([testitem.testName isEqualToString:@"B2_E2_ACR_1000"]||[testitem.testName isEqualToString:@"H200_BC_B4_E4_ACR_1000_X"]) {
                
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
            
            if ([testitem.testName isEqualToString:@"H200_BC_B4_E4_ACR_1000_X"])
            {
                Cap_Sum += Cfix;
                
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"H202_BC_B4_E4_ACR_1000_Cdut_X"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"H108_BC_ISOLATION_Z_AC"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"H202_BC_B4_E4_ACR_1000_Cdut_X"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"H108_BC_ISOLATION_Z_AC"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"H201_BC_B4_E4_ACR_1000_Cfix_X"];
            }
        }
    }
    else if ([testitem.units containsString:@"Ohm"])//Ohm
    {
        testvalue = [NSString stringWithFormat:@"%.2f",num];
        if (isDebug)
        {
            double i=arc4random()%10+100.000000;
            testvalue=[NSString stringWithFormat:@"%.2f",i];
        }
    }
    else if ([testitem.testName containsString:@"H205_TEMP_X"])
    {
        if (isDebug) {
            
            testvalue = @"26";
        }
        else
        {
            testvalue =[self.Config_Dic objectForKey:kTemp];
        }
        
     
    }
    else if ([testitem.testName containsString:@"H206_HUMID_X"])
    {
        if (isDebug) {
            
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
    if ([testitem.testName containsString:@"_Vmeas"] || [testitem.testName containsString:@"_Rref"] || [testitem.testName containsString:@"_Cfix"] || [testitem.testName containsString:@"_Vs"] || [testitem.testName containsString:@"_Cref"] || [testitem.testName containsString:@"_Rdut"] || [testitem.testName containsString:@"_Cdut"] || [testitem.testName containsString:@"_Rfix"]||[testitem.testName containsString:@"ISOLATION"])
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
    if (!(testvalue==NULL)) {
        [ItemArr addObject:testitem];      //将测试项加入数组中
        [testAppendString appendFormat:@"%@,",testvalue];
        
        if (fix_type==1) [testResultAppendStr appendFormat:@"%@,",testitem.result1];
        if (fix_type==2) [testResultAppendStr appendFormat:@"%@,",testitem.result2];
        if (fix_type==3) [testResultAppendStr appendFormat:@"%@,",testitem.result3];
        if (fix_type==4) [testResultAppendStr appendFormat:@"%@,",testitem.result4];
    }
    return ispass;
}


//================================================
//保存csv
//================================================
-(void)SaveCSV:(FileCSV *)csvFile withBool:(BOOL)need_title
{
    NSString * line    =  @"";
    NSString * value  =  @"";
    
    for(int i=0;i<[ItemArr count];i++)
    {
        Item *testitem=ItemArr[i];
        
        if (fix_type == 1) {value  = testitem.value1;}
        if (fix_type == 2) {value  = testitem.value2;}
        if (fix_type == 3) {value  = testitem.value3;}
        if (fix_type == 4) {value  = testitem.value4;}
        
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
    
    NSString *  contentStr = [NSMutableString stringWithFormat:@"\n%@,%@,%@,%@,%@,%@,%@%@,%@",self.dut_sn,test_result,@"Cr",companyName,self.NestID,self.Config_pro,line,start_time,end_time];

    NSMutableString  * contentString = [NSMutableString stringWithString:contentStr];
    

    //如果addDcr=YES,加数据加到contentString中
    if (addDcr)
    {
          [contentString appendString:[NSString stringWithFormat:@"%@",dcrAppendString]];
    }
    
    if(need_title == YES){
        
        NSString   * titleString = [NSString stringWithFormat:@"Version:,%@\n%@",[self.Config_Dic objectForKey:kSoftwareVersion],self.csvTitle];
        
        [csvFile CSV_Write:titleString];
    }
    
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
    
    [TestItemArr removeAllObjects];
    
    if ((Instrument&&self.isTest)||isDebug) {
        
        index = 2;
    }
    else //发送通知，测试已经结束，传数值过去
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dFX",fix_type] userInfo:nil];
    }
}

#pragma mark================空测试时，公司默认为NULL
-(void)selectNullTestNoti:(NSNotification *)noti
{
    if ([noti.object isEqualToString:@"NullTest"])
    {
         nulltest = YES;
         companyName = @"NULL";
    }
    else
    {
         nulltest = NO;
    }
}


#pragma mark 写入plist文件中
-(void)writeNullValueToPlist:(NSNotification *)noti
{
    
//1.差值异常，直接退出重新测试
//2.测试值OK，重新退出
//3.次数比较少，直接提示重新空测
    
    //获取数组中最大与最小的差值与平均值得%x进行判断
    if ([self getDifferValue:RfixArray withPercent:[deviation floatValue]]) {
        nullTimes = 0;
        B4_E4_Sum = 0;
        Cap_Sum   = 0;
        [RfixArray removeAllObjects];
        [alert ShowCancelAlert:[NSString stringWithFormat:@"第%d穴空测值差值超过%@,请重新空测",fix_type,deviation] Window:[NSApplication sharedApplication].keyWindow];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDifferNullTestNotice object:nil];
        return;
    }
    
    
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
    
    [agilentB2987A CloseDevice];
    [agilentE4980A CloseDevice];
    
    //数据清空
    B4_E4_Sum = 0;
    nullTimes = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinshNullTestNotice object:nil];

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



#pragma mark--------------监听公司名称的改变
-(void)selectCompanyNotice:(NSNotification *)noti
{
    companyName = noti.object;
}


#pragma mark-----------------多次测试和的值
-(void)add_RFixture_Value_To_Sum_Testname:(NSString *)testname RFixture:(double)RFixture
{
    NSString *largeRes= @"1001";
    if ([testname isEqualToString:@"B_E_DCR"])                   B_E_Sum   = B_E_Sum + fabs(RFixture);
    if ([testname isEqualToString:@"B2_E2_DCR"])                 B2_E2_Sum = B2_E2_Sum + fabs(RFixture);
    if ([testname isEqualToString:@"H203_BC_B4_E4_DCR_X"])       B4_E4_Sum = B4_E4_Sum + fabs(RFixture);
    if ([testname isEqualToString:@"ABC_DEF_DCR"])               ABC_DEF_Sum =ABC_DEF_Sum + fabs(RFixture);
    
    //加入数组中
    [RfixArray addObject:[NSString stringWithFormat:@"%f",RFixture]];
    
    
    if ([testname isEqualToString:@"H203_BC_B4_E4_DCR_X"]) {
        
        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"H109_BC_ISOLATION_R_DC"];
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",RFixture] forKey:@"H204_BC_B4_E4_DCR_Rfix_X"];
    }
    else
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",RFixture] forKey:[NSString stringWithFormat:@"%@_Rfix",testname]];
    }
}



#pragma mark----------------GΩ情况下调用方法，testname为测试项的名称
-(void)storeValueToDic_with_name:(NSString *)testname
{
    double Rdut,Rfixture;
    NSString *largeRes=@"1001";
    Rfixture=num*1E-9;

    if ([testname isEqualToString:@"B_E_DCR"]) {
        Rfixture = [updateItem.fix_B_E_Res floatValue];
    }
    if ([testname isEqualToString:@"B2_E2_DCR"]) {
        Rfixture = [updateItem.fix_B2_E2_Res floatValue];
    }
    if ([testname isEqualToString:@"H203_BC_B4_E4_DCR_X"]) {
         Rfixture = [updateItem.fix_B4_E4_Res floatValue];
    }
    if ([testname isEqualToString:@"ABC_DEF_DCR"]) {
         Rfixture = [updateItem.fix_ABC_DEF_Res floatValue];
    }
    
    Rdut=(num*1E-9*Rfixture)/(Rfixture-num*1E-9);
    
    
    if (isDebug) {
        
        Rdut = arc4random()%100;
    }
    
    if ([testname isEqualToString:@"H203_BC_B4_E4_DCR_X"]) {
        
        //提示空测
        //DCR为负值，超过量程，Rdut显示1001
        //DCR为正值，DCR-Rfix>0,Rdut显示-999,提示空测
        //DCR为正值, DCR-Rfix<0,正常计算
        //          Rdut>1000时，显示1001
        //          0<Rdut<1000时，正常计算
        
        if (num*1E-9>1000||num*1E-9<0||Rdut >=1000) {
            
            [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"H109_BC_ISOLATION_R_DC"];
        }
        else
        {
            if (num*1E-9>=Rfixture) {
                
                [store_Dic setValue:[NSString stringWithFormat:@"%@",@"-999"] forKey:@"H109_BC_ISOLATION_R_DC"];
                self.isShow = YES;
            }
            else
            {
                [store_Dic setValue:[NSString stringWithFormat:@"%f",Rdut] forKey:@"H109_BC_ISOLATION_R_DC"];
            }
        }
        
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:@"H204_BC_B4_E4_DCR_Rfix_X"];
    
        
    }
    else
    {
    
        if (num*1E-9>= Rfixture || Rdut > 1000 || num*1E-9 < 0)
        {
            [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
        }
        else
        {
            [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
        }
        
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:[NSString stringWithFormat:@"%@_Rfix",testname]];
    
    }
}


#pragma mark----------------MΩ情况下调用的方法，
-(void)storeValueToDic_With_Item:(Item *)item
{
    double Cdut,Cfix,Rdut;
    NSString *smallCap=@"<1fF";
    NSString *largeACR=@">100GOhm";
    Cfix=[updateItem.fix_Cap floatValue];
    Cdut=fabs(num*1E+12-Cfix);
    Rdut=1E+6/(Cdut*2*3.14159*item.freq.integerValue);
    
    if ([item.testName isEqualToString:@"H200_BC_B4_E4_ACR_1000_X"]) {
        
            if (Cdut <= 0)
            {
                [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"H202_BC_B4_E4_ACR_1000_Cdut_X"];
                [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"H108_BC_ISOLATION_Z_AC"];
            }
            else
            {
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"H202_BC_B4_E4_ACR_1000_Cdut_X"];
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"H108_BC_ISOLATION_Z_AC"];
            }
        
            [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"H201_BC_B4_E4_ACR_1000_Cfix_X"];
    }
    else
    {
    
        
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



#pragma mark ===============写入Log文件
-(void)writeTestLog:(int)fixtype withString:(NSString *)writeString
{
   
    if (fix_type==1) {
        
        [txt_file TXT_Write:[NSString stringWithFormat:@"%@:A Solt-->%@\n",[timeDay getFileTime], writeString]];
    }
    else if (fix_type==2)
    {
        [txt_file TXT_Write:[NSString stringWithFormat:@"%@:B Solt-->%@\n",[timeDay getFileTime],writeString]];
    }
    else if (fix_type==3)
    {
        [txt_file TXT_Write:[NSString stringWithFormat:@"%@:C Solt-->%@\n",[timeDay getFileTime],writeString]];
    }
    else if (fix_type==4)
    {
        [txt_file TXT_Write:[NSString stringWithFormat:@"%@:D Solt-->%@\n",[timeDay getFileTime],writeString]];
    }
    else
    {
        
    }
}


#pragma mark 获取数组中最大值和最小值的偏差
-(BOOL)getDifferValue:(NSArray *)array withPercent:(float)percent
{
    
    double  max = [[array valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double  min = [[array valueForKeyPath:@"@min.doubleValue"] doubleValue];
    double  arv = [[array valueForKeyPath:@"@avg.doubleValue"] doubleValue];
    
    //如果percent<=1,则按比例计算；如果>=1,则按照数值计算
     NSLog(@"差值%f==均值=%f====%f",max-min,arv,percent);
    if (percent< 1) {
        
        if ((max-min)>arv*percent) {
            return YES;
        }
        return NO;
    }
    else
    {
        if (max-min>percent) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
   
}





@end
