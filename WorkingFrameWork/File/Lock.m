//
//  Lock.m
//  BCM
//
//  Created by mac on 10/03/2018.
//  Copyright © 2018 macjinlongpiaoxu. All rights reserved.
//

#import "Lock.h"

@implementation Lock

static Lock * _lock = nil;

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _lock = [[Lock alloc] init] ;
    }) ;
    
    return _lock;
}
@end
