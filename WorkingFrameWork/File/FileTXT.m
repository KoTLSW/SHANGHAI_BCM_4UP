//
//  FileTXT.m
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "FileTXT.h"
@interface FileTXT(){

    NSString *txtpath;
    NSLock   *_lock;
      
}
@end

@implementation FileTXT

static FileTXT * _instance = nil;

+(instancetype) shareInstance;
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance;
}

- (id)init
{
    
    self = [super init];
    
    if (self)
    {
        txtpath = nil;
        _lock = [[NSLock alloc]init];
    }
    
    return self;
}

-(BOOL)TXT_Open:(NSString*)name
{
    NSFileManager *fm = [NSFileManager defaultManager];
    txtpath = name;
    if(![fm fileExistsAtPath:name])
    {
        [fm createFileAtPath:name contents:nil attributes:nil];
        return YES;
    }
    return NO;
}
-(void)TXT_Write:(NSString*)line
{
    if (txtpath!=nil) {
        NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:txtpath];
        [file seekToEndOfFile];
        [file writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
    }
    
}
-(NSString*)TXT_Read
{
    NSString *str = nil;
    if(txtpath!=nil)
    {
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:txtpath];
        [file seekToFileOffset:0];
        NSData *data = [file readDataToEndOfFile];
        str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [file closeFile];
    }
    return str;
}



@end
