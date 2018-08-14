//
//  ManagerPdca.h
//  BCM
//
//  Created by mac on 07/04/2018.
//  Copyright © 2018 macjinlongpiaoxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManagerPdca : NSObject

@property(nonatomic,strong)NSString * A_resultStr;
@property(nonatomic,strong)NSString * B_resultStr;
@property(nonatomic,strong)NSString * C_resultStr;
@property(nonatomic,strong)NSString * D_resultStr;

-(void)UploadPDCA_Dafen:(int)num Dic:(NSDictionary *)dic Arr:(NSArray *)array BOOL:(BOOL)isPass;

@end
