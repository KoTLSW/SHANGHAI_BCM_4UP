//
//  Lock.h
//  BCM
//
//  Created by mac on 10/03/2018.
//  Copyright © 2018 macjinlongpiaoxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lock : NSRecursiveLock

+(instancetype)shareInstance;

@end
