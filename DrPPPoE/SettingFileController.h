//
//  SettingFileController.h
//  DrCOMClientWS
//
//  Created by Keqin Su on 11-4-18.
//  Copyright 2011 City Hotspot Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MaxTextFieldInputLen	32
#define DrCOMClientWS			@"DrCOMClientWS"
#define DrCOMUsername			@"DrCOMUsername"
#define DrCOMPass				@"DrCOMPass"
#define DrCOMUrl				@"DrCOMUrl"
#define DrCOMRememberPass		@"DrCOMRememberPass"
#define DrCOMSignIn				@"DrCOMSignIn"
#define DrCOMYES				@"YES"
#define DrCOMYNO				@"NO"
@interface SettingFileController : NSObject

- (BOOL) writeParamInSettingFile:(NSString*)key value:(NSString*)value;
- (NSString*) readParamInSettingFile:(NSString*)key;
- (void) deleteParamInSettingFile:(NSString*)key;

@end
