//
//  MessagesTableViewController.m
//  ProductInfoApp
//
//  Created by Evan on 2015/6/21.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import "MessagesTableViewController.h"
#import "ProdinfoMessageDAO.h"
#import "MBProgressHUD.h"


@interface MessagesTableViewController () 
@property NSMutableDictionary *appSetting;
@property NSString *deviceToken;
@property NSString *phoneNumber;
//data
@property (strong, nonatomic) NSMutableArray *messageList;
@property (strong, nonatomic) ProdinfoMessageDAO *dao;
@end

@implementation MessagesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *plistPath = [self getPlistPath];
    self.appSetting = [[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] mutableCopy];
    self.deviceToken = [self.appSetting objectForKey:@"DeviceToken"];
    self.phoneNumber = [self.appSetting objectForKey:@"RegPhone"];

    //self.messageList = [[NSMutableArray arrayWithContentsOfFile:plistPath] mutableCopy];
    // 將tableview下的空白行移除
    self.tableView.tableFooterView = [[UIView alloc] init];
    // 在Navigation bar上加上刪除鍵
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"編輯" style: UIBarButtonItemStyleBordered target:self action:@selector(setCancelRecord:)];
    //清除Push Notification 的badge number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    self.navigationItem.rightBarButtonItem = btn;
    //等待連結的畫面啟動
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //HUD.delegate = self;
    //常用的设置
    
    //小矩形的背景色
    HUD.color = [UIColor clearColor];//这儿表示无背景
    //显示的文字
    HUD.labelText = @"訊息讀取中....";
    //细节文字
    //HUD.detailsLabelText = @"Test detail";
    //是否有庶罩
    HUD.dimBackground = YES;
    [HUD hide:YES afterDelay:2];

}

-(void)viewDidAppear:(BOOL)animated{
    self.dao = [ProdinfoMessageDAO sharedProdinfoMessage];
    //1.跟APP Server確認是否有新訊息
    [self postGetMessage];

    //2.Read Message from DB
    self.messageList = [self.dao getMessageSortByDate];
    [self.tableView reloadData];
    //取消等待畫面
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self didTableViewIsEmpty];

}

- (void)didTableViewIsEmpty {
    //Check is the messageList is null
    if (self.messageList.count == 0) {
        //create a lable size to fit the Table View
        UILabel *messageLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                        self.tableView.bounds.size.width,
                                                                        self.tableView.bounds.size.height)];
        //set the message
        messageLbl.text = @"您沒有任何訊息...";
        //center the text
        messageLbl.textAlignment = NSTextAlignmentCenter;
        //auto size the text
        [messageLbl sizeToFit];
        
        //set back to label view
        self.tableView.backgroundView = messageLbl;
        //no separator
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
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

//getMessage from FCC APP Server
-(void) postGetMessage{
    NSError * error;
    NSURLResponse *myResponse=nil;
    NSString *link =[self.appSetting objectForKey:@"MsgURL"];
    NSLog(@"Regist URL=%@",link);
    NSString *variable1 = @"mobile=";
    variable1 = [variable1 stringByAppendingString:self.phoneNumber];
    NSString *variable2 = @"&token=";
    variable2 = [variable2 stringByAppendingString:self.deviceToken];
    NSString *stringData = [NSString stringWithFormat: @"%@%@", variable1, variable2];
    NSLog(@"post string =%@",stringData);
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10]; //Set connection timeout = 10
    req.HTTPMethod =@"POST";
    req.HTTPBody = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&myResponse error:&error];

        if (error) {
            NSLog(@"connectionError %@", error);
            //TODO:Alter message
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
        
            NSArray * messages = [list objectForKey:@"msgs"];
        self.dao = [ProdinfoMessageDAO sharedProdinfoMessage];
        for(int n = 0; n < [messages count]; n++)
        {
            NSLog(@"message = %@",[messages[n] objectForKey:@"message"]);
            //save to db
            ProdInfoMessage *newMessage = [ProdInfoMessage new];
            newMessage.message = [messages[n] objectForKey:@"message"];
            newMessage.webUrl = [messages[n] objectForKey:@"weburl"];
            if (newMessage.webUrl) {
                newMessage.webUrlEnbled = [NSNumber numberWithInt:1];
            }else{
                newMessage.webUrlEnbled = [NSNumber numberWithInt:0];
            }
            newMessage.publishDate = [messages[n] objectForKey:@"date"];
            [self.dao insert:newMessage];
        }
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.messageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    // Configure the cell...
    ProdInfoMessage * data = [self.messageList objectAtIndex:indexPath.row];
    //cell.textLabel.adjustsFontSizeToFitWidth=YES;
    UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 16.0 ];
    cell.textLabel.font  = myFont;
    cell.textLabel.numberOfLines=0;
    cell.textLabel.text= data.message;
    cell.detailTextLabel.text = data.publishDate;
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove from database
        ProdInfoMessage * data = [self.messageList objectAtIndex:indexPath.row];
        [self.dao delete:data.rdid];
        // Remove from memory
        [self.messageList removeObjectAtIndex:indexPath.row];
        // Remve from TableView
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //Check is table view is empty
        [self didTableViewIsEmpty];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"刪除";
}

- (void)setCancelRecord:(UIBarButtonItem *)button {
    // Toggle the view controller's editing state
    [self setEditing:!self.editing animated:YES];
    
    // Update the button's title
    button.title = self.editing ? @"返回" : @"編輯";
    
    // other processing
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProdInfoMessage * data = [self.messageList objectAtIndex:indexPath.row];
    //NSLog(@"I am in didSelectRow, %@",data.webUrlEnbled);
    if ([data.webUrlEnbled isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        //NSLog(@"Did open browser with url %@ ;", data.webUrl);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:data.webUrl]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
