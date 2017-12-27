//
//  ProdinfoMessageDAO.h
//  ProductInfoApp
//
//  Created by Evan on 2015/7/25.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProdInfoMessage.h"

@interface ProdinfoMessageDAO : NSObject
//Singleton Desing Pattern
+(ProdinfoMessageDAO *) sharedProdinfoMessage;

//Instance-Level
@property (strong, nonatomic) NSString * dbPath;

-(NSMutableArray *) getMessageSortByDate;
-(void) insert:(ProdInfoMessage *) data;
-(void) delete:(int) rdid;

@end
