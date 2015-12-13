//
//  AppDelegate.h
//  DrPPPoEBooter
//
//  Created by KingsleyYau on 14-3-31.
//  Copyright (c) 2014年 KingsleyYau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (NSArray *)runningProcesses;
@end
