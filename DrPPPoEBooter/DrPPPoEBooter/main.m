//
//  main.m
//  DrPPPoEBooter
//
//  Created by KingsleyYau on 14-3-31.
//  Copyright (c) 2014年 KingsleyYau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#include <string>
using namespace std;

/*
 * 运行命令
 */
static inline void SystemComandExecute(string command) {
	string sCommand = command;
	sCommand += " &>/dev/null";
	system(sCommand.c_str());
}

int main(int argc, char * argv[])
{
    @autoreleasepool {
        // 关闭旧的进程
        NSArray *arrayProcess = [AppDelegate runningProcesses];
        for(NSDictionary *dictProcess in arrayProcess) {
            NSString *processName = [dictProcess objectForKey:@"ProcessName"];
            NSString *processID = [dictProcess objectForKey:@"ProcessID"];
            if([processName isEqualToString:@"PPPoEiOSTest_"]) {
                char cmd[1024] = {'\0'};
                sprintf(cmd, "kill -s HUP %s", [processName UTF8String]);
                SystemComandExecute(cmd);
                break;
            }
        }
        
        // 重新打开
        NSString* string = [[NSBundle mainBundle] pathForResource:@"PPPoEiOSTest_" ofType:nil];
        argv[0] = (char*)[string UTF8String];
        execve([string UTF8String], argv, NULL);
    }
}
