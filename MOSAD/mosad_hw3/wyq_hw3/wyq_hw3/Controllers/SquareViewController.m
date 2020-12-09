//
//  SquareViewController.m
//  wyq_hw3
//
//  Created by Yqi on 2020/12/7.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SquareViewController.h"
#import <Masonry/Masonry.h>
#import "ZoomPicViewController.h"
#import "PicCell.h"
#import "ButtonBar.h"

#import <SDWebImage/UIImageView+WebCache.h>


@interface SquareViewController () <UITableViewDataSource>


@property (strong, nonatomic) NSMutableArray * urlArray;
@property (nonatomic,copy) NSMutableArray *fileArray;
@property (nonatomic,strong) NSFileManager *fileManager;
@property (nonatomic) BOOL is_load_press;


@property(nonatomic,strong) NSIndexPath* myIndex;


@end


@implementation SquareViewController

- (instancetype)init {
    self = [super init];
    
    // TabBar & navi
    self.tabBarItem.title = @"图片";
    self.navigationItem.title = @"图片";
    UIImage *img1 = [[UIImage imageNamed:@"user1"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img2 = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.image = img1;
    self.tabBarItem.selectedImage = img2;

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.urlArray=[NSMutableArray arrayWithArray:@[@"https://hbimg.huabanimg.com/d8784bbeac692c01b36c0d4ff0e072027bb3209b106138-hwjOwX_fw658",
         @"https://hbimg.huabanimg.com/6215ba6f9b4d53d567795be94a90289c0151ce73400a7-V2tZw8_fw658",
         @"https://hbimg.huabanimg.com/834ccefee93d52a3a2694535d6aadc4bfba110cb55657-mDbhv8_fw658",
         @"https://hbimg.huabanimg.com/f3085171af2a2993a446fe9c2339f6b2b89bc45f4e79d-LacPMl_fw658",
         @"https://hbimg.huabanimg.com/e5c11e316e90656dd3164cb97de6f1840bdcc2671bdc4-vwCOou_fw658"]];
     
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        self.fileManager = [NSFileManager defaultManager];
        self.fileArray=[NSMutableArray arrayWithArray:@[[cachePath stringByAppendingPathComponent:[NSString stringWithFormat: @"%d.png", 0]],
                                                              [cachePath stringByAppendingPathComponent:[NSString stringWithFormat: @"%d.png", 1]],
                                                              [cachePath stringByAppendingPathComponent:[NSString stringWithFormat: @"%d.png", 2]],
                                                              [cachePath stringByAppendingPathComponent:[NSString stringWithFormat: @"%d.png", 3]],
                                                              [cachePath stringByAppendingPathComponent:[NSString stringWithFormat: @"%d.png", 4]]]];
    self.is_load_press=false;
     
    return self;
}



- (void)viewDidLoad{
    [super viewDidLoad];

    // cell之间分割线不显示
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    UINib *nib = [UINib nibWithNibName:@"PicCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"PicCell"];
    
    UINib *nib2 = [UINib nibWithNibName:@"ButtonBar" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"ButtonBar"];
    
    [self.tableView setBounces:NO];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - 按钮事件
- (void) pressLoadBtn{

    NSOperationQueue *queue =[[NSOperationQueue alloc]init];
    for(int i = 0; i < 5; i++){
        NSDictionary * dict= [NSDictionary dictionaryWithObject:[NSString
    stringWithFormat:@"%d",i] forKey:@"key"];
        NSInvocationOperation *op=[[NSInvocationOperation
                                    alloc]initWithTarget:self selector:@selector(downloadImages:) object:dict];
        [queue addOperation:op];
    }
    
}


- (void) pressCleanBtn{
    self.is_load_press = false;
    
    [self.tableView reloadData];
}

- (void) pressDelCacheBtn{
    for(int i = 0; i < 5; i++){
        [self.fileManager removeItemAtPath:self.fileArray[i] error:nil];
    }
}

#pragma mark - 图片处理
// 下载图片
- (void)downloadImages: (NSDictionary*) dict {
    self.is_load_press = true;
    
    int index = [[dict valueForKey:@"key"] intValue];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject
                                                                      delegate: self
                                                                 delegateQueue: [NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:self.urlArray[index]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask * dataTask = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachePath = [paths objectAtIndex:0];
            NSString *filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat: @"%d.png", index]];
            [UIImagePNGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:url]]) writeToFile:filePath atomically:YES];
            NSOperationQueue *queue =[NSOperationQueue mainQueue];
            NSInvocationOperation *op=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(reload) object: NULL];
            [queue addOperation:op];
        }
    }];
    [dataTask resume];
}

- (void)reload{
    [self.tableView reloadData];
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
    return 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0) return 40;
    return 100;
}



// 设置每个 Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PicCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PicCell"];
    if (cell == nil){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PicCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        
    }
    cell.showImageBlock = ^(UIImage *img){
        ZoomPicViewController *bivc = [[ZoomPicViewController alloc] init];
        bivc.view.backgroundColor = [UIColor blackColor];
        bivc.image = img;
        [self presentViewController:bivc animated:YES completion:nil];
    };
    
    long i = indexPath.row;
    if(i == 0)
    {
        ButtonBar * buttonCell = [tableView dequeueReusableCellWithIdentifier:@"ButtonBar"];
        [buttonCell.loadBtn addTarget:self action:@selector(pressLoadBtn) forControlEvents:UIControlEventTouchUpInside];
        [buttonCell.cleanBtn addTarget:self action:@selector(pressCleanBtn) forControlEvents:UIControlEventTouchUpInside];
        [buttonCell.delCacheBtn addTarget:self action:@selector(pressDelCacheBtn) forControlEvents:UIControlEventTouchUpInside];
        return buttonCell;
    }
    else{
        if(self.is_load_press==false){
            //[cell addPic:NULL];
            [cell addPic:[UIImage imageNamed:@"avatar.png"]];
        } else{
            if([self.fileManager fileExistsAtPath:self.fileArray[indexPath.section]]==false){
                NSLog(@"Download not complete");
                [cell addPic:[UIImage imageNamed:@"user2.png"]];
            }else{
                [cell addPic:[UIImage imageWithContentsOfFile:self.fileArray[indexPath.item-1]]];
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




@end
