//
//  Utilities.m
//  DrCOMClientWS
//
//  Created by Keqin Su on 11-5-5.
//  Copyright 2011 City Hotspot Co., Ltd. All rights reserved.
//

#import "Utilities.h"
#import "IPAddress.h"
#import "GTMBase64.h"
#import "NSDataEx.h"
#include <zlib.h>

@implementation Utilities

+ (void)showDrAlert:(NSString*)msg {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
	[alert show];
}

+ (NSString*) trimString:(NSString*)str {
	if (str && str.length > 0) {
		while ([str hasPrefix:@" "]) {
			str = [str substringFromIndex:1];
		}
		while ([str hasSuffix:@" "]) {
			str = [str substringToIndex:str.length - 1];
		}
		return str;
	}
	return @"";
}

+ (NSString*) MD5StringOfString:(NSString*)inputStr {
	NSData* inputData = [inputStr dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char outputData[CC_MD5_DIGEST_LENGTH];
	CC_MD5([inputData bytes], [inputData length], outputData);
	
	NSMutableString* hashStr = [NSMutableString string];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
		[hashStr appendFormat:@"%02x", outputData[i]];
	
	return hashStr;
}

+ (NSString*) compareIPAddress:(NSString*)ipAddress {
	NSString *devName = nil;
	InitAddresses();
    NSInteger count = GetIPAddresses();
	for (int i = 0; i < count; i++) {
		NSString* name = [NSString stringWithFormat:@"%s", if_names[i]];
		NSString* ip = [NSString stringWithFormat:@"%s", ip_names[i]];
		if ([ipAddress isEqualToString:ip]) {
			devName = name;
			break;
		}
	}
	FreeAddresses();
	return devName;
}

+ (NSString*) GetHardwareAddress:(NSString*)devName {
	NSString *HardwareAddress = nil;
	InitAddresses();
    NSInteger count = GetIPAddresses();
    GetHWAddresses();
	for (int i = 0; i < count; i++) {
        NSString* name = [NSString stringWithFormat:@"%s", if_names[i]];
		NSString* mac = [NSString stringWithFormat:@"%s", hw_addrs[i]];
        if ([devName isEqualToString:name]) {
			HardwareAddress = mac;
			break;
		}
	}
	FreeAddresses();
	return HardwareAddress;
}

+ (NSString*) GetHardwareAddressList {
    NSString *HardwareAddress = nil;
    NSString *Tmp = nil;
	InitAddresses();
    NSInteger count = GetIPAddresses();
    GetHWAddresses();
    int iCount = 1;
	for (int i = 0; i < count; i++) {
        NSString* name = [NSString stringWithFormat:@"%s", if_names[i]];
		NSString* mac = [NSString stringWithFormat:@"%s", hw_addrs[i]];
        if (([name length] > 0) && (![name isEqualToString:@"lo"]) && (![mac isEqualToString:@"00:00:00:00:00:00"])) {
            Tmp = [NSString stringWithFormat:@"%@&m%d=%s", ([HardwareAddress length] > 0) ? HardwareAddress : @"", iCount++, hw_addrs[i]];
			HardwareAddress = Tmp;
		}
	}
	FreeAddresses();
    if ([HardwareAddress length] > 1) {
        HardwareAddress = [HardwareAddress substringFromIndex:1];
    }
	return HardwareAddress;
}

+ (NSString*) encodeString:(NSString*)str key:(NSString*)key {
	NSString *value = nil;
	if ([str length] > 0) {
		NSData *original = [str dataUsingEncoding:NSUTF8StringEncoding];
		NSData *toBase64pre = [GTMBase64 encodeData:original];
		NSData *encryptData = [toBase64pre AES256EncryptWithKey:key];
		NSData *toBase64lat = [GTMBase64 encodeData:encryptData];
		NSString *data = [[NSString alloc] initWithData:toBase64lat encoding:NSUTF8StringEncoding];
		value = [NSString stringWithString:data];
	}
	return value;
}

+ (NSString*) decodeString:(NSString*)str key:(NSString*)key {
	NSString *value = nil;
	if ([str length] > 0) {
		NSData *original = [str dataUsingEncoding:NSUTF8StringEncoding];
		NSData *fromBase64pre = [GTMBase64 decodeData:original];
		NSData *decryptData = [fromBase64pre AES256DecryptWithKey:key];
		NSData *fromBase64lat = [GTMBase64 decodeData:decryptData];
		NSString *data = [[NSString alloc] initWithData:fromBase64lat encoding:NSUTF8StringEncoding];
		value = [NSString stringWithString:data];
	}
	return value;
}

+ (NSString*) findStringBetween:(NSString*)data strBegin:(NSString*)strBegin strEnd:(NSString*)strEnd {
	NSString *msg = nil;
	NSRange msgBeginRange = [data rangeOfString:strBegin];
	if (msgBeginRange.length > 0) {
		NSRange msgTempRange;
		msgTempRange.length = [data length] - (msgBeginRange.location + msgBeginRange.length);
		msgTempRange.location = msgBeginRange.location + msgBeginRange.length;
		NSRange msgEndRange = [data rangeOfString:strEnd options:NSCaseInsensitiveSearch range:msgTempRange];
		NSRange msgRange;
		msgRange.location = msgBeginRange.location + msgBeginRange.length;
		msgRange.length = msgEndRange.location - msgRange.location;
		msg = [data substringWithRange:msgRange];
	}
	return msg;
}
@end
