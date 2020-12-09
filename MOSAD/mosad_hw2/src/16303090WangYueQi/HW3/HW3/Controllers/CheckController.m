//
//  CheckController.m
//  16303090WangYueQi
//
//  Created by Yqi on 2020/10/26.
//  Copyright © 2020 Yqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckController.h"
#import "CheckControllerView.h"
#import "FindController.h"
#import "TabBarController.h"

@interface CheckController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSourceTitles;
@property (nonatomic, strong) NSArray *dataSourceImgs;

@property (nonatomic, strong) UIButton* addbtn;

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property double  imgx;
@property double  imgy;
@property int imgcnt;


@end

@implementation CheckController


- (instancetype) init{
    if(self = [super init]){
        //tabbar
        self.tabBarItem.title = @"打卡";
        UIImage *img1 = [[UIImage imageNamed:@"user1"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *img2 = [[UIImage imageNamed:@"user2"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.image = img1;
        self.tabBarItem.selectedImage = img2;
        
        // 用collectionview实现每一项
        _dataSourceTitles = @[@"时间",@"地点",@"景点",@"心得",@"配图"];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[CheckControllerView class] forCellWithReuseIdentifier:@"cellId"];
        
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView setUserInteractionEnabled:YES];
        
        [self.view addSubview:_collectionView];
        
        
        // 添加图片按钮
        UIView *btnField = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        //UIButton* addbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
        _addbtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 250, 70, 70)];
        _addbtn.backgroundColor = [UIColor whiteColor];
        _addbtn.layer.cornerRadius = 4;
        [_addbtn setTitle:@"+" forState:UIControlStateNormal];
        _addbtn.titleLabel.font =  [UIFont systemFontOfSize: 32.0];
        [_addbtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
        _addbtn.layer.shadowColor = [UIColor blackColor].CGColor;
        _addbtn.layer.shadowOffset = CGSizeMake(1, 1);
        _addbtn.layer.shadowRadius = 4;
        _addbtn.layer.shadowOpacity = 0.2;
        
        _imgx = 0;
        _imgy = 0;
        _imgcnt = 0;
        [btnField addSubview:_addbtn];
        [_addbtn addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
        [_addbtn sendActionsForControlEvents:UIControlEventTouchDown];
        
        
        
        // 发布按钮
        UIButton* btn2 = [[UIButton alloc]initWithFrame:CGRectMake(300, 600, 60, 32)];
        btn2.backgroundColor = [UIColor whiteColor];
        btn2.layer.cornerRadius = 4;
        [btn2 setTitle:@"发布" forState:UIControlStateNormal];
        [btn2 setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        btn2.titleLabel.font =  [UIFont systemFontOfSize: 14.0];
        btn2.layer.shadowColor = [UIColor blackColor].CGColor;
        btn2.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        btn2.layer.shadowRadius = 2;
        btn2.layer.shadowOpacity = 0.2;
        [btnField addSubview:btn2];
        btn2.enabled = YES;
        
        
        [btn2 addTarget:self action:@selector(jumpToFind) forControlEvents:UIControlEventTouchUpInside];
        [btn2 sendActionsForControlEvents:UIControlEventTouchDown];
        
        [self.view addSubview:btnField];
        
        // 信息输入框
        NSInteger height = 20;
        for(int i = 1; i < 4; i++){
            UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(100, height, 200, 30)];
            
            tf.layer.borderColor = [[UIColor colorWithRed:215.0 / 255.0 green:215.0 / 255.0 blue:215.0 / 255.0 alpha:1] CGColor];
            tf.layer.borderWidth = 0.6f;
            tf.layer.cornerRadius = 6.0f;
            tf.delegate = self;
            [tf setEnabled:YES];
            [self.view addSubview:tf];
            height += 40;
        }
        UITextView *tv =  [[UITextView alloc] initWithFrame:CGRectMake(100, height, 200, 90)];
        tv.delegate = self;
        tv.editable = YES;
        tv.layer.borderColor = [[UIColor colorWithRed:215.0 / 255.0 green:215.0 / 255.0 blue:215.0 / 255.0 alpha:1] CGColor];
        tv.layer.borderWidth = 0.6f;
        tv.layer.cornerRadius = 6.0f;
        [self.view addSubview:tv];
        
    }
    return self;
}



- (void) jumpToFind{
    // 动画
    CATransition *animation = [CATransition animation];
    animation.type = @"cube";
    animation.subtype = kCATransitionFromLeft ;
    animation.duration = 0.5;
    //换图片的时候使用转场动画
    [self.view.window.layer addAnimation:animation forKey:@"kTransitionAnimation"];
    
    [self.navigationController pushViewController:[[TabBarController alloc] init] animated:NO];
}




#pragma mark 选择图片
-(UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        _imageView.center = self.view.center;
        _imageView.image = [UIImage imageNamed:@"bgImage.jpg"];
        _imageView.userInteractionEnabled = YES;  //这个一定要设置为YES，默认的为NO，NO的时候不可发生用户交互动作
        UITapGestureRecognizer *clickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseImage)];
        [_imageView addGestureRecognizer:clickTap];
    }
    return _imageView;
}

-(void)chooseImage {
     self.imagePicker = [[UIImagePickerController alloc] init];
     self.imagePicker.delegate = self;
     self.imagePicker.allowsEditing = YES;
     
     UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
     
     UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"从相机拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
             self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
             [self presentViewController:self.imagePicker animated:YES completion:nil];
         }
     }];
     
     UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
         [self presentViewController:self.imagePicker animated:YES completion:nil];
     }];
     
     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
         NSLog(@"点击了取消");
     }];
     
     [actionSheet addAction:cameraAction];
     [actionSheet addAction:photoAction];
     [actionSheet addAction:cancelAction];
     
     [self presentViewController:actionSheet animated:YES completion:nil];
    
     [self presentViewController:_imagePicker animated:YES completion:nil];
 }


//获取选择的图片
 -(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
     [picker dismissViewControllerAnimated:YES completion:nil];
     UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
     //self.imageView.image = image;
     
     //展示选择的图片
     UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(100+_imgx, 250+_imgy, 70, 70)];
     [self.view addSubview: iv];
     iv.image = image;
     
     // 图片位置变化
     _imgcnt++;
     _imgx += 80;
     if(_imgcnt % 3 == 0){
         _imgy += 80;
         _imgx = 0;
     }
     
     // 按钮位置变化
     _addbtn.frame = CGRectMake(100+_imgx, 250+_imgy, 70, 70);
 }


//从相机或者相册界面弹出
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark 处理collectionView的delegates和dataSource
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置navTitle
    [self.parentViewController.navigationItem setTitle:[NSString stringWithFormat:@"添加打卡"]];
}

#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CheckControllerView *cell = (CheckControllerView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    cell.label.text = _dataSourceTitles[indexPath.row];
    if(indexPath.row == 4){
        cell.label.frame = CGRectMake(0, 0,40, 140);
    }

    return cell;
}



//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(300, 30);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 10, 20, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}



//点击item方法 跳转到对应的view
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark textField代理方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}



@end
