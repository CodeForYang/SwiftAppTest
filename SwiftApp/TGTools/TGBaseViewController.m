//
//  TGBaseViewController.m
//  SwiftApp
//
//  Created by 杨佩 on 2022/3/28.
//

#import "TGBaseViewController.h"

@interface TGBaseViewController ()

@end

@implementation TGBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 获取自己window上正在显示的vc 以及 跳转
+ (UIViewController *)getCurrentVC {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC{
    
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        rootVC = [self getCurrentVCFrom:[rootVC presentedViewController]];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        currentVC = rootVC;
        
    }
    return currentVC;
}

@end
