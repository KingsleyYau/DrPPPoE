//
//  MainViewController.h
//  DrPPPoE
//
//  Created by KingsleyYau on 14-4-2.
//  Copyright (c) 2014年 KingsleyYau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (nonatomic, weak) IBOutlet UIView *usernameView;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UIView *passwordView;
@property (nonatomic, weak) IBOutlet UITextField *passTextField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *logoutButton;

@property (nonatomic, weak) IBOutlet UIView *markView;

- (IBAction)loginAction:(id)sender;
- (IBAction)logoutAction:(id)sender;

- (BOOL)login:(NSString *)username password:(NSString *)password;
- (void)logout;
- (BOOL)checkStatus;
@end
