//
//  ConfigInstr.m
//  BCM
//
//  Created by mac on 26/02/2018.
//  Copyright © 2018 macjinlongpiaoxu. All rights reserved.
//

#import "ConfigInstr.h"

@interface ConfigInstr ()
{
    __weak IBOutlet NSPopUpButton *PopButton_2987A;

    __weak IBOutlet NSPopUpButton *PopButton_2987B;

    __weak IBOutlet NSPopUpButton *PopButton_2987C;
    
    __weak IBOutlet NSPopUpButton *PopButton_2987D;
    
    
    
    
    __weak IBOutlet NSPopUpButton *PopButton_4980A;
    
    __weak IBOutlet NSPopUpButton *PopButton_4980B;
    
    __weak IBOutlet NSPopUpButton *PopButton_4980C;
    
    __weak IBOutlet NSPopUpButton *PopButton_4980D;
    
    
    AgilentTools    *  aglientTools;                   //安捷伦工具类
    NSMutableArray  *  arr_4980;                       //e4980数组
    NSMutableArray  *  arr_2987;                       //2987A数组
    NSMutableDictionary  * dictionary;                 //从param文件中读取的全局字典
    
    
}

@end

@implementation ConfigInstr




-(id)init
{
    self = [super initWithWindowNibName:@"ConfigInstr"];
    return self;
}





- (void)windowDidLoad {
    [super windowDidLoad];
    
    
     aglientTools =[AgilentTools Instance];
     arr_4980 = [[NSMutableArray alloc]initWithCapacity:10];
     arr_2987 = [[NSMutableArray alloc]initWithCapacity:10];
    
    
    NSArray  *  arr =[aglientTools getUsbArray];
//    for (NSString * agilentString in arr)
//    {
//        if ([agilentString containsString:@"0x0909"])
//        {
//            [arr_4980 addObject:agilentString];
//        }
//        else
//        {
//            [arr_2987 addObject:agilentString];
//        }
//    }
    
    //显示在界面PopButton按钮上
    [PopButton_2987A addItemsWithTitles:arr];
    [PopButton_2987B addItemsWithTitles:arr];
    [PopButton_2987C addItemsWithTitles:arr];
    [PopButton_2987D addItemsWithTitles:arr];
    
    //4980
    [PopButton_4980A addItemsWithTitles:arr];
    [PopButton_4980B addItemsWithTitles:arr];
    [PopButton_4980C addItemsWithTitles:arr];
    [PopButton_4980D addItemsWithTitles:arr];
    

#pragma mark---------下面的代码测试的时候使用
    /*
    NSArray  * arr_2987b = @[@"2987A",@"2987B",@"2987C",@"2987D"];
    [PopButton_2987A addItemsWithTitles:arr_2987b];
    [PopButton_2987B addItemsWithTitles:arr_2987b];
    [PopButton_2987C addItemsWithTitles:arr_2987b];
    [PopButton_2987D addItemsWithTitles:arr_2987b];
    NSArray  * arr_4980b = @[@"4980A",@"4980B",@"4980C",@"4980D"];
    //4980
    [PopButton_4980A addItemsWithTitles:arr_4980b];
    [PopButton_4980B addItemsWithTitles:arr_4980b];
    [PopButton_4980C addItemsWithTitles:arr_4980b];
    [PopButton_4980D addItemsWithTitles:arr_4980b];
    */
    
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)show_2987A_Action:(id)sender {
    
    
    
    
}



- (IBAction)show_4980_Action:(id)sender {
    
    
    
}






- (IBAction)Bind_Fix_InStrument:(id)sender {
    
   //将选择的仪器仪表写入param plist文件中
    NSString   * instrument_2987A = [PopButton_2987A.titleOfSelectedItem length]>0?PopButton_2987A.titleOfSelectedItem:@"";
    NSString   * instrument_2987B = [PopButton_2987B.titleOfSelectedItem length]>0?PopButton_2987B.titleOfSelectedItem:@"";
    NSString   * instrument_2987C = [PopButton_2987C.titleOfSelectedItem length]>0?PopButton_2987C.titleOfSelectedItem:@"";
    NSString   * instrument_2987D = [PopButton_2987D.titleOfSelectedItem length]>0?PopButton_2987D.titleOfSelectedItem:@"";
    
    NSString   * instrument_4980A = [PopButton_4980A.titleOfSelectedItem length]>0?PopButton_4980A.titleOfSelectedItem:@"";
    NSString   * instrument_4980B = [PopButton_4980B.titleOfSelectedItem length]>0?PopButton_4980B.titleOfSelectedItem:@"";
    NSString   * instrument_4980C = [PopButton_4980C.titleOfSelectedItem length]>0?PopButton_4980C.titleOfSelectedItem:@"";
    NSString   * instrument_4980D = [PopButton_4980D.titleOfSelectedItem length]>0?PopButton_4980D.titleOfSelectedItem:@"";
    

    //获取param.plist文件，将相关的值写入文件中
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"Param" ofType:@"plist"];
    dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    
    [self ChangeDictionaryContent:instrument_2987A Key:@"Fix1" SubKey:@"b2987_adress"];
    [self ChangeDictionaryContent:instrument_2987B Key:@"Fix2" SubKey:@"b2987_adress"];
    [self ChangeDictionaryContent:instrument_2987C Key:@"Fix3" SubKey:@"b2987_adress"];
    [self ChangeDictionaryContent:instrument_2987D Key:@"Fix4" SubKey:@"b2987_adress"];
    
    [self ChangeDictionaryContent:instrument_4980A Key:@"Fix1" SubKey:@"e4980_adress"];
    [self ChangeDictionaryContent:instrument_4980B Key:@"Fix2" SubKey:@"e4980_adress"];
    [self ChangeDictionaryContent:instrument_4980C Key:@"Fix3" SubKey:@"e4980_adress"];
    [self ChangeDictionaryContent:instrument_4980D Key:@"Fix4" SubKey:@"e4980_adress"];
  
    [dictionary writeToFile:plistPath atomically:YES];
    
    //设置完后退出软件
      exit(0);
}


/**
 *  改变字典的值
 *
 *  @param content key对应的value
 *  @param key     字典中的字典
 *  @param subkey  子字典对应的value
 */
-(void)ChangeDictionaryContent:(NSString *)content Key:(NSString *)key SubKey:(NSString *)subkey
{
     NSMutableDictionary *subDic = [dictionary objectForKey:key];
    [subDic setObject:content forKey:subkey];
    [dictionary setObject:subDic forKey:key];
}

//取消设置并关闭窗口
- (IBAction)CancelandCloseWindow:(id)sender {
    
     [self.window orderOut:self];
    
}


@end
