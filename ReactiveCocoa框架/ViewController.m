//
//  ViewController.m
//  ReactiveCocoa框架
//
//  Created by apple on 15/10/18.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "ViewController.h"

#import "RedView.h"
#import "ReactiveCocoa.h"
#import "NSObject+RACKVOWrapper.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet RedView *redView;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 6.处理当界面有多次请求时，需要都获取到数据时，才能展示界面
    RACSignal *requestHot = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"请求最热商品");
        [subscriber sendNext:@"获取最热商品"];
        return nil;
    }];
    
    RACSignal *requestNew = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"请求最新商品");
//        [subscriber sendNext:@"获取最新商品"];
        return nil;
    }];
    
    // Selector调用:当所有信号都发送数据的时候调用
    // 数组存放信号
    // Selector注意点:参数根据数组元素决定
    // Selector方法参数类型,就是信号传递出来数据
    [self rac_liftSelector:@selector(updateUI:data2:) withSignalsFromArray:@[requestHot,requestNew]];
    
}
// 只要两个请求都请求完成的时候才会调用
- (void)updateUI:(NSString *)data1 data2:(NSString *)data2
{
    NSLog(@"%@ %@",data1,data2);
}

- (void)rac_textSignal
{
    // 5.监听文本框
    [_textField.rac_textSignal subscribeNext:^(id x) {
        // x:文本框的文字
        NSLog(@"%@",x);
    }];

}

- (void)notication
{
    // 4.监听通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

- (void)event
{
    // 3.监听事件
    //  只要按钮产生这个事件,就会产生一个信号
    [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        NSLog(@"按钮被点击%@",x);
    }];
    _btn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"按钮点击");
        return [RACSignal empty];
    }];
}

- (void)KVO
{
    // 2.KVO
    [_redView rac_observeKeyPath:@"name" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        // 只要监听的属性一改变调用
        NSLog(@"%@",_redView.name);
    }];
    
    // KVO:第二种,只要对象的值改变,就会产生信号,订阅信号
    [[_redView rac_valuesForKeyPath:@"name" observer:nil] subscribeNext:^(id x) {
        
    }];

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _redView.name = @"123";
}


- (void)delegate
{
    // 使用任何框架,都可以尝试下敲框架的类名
    // 1.代替代理,RACSubject
    // RAC方法:可以判断下某个方法有没有调用
    // 只要self调用Selector就会产生一个信号
    // rac_signalForSelector:监听某个对象调用某个方法
    [[self rac_signalForSelector:@selector(didReceiveMemoryWarning)] subscribeNext:^(id x) {
        
        NSLog(@"控制器调用了didReceiveMemoryWarning");
    }];
    // 判断下redView有没有调用btnClick,就表示点击了按钮
    [[_redView rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        NSLog(@"点击了按钮");
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
