//
//  Item.m
//  MKPlist_Sample
//
//  Created by Michael on 16/11/7.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "Item.h"

@implementation Item

-(id)initWithItem:(Item *)item
{
    
    if (self == [super init])
    {
        self.id = item.id;
        self.retryTimes = item.retryTimes;
        self.testName = item.testName;
        self.testFailItems =item.testFailItems;
        self.max = item.max;
        self.min = item.min;
        self.isTest = item.isTest;
        self.isShow = item.isShow;
        self.messageError = item.messageError;
        self.value1 = item.value1;
        self.value2 = item.value2;
        self.value3 = item.value3;
        self.value4 = item.value4;
        
        self.result1 = item.result1;
        self.result2 = item.result2;
        self.result3 = item.result3;
        self.result4 = item.result4;
        self.testAllCommand = item.testAllCommand;
        self.units = item.units;
        self.freq = item.freq;
        
    }


    return [super init];
}

@end
