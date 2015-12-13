//
//  SettingFileController.m
//  DrCOMClientWS
//
//  Created by Keqin Su on 11-4-18.
//  Copyright 2011 City Hotspot Co., Ltd. All rights reserved.
//

#import "SettingFileController.h"

@interface SettingFileController()
- (void) getTheRangesByKey:(NSString*)data key:(NSString*)key keyRange:(NSRange*)keyRange valueRange:(NSRange*)valueRange;
@end

@implementation SettingFileController

#define SettingFilePath @"/DrCOMConfig"
#define EvaluateMark @":="
#define EndMark @";\n"

- (void) getTheRangesByKey:(NSString*)data key:(NSString*)key keyRange:(NSRange*)keyRange valueRange:(NSRange*)valueRange
{
	NSString* beginKey = [key stringByAppendingString:EvaluateMark];
	*keyRange = [data rangeOfString:beginKey];
	if ((*keyRange).length > 0) {
		// the key was exist;
		NSRange valueFindingRange;
		valueFindingRange.length = [data length] - ((*keyRange).location + (*keyRange).length);
		valueFindingRange.location = (*keyRange).location + (*keyRange).length;
		NSRange endRange = [data rangeOfString:EndMark options:NSCaseInsensitiveSearch range:valueFindingRange];
		if (endRange.length > 0) {
			(*valueRange).location = valueFindingRange.location;
			(*valueRange).length = endRange.location - valueFindingRange.location;
		}
	}
}

// write, read and delete parameter in setting file
- (BOOL) writeParamInSettingFile:(NSString*)key value:(NSString*)value
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [paths objectAtIndex:0];
	NSString *path = [docPath stringByAppendingString:SettingFilePath];
	
	// get setting file data
    NSError *errorF;
	NSMutableString* data = [[NSMutableString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&errorF];
	if (nil == data) {
		data = [[NSMutableString alloc] init];
	}
	
	NSRange keyRange;
	NSRange valueRange;
	[self getTheRangesByKey:data key:key keyRange:&keyRange valueRange:&valueRange];
	if (keyRange.length > 0) {
		[data deleteCharactersInRange:valueRange];
		[data insertString:value atIndex:valueRange.location];
	} else {
		[data appendString:key];
		[data appendString:EvaluateMark];
		[data appendString:value];
		[data appendString:EndMark];
	}
	
	NSError *error;
	Boolean result = [data writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];

	return result;
}

- (NSString*) readParamInSettingFile:(NSString*)key
{
	NSString* value = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [paths objectAtIndex:0];
	NSString *path = [docPath stringByAppendingString:SettingFilePath];
	
	// read setting file data
    NSError *errorF;
	NSString* data = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&errorF];
	
	NSRange keyRange;
	NSRange valueRange;
	[self getTheRangesByKey:data key:key keyRange:&keyRange valueRange:&valueRange];
	if (keyRange.length > 0 && valueRange.length > 0) {
		value = [data substringWithRange:valueRange];
	}
	
	return value;
}

- (void) deleteParamInSettingFile:(NSString*)key
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [paths objectAtIndex:0];
	NSString *path = [docPath stringByAppendingString:SettingFilePath];
	
	// read setting file data
    NSError *errorF;
	NSMutableString* data = [[NSMutableString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&errorF];
	
	NSRange keyRange;
	NSRange valueRange;
	[self getTheRangesByKey:data key:key keyRange:&keyRange valueRange:&valueRange];
	if (keyRange.length > 0 && valueRange.length > 0) {
		NSRange deleteRange;
		deleteRange.location = keyRange.location;
		deleteRange.length = keyRange.length + valueRange.length + [EndMark length];
		[data deleteCharactersInRange:deleteRange];
		
		NSError *error;
		[data writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
	}
}
@end
