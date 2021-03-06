//
//  TOAlertViewController.m
//
//  Copyright 2019 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOAlertViewController.h"
#import "TOAlertView.h"
#import "TOAlertDimmingView.h"
#import "TOAlertViewTransitioning.h"

@interface TOAlertViewController () <UIViewControllerTransitioningDelegate>

// State to track when we're dismissing so to disable any implicit layout
@property (nonatomic, assign) BOOL isDismissing;

// Managed views
@property (nonatomic, strong) TOAlertDimmingView *dimmingView;
@property (nonatomic, strong) TOAlertView *alertView;

@end

@implementation TOAlertViewController

// Defining title in the header is only for documentation convenience.
// The internal implementation will actually be used.
@dynamic title;

#pragma mark - View Controller Creation -

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    if (self = [super init]) {
        super.title = title;
        _message = [message copy];
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set us as the manager for our own presentation controller
    self.transitioningDelegate = self;

    // Add the subiews
    [self.view addSubview:self.dimmingView];
    [self.view addSubview:self.alertView];

    // Set the block handler for all buttons to dismiss
    __weak typeof(self) weakSelf = self;
    self.alertView.buttonTappedHandler = ^(void (^buttonAction)(void)) {
        [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:buttonAction];
    };
}

#pragma mark - View Controller Configuration -

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - View Layout -

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (self.isDismissing) { return; }

    UIEdgeInsets layoutMargins = self.view.layoutMargins;
    CGSize contentSize = self.view.bounds.size;
    contentSize.width -= (layoutMargins.left + layoutMargins.right);
    contentSize.height -= (layoutMargins.top + layoutMargins.bottom);
    [self.alertView sizeToFitInBoundSize:contentSize];
    self.alertView.center = self.view.center;
}

#pragma mark - Presentation Handling -

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                            presentingController:(UIViewController *)presenting
                                                                                sourceController:(UIViewController *)source
{
    return [[TOAlertViewTransitioning alloc] initWithAlertView:self.alertView dimmingView:self.dimmingView reverse:NO];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isDismissing = YES;
    return [[TOAlertViewTransitioning alloc] initWithAlertView:self.alertView dimmingView:self.dimmingView reverse:YES];
}

#pragma mark - Lazy View Accessors -

- (TOAlertDimmingView *)dimmingView
{
    if (_dimmingView) { return _dimmingView; }
    _dimmingView = [[TOAlertDimmingView alloc] initWithFrame:self.view.bounds];
    return _dimmingView;
}

- (TOAlertView *)alertView
{
    if (_alertView) { return _alertView; }
    _alertView = [[TOAlertView alloc] initWithTitle:self.title message:self.message];
    return _alertView;
}

#pragma mark - Regular Accessor Management -

- (void)addAction:(TOAlertAction *)action
{
    [self.alertView addAction:action];
}

- (void)removeAction:(TOAlertAction *)action
{
    [self.alertView removeAction:action];
}

- (void)removeActionAtIndex:(NSUInteger)index
{
    [self.alertView removeActionAtIndex:index];
}

#pragma mark - Layout Accessors -

- (void)setMaximumWidth:(CGFloat)maximumWidth { self.alertView.maximumWidth = maximumWidth; }
- (CGFloat)maximumWidth { return self.alertView.maximumWidth; }

- (void)setCornerRadius:(CGFloat)cornerRadius { self.alertView.cornerRadius = cornerRadius; }
- (CGFloat)cornerRadius { return self.alertView.cornerRadius; }

- (void)setButtonCornerRadius:(CGFloat)buttonCornerRadius { self.alertView.buttonCornerRadius = buttonCornerRadius; }
- (CGFloat)buttonCornerRadius { return self.alertView.buttonCornerRadius; }

- (void)setButtonSpacing:(CGSize)buttonSpacing { self.alertView.buttonSpacing = buttonSpacing; }
- (CGSize)buttonSpacing { return self.alertView.buttonSpacing; }

- (void)setButtonHeight:(CGFloat)buttonHeight { self.alertView.buttonHeight = buttonHeight; }
- (CGFloat)buttonHeight { return self.alertView.buttonHeight; }

- (void)setContentInsets:(UIEdgeInsets)contentInsets { self.alertView.contentInsets = contentInsets; }
- (UIEdgeInsets)contentInsets { return self.alertView.contentInsets; }

- (void)setButtonInsets:(UIEdgeInsets)buttonInsets { self.alertView.buttonInsets = buttonInsets; }
- (UIEdgeInsets)buttonInsets { return self.alertView.buttonInsets; }

- (void)setVerticalTextSpacing:(CGFloat)verticalTextSpacing { self.alertView.verticalTextSpacing = verticalTextSpacing; }
- (CGFloat)verticalTextSpacing { return self.alertView.verticalTextSpacing; }

#pragma mark - Theme Accessors -

// Global dialog style
- (void)setStyle:(TOAlertViewStyle)style { self.alertView.style = style; }
- (TOAlertViewStyle)style { return self.alertView.style; }

// Title label color
- (void)setTitleColor:(UIColor *)titleColor { self.alertView.titleColor = titleColor; }
- (UIColor *)titleColor { return self.alertView.titleColor; }

// Message label color
- (void)setMessageColor:(UIColor *)messageColor {self.alertView.messageColor = messageColor; }
- (UIColor *)messageColor { return self.alertView.messageColor; }

// Color of default action button background
- (void)setActionButtonColor:(UIColor *)actionButtonColor { self.alertView.actionButtonColor = actionButtonColor; }
- (UIColor *)actionButtonColor { return self.alertView.actionButtonColor; }

// Color of default action button text
- (void)setActionTextColor:(UIColor *)actionTextColor { self.alertView.actionTextColor = actionTextColor; }
- (UIColor *)actionTextColor { return self.alertView.actionTextColor; }

// Color of the default action button background
- (void)setDefaultActionButtonColor:(UIColor *)defaultActionButtonColor { self.alertView.defaultActionButtonColor = defaultActionButtonColor; }
- (UIColor *)defaultActionButtonColor { return self.alertView.defaultActionButtonColor; }

// Color of the default action button text
- (void)setDefaultActionTextColor:(UIColor *)defaultActionTextColor { self.alertView.defaultActionTextColor = defaultActionTextColor; }
- (UIColor *)defaultActionTextColor { return self.alertView.defaultActionTextColor; }

// Color of the destruction action button background
- (void)setDestructiveActionButtonColor:(UIColor *)destructiveActionButtonColor { self.alertView.destructiveActionButtonColor = destructiveActionButtonColor; }
- (UIColor *)destructiveActionButtonColor { return self.alertView.destructiveActionButtonColor; }

// Color of the destructive action button text
- (void)setDestructiveActionTextColor:(UIColor *)destructiveActionTextColor { self.alertView.destructiveActionTextColor = destructiveActionTextColor; }
- (UIColor *)destructiveActionTextColor { return self.alertView.destructiveActionTextColor; }

#pragma mark - Action Accessors -

// The default button action
- (void)setDefaultAction:(TOAlertAction *)action { self.alertView.defaultAction = action; }
- (TOAlertAction *)defaultAction { return self.alertView.defaultAction; }

// The cancel button action
- (void)setCancelAction:(TOAlertAction *)action {self.alertView.cancelAction = action; }
- (TOAlertAction *)cancelAction { return self.alertView.cancelAction; }

// The destructive button 
- (void)setDestructiveAction:(TOAlertAction *)action { self.alertView.destructiveAction = action; }
- (TOAlertAction *)destructiveAction { return self.alertView.destructiveAction; }

@end
