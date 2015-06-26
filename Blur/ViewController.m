//
//  ViewController.m
//  Blur
//
//  Created by 李文龙 on 15/6/26.
//  Copyright (c) 2015年 李文龙. All rights reserved.
//

#import "ViewController.h"
#import "BlurView.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Private Method

- (UIButton*)createRightItemAction:(SEL)selector
{
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    rightBtn.frame = CGRectMake(275, 2, 50, 40);
    //[rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
    rightBtn.adjustsImageWhenHighlighted = YES;
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    return rightBtn;
}

- (void)initDatas
{
    self.title = @"Blur";
}

- (void)initViews
{
    UIButton * rightBtn = [self createRightItemAction:@selector(btnClick:)];
    [rightBtn setTitle:@"点击" forState:UIControlStateNormal];
}

#pragma mark - UIButton Event
- (void)btnClick:(id)sender {
    [BlurView showBlurViewFromSupView:self.view.window];
}

#pragma mark - Lifecycle Method
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initDatas];
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
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
