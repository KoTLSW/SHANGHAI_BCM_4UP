//
//  GlobalVar.m
//  WorkingFrameWork
//
//  Created by mac on 14/12/2017.
//  Copyright © 2017 macjinlongpiaoxu. All rights reserved.
//

#import "GlobalVar.h"

@implementation GlobalVar

static GlobalVar * global = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        global = [[self alloc] init] ;
    }) ;
    
    return global;
}




@end
