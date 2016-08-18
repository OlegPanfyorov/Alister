//
//  ANKeyboardHandler.m
//
//  Created by Oksana Kovalchuk on 17/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANKeyboardHandler.h"

static const CGFloat kCalculatedContentPadding = 10;
static const CGFloat kMinimumScrollOffsetPadding = 20;

@interface ANKeyboardHandler () <UIGestureRecognizerDelegate>
{
    struct {
        BOOL shouldNotifityKeyboardState : YES;
    } _delegateExistingMethods;
}
@property (nonatomic, weak) UIScrollView* target;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic, assign) BOOL isKeyboardVisible; //sometimes IOS send unbalanced show/hide notifications
@property (nonatomic, assign) UIEdgeInsets defaultContentInsets;

@end

@implementation ANKeyboardHandler

+ (instancetype)handlerWithTarget:(id)target
{
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(UIScrollView*)scrollView
{
    self = [super init];
    if (self)
    {
        NSAssert([scrollView isKindOfClass:[UIScrollView class]],
                 @"You can't handle keyboard on class %@\n It must me UIScrollView subclass", NSStringFromClass([scrollView class]));
        
        self.target = scrollView;
        [self setupKeyboard];
        self.enabled = YES;
    }
    return self;
}

- (void)setDelegate:(id<ANKeyboardHandlerDelegate>)delegate
{
    _delegate = delegate;
    BOOL shouldNotify = ([delegate respondsToSelector:@selector(keyboardWillUpdateToVisible:withNotification:)]);
    _delegateExistingMethods.shouldNotifityKeyboardState = shouldNotify;
}

- (void)setupKeyboard
{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.tapRecognizer.delegate = self;
    UIScrollView* target = self.target;
    [target addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.cancelsTouchesInView = NO;
    self.defaultContentInsets = target.contentInset;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc
{
    [self.target removeGestureRecognizer:self.tapRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    if (!self.isKeyboardVisible)
    {
        self.isKeyboardVisible = YES;
        [self handleKeyboardWithNotification:aNotification];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    if (self.isKeyboardVisible)
    {
        self.isKeyboardVisible = NO;
        [self handleKeyboardWithNotification:aNotification];
    }
}

- (UIView*)findViewThatIsFirstResponderInParent:(UIView*)parent
{
    if (parent.isFirstResponder)
    {
        return parent;
    }
    
    for (UIView *subView in parent.subviews)
    {
        UIView *firstResponder = [self findViewThatIsFirstResponderInParent:subView];
        if (firstResponder != nil)
        {
            return firstResponder;
        }
    }
    
    return nil;
}

- (void)handleKeyboardWithNotification:(NSNotification*)aNotification
{
    NSDictionary* info = aNotification.userInfo;
    __block CGFloat kbHeight = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    UIView* responder = [self findViewThatIsFirstResponderInParent:self.target];
    
    UIEdgeInsets contentInsets = [self _updatedInsetsWithKeyboardHeight:kbHeight];
    
    void (^animationBlock)(void) = ^{
        
        [self _dispatchBlockToMain:^{
            if (self.isEnabled)
            {
                UIScrollView* target = self.target;
                target.contentInset = contentInsets;
                target.scrollIndicatorInsets = contentInsets;
                CGFloat viewableHeight = target.bounds.size.height - target.contentInset.top - target.contentInset.bottom;
                if (responder && contentInsets.bottom > 0)
                {
                    CGFloat maxY = [self _bottomOffsetWithScrollView:target withResponderView:responder withVisibleArea:viewableHeight];//fabs((CGRectGetMaxY(responder.frame) - kbHeight));
                    CGPoint nextOffset = CGPointMake(0, maxY);
                    [target setContentOffset:nextOffset animated:YES];
                    
                }
            }
            if (self.animationBlock)
            {
                self.animationBlock(kbHeight);
            }
        }];
    };
    
    [UIView animateWithDuration:duration animations:animationBlock completion:^(__unused BOOL finished) {
        if (self.animationCompletion)
        {
            self.animationCompletion(self.isKeyboardVisible);
        }
    }];
}

- (CGFloat)_bottomOffsetWithScrollView:(UIScrollView*)scrollView withResponderView:(UIView*)view withVisibleArea:(CGFloat)viewAreaHeight
{
    CGSize contentSize = scrollView.contentSize;
    __block CGFloat offset = 0.0;
    
    CGRect subviewRect = [view convertRect:view.bounds toView:scrollView];
    
    __block CGFloat padding = 0.0;
    
    void(^centerViewInViewableArea)()  = ^ {
        // Attempt to center the subview in the visible space
        padding = (viewAreaHeight - subviewRect.size.height) / 2;
        
        // But if that means there will be less than kMinimumScrollOffsetPadding
        // pixels above the view, then substitute kMinimumScrollOffsetPadding
        if (padding < kMinimumScrollOffsetPadding ) {
            padding = kMinimumScrollOffsetPadding;
        }
        
        // Ideal offset places the subview rectangle origin "padding" points from the top of the scrollview.
        // If there is a top contentInset, also compensate for this so that subviewRect will not be placed under
        // things like navigation bars.
        offset = subviewRect.origin.y - padding - scrollView.contentInset.top;
    };
    
    // If possible, center the caret in the visible space. Otherwise, center the entire view in the visible space.
    if ([view conformsToProtocol:@protocol(UITextInput)]) {
        UIView <UITextInput> *textInput = (UIView <UITextInput>*)view;
        UITextPosition *caretPosition = [textInput selectedTextRange].start;
        if (caretPosition) {
            CGRect caretRect = [scrollView convertRect:[textInput caretRectForPosition:caretPosition] fromView:textInput];
            
            // Attempt to center the cursor in the visible space
            // pixels above the view, then substitute kMinimumScrollOffsetPadding
            padding = (viewAreaHeight - caretRect.size.height) / 2;
            
            // But if that means there will be less than kMinimumScrollOffsetPadding
            // pixels above the view, then substitute kMinimumScrollOffsetPadding
            if (padding < kMinimumScrollOffsetPadding ) {
                padding = kMinimumScrollOffsetPadding;
            }
            
            // Ideal offset places the subview rectangle origin "padding" points from the top of the scrollview.
            // If there is a top contentInset, also compensate for this so that subviewRect will not be placed under
            // things like navigation bars.
            offset = caretRect.origin.y - padding - scrollView.contentInset.top;
        } else {
            centerViewInViewableArea();
        }
    } else {
        centerViewInViewableArea();
    }
    
    // Constrain the new contentOffset so we can't scroll past the bottom. Note that we don't take the bottom
    // inset into account, as this is manipulated to make space for the keyboard.
    CGFloat maxOffset = contentSize.height - viewAreaHeight - scrollView.contentInset.top;
    if (offset > maxOffset) {
        offset = maxOffset;
    }
    
    // Constrain the new contentOffset so we can't scroll past the top, taking contentInsets into account
    if ( offset < -scrollView.contentInset.top ) {
        offset = -scrollView.contentInset.top;
    }
    
    return offset;

}


- (void)hideKeyboard
{
    [self.target endEditing:YES];
}

- (UIEdgeInsets)_updatedInsetsWithKeyboardHeight:(CGFloat)keyboardHeight
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (self.isKeyboardVisible)
    {
        UIScrollView* target = self.target;
        insets = UIEdgeInsetsMake(target.contentInset.top,
                                  0.0,
                                  target.contentInset.bottom + keyboardHeight,
                                  0.0);
    }
    else
    {
        insets = self.defaultContentInsets;
    }
    return insets;
}

#pragma mark - UIGesture delegate

- (BOOL)gestureRecognizer:(__unused UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    if ([touch.view isKindOfClass:[UIControl class]])
    {
        [self hideKeyboard];
        return NO;
    }
    return YES;
}

- (void)_dispatchBlockToMain:(void(^)(void))block
{
    if (block)
    {
        if ([NSThread isMainThread])
        {
            block();
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
        }
    }
}

@end
