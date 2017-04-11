//
//  ViewController.m
//  StreamKit
//
//  Created by 李浩 on 2016/12/18.
//  Copyright © 2016年 李浩. All rights reserved.
//

#import "ViewController.h"
#import "StreamKit.h"
#import "SecondController.h"
@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) NSString* textContent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width*4, self.view.frame.size.height);
    scrollView.delegate = self;
    [[scrollView sk_signalForDelegateEndDecelerating] subscribe:^(id x) {
        NSLog(@"b");
    }];
    [self.view addSubview:scrollView];
    
//    SK(label,text) = SKObserve(self, textContent);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
