//
//  FileCSV.h
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCSV : NSObject
//=======================================
- (id)init;
+(instancetype) shareInstance;
- (void)addGlobalLock;
- (BOOL)CSV_Open:(NSString*)path;
- (void)CSV_Write:(NSString*)line;
//=======================================

@end
