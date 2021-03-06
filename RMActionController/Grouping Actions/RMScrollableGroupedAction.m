//
//  RMScrollableGroupedAction.m
//  RMImageAction-Demo
//
//  Created by Roland Moers on 19.11.16.
//  Copyright © 2016 Roland Moers. All rights reserved.
//

#import "RMScrollableGroupedAction.h"

@interface RMScrollableGroupedAction ()

@property (nonatomic, assign) CGFloat actionWidth;
@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;

@end

@implementation RMScrollableGroupedAction

#pragma mark - Class
+ (instancetype)actionWithStyle:(RMActionStyle)style andActions:(NSArray *)actions {
    RMScrollableGroupedAction *action = [super actionWithStyle:style andActions:actions];
    action.actionWidth = 50;
    
    return action;
}

+ (instancetype)actionWithStyle:(RMActionStyle)style actionWidth:(CGFloat)actionWidth andActions:(NSArray *)actions {
    RMScrollableGroupedAction *action = [[self class] actionWithStyle:style andActions:actions];
    action.actionWidth = actionWidth;
    
    return action;
}

#pragma mark - View
- (UIView *)loadView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    __block UIView *currentLeft = nil;
    [self.actions enumerateObjectsUsingBlock:^(RMAction *action, NSUInteger index, BOOL *stop) {
        [scrollView addSubview:action.view];
        
        if(index == 0) {
            NSDictionary *bindings = @{@"actionView": action.view};
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[actionView]-(>=0)-|" options:0 metrics:nil views:bindings]];
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[actionView]" options:0 metrics:nil views:bindings]];
        } else {
            NSDictionary *bindings = @{@"actionView": action.view, @"currentLeft": currentLeft};
            NSDictionary *metrics = @{@"width": @(self.actionWidth)};
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[actionView]-(>=0)-|" options:0 metrics:nil views:bindings]];
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[currentLeft(width)]-(0)-[actionView(width)]" options:0 metrics:metrics views:bindings]];
        }
        
        currentLeft = action.view;
    }];
    
    NSDictionary *bindings = @{@"currentLeft": currentLeft, @"scrollView": scrollView};
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[currentLeft]-(0)-|" options:0 metrics:nil views:bindings]];
    
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [scrollView addConstraint: self.heightConstraint];
    [self updateFont];
    
    return scrollView;
}

#pragma mark - Helper
- (void)updateFont {
    __block CGFloat maxHeight = 0;
    [self.actions enumerateObjectsUsingBlock:^(RMAction *action, NSUInteger index, BOOL *stop) {
        maxHeight = MAX(maxHeight, [action.view systemLayoutSizeFittingSize:CGSizeMake(self.actionWidth, 999999) withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityFittingSizeLevel].height);
    }];
    self.heightConstraint.constant = maxHeight;
}

@end
