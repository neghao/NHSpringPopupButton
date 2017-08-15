//
//  NHSpringPopupButton.h
//  animationButton
//
//  Created by neghao on 2017/8/15.
//  Copyright © 2017年 neghao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NHSpringDirection) {
    NHSpringDirectionLeft = 0,
    NHSpringDirectionRight,
    NHSpringDirectionUp,
    NHSpringDirectionDown
};

@class NHSpringPopupButton;

@protocol NHSpringPopupButtonDelegate <NSObject>

@optional
- (void)NHSpringPopupButtonWillExpand:(NHSpringPopupButton *)expandableView;
- (void)NHSpringPopupButtonDidExpand:(NHSpringPopupButton *)expandableView;
- (void)NHSpringPopupButtonWillCollapse:(NHSpringPopupButton *)expandableView;
- (void)NHSpringPopupButtonDidCollapse:(NHSpringPopupButton *)expandableView;


- (void)NHSpringPopupButtonDidClickSubButton:(UIButton *)subButton;

@end



@interface NHSpringPopupButton : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak, readonly) NSArray *buttons;
@property (nonatomic, strong) UIView *homeButtonView;
@property (nonatomic, readonly) BOOL isCollapsed;
@property (nonatomic, weak) id <NHSpringPopupButtonDelegate> delegate;

// The direction in which the menu expands
@property (nonatomic) enum NHSpringDirection direction;

// Indicates whether the home button will animate it's touch highlighting, this is enabled by default
@property (nonatomic) BOOL animatedHighlighting;

// Indicates whether menu should collapse after a button selection, this is enabled by default
@property (nonatomic) BOOL collapseAfterSelection;

// The duration of the expand/collapse animation
@property (nonatomic) float animationDuration;

// The default alpha of the homeButtonView when not tapped
@property (nonatomic) float standbyAlpha;

// The highlighted alpha of the homeButtonView when tapped
@property (nonatomic) float highlightAlpha;

// The spacing between menu buttons when expanded
@property (nonatomic) float buttonSpacing;

// Initializers
- (id)initWithFrame:(CGRect)frame springDirection:(NHSpringDirection)direction;

- (void)setButtonTitles:(NSArray *)titles
                 images:(NSArray *)images
             buttonSize:(CGSize)buttonSize;


- (void)showButtons;
- (void)dismissButtons;

@end
