//
//  HomepageViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomepageViewController.h"
#import <Masonry/Masonry.h>
#import "PostCell.h"
#import "CommentTableViewController.h"
#import "UserpageViewController.h"
#import "PostViewController.h"
#import "ZoomPicViewController.h"
#import "UserNDataItem.h"
#import "DataItem.h"
#import <AFNetworking/AFNetworking.h>

@interface HomepageViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;


@property (nonatomic, strong) UserItem * userItem;
@property (nonatomic, strong) NSMutableArray *textItems;



@end

@implementation HomepageViewController 

- (instancetype)init{
    //用下面这个 tableview上边会有空白区域
    //self = [super initWithStyle:UITableViewStyleGrouped];
    self = [super init];
    
    // TabBar & navi
    self.tabBarItem.title = @"主页";
    self.navigationItem.title = @"主页";
    UIImage *img1 = [[UIImage imageNamed:@"user1"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img2 = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.image = img1;
    self.tabBarItem.selectedImage = img2;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // search
    [self.navigationItem setTitleView:[self searchBar]];
    
    // postBtn
    [self topLeftButton];
    
    // right
    UIBarButtonItem *rightButton =
        [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(post)];
    [self.navigationItem setRightBarButtonItem: rightButton];
    
    return self;
}



- (void)viewDidLoad{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"PostCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"PostCell"];

    // cell之间分割线不显示
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setBounces:NO];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    
    _textItems = [NSMutableArray arrayWithCapacity:1];
    [self loadBlogData];
}

- (void)topLeftButton{
    UIImage *img = [[UIImage imageNamed:@"avatar"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [button setImage:img forState:UIControlStateNormal];
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;
    [button.widthAnchor constraintEqualToConstant:35].active = YES;
    [button.heightAnchor constraintEqualToConstant:35].active = YES;
    
    [button addTarget:self action:@selector(toUserPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:button]];
}


- (UISearchBar *)searchBar{
    if(!_searchBar){
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _searchBar.delegate = self;
    }
    return _searchBar;
}


#pragma mark - Table view data source
// tableView 中 Section 的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}
// 每个 Section 中的 Cell 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return [_textItems count];
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
        //[self.navigationController pushViewController:bivc animated:YES];
        [self presentViewController:bivc animated:YES completion:nil];
    };
    
    [cell.likeButton addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
    [cell.portraitButton addTarget:self action:@selector(toUserPage:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentButton addTarget:self action:@selector(showCommentPage:) forControlEvents:UIControlEventTouchUpInside];
    
    long i = indexPath.row;
    cell.userNameLabel.text = _username;
    
    
    [self setLabel:cell.textContentLabel Detail:[_textItems[i] detail]];
       
    cell.timeLabel.text = [self timeStampToTime:[_textItems[i]  PublishDate]];
        
    cell.likeNumberLabel.text = [NSString stringWithFormat:@"%d", [_textItems[i]  likeNum]];
    cell.commentNumberLabel.text = [NSString stringWithFormat:@"%d", [_textItems[i]  commentNum]];
    
    [cell.likeButton addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.commentButton addTarget:self action:@selector(showCommentPage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    DataItem *contentItem = _textItems[i];
    if([contentItem.contentType isEqualToString:@"Text"]){
        [cell dontShowPicView];
    }
    else{
        NSArray *images = contentItem.album[@"Images"];
        if((NSNull *)images != [NSNull null]){
            for(int i = 0; i < [images count]; i++){
                NSString *thumbName = images[i][@"Thumb"];
                NSString *imageURL = [NSString stringWithFormat:@"http://172.18.178.56/api/thumb/%@", thumbName];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                [cell addPic:image];
            }
            if([images count] == 0){
                [cell addPic:[UIImage imageNamed:@"dogdog.jpg"]];
            }
        }
    }
    
    return cell;
}

- (UIViewController *)viewController {
    for (UIView* next = [self.view superview]; next; next = next.superview) {
    UIResponder *nextResponder = [next nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
      return (UIViewController *)nextResponder;
    }
  }
  return nil;
}



- (void)likePost:(UIButton *)btn {
    // 得到indexPath
    UIView *contentView = [btn superview];
    PostCell *cell = (PostCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    
    NSInteger i = indexPath.row;
    NSString *contentID = [_textItems[i] contentID];
    NSString *URL = [NSString stringWithFormat:@"%@%@",@"http://172.18.178.56/api/like/",contentID];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *body = @{
        @"isContent" : @YES,
        @"isComment" : @NO,
        @"isReply" : @NO
    };
    
    NSLog(@"Id : %@", contentID);
    

    NSLog(@"尝试点赞");
    [manager POST:URL parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"%@", responseObject);
                if([responseObject[@"State"] isEqualToString:@"exist"])
                {
                    {
                        NSLog(@"取消点赞");
                        [manager PATCH:URL parameters:body headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            NSLog(@"%@", responseObject);
                            [self loadBlogData];
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            NSLog(@"failed to patch somehow");
                        }];
                    }
                }
                [self loadBlogData];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"failed to post somehow");
            }];

    
}

- (void)showCommentPage:(UIButton *)btn {
    UIView *contentView = [btn superview];
    PostCell *cell = (PostCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *contentID = [_textItems[indexPath.row] contentID];
    NSString *ownID = [_textItems[indexPath.row] ownID];
    
    [self presentViewController:[[CommentTableViewController alloc]initWithContentID:contentID andOwnID:ownID] animated:YES completion:nil];
}

- (void)toUserPage:(UIButton *)btn{
    UserpageViewController* uvc = [[UserpageViewController alloc] init];
    uvc.userID = _userID;
    uvc.userName = _username;
    [self.navigationController pushViewController:uvc animated:NO];
}


- (void)setPortraitButtonWithImage:(UIImage *)image{
    int r = 35;
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, r, r)];
    [button setImage:image forState:UIControlStateNormal];
    button.layer.cornerRadius = r/2;
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.layer.masksToBounds = YES;
    
    [button.widthAnchor constraintEqualToConstant:35].active = YES;
    [button.heightAnchor constraintEqualToConstant:35].active = YES;
    
    button.layer.borderWidth = 1.2;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [button addTarget:self action:@selector(toUserPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:button]];
}

- (void)post
{
    [self.navigationController pushViewController:[PostViewController new] animated:NO];
}

- (void)loadData {
    NSString *URL = @"http://172.18.178.56/api/user/info/self" ;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:URL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        if([response[@"State"] isEqualToString:@"success"]){
            self.userItem = [[UserItem alloc] initWithDict:response];
            self->_userID = self.userItem.userid;
            self->_username = self.userItem.userName;
        }
        
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to fetch public contents somehow");
    }];
    
}


- (void)loadBlogData{
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
                [self.textItems addObject:newItem];
            }else {
                NSInteger n = [data count];
                for(int i = 0; i < n; i++){
                    DataItem *newItem = [[DataItem alloc]initWithDict:data[i]];
                    
                    
                    if([self.textItems count] > i)
                        self.textItems[i] = newItem;
                    else{
                        [self.textItems addObject:newItem];
                    }
                    
                }
            }
            //NSLog(@"-----home load blog%@", data);
            
        }
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to fetch self contents somehow");
    }];
    
}

- (NSString *)timeStampToTime:(long)time
{
   NSDate *date=[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)time];
   
   NSDateFormatter *dataformatter = [[NSDateFormatter alloc] init];
   dataformatter.dateFormat = @"MM-dd HH:mm a";
   
   return [dataformatter stringFromDate:date];
}

- (void)setLabel:(UILabel *)label
        Detail:(NSString *)detail{
    NSString *newDetail = nil;
    if([detail length] == 0) newDetail = @"";
    else newDetail = [NSString stringWithFormat:@"%@\n", detail];
    
    NSUInteger lenDetail = [newDetail length];
    
    NSRange rangeDetail = NSMakeRange(0, lenDetail);
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",newDetail]];

    // Detail 样式
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:rangeDetail];
    

    [label setAttributedText:str];
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchText = searchBar.text;
    NSInteger n = [_textItems count];
    for(int i = 0; i < n; i++){
        NSString *detail = [_textItems[i] detail];
        NSString *contentStringAtI = [NSString stringWithFormat:@"%@",detail];
        if([contentStringAtI rangeOfString:searchText].location != NSNotFound){
            [self AlertWithTitle:@"找到了" message:[NSString stringWithFormat:@"第%d条", i+1]];
            return;
        }
    }
    [self AlertWithTitle:@"没找到" message:nil];
}

- (void)AlertWithTitle:(NSString *)title
               message:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    // 显示对话框
    [self presentViewController:alert animated:true completion:nil];
}

@end
