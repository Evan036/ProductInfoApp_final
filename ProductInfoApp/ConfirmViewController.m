//
//  ConfirmViewController.m
//  ProductInfoApp
//
//  Created by Evan on 2015/6/19.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import "ConfirmViewController.h"
#import "MBProgressHUD.h"

@interface ConfirmViewController ()<UITextFieldDelegate>
@property NSMutableDictionary *appSetting;
- (IBAction)userConfirmed:(id)sender;
- (IBAction)reSentConfirmCode:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *confirmCode;
@property NSString * phoneNumber;
@property NSString * deviceToken;
@property NSString *authorizedDone;
@property NSString * memberType;
@property NSString *myStorybord;
@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,20)];
    //設定StatusBar 的背景顏色
    //R-242, G-148, B-23
    label.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:148.0/255.0f blue:23.0/255.0f alpha:1.0];
    [self.view addSubview:label];
    //檢查StoryBoard
    [self checkStoryBoard];
    
    //讀取APP的設定檔
    NSString *plistPath = [self getPlistPath];
    self.appSetting = [[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] mutableCopy];
    self.deviceToken = [self.appSetting objectForKey:@"DeviceToken"];
    //NSLog(@"phoneNumber=%@",self.phoneNumber);
    //設TextField Deletage
    self.confirmCode.delegate = self;
    self.authorizedDone = @"NO";
    //設按鍵事件
    UIButton *button=(UIButton *)[self.view viewWithTag:1];
    [button addTarget:self
               action:@selector(methodTouchDown:)
     forControlEvents:UIControlEventTouchDown];

}

- (NSString *)validateForm {
    NSString *errorMessage;
    
    if (!(self.confirmCode.text.length == 4)){
        errorMessage = @"請輸入四碼認證碼";
    }
    
    return errorMessage;
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

-(void)methodTouchDown:(id)sender{
    //出現waiting畫面
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //小矩形的背景色
    HUD.color = [UIColor clearColor];//这儿表示无背景
    //显示的文字
    HUD.labelText = @"系統驗證中....";
    //细节文字
    //HUD.detailsLabelText = @"Test detail";
    //是否有庶罩
    HUD.dimBackground = YES;
    [HUD hide:YES afterDelay:2];
}

- (NSString *)validateAuth {
    NSString *errorMessage;
    NSLog(@"Test1 = %@", self.authorizedDone);
    if ([self.authorizedDone isEqualToString:@"NO"]){
        
        errorMessage = @"驗證失敗";
    }
    
    return errorMessage;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.confirmCode) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"toMainMenu"]) {
        NSString *errorMessage = [self validateForm];
        if (errorMessage) {
            return NO;
        }
        if ([self.authorizedDone isEqualToString:@"NO"]) {
            return NO;
        }
    }
    return YES;
}

- (IBAction)userConfirmed:(id)sender {
    NSString *errorMessage = [self validateForm];
    //confirm code validation
    if (errorMessage) {
        [[[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"確定", nil] show];
        return;
    }
    //TODO:傳送確認碼給Server, 等待Server的回應, 同時確認VIP的狀況

    [self postAuthorized];
    //如果Server確認ok, 改變IsRegisted的狀態
    if ([self.authorizedDone isEqualToString:@"YES"]) {
        [self.appSetting setObject:@"YES" forKey:@"IsRegisted"];
        //把會員狀態儲存起來
        if ([self.memberType isEqualToString:@"2"]){
            [self.appSetting setObject:@"YES" forKey:@"IsVIP"];
            [self.appSetting setObject:@"YES" forKey:@"IsMember"];
        } else if ([self.memberType isEqualToString:@"1"]){
            [self.appSetting setObject:@"NO" forKey:@"IsVIP"];
            [self.appSetting setObject:@"YES" forKey:@"IsMember"];
        } else {
            [self.appSetting setObject:@"NO" forKey:@"IsVIP"];
            [self.appSetting setObject:@"NO" forKey:@"IsMember"];
        }
        [self.appSetting setObject:self.phoneNumber forKey:@"RegPhone"];
        //NSLog(@"SettingListModified=%@",self.appSetting);
        //將檔案寫入
        NSString * targetFile = [NSHomeDirectory()
                             stringByAppendingPathComponent:@"Documents/Setting.plist"];
        [self.appSetting writeToFile:targetFile atomically:YES];
        //判斷會員資格來顯示不同的訊息
        if ([self.memberType isEqualToString:@"2"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"註冊成功"
                                                         message:@"感謝您使用中華食物網行動APP。"
                                                        delegate:nil
                                               cancelButtonTitle:@"確定"
                                               otherButtonTitles:nil];
            [alert show];
        } else if ([self.memberType isEqualToString:@"1"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"註冊成功"
                                                         message:@"感謝您使用中華食物網行動APP。"
                                                        delegate:nil
                                               cancelButtonTitle:@"確定"
                                               otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息功能未開通"
                                                         message:@"您尚未成為中華食物網的網站會員，請先至官網註冊加入。 www.foodchina.com.tw"
                                                        delegate:self
                                               cancelButtonTitle:@"確定"
                                               otherButtonTitles:@"前往註冊", nil];

            [alert show];
        }
        //go to main menu
        NSString * storyboardName = self.myStorybord;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"MainMenu"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}
//Authorized in FCC APP Server
-(void) postAuthorized{
    NSError * error;
    NSURLResponse *myResponse=nil;
    NSString *link =[self.appSetting objectForKey:@"AuthURL"];
    NSLog(@"Regist URL=%@",link);
    NSString *variable1 = @"mobile=";
    variable1 = [variable1 stringByAppendingString:self.phoneNumber];
    NSString *variable2 = @"&auth=";
    variable2 = [variable2 stringByAppendingString:self.confirmCode.text];
    NSString *variable3 = @"&token=";
    variable3 = [variable3 stringByAppendingString:self.deviceToken];
    NSString *stringData = [NSString stringWithFormat: @"%@%@%@", variable1, variable2, variable3];
    NSLog(@"post string =%@",stringData);
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30]; //Set connection timeout = 10
    req.HTTPMethod =@"POST";
    req.HTTPBody = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&myResponse error:&error];
    if (error) {
        NSLog(@"connectionError %@", error);
        //TODO:Alter message
        self.authorizedDone = @"NO";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"伺服器連線錯誤"
                                                        message:@"目前無法連線至伺服器, 請稍後再試。"
                                                       delegate:nil
                                              cancelButtonTitle:@"確定"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    NSString * responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"responseString =>\n %@", responseString);
    NSDictionary * list = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSString *code  = [list objectForKey:@"code"];
    NSLog(@"code ->%@",code);
    if ([code intValue] == 0) {
        NSLog(@"認證錯誤");
        self.authorizedDone = @"NO";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"認證失敗"
                                                        message:@"請確認後再傳送一次！。"
                                                       delegate:nil
                                              cancelButtonTitle:@"確定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    if ([code intValue] == 1) {
        self.memberType = [[list objectForKey:@"type"]stringValue];
        NSLog(@"認證成功, type=%@",self.memberType);
        self.authorizedDone = @"YES";
        
    }

    
}

//Registered in FCC APP Server
-(void) postRegisted{
    NSString *link =[self.appSetting objectForKey:@"RegURL"];
    NSLog(@"Regist URL=%@",link);
    NSString *variable1 = @"mobile=";
    variable1 = [variable1 stringByAppendingString:self.phoneNumber];
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


- (IBAction)reSentConfirmCode:(id)sender {
    //TODO:重新Request Server傳送確認碼
    //出現對話視窗
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"重新傳送確認碼"
                                                    message:@"確認碼將會在五分鐘內傳至你註冊的手機號碼中, 請留意簡訊訊息！"
                                                   delegate:nil
                                          cancelButtonTitle:@"確定"
                                          otherButtonTitles:nil];
    [alert show];
    //Call registed Request
    [self postRegisted];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"This is alertView.clickedButtonAtIndex fun:%zd",buttonIndex);
    switch(buttonIndex){
    case 1:
    //Open website url for registeration
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.foodchina.com.tw"]];
    break;
    }
}
@end
