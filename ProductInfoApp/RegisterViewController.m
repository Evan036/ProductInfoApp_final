//
//  RegisterViewController.m
//  ProductInfoApp
//
//  Created by Evan on 2015/6/19.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
- (IBAction)pressReturn:(id)sender;
@property (weak, nonatomic) NSString * fromReset;
@property NSMutableDictionary *appSetting;
@property (strong, nonatomic) NSString * deviceToken;
@property NSString *myStorybord;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 改變Status bar 的顏色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //設定StatusBarStyle為白色文字表示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,20)];
    //設定StatusBar 的背景顏色
    //R-242, G-148, B-23
    label.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:148.0/255.0f blue:23.0/255.0f alpha:1.0];
    [self.view addSubview:label];
    //確認是否是由重新註冊功能來的request, 如果不是則需要把pressReturn按鈕隱藏起來.
    if ([_fromReset isEqualToString:@"YES"]) {
        //do nothing
    } else {
        //hidden button
        UIButton *button = (UIButton *)[self.view viewWithTag:100];
        button.hidden = YES;
    }
    //檢查StoryBoard
    [self checkStoryBoard];
    //設定Textfield的delegate
    self.phoneNumber.delegate = self;

    //讀取APP的設定檔中的devicetoken
    NSString *plistPath = [self getPlistPath];
    self.appSetting = [[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] mutableCopy];
    self.deviceToken = [self.appSetting objectForKey:@"DeviceToken"];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.phoneNumber) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) checkStoryBoard{
    CGSize iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSScreenSize.height == 568) {
        //iPhone 5/5C/5S
        self.myStorybord = @"Main";
    }
    if (iOSScreenSize.height == 667) {
        //iPhone 6
        self.myStorybord = @"iPhone6";
    }
    if (iOSScreenSize.height == 736) {
        //iPhone 6 plus
        self.myStorybord = @"iPhone6p";
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //將page2設定成Storyboard Segue的目標UIViewController
    id page2 = segue.destinationViewController;
    
    //將值透過Storyboard Segue帶給頁面2的string變數
    [page2 setValue:self.phoneNumber.text forKey:@"phoneNumber"];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"toConfirmPhone"]) {
        //phone number validation
        // next step is to implement validateForm
        NSString *errorMessage = [self validateForm];
        if (errorMessage) {
            [[[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"確定", nil] show];
            return false;
        }
        
        // Send the form values to the server here.
        [self postRegisted];
        
    }
    return true;
}

//Registered in FCC APP Server
-(void) postRegisted{
    NSString *link =[self.appSetting objectForKey:@"RegURL"];
    NSLog(@"Regist URL=%@",link);
    NSString *variable1 = @"mobile=";
    variable1 = [variable1 stringByAppendingString:self.phoneNumber.text];
    NSString *variable2 = @"&token=";
    variable2 = [variable2 stringByAppendingString:self.deviceToken];
    NSString *variable3 = @"&type=1";
    NSString *stringData = [NSString stringWithFormat: @"%@%@%@", variable1, variable2, variable3];
    NSLog(@"post string =%@",stringData);
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
    req.HTTPMethod =@"POST";
    req.HTTPBody = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connectionError %@", connectionError);
            //TODO:Alter message and return to registeration screen
            return;
        }
    }];
    
}


- (NSString *)validateForm {
    NSString *errorMessage;
    
    NSString *regex = @"09[0-9]{8}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (!(self.phoneNumber.text.length == 10)){
        errorMessage = @"請輸入完整的手機號碼";
    } else if (![emailPredicate evaluateWithObject:self.phoneNumber.text]){
        errorMessage = @"請輸入手機號碼格式09XXXXXXXX";
    }
    
    return errorMessage;
}

#pragma mark - 存取PList檔
-(NSString *)getPlistPath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Setting.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: plistPath])
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
        NSError *error;
        [fileManager copyItemAtPath:bundlePath toPath:plistPath error:&error];
    }
    
    return plistPath;
}


- (IBAction)pressReturn:(id)sender {
    //返回主選單
    NSString * storyboardName = self.myStorybord;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"MainMenu"];
    [self presentViewController:vc animated:YES completion:nil];
}
@end
