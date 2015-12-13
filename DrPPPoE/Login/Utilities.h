//
//  Utilities.h
//  DrCOMClientWS
//
//  Created by Keqin Su on 11-5-5.
//  Copyright 2011 City Hotspot Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface Utilities : NSObject {

}

+ (void) showDrAlert:(NSString*)msg;
+ (NSString*) trimString:(NSString*)str;
+ (NSString*) MD5StringOfString:(NSString*)inputStr;
+ (NSString*) compareIPAddress:(NSString*)ipAddress;
+ (NSString*) GetHardwareAddress:(NSString*)ipAddress;
+ (NSString*) GetHardwareAddressList;
+ (NSString*) encodeString:(NSString*)str key:(NSString*)key;
+ (NSString*) decodeString:(NSString*)str key:(NSString*)key;
+ (NSString*) findStringBetween:(NSString*)data strBegin:(NSString*)strBegin strEnd:(NSString*)strEnd;

@end
