//
//  Plist.h
//  MKPlist_Sample
//
//  Created by Michael on 16/11/7.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "UpdateItem.h"
#import "Common.h"

@interface Plist : NSObject

@property(nonatomic,strong)NSMutableString  * titile;

//=============================================
+(Plist *)shareInstance;
-(NSMutableArray *)PlistRead:(NSString *)fileName Key:(NSString *)key;
-(NSDictionary *)PlistRead:(NSString *)fileName;
- (void)PlistWrite:(NSString*)filename UpdateItem:(UpdateItem *)updateItem Key:(NSString *)key;
//=============================================

@end
