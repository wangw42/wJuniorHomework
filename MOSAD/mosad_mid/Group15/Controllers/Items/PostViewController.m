//
//  WritingPostViewController.m
//  Group15
//
//  Created by Yqi on 2020/12/2.
//  Copyright © 2020 yueqi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostViewController.h"
#import "DataItem.h"
#import <AFNetworking/AFNetworking.h>

@interface PostViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (nonatomic) int picNum;
@property (nonatomic) NSMutableArray *imageCache;

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView *detailView;

@property (nonatomic, strong) UITableView *optionTable;
@property (nonatomic) DataItem *postItem;
@property (nonatomic, strong) UISwitch *publicSwitch;

@property (nonatomic, strong) UIScrollView *imageView;
@property (nonatomic, strong) UIView *innerImageView;
@property (nonatomic, strong) UIButton *addPicButton;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic) int w;
@property (nonatomic) int h;


@end

@implementation PostViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    _postItem = [DataItem new];
    
    // 隐藏 tabBar
    self.tabBarController.tabBar.hidden=YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // 计算无遮挡页面尺寸
    UIWindow *window = UIApplication.sharedApplication.windows[0];
    CGRect safe = window.safeAreaLayoutGuide.layoutFrame;
    CGRect navRect = self.navigationController.navigationBar.frame;
    
    _x = safe.origin.x;
    _y = safe.origin.y + navRect.size.height;
    _w = safe.size.width;
    _h = safe.size.height - navRect.size.height;
    
    
    // 右上方按钮
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"发布"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(postIt)];
    [self.navigationItem setRightBarButtonItem:postButton];
    
    // 手动设置返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backTapped:)];
    
     
    
    // Detail 输入框
    _detailView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, _w, _h - 300)];
    [_detailView setFont:[UIFont systemFontOfSize:20]];
    _detailView.delegate = self;
    [_detailView setText:@"Detail"];
    [_detailView setTextColor:[UIColor lightGrayColor]];
    [self.view addSubview:_detailView];
    
    
    // 下方的贴图区域
    [self picAdder];
    
    // 初始化imagePicker
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    
    // 图片缓存
    _imageCache = [NSMutableArray new];
    _picNum = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden=NO;
}

- (void)postIt {
    //_postItem.title = _titleField.text;
    _postItem.images = _imageCache;
    
    _postItem.detail = _detailView.text;
    _postItem.title = @"null";
    _postItem.isPublic = YES;
    //_postItem.isPublic = [_publicSwitch isOn];
    NSString *URL = @"http://172.18.178.56/api/content/text";
    NSString *imgUrl = @"http://172.18.178.56/api/content/album";
    
    NSDictionary *body = [_postItem getDict];
    NSLog(@"%@", body);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if (_picNum != 0) {
        //[body setValue:@[] forKey:@"tags"];
        [manager POST:imgUrl parameters:body headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if(self.picNum > 0) {
                for(int i = 0; i < self.picNum; i++) {
                    NSData *imageData = UIImageJPEGRepresentation(self.imageCache[i], 0.7);
                    NSString *key1 = [NSString stringWithFormat:@"file%d", i + 1];
                    NSString *key2 = [NSString stringWithFormat:@"thumb%d", i + 1];
                    [formData appendPartWithFileData:imageData name:key1 fileName:key1 mimeType:@"image/jpg"];
                    [formData appendPartWithFileData:imageData name:key2 fileName:key2 mimeType:@"image/jpg"];
                }
            }
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject ) {
           NSLog(@"response obj : %@",responseObject);
           NSDictionary *response = (NSDictionary *)responseObject;
           if([response[@"State"] isEqualToString:@"success"])
           {
               // 初始化图片缓存
               self.imageCache = [NSMutableArray new];
               self.picNum = 0;
               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发布成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
               [alertController addAction:[UIAlertAction actionWithTitle:@"返回主页" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                   [self.navigationController popViewControllerAnimated:NO];
               }]];
               [self presentViewController:alertController animated:YES completion:nil];
           }
           else if([response[@"State"] isEqualToString:@"max_size"])
           {
               NSLog(@"失败,容量超额了");
           }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败，网络连接出错");

        }];
    } else {
    
        [manager POST:URL parameters:body headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"%@",responseObject);
            NSDictionary *response = (NSDictionary *)responseObject;
            if([response[@"State"] isEqualToString:@"success"])
            {
                [self Alert:@"发布成功"];
                [self.navigationController popViewControllerAnimated:NO];
            }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self Alert:@"请求失败"];
        }];
    
    }
    
}

#pragma mark 图片区域
- (void)picAdder {
    // imageView 是下方整个添加和显示图片的区域
    _imageView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _h - 120, _w, 120)];
    [_imageView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
    
    // innerImageView 是 imageView 的内部视图，应将图片和按钮添加到此视图
    // 每次更改该视图的 frame 时应调用 _imageView 的 setContentSize: 方法
    _innerImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _w, 120)];
    [_imageView addSubview:_innerImageView];
    [_imageView setContentSize:_innerImageView.frame.size];
    [_imageView setClipsToBounds:YES];
    
    // 按钮
    _addPicButton = [[UIButton alloc] initWithFrame:[self frameAtIndex:0]];
    [_addPicButton setTitle:@"+" forState:UIControlStateNormal];
    [_addPicButton.titleLabel setFont:[UIFont systemFontOfSize:40]];
    [_addPicButton setBackgroundColor:[UIColor lightGrayColor]];
    [[_addPicButton layer]setCornerRadius:5];
    [_addPicButton addTarget:self action:@selector(addPic) forControlEvents:UIControlEventTouchUpInside];
    [_innerImageView addSubview:_addPicButton];
    
    [self.view addSubview:_imageView];
}

- (void)addPic
{
    // 如果图片数已大于等于3，resize
    if(_picNum >= 3) {
        [_innerImageView setFrame:CGRectMake(0, 0, 120 * (_picNum + 1), 120)];
        [_imageView setContentSize:_innerImageView.frame.size];
    }
    
    // 呈现选项：从相册中选取 / 从相机选取 / 取消
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [actionSheet addAction:photoAction];
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

// 对选中图片的处理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"选中图片");

    // 呈现选中的照片的视图
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self saveImage:selectedImage withName:@"testImg.png"];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"testImg.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    UIImageView *newPicView = [[UIImageView alloc] initWithFrame:[self frameAtIndex:_picNum]];
    newPicView.image = savedImage;
    
    // 视图样式
    [newPicView.layer setCornerRadius:5];
    [newPicView.layer setMasksToBounds:YES];
    
    [_imageView addSubview:newPicView];
    
    // 添加成功后再移动添加按钮
    _addPicButton.frame = [self frameAtIndex:_picNum + 1];
    
    // 增加图片计数
    _picNum ++;
    [_imageCache addObject:selectedImage];

}


#pragma mark - 保存图片至沙盒（应该是提交后再保存到沙盒,下次直接去沙盒取）
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.01);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}

- (CGRect)frameAtIndex:(int) i {
    return CGRectMake(10 + 110 * i, 10, 100, 100);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)backTapped:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

# pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 0.0001f;
}


# pragma mark place holder 模拟
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Detail"]) {
         textView.text = @"";
         textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Detail";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

# pragma mark 提示
- (void)Alert:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:true completion:nil];
}

@end
