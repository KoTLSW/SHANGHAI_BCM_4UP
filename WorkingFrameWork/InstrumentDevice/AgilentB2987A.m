//
//  AgilentB2987A.m
//  Communication
//
//  Created by mac on 2017/9/11.
//  Copyright © 2017年 maceastwin. All rights reserved.
//USB0::0x0957::0xD618::MY54320331::0::INSTR
//USB0::0x0957::0x9418::MY54320416::INSTR

#import "AgilentB2987A.h"

@implementation AgilentB2987A

-(BOOL)FindAndOpen:(NSString *)serial
{
    return NO;
}


-(BOOL) OpenDevice
{
    if (_isOpen) return YES;
    status = viOpen(defaultRM, instrDescriptor, VI_NULL,VI_NULL, &instr);
    if (status==VI_SUCCESS) {
        return YES;
    }else
    {
        _isOpen=false;
        return NO;
    }
}


-(void)CloseDevice
{
    
    if (!_isOpen) return;
    /* Now close the session we just opened.                            */
    /* In actuality, we would probably use an attribute to determine    */
    /* if this is the instrument we are looking for.                    */
    viClose (instr);
    status = viClose(findList);
    status = viClose (defaultRM);
    
    //2015.1.19
    _isOpen = FALSE;
}


-(NSMutableArray *)getArrayAboutGPIBDevice
{
    
        return nil;
}

-(void)SetMessureMode:(enum AgilentB2987AMessureMode)mode andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType
{
    switch (mode) {
        case AgilentB2987A_RES:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            
            //            [self WriteLine:@":SENS:RES:RANG:AUTO ON" andCommunicateType:communicateType];usleep(50*1000);
            
            [self WriteLine:@":SENS:FUNC:ON 'RES'" andCommunicateType:communicateType];usleep(10*1000);
//            [self WriteLine:@":SENS:RES:RANG:AUTO:LLIM 1E+9" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:RES:RANG:AUTO ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:CURR:NPLC:AUTO ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SOUR:FUNC:MODE VOLT" andCommunicateType:communicateType]; usleep(50*1000);
            [self WriteLine:@":SOUR:VOLT 20" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":OUTP ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:RES:APER 1" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:RES:NPLC 1" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":INP ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:RES:VSEL VSO" andCommunicateType:communicateType];usleep(50*1000);
            
            
//            [self WriteLine:@":MEAS:RES?" andCommunicateType:communicateType];usleep(10*1000);
            
        }
            break;
            
        case AgilentB2987A_CURR:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SOUR:FUNC:MODE VOLT" andCommunicateType:communicateType]; usleep(50*1000);
            [self WriteLine:@":SOUR:VOLT 20" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:FUNC 'CURR'" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:CURR:RANG:AUTO ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:CURR:NPLC:AUTO OFF" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:CURR:APER 1" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:CURR:NPLC 1" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":OUTP ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":INP ON" andCommunicateType:communicateType];usleep(2000*1000);
            [self WriteLine:@":MEAS:CURR?" andCommunicateType:communicateType];usleep(1000*1000);        }
            break;
            
        case AgilentB2987A_VOLT:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SOUR:FUNC:MODE VOLT" andCommunicateType:communicateType]; usleep(50*1000);
            [self WriteLine:@":SOUR:VOLT 20" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:FUNC 'VOLT'" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:VOLT:RANG:AUTO ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:VOLT:NPLC:AUTO ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:VOLT:APER:AUTO ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":SENS:VOLT:GUAR OFF" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":OUTP ON" andCommunicateType:communicateType];usleep(50*1000);
            [self WriteLine:@":INP ON" andCommunicateType:communicateType];usleep(2000*1000);
            [self WriteLine:@":MEAS:VOLT?" andCommunicateType:communicateType];usleep(1000*1000);
        }
            break;
            
            
            break;
        default:
            break;
    }
}


-(BOOL) WriteLine:(NSString*)writeString
{
    /*  Now we must enable the service request event so that VISA
     *  will receive the events.  Note: one of the parameters is
     *  VI_QUEUE indicating that we want the events to be handled by
     *  a synchronous event queue.  The alternate mechanism for handling
     *  events is to set up an asynchronous event handling function using
     *  the VI_HNDLR option.  The events go into a queue which by default
     *  can hold 50 events.  This maximum queue size can be changed with
     *  an attribute but it must be called before the events are enabled.
     */
    status = viEnableEvent (instr, VI_EVENT_SERVICE_REQ, VI_QUEUE, VI_NULL);
    
    
    NSString* dataLine = [[NSString alloc] initWithFormat:@"%@\n", writeString];
    NSInteger dataLen = [dataLine length];
    char inputBuffer[dataLen];
    strcpy(inputBuffer, [dataLine UTF8String]);
    
    status = viWrite (instr, (ViBuf)inputBuffer, (ViUInt32)strlen(inputBuffer), &writeCount);
    if (status < VI_SUCCESS)
    {
        return NO;
    }
    
    return YES;
}




//GPIB通信
-(NSString*) ReadData:(int)readDataCount
{
    
    return nil ;
}

-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType
{
    /*
     * At this point we now have a session open to the instrument at
     * Primary Address 2.  We can use this session handle to write
     * an ASCII command to the instrument.  We will use the viWrite function
     * to send the string "*IDN?", asking for the device's identification.
     */
    
    
    switch (communicateType) {
        case AgilentB2987A_LAN_Type:
            status = viSetAttribute (instr, VI_ATTR_TCPIP_NODELAY, 8000);
            break;
        case AgilentB2987A_USB_Type:
            status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 8000);
            break;
        default:
            status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 8000);
            NSLog(@"其它的通信方式");
            break;
    }
    
    NSString* dataLine = [[NSString alloc] initWithFormat:@"%@\n", data];
    NSInteger dataLen = [dataLine length];
    char inputBuffer[dataLen];
    strcpy(inputBuffer, [dataLine UTF8String]);
    
    status = viWrite (instr, (ViBuf)inputBuffer, (ViUInt32)strlen(inputBuffer), &writeCount);
    if (status < VI_SUCCESS)
    {
        return NO;
    }
    
    return YES;
}


//*******************注意*************************//
//网口通信一次最多只能够读取16个字节，既readDataCount<=16;
-(NSString*) ReadData:(int)readDataCount  andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType
{
    
    unsigned char buffer[20* readDataCount];   //建立缓存空间
    memset(buffer, 0, 20* readDataCount);      //对内存空间进行清零处理
    switch (communicateType) {
        case AgilentB2987A_LAN_Type:
            status = viRead (instr, buffer, readDataCount, &retCount);
            break;
        case AgilentB2987A_USB_Type:
            status = viRead (instr, buffer, readDataCount, &retCount);
            break;
        default:
            NSLog(@"其它的通信方式");
            break;
    }
    
    if (status < VI_SUCCESS)
    {
        return @"";
    }
    
    NSString *result = [[NSString alloc] initWithUTF8String:(const char*)buffer];
    return result ;
}

+(NSArray *)getArratWithCommunicateType:(enum AgilentB2987ACommunicateType)communicateType;
{
    NSMutableArray * array=[[NSMutableArray alloc]init];
    ViSession deRM;
    ViFindList findLt = 0;
    ViUInt32 numInstr = 0;
    char instrDes[VI_FIND_BUFLEN];
    int status = viOpenDefaultRM (&deRM);
    if (status < VI_SUCCESS)
    {
        exit (EXIT_FAILURE);
    }
    
    switch (communicateType) {
            
        case AgilentB2987A_LAN_Type:
            status = viFindRsrc (deRM, "TCPIP0::A-B2987A-20331.local::?*", &findLt, &numInstr, instrDes);
            break;
        case AgilentB2987A_USB_Type:
            status = viFindRsrc (deRM, "USB0::0x0957::0xD618::?*INSTR", &findLt, &numInstr, instrDes);
            break;

        default:
            status = viFindRsrc (deRM, "USB0::0x0957::0x9318::?*INSTR", &findLt, &numInstr, instrDes);
            NSLog(@"其它的通信方式");
            break;
    }
    
    while (status==0 && numInstr--) {
        NSString *instr = [NSString stringWithUTF8String:instrDes];
        [array addObject:instr];
        status = viFindNext(findLt, instrDes);
        if (status < VI_SUCCESS)continue;
    }
    
    viClose (deRM);
    return array;
}

-(BOOL) Find:(NSString *)serial andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType
{
    status = viOpenDefaultRM (&defaultRM);
    if (status < VI_SUCCESS){
        exit (EXIT_FAILURE);
    }
    
    /*
     * Find all the VISA resources in our system and store the number of resources
     * in the system in numInstrs.  Notice the different query descriptions a
     * that are available.
     
     Interface         Expression
     --------------------------------------
     GPIB              "GPIB[0-9]*::?*INSTR"
     VXI               "VXI?*INSTR"
     GPIB-VXI          "GPIB-VXI?*INSTR"
     Any VXI           "?*VXI[0-9]*::?*INSTR"
     Serial            "ASRL[0-9]*::?*INSTR"
     PXI               "PXI?*INSTR"
     All instruments   "?*INSTR"
     All resources     "?*"
     */
    
    if (serial == nil) {
        
        switch (communicateType) {
                
            case AgilentB2987A_USB_Type:
                status = viFindRsrc (defaultRM, "USB0::0x0957::?*INSTR", &findList, &numInstrs, instrDescriptor);
                break;
            case AgilentB2987A_LAN_Type:
                status = viFindRsrc (defaultRM, "TCPIP0::A-B2987A-20331.local::?*", &findList, &numInstrs, instrDescriptor);
                break;
            default:
                NSLog(@"其它的通信方式");
                break;
        }
        
        if (status < VI_SUCCESS)
        {
            return false;
        }
        
        
    }else{
        const char *s = [serial UTF8String];
        status = viFindRsrc (defaultRM, (char*)s, &findList, &numInstrs, instrDescriptor);
        
        if (status == VI_SUCCESS){
            self.agilentSerial=serial;
        }
    }
    
    if (status < VI_SUCCESS){
        printf ("An error occurred while finding resources.\n");
        fflush(stdin);
        viClose (defaultRM);
        return NO;
    }
    
    NSLog(@"%s",instrDescriptor);
    return YES;
}

-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum AgilentB2987ACommunicateType)communicateType
{
    
    if (_isOpen) return YES;
    
    //    status = viOpen (defaultRM, "TCPIP0::169.254.4.10::5025::SOCKET", VI_NULL, VI_NULL, &instr);
    
    switch (communicateType) {
        case AgilentB2987A_LAN_Type:
            status = viOpen (defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
            break;
        case AgilentB2987A_USB_Type:
            status = viOpen (defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
            break;
        default:
            status = viOpen (defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
            NSLog(@"其它的通信方式");
            break;
    }
    
    
    if (status < VI_SUCCESS)
    {
        
        return NO;
    }
    _isOpen = YES;
    
    return YES;
}

-(void)delayMs:(int)ms{
    HiperTimer* timer=[[HiperTimer alloc] init];
    [timer Start];
    while ([timer durationMillisecond]<ms);
    timer=nil;
}




@end
