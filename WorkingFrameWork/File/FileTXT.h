//
//  FileTXT.h
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileTXT : NSObject

+(instancetype) shareInstance;
-(BOOL)TXT_Open:(NSString*)name;
-(void)TXT_Write:(NSString*)line;
-(NSString*)TXT_Read;
@end
