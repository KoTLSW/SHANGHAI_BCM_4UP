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

//上传数据
-(void)UploadPDCA_Dafen:(int)num Dic:(NSDictionary *)dic Arr:(NSArray *)array BOOL:(BOOL)isPass;

//卡站
-(NSString *)SFC_CheckSN:(NSString *)Sn WithStationID:(NSString *)station_id;

@end
