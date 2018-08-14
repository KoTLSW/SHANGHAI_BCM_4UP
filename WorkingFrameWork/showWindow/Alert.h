//
//  Alart.h
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/26.
//  Copyright © 2016年 h. All rights reserved.
//
#import <Cocoa/Cocoa.h>

@interface Alert : NSObject

- (void)ShowCancelAlert:(NSString*)message Window:(NSWindow *)window;

- (void)ShowCancelAlert:(NSString*)message;

+(id)allocWithZone:(struct _NSZone *)zone;

+(instancetype)shareInstance;

@end
