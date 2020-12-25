//
//  MomentViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MomentViewController.h"

#import "PostCell.h"
#import "CommentTableViewController.h"
#import "ZoomPicViewController.h"
#import "UserpageViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "UserNDataItem.h"
#import "UserItem.h"
#import "DataItem.h"

@interface MomentViewController ()

@property (nonatomic, strong) NSMutableArray *momentItems;

@end

@implementation MomentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _momentItems = [NSMutableArray arrayWithCapacity:1];
    
    UINib *nib = [UINib nibWithNibName:@"PostCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"PostCell"];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self loadData];
}
// 设置 cell 是否允许左滑
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}
// 设置默认的左滑按钮的title
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
// 点击左滑出现的按钮时触发
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击左滑出现的按钮时触发");
}
// 左滑结束时调用(只对默认的左滑按钮有效，自定义按钮时这个方法无效)
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"左滑结束");
}
// 自定义左滑cell时的按钮和触发方法
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 创建第一个按钮和触发事件
    UITableViewRowAction *cellActionA = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        NSInteger i = indexPath.row;
        NSString *contentID = [_momentItems[i] contentID];
        NSString *title = [_momentItems[i] title];

        NSString *URL = [NSString stringWithFormat:@"%@%@",@"http://172.18.178.56/api/content/all/",contentID];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"编辑" message:@"请输入编辑内容！" preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
          textField.placeholder = @"在这里输入内容";
        }];
        UITextField *detailtextField = alert.textFields.firstObject;
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了取消按钮");
        }];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点了确认按钮");
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];

            NSLog(@"Id : %@", contentID);
            NSDictionary *body = @{
                @"title" : title,
                @"detail" : detailtextField.text,
                @"tags":[NSMutableArray new],
                @"isPublic":@YES
            };
           
            [manager PATCH:URL parameters:body headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        NSLog(@"%@", responseObject);
                        if([responseObject[@"State"] isEqualToString:@"success"])
                        {
                            NSLog(@"编辑成功");
                            [self loadData];
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"failed to post somehow");
                    }];
        }];
        [alert addAction:confirm];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
        

        NSLog(@"点击了 编辑");
    }];
    // 定义按钮的颜色
    cellActionA.backgroundColor = [UIColor colorWithRed:32.0/255.0 green:178.0/255.0 blue:170.0/255.0 alpha:1.0];

    // 创建第二个按钮和触发事件
    UITableViewRowAction *cellActionB = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        NSInteger i = indexPath.row;
        NSString *contentID = [_momentItems[i] contentID];
        NSString *URL = [NSString stringWithFormat:@"%@%@",@"http://172.18.178.56/api/content/",contentID];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];

        NSLog(@"Id : %@", contentID);
    
        [manager DELETE:URL parameters:nil headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"%@", responseObject);
                    if([responseObject[@"State"] isEqualToString:@"success"])
                    {
                        NSLog(@"成功删除该内容");
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"成功删除该内容！" preferredStyle:UIAlertControllerStyleAlert];

                        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            NSLog(@"点了确认按钮");
                        }];
                        [alert addAction:confirm];
                        [self presentViewController:alert animated:YES completion:nil];
                        [self loadData];


                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"failed to post somehow");
                }];

        NSLog(@"点击了 删除 %ld", i);

    }];
    cellActionB.backgroundColor = [UIColor colorWithRed:240/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    // 注意这里返回的是一个按钮组，即使只定义了一个按钮也要返回一个组
    return @[cellActionA, cellActionB];
}

#pragma mark - UITableViewDataSource

// section 个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Section 中的 Cell 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_momentItems count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

// 设置每个 Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    if (cell == nil){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.showImageBlock = ^(UIImage *img){
        ZoomPicViewController *bivc = [[ZoomPicViewController alloc] init];
        bivc.view.backgroundColor = [UIColor blackColor];
        bivc.image = img;
        [self.navigationController pushViewController:bivc animated:YES];
        [self presentViewController:bivc animated:YES completion:nil];
    };
    
    [cell.likeButton addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentButton addTarget:self action:@selector(showCommentPage:) forControlEvents:UIControlEventTouchUpInside];
    
    long i = indexPath.row;
    cell.userNameLabel.text = _userName;
    
    [self setLabel:cell.textContentLabel Detail:[_momentItems[i] detail]];
       
    cell.timeLabel.text = [self timeStampToTime:[_momentItems[i]  PublishDate]];
        
    cell.likeNumberLabel.text = [NSString stringWithFormat:@"%d", [_momentItems[i]  likeNum]];
    cell.commentNumberLabel.text = [NSString stringWithFormat:@"%d", [_momentItems[i]  commentNum]];
    
    [cell.likeButton addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.commentButton addTarget:self action:@selector(showCommentPage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    DataItem *contentItem = _momentItems[i];
    if([contentItem.contentType isEqualToString:@"Text"]){
       [cell dontShowPicView];
    }
    else{
        NSArray *images = contentItem.album[@"Images"];
        if((NSNull *)images != [NSNull null])
        {
            for(int i = 0; i < [images count]; i++)
            {
                NSString *thumbName = images[i][@"Thumb"];
                NSString *imageURL = [NSString stringWithFormat:@"http://172.18.178.56/api/thumb/%@", thumbName];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                [cell addPic:image];
            }
            if([images count] == 0)
            {
                [cell addPic:[UIImage imageNamed:@"noImage.jpg"]];
            }
        }
    }
    
    return cell;
}


- (void)likePost:(UIButton *)btn {
    UIView *contentView = [btn superview];
    PostCell *cell = (PostCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // 已经得到indexPath
    NSLog(@"第%ld行点赞", indexPath.row);
}


- (void)showCommentPage:(UIButton *)btn {
    UIView *contentView = [btn superview];
    PostCell *cell = (PostCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSLog(@"%ld行评论", indexPath.row);
    [self presentViewController:[CommentTableViewController new] animated:YES completion:nil];
}


- (void)loadData{
    NSString *URL = [@"http://172.18.178.56/api/content/texts/" stringByAppendingString:_userID];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:URL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        if([response[@"State"] isEqualToString:@"success"])
        {
            NSArray *data = response[@"Data"];
            
            if((NSNull*)data == [NSNull null]){
                DataItem *newItem = [[DataItem alloc]initEmpty];
                [self.momentItems addObject:newItem];
            }else {
                NSInteger n = [data count];
                for(int i = 0; i < n; i++)
                {
                    DataItem *newItem = [[DataItem alloc]initWithDict:data[i]];
                    
                    
                    if([self.momentItems count] > i)
                        self.momentItems[i] = newItem;
                    else{
                        [self.momentItems addObject:newItem];
                    }
                    
                }
            }
            
        }
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to fetch public contents somehow");
    }];
    
}


- (NSString *)timeStampToTime:(long)time {
   NSDate *date=[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)time];
   
   NSDateFormatter *dataformatter = [[NSDateFormatter alloc] init];
   dataformatter.dateFormat = @"MM-dd HH:mm a";
   
   return [dataformatter stringFromDate:date];
}


- (void)setLabel:(UILabel *)label
        Detail:(NSString *)detail {
    NSString *newDetail = nil;
    if([detail length] == 0) newDetail = @"";
    else newDetail = [NSString stringWithFormat:@"%@\n", detail];
    
    NSUInteger lenDetail = [newDetail length];
    
    NSRange rangeDetail = NSMakeRange(0, lenDetail);
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",newDetail]];

    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:rangeDetail];
    
    [label setAttributedText:str];
}


@end

