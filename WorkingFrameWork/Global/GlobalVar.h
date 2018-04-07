//
//  GlobalVar.h
//  WorkingFrameWork
//
//  Created by mac on 14/12/2017.
//  Copyright © 2017 macjinlongpiaoxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVar : NSObject

@property(nonatomic,strong)NSArray  *  itemArr;

+(instancetype) shareInstance;

@end
