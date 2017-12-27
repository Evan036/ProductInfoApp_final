//
//  ProdinfoMessageDAO.m
//  ProductInfoApp
//
//  Created by Evan on 2015/7/25.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import "ProdinfoMessageDAO.h"
#import "FMDB.h"

@implementation ProdinfoMessageDAO
+(ProdinfoMessageDAO *) sharedProdinfoMessage{
    static ProdinfoMessageDAO * dao;
    if (dao == nil){
        dao = [ProdinfoMessageDAO new];
    }
    return dao;
}

-(instancetype) init{
    self = [super init];
    if (self) {
        self.dbPath = [NSHomeDirectory()
                       stringByAppendingPathComponent:@"Documents/prodInfo.sqlite"];
        NSLog(@"PATH: %@", self.dbPath);
        NSFileManager * fileMgr = [NSFileManager defaultManager];
        if (![fileMgr fileExistsAtPath:self.dbPath]) {
            NSString * source = [[NSBundle mainBundle] pathForResource:@"prodInfo" ofType:@"sqlite"];
            NSError * error;
            [fileMgr copyItemAtPath:source toPath:self.dbPath error:&error];
            if (error) {
                NSLog(@"Copy File fail!");
            } else {
                NSLog(@"Copy File successfully!");
            }
        }else{
            NSLog(@"File exists!");
        }
    }
    return self;
}

-(NSMutableArray *)getMessageSortByDate{
    NSMutableArray * list = [NSMutableArray new];
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    NSString * sql = @"SELECT * FROM prodInfoMessage order by PublishDate desc;";
    FMResultSet * result = [db executeQuery:sql];
    while ([result next]) {
        ProdInfoMessage * r = [ProdInfoMessage new];
        r.rdid = [result intForColumn:@"RdId"];
        r.message  = [result stringForColumn:@"Message"];
        r.webUrl = [result stringForColumn:@"WebLink"];
        r.webUrlEnbled = [NSNumber numberWithInt:[result intForColumn:@"WebLinkEnable"]];
        r.publishDate = [result stringForColumn:@"PublishDate"];
        [list addObject:r];
    }
    NSLog(@"COUNT :%lu", (unsigned long)list.count);
    [db close];
    return list;
}

-(void) insert:(ProdInfoMessage *)data{
    NSString * sql = @"INSERT INTO prodInfoMessage (Message,WebLink,WebLinkEnable,PublishDate) VALUES (:m,:w,:we,:p);";
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:data.message forKey:@"m"];
    [dict setObject:data.webUrl forKey:@"w"];
    [dict setObject:data.webUrlEnbled forKey:@"we"];
    [dict setObject:data.publishDate forKey:@"p"];
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    [db executeUpdate:sql withParameterDictionary:dict];
    [db close];
}

-(void) delete:(int)rdid{
    NSString * sql = @"DELETE FROM prodInfoMessage WHERE RdId=:rdid;";
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInt:rdid] forKey:@"rdid"];
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    [db executeUpdate:sql withParameterDictionary:dict];
    [db close];
}


@end
