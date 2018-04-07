//
//  UpdateItem.m
//  BCM
//
//  Created by mac on 04/03/2018.
//  Copyright © 2018 macjinlongpiaoxu. All rights reserved.
//

#import "UpdateItem.h"

@implementation UpdateItem

-(id)initWithItem:(UpdateItem *)updateItem
{
    
    if (self == [super init])
    {
        self.fix_ABC_DEF_Res =  updateItem.fix_ABC_DEF_Res;
        self.fix_B2_E2_Res   =  updateItem.fix_B2_E2_Res;
        self.fix_B4_E4_Res   =  updateItem.fix_B4_E4_Res;
        self.fix_B_E_Res     =  updateItem.fix_B_E_Res;
        self.fix_Cap         =  updateItem.fix_Cap;
    }
    
    return [super init];
}

@end
