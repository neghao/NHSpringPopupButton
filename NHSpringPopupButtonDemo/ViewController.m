//
//  ViewController.m
//  NHSpringPopupButtonDemo
//
//  Created by neghao on 2017/8/15.
//  Copyright © 2017年 neghao. All rights reserved.
//

#import "ViewController.h"
#import "NHSpringPopupButton.h"

@interface ViewController ()

@property (nonatomic, strong) NHSpringPopupButton *springButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _springButton = [[NHSpringPopupButton alloc] initWithFrame:CGRectMake(100, self.view.bounds.size.height - 100, 50, 50) springDirection:NHSpringDirectionUp];
    
//    _springButton.backgroundColor = [UIColor blackColor];
    //    _springButton.homeButtonView = [self createHomeButtonView];
    
    NSArray *titls = @[@"A", @"B", @"C", @"D", @"E", @"F"];
    [_springButton setButtonTitles:titls images:nil buttonSize:CGSizeMake(30, 30)];
    
    
    [self.view addSubview:_springButton];
    
}

- (IBAction)showContentView:(UIButton *)sender {
    

}


@end
