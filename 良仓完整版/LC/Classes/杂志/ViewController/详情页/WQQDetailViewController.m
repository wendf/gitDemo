//
//  WQQDetailViewController.m
//  LC
//
//  Created by QianFeng on 15/10/5.
//  Copyright (c) 2015年 第一小组二分队. All rights reserved.
//

#import "WQQDetailViewController.h"
#import <WebKit/WebKit.h>
#import "UMSocial.h"

@interface WQQDetailViewController ()<WKNavigationDelegate,UMSocialUIDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) UIProgressView *progressView;

@end

@implementation WQQDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavigateionRightItem];
    [self createNavigateionLeftItem];
    
    self.webView = [[WKWebView alloc]initWithFrame:self.view.bounds];
    self.webView.backgroundColor = LCBaseColor;
    self.title = self.model.nav_title;
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.model.topic_url]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self createProgressView];
}

- (void)createProgressView {
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, LCKScreenWidth, 10)];
    self.progressView.progress = 0;
    [self.view addSubview:self.progressView];
}

- (void)createNavigateionLeftItem {
    UIButton *button = [CustomViewFactory createButton:CGRectMake(0, 0, 40, 40) backgourdImage:[UIImage imageNamed:@"loginBack.png"]];
    button.tag = 17;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)createNavigateionRightItem {
    // 收藏
    UIButton *button = [CustomViewFactory createButton:CGRectMake(0, 0, 40, 40) backgourdImage:[UIImage imageNamed:@"uncollected_spec@2x.png"]];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 37;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    if ([[WQQDBManager sharedInstance] isManaegrExists:self.model]) {
        item.enabled = NO;
    }
    
    // 分享
    UIButton *button1 = [CustomViewFactory createButton:CGRectMake(0, 0, 40, 40) backgourdImage:[UIImage imageNamed:@"btn_ware_forward@2x.png"]];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    button1.tag = 27;
    [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[item1,item];
}

- (void)buttonClick:(UIButton *)button {
    // 返回
    if (button.tag == 17) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.navigationController popViewControllerAnimated:YES];

    }
    // 分享
    if (button.tag == 27) {
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:LCAPPKEY
                                          shareText:self.model.nav_title
                                         shareImage:nil
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToRenren,UMShareToDouban,nil]
                                           delegate:self];

        
    }
    // 收藏
    if (button.tag == 37) {
        [[WQQDBManager sharedInstance] addManagerModelInfo:self.model];
        button.enabled = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    self.progressView.progress = self.webView.estimatedProgress;
    if(self.progressView.progress == 1.0) {
        self.progressView.hidden = YES;
    }
}



@end
