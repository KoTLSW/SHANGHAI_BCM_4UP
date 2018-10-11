//
//  Alart.m
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/26.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Alert.h"

static Alert * SharedInstance = nil;

//=============================================
@implementation Alert



+(id)allocWithZone:(struct _NSZone *)zone
{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
    
        SharedInstance =[super allocWithZone:zone];
    });
    

    return SharedInstance;

}

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        SharedInstance =[[Alert alloc]init];
    });
    

    return SharedInstance;
}


//=============================================
- (void)ShowCancelAlert:(NSString*)message Window:(NSWindow *)window
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"提示信息:";
        alert.informativeText = [NSString stringWithFormat:@"             \n             %@",message];
        [alert addButtonWithTitle:@"确定"];
        
        //第二种方式，以sheet的方式出现
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"alert 展示完毕");
           //exit(0);
        }];
        
    });
}


//=============================================
- (void)ShowCancelAlert:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"Message";
        alert.informativeText = message;
        [alert addButtonWithTitle:@"确定"];
        
        //第一种方式，以modal的方式出现
        [alert runModal];
//         exit(0);
        
    });
}
//=============================================
@end
//=============================================

