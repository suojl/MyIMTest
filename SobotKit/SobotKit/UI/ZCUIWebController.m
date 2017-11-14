//
//  ZCUIWebController.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIWebController.h"
#import "ZCLIbGlobalDefine.h"

/**
 *  PageClickTag ENUM
 */
typedef NS_ENUM(NSInteger, PageClickTag) {
    /** 返回 */
    BUTTON_WEB_BACK      = 1,
    /** 刷新 */
    BUTTON_REREFRESH = 2,
};


@interface ZCUIWebController ()<UIWebViewDelegate>{
    NSString *pageURL;
    
    UIWebView *_webView;
    
    BOOL  navBarHide;
    
}

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshButtonItem;
@property (nonatomic, strong) UIBarButtonItem *urlCopyButtonItem;

@end

@implementation ZCUIWebController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createTitleView];
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.tag = BUTTON_WEB_BACK;
    [self.backButton setTitle:@"" forState:UIControlStateNormal];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_back_disabled"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_back_disabled"] forState:UIControlStateHighlighted];
    
    // 隐藏右上角的按钮
    self.moreButton.enabled = NO;
    [self.moreButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, NavBarHeight, self.view.frame.size.width, self.view.frame.size.height-NavBarHeight-44)];
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [_webView scalesPageToFit];
    [_webView setScalesPageToFit:YES];
    [_webView setDelegate:self];
    
    [self.view addSubview:_webView];
    
//    NSURL *url=[[ NSURL alloc ] initWithString:pageURL];
//    [_webView loadRequest:[ NSURLRequest requestWithURL:url]];
    [self checkTxtEncode];
    
    [self updateToolbarItems];
    
    navBarHide = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES];
}

/**
 *  暂时不使用
 */
-(void) checkTxtEncode{
    NSString *fileName = [pageURL lastPathComponent];
    
    if (fileName && [[fileName lowercaseString] hasSuffix:@".txt"])
    {
        NSData *attachmentData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:pageURL]];
        
        //txt分带编码和不带编码两种，带编码的如UTF-8格式txt，不带编码的如ANSI格式txt
        //不带的，可以依次尝试GBK和GBK编码
        NSString *aStr=[[NSString alloc] initWithData:attachmentData encoding:0x80000632];
        if (!aStr)
        {
            //用GBK编码不行,再用GB18030编码
            aStr=[[NSString alloc] initWithData:attachmentData encoding:0x80000631];
        }
        if( !aStr){
            aStr=[[NSString alloc] initWithData:attachmentData encoding:NSUTF8StringEncoding];
        }
        if(aStr){
            //通过html语言进行排版
            NSString* responseStr = [NSString stringWithFormat:
                                     @"<HTML>"
                                     "<head>"
                                     "<title>Text View</title>"
                                     "</head>"
                                     "<BODY>"
                                     "<pre>"
                                     "%@"
                                     "/pre>"
                                     "</BODY>"
                                     "</HTML>",
                                     aStr];
            
            [_webView loadHTMLString:responseStr baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        }else{
            NSURL *url=[[ NSURL alloc ] initWithString:pageURL];
            [_webView loadRequest:[ NSURLRequest requestWithURL:url]];
        }
    }else{
        NSURL *url=[[ NSURL alloc ] initWithString:pageURL];
        [_webView loadRequest:[ NSURLRequest requestWithURL:url]];
        
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _webView = nil;
    _backBarButtonItem = nil;
    _forwardBarButtonItem = nil;
    _refreshBarButtonItem = nil;
    _stopBarButtonItem = nil;
    _refreshButtonItem = nil;
    _urlCopyButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    if(!navBarHide){
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    
}
-(id)initWithURL:(NSString *)url{
    self=[super init];
    if(self){
        pageURL=url;
    }
    return self;
}

-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_WEB_BACK){
        if(self.navigationController != nil && self.navigationController.childViewControllers.count>1){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 处理掉底部输入框的痕迹
            self.navigationController.toolbarHidden = YES;
        });
        
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateToolbarItems];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}



- (void)updateToolbarItems {
    self.backBarButtonItem.enabled = _webView.canGoBack;
    self.forwardBarButtonItem.enabled = _webView.canGoForward;
    
//    UIBarButtonItem *refreshStopBarButtonItem = _webView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    // 显示刷新的按钮
    UIBarButtonItem *refreshStopBarButtonItem =  self.refreshBarButtonItem  ;
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat toolbarWidth = 250.0f;
        fixedSpace.width = 35.0f;
        
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          refreshStopBarButtonItem,
                          fixedSpace,
                          self.backBarButtonItem,
                          fixedSpace,
                          self.forwardBarButtonItem,
                          fixedSpace,
                          self.urlCopyButtonItem,
                          nil];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f)];
        toolbar.items = items;
        toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationItem.rightBarButtonItems = items.reverseObjectEnumerator.allObjects;
    }
    
    else {
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          self.backBarButtonItem,
                          flexibleSpace,
                          self.forwardBarButtonItem,
                          flexibleSpace,
                          self.urlCopyButtonItem,
                          flexibleSpace,
                          refreshStopBarButtonItem,
                          fixedSpace,
                          nil];
        
        self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.toolbarItems = items;
        
    }
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
//        _backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_back"]
//                                                              style:UIBarButtonItemStylePlain
//                                                             target:self
//                                                             action:@selector(goBackTapped:)];
//        _backBarButtonItem.width = 18.0f;
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_back"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_back_pressed"] forState:UIControlStateHighlighted];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_back_disabled"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(goBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _backBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        
        _backBarButtonItem.width = 25.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    if (!_forwardBarButtonItem) {
//        _forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_next"]
//                                                                 style:UIBarButtonItemStylePlain
//                                                                target:self
//                                                                action:@selector(goForwardTapped:)];
//        _forwardBarButtonItem.width = 18.0f;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_next"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_next_pressed"] forState:UIControlStateHighlighted];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_next_disabled"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(goForwardTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _forwardBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        
        _forwardBarButtonItem.width = 25.0f;
        
        
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
      
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_refreshBar_normal"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_refreshBar_pressed"] forState:UIControlStateHighlighted];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_refreshBar_pressed"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(reloadTapped:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _refreshBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];

        _refreshBarButtonItem.width = 25.0f;
        
    }
    return _refreshBarButtonItem;
}



- (UIBarButtonItem *)urlCopyButtonItem {
    if (!_urlCopyButtonItem) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_web_Copy_nols"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_web_Copy_press"] forState:UIControlStateHighlighted];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_web_Copy_press"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(copyURL:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _urlCopyButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        
        _urlCopyButtonItem.width = 25.0f;
        
    }
    return _urlCopyButtonItem;
}

#pragma mark - Target actions

- (void)goBackTapped:(UIBarButtonItem *)sender {
    [_webView goBack];
}

- (void)goForwardTapped:(UIBarButtonItem *)sender {
    [_webView goForward];
}

- (void)reloadTapped:(UIBarButtonItem *)sender {
    [_webView reload];
}

- (void)copyURL:(UIBarButtonItem *)sender{
    NSString *currentURL = [_webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
//    NSLog(@"复制链接%@",currentURL);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:currentURL];
    [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@" 复制成功 ") duration:1.0f view:self.view position:ZCToastPositionCenter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
