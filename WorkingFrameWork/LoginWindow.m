//
//  LoginWindow.m
//  BCM
//
//  Created by xhkj on 2018/2/7.
//  Copyright © 2018年 macjinlongpiaoxu. All rights reserved.
//

#import "LoginWindow.h"
#import "Common.h"

@interface LoginWindow ()
{
    NSMutableDictionary *m_Dic;
    
    IBOutlet NSButton *singleTestButton;
    
    IBOutlet NSButton *nullTestButton;
    
    IBOutlet NSButton *LoopTestButton;
    
    IBOutlet NSButton *SfcUploadButton;
    
    IBOutlet NSButton *PdcaUploadButton;
    
    IBOutlet NSButton *test_40_Data_button;
    
}
@end

@implementation LoginWindow

-(id)init
{
    self = [super initWithWindowNibName:@"LoginWindow"];
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}











- (IBAction)choose_TestMode:(id)sender {
    
    NSButton   * button = sender;
    
    if ([button.title containsString:@"Single-Test"]) {
        
        if (singleTestButton.state) {
            
            nullTestButton.state = NO;
            LoopTestButton.state = NO;
        }
        
    }
    
    if ([button.title containsString:@"Null-Test"]) {
        
        if (nullTestButton.state) {
            
            singleTestButton.state = NO;
            LoopTestButton.state   = NO;
        }
        
    }
    if ([button.title containsString:@"Loop-Test"]) {
        
        if (LoopTestButton.state) {
            
            singleTestButton.state = NO;
            nullTestButton.state = NO;
        }
    }
}





- (IBAction)clickToLogin:(NSButton *)sender
{
    //*********测试模式选择*********//
    //单个产品测试
    if (singleTestButton.state)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTestModeNotice object:@"SingleTest"];
        
        [self.window orderOut:self];
    }
    //循环测试
    else if (LoopTestButton.state) {

        [[NSNotificationCenter defaultCenter] postNotificationName:kTestModeNotice object:@"LoopTest"];
        
        [self.window orderOut:self];
    }
    //正常测试
    else
    {
         [[NSNotificationCenter defaultCenter] postNotificationName:kTestModeNotice object:@"NormalTest"];
    }
    
    
    //*********40组数据选择*********//
    if (test_40_Data_button.state)
    {
         [[NSNotificationCenter defaultCenter] postNotificationName:kTest40DataNotice object:@"YES"];
    }
    else
    {
         [[NSNotificationCenter defaultCenter] postNotificationName:kTest40DataNotice object:@"NO"];
    }
    
    
    //*********数据上传选择*********//
    if (SfcUploadButton.state)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSfcUploadNotice object:@"YES"];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSfcUploadNotice object:@"NO"];
    }

    if (PdcaUploadButton.state)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPdcaUploadNotice object:@"YES"];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPdcaUploadNotice object:@"NO"];
    }

    [self.window orderOut:self];
    

}



@end
