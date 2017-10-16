//
//  NHSpringPopupButton.m
//  animationButton
//
//  Created by neghao on 2017/8/15.
//  Copyright © 2017年 neghao. All rights reserved.
//

#import "NHSpringPopupButton.h"


#define kDefaultAnimationDuration 0.25f


@interface NHSpringPopupButton ()
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) NSMutableArray *subButtons;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, weak) NSArray *buttons;

@end


@implementation NHSpringPopupButton

- (NSMutableArray *)subButtons {

    if (!_subButtons) {
        _subButtons = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _subButtons;
}

- (void)setButtonTitles:(NSArray *)titles
                 images:(NSArray *)images
             buttonSize:(CGSize)buttonSize {
    
    int i = 0;
    for (NSString *title in titles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        
        if (titles && images) {
            [button setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        } else {
            [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        }
        
        button.frame = CGRectMake(0.f, 0.f, buttonSize.width, buttonSize.height);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        button.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
        button.clipsToBounds = YES;
        button.tag = 100 + i;
        
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addButton:button];
        
        i ++;
    }
    
        [self bringSubviewToFront:self.homeButton];
}

- (void)addButton:(UIButton *)button {
    assert(button != nil);

    if ([self.subButtons containsObject:button] == false) {
        [self.subButtons addObject:button];
        [self addSubview:button];
        button.hidden = YES;
    }
}


- (void)didClickButton:(UIButton *)button {
    NSLog(@"点击了第%ld个button",button.tag - 100);
    __weak typeof(button)weakButton = button;
    if (self.delegate && [self.delegate respondsToSelector:@selector(NHSpringPopupButtonDidClickSubButton:)]) {
        [self.delegate NHSpringPopupButtonDidClickSubButton:weakButton];
    }
//    [self dismissButtons];
}


- (void)showButtons {
    if (self.delegate && [self.delegate respondsToSelector:@selector(NHSpringPopupButtonWillExpand:)]) {
        [self.delegate NHSpringPopupButtonWillExpand:self];
    }
    
    [self _prepareForButtonExpansion];
    
    self.userInteractionEnabled = NO;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:_animationDuration];
    [CATransaction setCompletionBlock:^{
        for (UIButton *button in self.subButtons) {
            button.transform = CGAffineTransformIdentity;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(NHSpringPopupButtonDidExpand:)]) {
            [self.delegate NHSpringPopupButtonDidExpand:self];
        }
        
        self.userInteractionEnabled = YES;
    }];
    
    NSArray *buttonContainer = self.subButtons;
    
    if (self.direction == NHSpringDirectionUp || self.direction == NHSpringDirectionLeft) {
        buttonContainer = [self _reverseOrderFromArray:self.subButtons];
    }
    
    for (int i = 0; i < buttonContainer.count; i++) {
        int index = (int)buttonContainer.count - (i + 1);
        
        UIButton *button = [buttonContainer objectAtIndex:index];
        button.hidden = NO;
        
        // position animation
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        CGPoint originPosition = CGPointZero;
        CGPoint finalPosition = CGPointZero;
        
        switch (self.direction) {
            case NHSpringDirectionLeft:
                originPosition = CGPointMake(self.frame.size.width - self.homeButton.frame.size.width, self.frame.size.height/2.f);
                finalPosition = CGPointMake(self.frame.size.width - self.homeButton.frame.size.width - button.frame.size.width/2.f - self.buttonSpacing
                                            - ((button.frame.size.width + self.buttonSpacing) * index),
                                            self.frame.size.height/2.f);
                break;
                
            case NHSpringDirectionRight:
                originPosition = CGPointMake(self.homeButton.frame.size.width, self.frame.size.height/2.f);
                finalPosition = CGPointMake(self.homeButton.frame.size.width + self.buttonSpacing + button.frame.size.width/2.f
                                            + ((button.frame.size.width + self.buttonSpacing) * index),
                                            self.frame.size.height/2.f);
                break;
                
            case NHSpringDirectionUp:
                originPosition = CGPointMake(self.frame.size.width/2.f, self.frame.size.height - self.homeButton.frame.size.height);
                finalPosition = CGPointMake(self.frame.size.width/2.f,
                                            self.frame.size.height - self.homeButton.frame.size.height - self.buttonSpacing - button.frame.size.height/2.f
                                            - ((button.frame.size.height + self.buttonSpacing) * index));
                break;
                
            case NHSpringDirectionDown:
                originPosition = CGPointMake(self.frame.size.width/2.f, self.homeButton.frame.size.height);
                finalPosition = CGPointMake(self.frame.size.width/2.f,
                                            self.homeButton.frame.size.height + self.buttonSpacing + button.frame.size.height/2.f
                                            + ((button.frame.size.height + self.buttonSpacing) * index));
                break;
                
            default:
                break;
        }
        
        positionAnimation.duration = _animationDuration;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:originPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:finalPosition];
        positionAnimation.beginTime = CACurrentMediaTime() + (_animationDuration/(float)self.subButtons.count * (float)i);
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        
        [button.layer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        button.layer.position = finalPosition;
        
        // scale animation
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        scaleAnimation.duration = _animationDuration;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:0.01f];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1.f];
        scaleAnimation.beginTime = CACurrentMediaTime() + (_animationDuration/(float)self.subButtons.count * (float)i) + 0.03f;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        
        [button.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        button.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    }
    
    [CATransaction commit];
    
    _isCollapsed = NO;
}

- (void)dismissButtons {
    if (self.delegate && [self.delegate respondsToSelector:@selector(NHSpringPopupButtonWillCollapse:)]) {
        [self.delegate NHSpringPopupButtonWillCollapse:self];
    }
    
    self.userInteractionEnabled = NO;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:_animationDuration];
    [CATransaction setCompletionBlock:^{
        [self _finishCollapse];
        
        for (UIButton *button in self.subButtons) {
            button.transform = CGAffineTransformIdentity;
            button.hidden = YES;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(NHSpringPopupButtonDidCollapse:)]) {
            [self.delegate NHSpringPopupButtonDidCollapse:self];
        }
        
        self.userInteractionEnabled = YES;
    }];
    
    int index = 0;
    for (int i = (int)self.subButtons.count - 1; i >= 0; i--) {
        UIButton *button = [self.subButtons objectAtIndex:i];
        
        if (self.direction == NHSpringDirectionDown || self.direction == NHSpringDirectionRight) {
            button = [self.subButtons objectAtIndex:index];
        }
        
        // scale animation
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        scaleAnimation.duration = _animationDuration;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:1.f];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0.01f];
        scaleAnimation.beginTime = CACurrentMediaTime() + (_animationDuration/(float)self.subButtons.count * (float)index) + 0.03;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        
        [button.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        button.transform = CGAffineTransformMakeScale(1.f, 1.f);
        
        // position animation
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        CGPoint originPosition = button.layer.position;
        CGPoint finalPosition = CGPointZero;
        
        switch (self.direction) {
            case NHSpringDirectionLeft:
                finalPosition = CGPointMake(self.frame.size.width - self.homeButton.frame.size.width, self.frame.size.height/2.f);
                break;
                
            case NHSpringDirectionRight:
                finalPosition = CGPointMake(self.homeButton.frame.size.width, self.frame.size.height/2.f);
                break;
                
            case NHSpringDirectionUp:
                finalPosition = CGPointMake(self.frame.size.width/2.f, self.frame.size.height - self.homeButton.frame.size.height);
                break;
                
            case NHSpringDirectionDown:
                finalPosition = CGPointMake(self.frame.size.width/2.f, self.homeButton.frame.size.height);
                break;
                
            default:
                break;
        }
        
        positionAnimation.duration = _animationDuration;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:originPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:finalPosition];
        positionAnimation.beginTime = CACurrentMediaTime() + (_animationDuration/(float)self.subButtons.count * (float)index);
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        
        [button.layer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        button.layer.position = originPosition;
        index++;
    }
    
    [CATransaction commit];
    
    _isCollapsed = YES;
}


#pragma mark -
#pragma mark initialized

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self _defaultInit];
        [self addSubview:self.homeButton];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame springDirection:(NHSpringDirection)direction {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _defaultInit];
        _direction = direction;
        [self addSubview:self.homeButton];
    }
    return self;
}

- (UIButton *)homeButton {
    if (!_homeButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.bounds];
        [button setTitle:@"Tap" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        button.layer.cornerRadius = button.bounds.size.height / 2;
        button.backgroundColor =[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
//        [button addTarget:self action:@selector(clickHomeButton:) forControlEvents:UIControlEventTouchUpInside];
        button.userInteractionEnabled = NO;
        _homeButton = button;
    }
    return _homeButton;
}

- (void)clickHomeButton:(UIButton *)button {
    if (button.selected) {
        [self dismissButtons];
    } else {
        [self showButtons];
    }
    button.selected = !button.selected;
}


#pragma mark -
#pragma mark Private Methods

- (void)_defaultInit {
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    
    self.direction = NHSpringDirectionUp;
    self.animatedHighlighting = YES;
    self.collapseAfterSelection = YES;
    self.animationDuration = kDefaultAnimationDuration;
    self.standbyAlpha = 1.f;
    self.highlightAlpha = 0.45f;
    self.originFrame = self.frame;
    self.buttonSpacing = 20.f;
    _isCollapsed = YES;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    self.tapGestureRecognizer.delegate = self;
    
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)_handleTapGesture:(id)sender {
    if (self.tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchLocation = [self.tapGestureRecognizer locationOfTouch:0 inView:self];
        
        if (_collapseAfterSelection && _isCollapsed == NO && CGRectContainsPoint(self.homeButton.frame, touchLocation) == false) {
            [self dismissButtons];
        }
    }
}

- (void)_animateWithBlock:(void (^)(void))animationBlock {
    [UIView transitionWithView:self
                      duration:kDefaultAnimationDuration
                       options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                    animations:animationBlock
                    completion:NULL];
}

- (void)_setTouchHighlighted:(BOOL)highlighted {
    float alphaValue = highlighted ? _highlightAlpha : _standbyAlpha;
    
    if (self.homeButton.alpha == alphaValue)
        return;
    
    if (_animatedHighlighting) {
        [self _animateWithBlock:^{
            if (self.homeButton != nil) {
                self.homeButton.alpha = alphaValue;
            }
        }];
    } else {
        if (self.homeButton != nil) {
            self.homeButton.alpha = alphaValue;
        }
    }
}

- (float)_combinedButtonHeight {
    float height = 0;
    for (UIButton *button in self.subButtons) {
        height += button.frame.size.height + self.buttonSpacing;
    }
    
    return height;
}

- (float)_combinedButtonWidth {
    float width = 0;
    for (UIButton *button in self.subButtons) {
        width += button.frame.size.width + self.buttonSpacing;
    }
    
    return width;
}

- (void)_prepareForButtonExpansion {
    float buttonHeight = [self _combinedButtonHeight];
    float buttonWidth = [self _combinedButtonWidth];
    
    switch (self.direction) {
        case NHSpringDirectionUp:
        {
            self.homeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            
            CGRect frame = self.frame;
            frame.origin.y -= buttonHeight;
            frame.size.height += buttonHeight;
            self.frame = frame;
        }
            break;
            
        case NHSpringDirectionDown:
        {
            self.homeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            
            CGRect frame = self.frame;
            frame.size.height += buttonHeight;
            self.frame = frame;
        }
            break;
            
        case NHSpringDirectionLeft:
        {
            self.homeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            CGRect frame = self.frame;
            frame.origin.x -= buttonWidth;
            frame.size.width += buttonWidth;
            self.frame = frame;
        }
            break;
            
        case NHSpringDirectionRight:
        {
            self.homeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            
            CGRect frame = self.frame;
            frame.size.width += buttonWidth;
            self.frame = frame;
        }
            break;
            
        default:
            break;
    }
}

- (void)_finishCollapse {
    self.frame = _originFrame;
}

- (UIView *)_subviewForPoint:(CGPoint)point {
    for (UIView *subview in self.subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            return subview;
        }
    }
    
    return self;
}

- (NSArray *)_reverseOrderFromArray:(NSArray *)array {
    NSMutableArray *reverseArray = [NSMutableArray array];
    
    for (int i = (int)array.count - 1; i >= 0; i--) {
        [reverseArray addObject:[array objectAtIndex:i]];
    }
    
    return reverseArray;
}

#pragma mark -
#pragma mark Setters/Getters

- (NSArray *)buttons {
    return [self.subButtons copy];
}



#pragma mark -
#pragma mark Touch Handling Methods

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        if (_isCollapsed) {
            return self;
        } else {
            return [self _subviewForPoint:point];
        }
    }
    
    return hitView;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"%s",__func__);
    
    UITouch *touch = [touches anyObject];
    
    if (CGRectContainsPoint(self.frame, [touch locationInView:self])) {
        [self _setTouchHighlighted:YES];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"%s",__func__);
    
    UITouch *touch = [touches anyObject];
    
    [self _setTouchHighlighted:NO];
    
//    if (CGRectContainsPoint(self.frame, [touch locationInView:self])) {
        if (_isCollapsed) {
            [self showButtons];
        } else {
            [self dismissButtons];
        }
//    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"%s",__func__);
    [self _setTouchHighlighted:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    NSLog(@"%s",__func__);
    
    UITouch *touch = [touches anyObject];
    
    [self _setTouchHighlighted:CGRectContainsPoint(self.frame, [touch locationInView:self])];
}



#pragma mark -
#pragma mark UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchLocation = [touch locationInView:self];
    
    if ([self _subviewForPoint:touchLocation] != self && _collapseAfterSelection) {
        return YES;
    }
    
    return NO;
}




@end
