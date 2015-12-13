//
//  NSDataEx.h
//  DrCOMClientWS
//
//  Created by Keqin Su on 11-4-18.
//  Copyright 2011 City Hotspot Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(AESAdditions)
- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;
@end
