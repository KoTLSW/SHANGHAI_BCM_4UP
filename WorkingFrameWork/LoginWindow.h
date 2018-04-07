//
//  LoginWindow.h
//  BCM
//
//  Created by xhkj on 2018/2/7.
//  Copyright © 2018年 macjinlongpiaoxu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LoginWindow : NSWindowController

@property (weak) IBOutlet NSTextField *userName;
@property (weak) IBOutlet NSTextField *passWord;
@property (weak) IBOutlet NSTextField *logInfo;
@end
