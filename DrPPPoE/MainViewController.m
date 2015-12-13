//
//  MainViewController.m
//  DrPPPoE
//
//  Created by KingsleyYau on 14-4-2.
//  Copyright (c) 2014年 KingsleyYau. All rights reserved.
//

#import "MainViewController.h"
#import "SettingFileController.h"
#import "Utilities.h"

#import "common/command.h"
#import "common/IPAddress.h"

#include "drppoe/DrppoePlugin.h"

#define DrPPPID 	"/private/var/run/ppp0.pid"
#define DrPPPoEID   "/private/var/tmp/pppoe.pid"

@interface MainViewController () {
    DrppoePlugin m_DrppoePlugin;
    DrMutex m_Mutex;
}
@property (nonatomic, retain) SettingFileController *fileController;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.usernameView.layer.borderWidth = 1;
    self.usernameView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.passwordView.layer.borderWidth = 1;
    self.passwordView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    // TODO:初始化界面
	[self setInterface];
	//reconnectSwitch.enabled = NO;
	[self setViewControl:NO];
    // TODO:初始化配置
	[self initFileSetting];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 界面事件
- (IBAction)loginAction:(id)sender {
    [self startLoading];
    dispatch_queue_t requestQueue = dispatch_queue_create("com.drcom.drpppoe.login", NULL);        dispatch_async(requestQueue, ^{
        // 开始登录,阻塞
        BOOL bFlag = [self login:self.nameTextField.text password:self.passTextField.text];
        // 登录完成
        dispatch_async(dispatch_get_main_queue(), ^{
            if(bFlag) {
                // 登录成功
                [self loginSuccess];
            }
            else {
                // 登录失败
                [self loginFail];
            }
        });
        
    });
}
- (IBAction)logoutAction:(id)sender {
    dispatch_queue_t requestQueue = dispatch_queue_create("com.drcom.com.login", NULL);        dispatch_async(requestQueue, ^{
        // 开始登录,阻塞
        [self logout];
        // 登录完成
        dispatch_async(dispatch_get_main_queue(), ^{
            [self logoutSuccess];
        });
    });
}

- (void)setInterface {
    // 初始化界面
	self.nameTextField.placeholder = NSLocalizedString(@"username", nil);
	self.passTextField.placeholder = NSLocalizedString(@"password", nil);
	[self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [self.logoutButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];

    // TODO:读取版本号
    NSString *verString = [NSString stringWithFormat:@"Ver %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    self.versionLabel.text = verString;
}
- (void)startLoading {
	[self.view addSubview:self.markView];
	[(UIActivityIndicatorView *)[self.markView viewWithTag:202] startAnimating];
	
	self.markView.center = CGPointMake(self.markView.frame.size.width/2, 0 - self.markView.frame.size.height/2);
	self.markView.alpha = 0.0f;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	self.markView.center = CGPointMake(self.markView.frame.size.width/2, self.markView.frame.size.height/2);
	self.markView.alpha = 0.70f;
	[UIView commitAnimations];
}
- (void)stopLoading {
	[(UIActivityIndicatorView *)[self.markView viewWithTag:202] stopAnimating];
	[self.markView removeFromSuperview];
}
#pragma mark - 逻辑事件
- (void)initFileSetting {
    // 读取配置文件
    self.fileController = [[SettingFileController alloc] init];
	self.nameTextField.text = [Utilities decodeString:[self.fileController readParamInSettingFile:DrCOMUsername] key:DrCOMClientWS];
    
//    // 自动登陆
//	if ([[self.fileController readParamInSettingFile:DrCOMSignIn] isEqualToString:DrCOMYES]) {
//		[rememberSwitch setOn:YES animated:YES];
//		[signSwitch setOn:YES animated:YES];
//	} else {
//		[signSwitch setOn:NO animated:YES];
//	}
//    // 记住密码
//	if ([[self.fileController readParamInSettingFile:DrCOMRememberPass] isEqualToString:DrCOMYES]) {
//		[rememberSwitch setOn:YES animated:YES];
//		passField.text = [Utilities decodeString:[self.fileController readParamInSettingFile:DrCOMPass] key:DrCOMClientWS];
//	} else {
//		[rememberSwitch setOn:NO animated:YES];
//	}
    
//    // 如果已经登录,显示状态
//    if(self.gwUrl.length > 0) {
//        [self setViewControl:YES];
//        // 调用获取在线状态
//        _drCOMAuth->SetGatewayAddress([self.gwUrl UTF8String]);
//        [self startHttpStatusTimer];
//    }
//	else if ([[self.fileController readParamInSettingFile:DrCOMSignIn] isEqualToString:DrCOMYES] && [nameField.text length] > 0 && [passField.text length] >0)  {
//        // 自动登陆
//		[self onLogin];
//	}
}
- (void)setViewControl:(BOOL)login {
    // 启用/禁用控件
	if (login) {
		self.nameTextField.hidden = YES;
		self.passTextField.hidden = YES;
		self.loginButton.hidden = YES;
        
		self.logoutButton.hidden = NO;
	} else {
		self.nameTextField.hidden = NO;
		self.passTextField.hidden = NO;
		self.loginButton.hidden = NO;
        
		self.logoutButton.hidden = YES;
	}
}
- (void)loginSuccess {
    // 刷新界面
    [self stopLoading];
	[self setViewControl:YES];

    // 记录用户名
    [self.fileController writeParamInSettingFile:DrCOMUsername value:[Utilities encodeString:self.nameTextField.text key:DrCOMClientWS]];
    [self.fileController writeParamInSettingFile:DrCOMPass value:[Utilities encodeString:self.passTextField.text key:DrCOMClientWS]];
    
    // 开始刷新在线状态
    [self startStatusTimer];
}
- (void)loginFail {
    [self stopLoading];
    [self setViewControl:NO];
    [Utilities showDrAlert:@"登录失败"];
}
- (void)logoutSuccess {
    // 刷新界面
    [self stopLoading];
    [self setViewControl:NO];
    
    // 修改配置
    if (![[self.fileController readParamInSettingFile:DrCOMRememberPass] isEqualToString:DrCOMYES]) {
        self.passTextField.text = @"";
    }
    
    // 停止在线检测
    [self.timer invalidate];
    self.timer = nil;
};
- (void)statusFail {
    [self setViewControl:NO];
    [Utilities showDrAlert:@"断线"];
    // 停止在线检测
    [self.timer invalidate];
    self.timer = nil;
}
- (void)startStatusTimer {
    // 开始每30秒刷新在线状态
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(30.0) target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        [self.timer fire];
    }
}
- (void)timerFireMethod:(NSTimer*)theTimer {
    [self status];
}

- (BOOL)status {
    // 检测在线状态
    BOOL ret = [self checkStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(ret) {
            // 在线
        }
        else {
            // 下线
            [self statusFail];
        }
    });
    return ret;
}
- (BOOL)login:(NSString *)username password:(NSString *)password {
    string strUsername = [username UTF8String];
    string strPassword = [password UTF8String];
    string cmd = "/usr/sbin/pppd pty '/usr/sbin/pppoe -I en0 -T 30 -U -m 1412' noipdefault noauth default-asyncmap defaultroute hide-password nodetach usepeerdns mtu 1492 mru 1492 noaccomp nodeflate nopcomp novj novjccomp user ";
    cmd += strUsername;
    cmd += " password ";
    cmd += strPassword;
    cmd += " lcp-echo-interval 20 lcp-echo-failure 3 &";
    
    SystemComandExecute(cmd);

    return [self checkStatus];
}
- (void)logout {
    m_Mutex.lock();
    
    char cmd[1024] = {'\0'};
    sprintf(cmd, "setprop net.pppoe.ppp-exit %s", DrPPPID);
	SystemComandExecute(cmd);
	SystemComandExecute("setprop net.pppoe.reason gone");
	SystemComandExecute("setprop net.pppoe.interface");
    
    
    FILE* file = fopen(DrPPPID, "r");
	if(NULL != file) {
        sprintf(cmd, "%s file is not NULL", DrPPPID);
		int pid = -1;
		fscanf(file, "%d", &pid);
		if(-1 != pid) {
			sprintf(cmd, "kill -s HUP %d", pid);
			SystemComandExecute(cmd);
            
			sprintf(cmd, "rm %s", DrPPPID);
			SystemComandExecute(cmd);
		}
        
		usleep(200);
		pid = GetProcessPid("pppd");
		if(-1 != pid) {
			sprintf(cmd, "kill -s HUP %d", pid);
			SystemComandExecute(cmd);
		}
		fclose(file);
	}
    
    sleep(1);
    m_DrppoePlugin.StopDrPPPoEPlugin();
    m_Mutex.unlock();
}
- (BOOL)checkStatus {
    m_Mutex.lock();
    BOOL bFlag = NO;
    
    char cmd[1024] = {'\0'};
    FILE* file = fopen(DrPPPID, "r");
	if(NULL != file) {
        sprintf(cmd, "%s file is not NULL!", DrPPPID);
		int pid = -1;
		fscanf(file, "%d", &pid);
		if(-1 != pid) {
            sprintf(cmd, "%s (pid:%d)", DrPPPID, pid);
            bFlag = YES;
		}
        
		usleep(200);
		pid = GetProcessPid("pppd");
		if(-1 != pid) {
            sprintf(cmd, "GetProcessPid (pid:%d)", pid);
            bFlag = YES;
		}
		fclose(file);
	}
    else {
        sprintf(cmd, "pppd process not found!");
    }
    
    if(bFlag == YES) {
        // 开始DrPPPoE插件协议
		m_DrppoePlugin.StartDrPPPoEPluginService();
    }
    else {

    }
    m_Mutex.unlock();
    return bFlag;
}
@end
