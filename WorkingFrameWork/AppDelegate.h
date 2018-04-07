//
//  AppDelegate.h
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

// 强引用窗口控制器
@property (strong) NSWindowController *mainWindowController;
@property(nonatomic,assign)int coutNum;
@property(nonatomic,assign)int totalNum;
@property(nonatomic,assign)NSLock * lock;
@end

