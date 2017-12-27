//
//  MessagesTableViewController.h
//  ProductInfoApp
//
//  Created by Evan on 2015/6/21.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesTableViewController : UITableViewController <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@end
