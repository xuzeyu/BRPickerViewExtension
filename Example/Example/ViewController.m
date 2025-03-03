//
//  ViewController.m
//  Example
//
//  Created by XUZY on 2022/10/24.
//

#import "ViewController.h"
#import "BRTextAddressPickerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"AddressPickerView" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(50, 100, 200, 50);
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClick {
    [BRTextAddressPickerView showAddressPickerWithFileName:nil showColumnNum:3 ignoreColumnNum:0 astrictAreaCodes:@[] selectAreaCode:@"110100" showLetters:@[@YES, @YES, @YES] orderLetters:@[@YES, @YES] resultBlock:^(NSArray<BRTextModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexs) {
        NSString *text = [models br_joinText:@"-"];
        NSLog(@"text = %@", text);
        NSString *text2 = [models br_joinValue:@"originalText" separator:@"-"];
        NSLog(@"text = %@", text2);
    }];
    
    //直接获取结果
    [BRTextAddressPickerView addressPickerWithFileName:nil showColumnNum:3 ignoreColumnNum:0 astrictAreaCodes:@[] selectAreaCode:@"120105" showLetters:@[@YES, @YES, @YES] orderLetters:@[@YES, @YES] resultBlock:^(NSArray<BRTextModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexs) {
        NSString *text = [models br_joinText:@"-"];
        NSLog(@"text = %@", text);
        NSString *text2 = [models br_joinValue:@"originalText" separator:@"-"];
        NSLog(@"text = %@", text2);
    }];
}

@end
