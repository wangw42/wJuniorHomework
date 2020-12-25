//
//  CommentTableViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import "CommentTableViewController.h"
#import "CommentCell.h"
#import <AFNetworking/AFNetworking.h>
#import "CommentItem.h"
#import "UserInfo.h"

@interface CommentTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UILabel *header;
@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic, strong) UIButton *commentButton;
@end

@implementation CommentTableViewController

- (instancetype)initWithContentID:(NSString *)contentID
                       andOwnID:(NSString *)ownID {
    self = [super init];
    _contentID = contentID;
    _ownID = ownID;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    _header = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, w, 80)];
    _header.text = @"  评论";
    _header.font = [UIFont boldSystemFontOfSize:30];
    self.tableView.tableHeaderView = _header;
    
    _commentField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, w, 45)];
    UIColor *veryLightGrayColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    [_commentField setBackgroundColor:veryLightGrayColor];
    [_commentField setPlaceholder:@" 写一条新的评论"];
    _commentButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 45)];
    [_commentButton setTitle:@"发布 " forState:UIControlStateNormal];
    UIColor *lightBlueColor = [UIColor colorWithRed:(float)29/255 green:(float)161/255 blue:(float)242/255 alpha:1];
    [_commentButton setTitleColor:lightBlueColor forState:UIControlStateNormal];
    [_commentField setRightViewMode:UITextFieldViewModeWhileEditing];
    [_commentField setRightView:_commentButton];
    self.tableView.tableFooterView = _commentField;
    
    UINib *nib = [UINib nibWithNibName:@"CommentCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CommentCell"];
    
    [self.tableView setBounces:NO];
    [self.view setBackgroundColor:veryLightGrayColor];
    
    [_commentButton addTarget:self action:@selector(publishComment) forControlEvents:UIControlEventTouchUpInside];
    
    [self loadData];
}

- (void)publishComment {
    NSString *URL = [NSString stringWithFormat:@"http://172.18.178.56/api/comment"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *body = @{
        @"contentID" : _contentID,
        @"fatherID"  : _ownID,
        @"content"   : [_commentField text],
        @"isReply"   : @NO
    };
    
    NSLog(@"params: %@", body);
    
    [manager POST:URL parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Comment Succeeded: %@", responseObject);
        [self loadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Comment Failed");
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [_commentItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    
    NSInteger i = indexPath.row;
    cell.userNameLabel.text = [_commentItems[i] userName];
    cell.textContentLabel.text = [_commentItems[i] commentContent];
    cell.timeLabel.text = [self timeStampToTime:[_commentItems[i] publishDate]];
    cell.likeLabel.text = [NSString stringWithFormat:@"%d",[_commentItems[i] likeNum]];
    if([UserInfo sharedUser].userId != [_commentItems[i] userID])
        [cell.deleteButton setHidden:YES];
    
    else
        [cell.replyButton setHidden:YES];
    
    
    
    
    return cell;
}

- (NSString *)timeStampToTime:(long)time{
   NSDate *date=[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)time];
   NSDateFormatter *dataformatter = [[NSDateFormatter alloc] init];
   dataformatter.dateFormat = @"MM-dd HH:mm a";
   return [dataformatter stringFromDate:date];
}


- (void)loadData {
    NSString *URL = [NSString stringWithFormat:@"http://172.18.178.56/api/comment/%@", _contentID];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:URL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSLog(@"%@",responseDict);
        if([responseDict[@"State"] isEqualToString:@"success"]){
            self.commentItems = [NSMutableArray new];
            NSArray *data = responseDict[@"Data"];
            if((NSNull *)data != [NSNull null]){
                NSInteger n = [data count];
                for(int i = 0; i < n; i++)
                {
                    CommentItem *newItem = [[CommentItem alloc] initWithDict:data[i]];
                    [self.commentItems addObject:newItem];
                }
            }
        }
        else
            NSLog(@"Wrong contentid");
        
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Load Failed");
    }];
}



@end
