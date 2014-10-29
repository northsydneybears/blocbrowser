//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Peter Gow on 18/10/2014.
//  Copyright (c) 2014 Peter Gow. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;


@end



@implementation BLCAwesomeFloatingToolbar

- (UIColor *)randomColor  {
    CGFloat red = arc4random_uniform(256) / 256.0;
    CGFloat green = arc4random_uniform(256) / 256.0;
    CGFloat blue = arc4random_uniform(256) / 256.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    NSLog(@"%@", color);
    return color;
}



    
- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        
        NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *btn = [[UIButton alloc] init];
            btn.userInteractionEnabled = NO;
            btn.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = self.randomColor;
            
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = [UIFont systemFontOfSize:10];

            [btn setTitle:titleForThisLabel forState:UIControlStateNormal];
            btn.backgroundColor = colorForThisLabel;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            //[btn targetForAction:@selector(clicked_btn:) withSender:self];
            [btn addTarget:self action:@selector(clicked_btn:) forControlEvents:UIControlEventTouchUpInside];
            [buttonArray addObject:btn];
        }
        
        self.buttons = buttonArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
//        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
//        [self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
        
    }
    
    return self;
}

- (void) clicked_btn:(id)sender
{
    UIButton* btn = sender;
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:btn.titleLabel.text];
    }
}

//- (void) tapFired:(UITapGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//        CGPoint location = [recognizer locationInView:self];
//        UIView *tappedView = [self hitTest:location withEvent:nil];
//        
//        if ([self.labels containsObject:tappedView]) {
//            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
//            }
//        }
//    }
//}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

// Pinch gesture

- (void) pinchFired:(UIPinchGestureRecognizer *)pinchGesture {
    if ([pinchGesture state] == UIGestureRecognizerStateBegan || [pinchGesture state] == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformScale([[pinchGesture view] transform], [pinchGesture scale], [pinchGesture scale]);
        [pinchGesture setScale:1];
    }
}

/*- (void) pinchFired:(UIPinchGestureRecognizer *)pinchGesture {
    if ([(UIPinchGestureRecognizer*)pinchGesture state] == UIGestureRecognizerStateBegan) {
        CGFloat _initialTouchScale = 1;
    }
    
    CGFloat scale = 1 - (_initialTouchScale - [(UIPinchGestureRecognizer*)pinchGesture scale]);
    CGAffineTransform currentTransform = self.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [self.transform = newTransform];
    
}
*/

// Long Press Gesture

- (void) pressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        for (UIButton* currBtn in self.buttons)
        {
            currBtn.backgroundColor = [self randomColor];
        }
    }
}

    
- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *currBtn in self.buttons) {
        NSUInteger currentLabelIndex = [self.buttons indexOfObject:currBtn];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        currBtn.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark - Touch Handling

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *btn = [self.buttons objectAtIndex:index];
        btn.userInteractionEnabled = enabled;
        btn.alpha = enabled ? 1.0 : 0.25;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
