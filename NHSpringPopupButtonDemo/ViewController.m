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
    
    _springButton = [[NHSpringPopupButton alloc] initWithFrame:CGRectMake(20, 64, 50, 50) springDirection:NHSpringDirectionRight];
    
    _springButton.backgroundColor = [UIColor blackColor];
    //    _springButton.homeButtonView = [self createHomeButtonView];
    
    NSArray *titls = @[@"A", @"B", @"C", @"D", @"E", @"F"];
    [_springButton setButtonTitles:titls images:nil buttonSize:CGSizeMake(30, 30)];
    
    
    [self.view addSubview:_springButton];
    
}
- (UILabel *)createHomeButtonView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    
    label.text = @"Tap";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = label.frame.size.height / 2.f;
    label.backgroundColor =[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    label.clipsToBounds = YES;
    
    return label;
}


- (IBAction)showContentView:(UIButton *)sender {
    

}


@end
