//
//  Table1.m
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/12.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Table.h"



//=============================================
@interface Table ()

@property(nonatomic,assign)int  index;
@end
//=============================================
@implementation Table
//=============================================
- (id)init:(NSView*)parent DisplayData:(NSArray*)arrayData
{
    
    self = [super init];
    
    
    _index=0;
    
    if (self)
    {
        
         self.testArray =arrayData;
        [self InitTableView:arrayData];
                
        [parent addSubview:self.view];
        
        self.view.translatesAutoresizingMaskIntoConstraints =NO;
        
        NSLayoutConstraint *constraint = nil;
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeLeading
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeTrailing
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        
        
        
        
//        [self.table setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
//        [self.table setAllowsColumnResizing:YES];
//        NSArray* columns=[self.table tableColumns];
//        for(int i=0;i<[columns count];i++)
//        {
//            [columns[i] setWidth:200];
//        }
        
    }

    return self;
}
//=============================================
- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
    NSTableView* aTableView = aNotification.object;
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,aTableView.numberOfRows)];
    [aTableView noteHeightOfRowsWithIndexesChanged:indexes];
    
    NSLog(@"aaa");
}

//=============================================
-(void)InitTableView:(NSArray*)arrayData
{
    _arrayDataSource =[[NSMutableArray alloc] init];
    
    NSLog(@"传递进来元素的数量%lu",(unsigned long)[arrayData count]);
        int countDisplay=1;
        
        for (int i=0; i<[arrayData count]; i++)
        {
            //解析数组下标,取值
            Item* item=[arrayData objectAtIndex:i];
            
            if((item.isTest == YES)&&(item.isShow == YES))
            {
                NSMutableDictionary* dic=[[NSMutableDictionary alloc] init];
                
                //赋值,在tableView 上显示的数据(固定值)
                [dic setValue:[NSString stringWithFormat:@"%d",countDisplay] forKey:TABLE_COLUMN_ID];
                [dic setValue:item.testName?    item.testName:@"" forKey:TABLE_COLUMN_TESTNAME];
                [dic setValue:item.units?     item.units:    @""  forKey:TABLE_COLUMN_UNITS];
                [dic setValue:item.min?     item.min:    @""      forKey:TABLE_COLUMN_MIN];
                [dic setValue:item.max?  item.max: @""            forKey:TABLE_COLUMN_MAX];
                [dic setValue:item.freq?  item.freq: @""            forKey:TABLE_COLUMN_FREQ];
                [dic setValue:item.value1 ?  item.value1:  @""    forKey:TABLE_COLUMN_VALUE_1];
                [dic setValue:item.result1 ? item.result1: @""    forKey:TABLE_COLUMN_RESULT_1];
                [dic setValue:item.value1 ?  item.value2:  @""    forKey:TABLE_COLUMN_VALUE_2];
                [dic setValue:item.result1 ? item.result2: @""    forKey:TABLE_COLUMN_RESULT_2];
                [dic setValue:item.value1 ?  item.value3:  @""    forKey:TABLE_COLUMN_VALUE_3];
                [dic setValue:item.result1 ? item.result3: @""    forKey:TABLE_COLUMN_RESULT_3];
                [dic setValue:item.value1 ?  item.value4:  @""    forKey:TABLE_COLUMN_VALUE_4];
                [dic setValue:item.result1 ? item.result4: @""    forKey:TABLE_COLUMN_RESULT_4];
                
                [_arrayDataSource addObject:dic];
                countDisplay++;
            }
        }
    
      NSLog(@"数组_arrayDataSource的个数%lu",(unsigned long)[_arrayDataSource count]);
        
        
        [self.table reloadData];
        [self.table needsDisplay];
    
}
//=============================================
-(void)SelectRow:(int)rowindex
{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:rowindex];
        [self.table selectRowIndexes:indexSet byExtendingSelection:NO];  // 选择指定行
        [self.table scrollRowToVisible:rowindex];                        // 滚动到指定行
        [self.table needsDisplay];
    });
}

//=============================================
-(void)flushTableRow:(Item*)item RowIndex:(NSInteger)rowIndex with:(int)fixtype
{
    
    NSLog(@"打印_arrayDataSource = %lu元素",[_arrayDataSource count]);
    
    if (fixtype == 1)
    {
         BOOL ispass1 = NO;
         if([item.result1 isEqualToString:@"PASS"])ispass1=YES;
        NSDictionary* color1 = [NSDictionary dictionaryWithObjectsAndKeys:ispass1?[NSColor greenColor]:[NSColor redColor],NSForegroundColorAttributeName, nil];
        NSAttributedString* result1 = [[NSAttributedString alloc] initWithString:ispass1?@"  PASS":@"  FAIL" attributes:color1];
        [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.value1       forKey:TABLE_COLUMN_VALUE_1];
        [[_arrayDataSource objectAtIndex:rowIndex] setValue:result1           forKey:TABLE_COLUMN_RESULT_1];
        
    }
    else if (fixtype == 2)
    {
        BOOL ispass2 = NO;
        if([item.result2 isEqualToString:@"PASS"])ispass2=YES;
        NSDictionary* color2 = [NSDictionary dictionaryWithObjectsAndKeys:ispass2?[NSColor greenColor]:[NSColor redColor],NSForegroundColorAttributeName, nil];
        NSAttributedString* result2 = [[NSAttributedString alloc] initWithString:ispass2?@"  PASS":@"  FAIL" attributes:color2];
        [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.value2       forKey:TABLE_COLUMN_VALUE_2];
        [[_arrayDataSource objectAtIndex:rowIndex] setValue:result2           forKey:TABLE_COLUMN_RESULT_2];
        
    }
    else if (fixtype == 3)
    {
         BOOL ispass3 = NO;
         if([item.result3 isEqualToString:@"PASS"])ispass3=YES;
         NSDictionary* color3 = [NSDictionary dictionaryWithObjectsAndKeys:ispass3?[NSColor greenColor]:[NSColor redColor],NSForegroundColorAttributeName, nil];
         NSAttributedString* result3 = [[NSAttributedString alloc] initWithString:ispass3?@"  PASS":@"  FAIL" attributes:color3];
        [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.value3       forKey:TABLE_COLUMN_VALUE_3];
        [[_arrayDataSource objectAtIndex:rowIndex] setValue:result3           forKey:TABLE_COLUMN_RESULT_3];
        
    }
    else if (fixtype == 4)
    {
        BOOL ispass4 = NO;
        if([item.result4 isEqualToString:@"PASS"])ispass4=YES;
        NSDictionary* color4 = [NSDictionary dictionaryWithObjectsAndKeys:ispass4?[NSColor greenColor]:[NSColor redColor],NSForegroundColorAttributeName, nil];
        NSAttributedString* result4 = [[NSAttributedString alloc] initWithString:ispass4?@"  PASS":@"  FAIL" attributes:color4];
        [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.value4       forKey:TABLE_COLUMN_VALUE_4];
        [[_arrayDataSource objectAtIndex:rowIndex] setValue:result4           forKey:TABLE_COLUMN_RESULT_4];
    
    
    }
    
    NSLog(@"1==%@,2===%@,3====%@,4===%@",item.result1,item.result2,item.result3,item.result4);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:rowIndex];
        [self.table selectRowIndexes:indexSet byExtendingSelection:YES]; // 选择指定行
        [self.table scrollRowToVisible:rowIndex];// 滚动到指定行
        [self.table reloadData];
        [self.table needsDisplay];
    });
}


//=============================================
-(void)ClearTable
{
    for (int i=0; i<[_arrayDataSource count]; i++)
    {
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_VALUE_1];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_RESULT_1];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_VALUE_2];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_RESULT_2];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_VALUE_3];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_RESULT_3];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_VALUE_4];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_RESULT_4];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
}

#pragma mark-tableView Delegate/DataSource
//=============================================
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_arrayDataSource count];
}
//=============================================
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([_arrayDataSource objectAtIndex:row]==nil)
        
        return @"";
    else
    {
    
        return [[_arrayDataSource objectAtIndex:row] objectForKey:[tableColumn identifier]];
    }
}
//=============================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
//=============================================

-(void)flushTableDic:(NSDictionary*)dic RowIndex:(NSInteger)rowIndex
{


    BOOL ispass = NO;
    
    if([dic[@"result"] isEqualToString:@"PASS"])ispass=YES;
    
    NSLog(@"================%@",dic[@"result"]);
    
    
    NSDictionary* color = [NSDictionary dictionaryWithObjectsAndKeys:ispass?[NSColor greenColor]:[NSColor redColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString* result = [[NSAttributedString alloc] initWithString:ispass?@"          PASS":@"          FAIL" attributes:color];
    
    //给模型对应的 key 值赋值
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:dic[@"value"]   forKey:TABLE_COLUMN_VALUE_1];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:result           forKey:TABLE_COLUMN_RESULT_1];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:rowIndex];
        [self.table selectRowIndexes:indexSet byExtendingSelection:NO]; // 选择指定行
        [self.table scrollRowToVisible:rowIndex];// 滚动到指定行
        [self.table reloadData];
        [self.table needsDisplay];
    });



}

//=============================================
@end

