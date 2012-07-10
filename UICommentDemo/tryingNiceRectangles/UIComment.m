//
//  UIComment.m
//  tryingImplementCommentNotes
//
//  Created by Alexey on 02.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIComment.h"
#import "ResizableRectangle.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIComment
@synthesize editView, fixedView;
@synthesize longPressRecognizer, panRecognizer;
@synthesize isEdit;
@synthesize firstTouchOrigin;
@synthesize delegate;
@synthesize originalOrigin;
@synthesize commentNumber;
@synthesize selectionRectangle = _selectionRectangle;
@synthesize isDeleted;

- (id) initWithFrame:(CGRect)frame delegate:(id<UICommentDelegate>)deleg 
       CommentNumber:(NSNumber *)number AndSelectionRectangle:(ResizableRectangle *)selectionRectangle
{
    self = [super init];
    [self setSelectionRectangle: selectionRectangle];
    self = [self initWithFrame: frame delegate:deleg AndCommentNumber: number];
    return self;
}

- (id) initWithFrame:(CGRect)frame delegate:(id<UICommentDelegate>)deleg AndCommentNumber: (NSNumber*) number
{
    self = [self initWithFrame:frame delegate:deleg];
    if (number != nil) {
        [self setCommentNumber: number];
    } else {
        [self setCommentNumber: [NSNumber numberWithDouble: [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)passedFrame delegate: (id<UICommentDelegate>)deleg
{
    self = [super initWithFrame: passedFrame];
    if (self) {
        [self setIsDeleted: NO];
        [self setDelegate: deleg];
        [[self layer] setCornerRadius: 5.0];
        [[self layer] setOpacity: 0.75];
        [self setEditView: [[UITextView alloc] initWithFrame: CGRectMake(0, 0, 
                                                                         passedFrame.size.width, 
                                                                         passedFrame.size.height)]];
        [[[self editView] layer] setBorderWidth: 3.0];
        [[[self editView] layer] setCornerRadius: 5.0];
        [[[self editView] layer] setMasksToBounds: YES];
        [[self editView] setHidden: NO];
        [[self editView] setBackgroundColor: [UIColor yellowColor]];
        [[self editView] setDelegate: self];
        UIToolbar *editViewToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 
                                                                                  [[self editView] frame].size.height - 25, 
                                                                                  [[self editView] frame].size.width, 
                                                                                  25)];
        UIBarButtonItem *editDoneButton = [[UIBarButtonItem alloc] 
                                       initWithBarButtonSystemItem: UIBarButtonSystemItemDone 
                                       target: self
                                       action: @selector(toFixed)];
        [editDoneButton setStyle: UIBarButtonItemStyleDone];
//        UIBarButtonItem *editShotButton = [[UIBarButtonItem alloc] 
//                                           initWithBarButtonSystemItem: UIBarButtonSystemItemSave 
//                                           target: self 
//                                           action: @selector(shotSuperView)];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle: @"Delete" 
                                                                         style: UIBarButtonSystemItemCancel 
                                                                        target: self action: @selector(removeCommentAndSelectionRectFromSuperview)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [editViewToolBar setAlpha: 0.75];
        [editViewToolBar setBarStyle: UIBarStyleBlackTranslucent];
        if ([[self delegate] respondsToSelector: @selector(switchToNextComment:)]) {
            UIBarButtonItem *nextCommentButton = [[UIBarButtonItem alloc] 
                                                  initWithBarButtonSystemItem: UIBarButtonSystemItemAction
                                                  target: self
                                                  action: @selector(switchToNextComment)];
            [editViewToolBar setItems: [NSArray arrayWithObjects: 
                                        flexibleSpace, editDoneButton, 
//                                        flexibleSpace, editShotButton,
                                        flexibleSpace, deleteButton,
                                        flexibleSpace, nextCommentButton, 
                                        flexibleSpace, nil]];
        } else {
            [editViewToolBar setItems: [NSArray arrayWithObjects: 
                                        flexibleSpace, editDoneButton, 
//                                        flexibleSpace, editShotButton,
                                        flexibleSpace, deleteButton,
                                        flexibleSpace, nil]];
        }
        [[self editView] addSubview: editViewToolBar];
        [self setFixedView:[[UIButton alloc] init]];
        [[self fixedView] setFrame: CGRectMake(0, 0, 40, 20)];
        UIImage *comment = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"comment" ofType: @"png"]];
        [[self fixedView] setBackgroundImage:comment forState:UIControlStateNormal];
        [[self fixedView] setBackgroundImage:comment forState:UIControlStateHighlighted];
        [[self fixedView] setHidden: YES];
        [[self fixedView] addTarget: self action: @selector(toEdit) forControlEvents: UIControlEventTouchDown];
        [self addSubview: [self editView]];
        [self addSubview: [self fixedView]];
        [self setLongPressRecognizer: [[UILongPressGestureRecognizer alloc] 
                                       initWithTarget: self 
                                       action: @selector(handleLongPress:)]];
        if ([self selectionRectangle] == nil)
        {
            [self setPanRecognizer: [[UIPanGestureRecognizer alloc] initWithTarget: self action:@selector(handlePan:)]];
            [self addGestureRecognizer: [self panRecognizer]];
        }
        [[self editView] addGestureRecognizer: [self longPressRecognizer]];
        [[self fixedView] addGestureRecognizer: [self longPressRecognizer]];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
                                       initWithBarButtonSystemItem: UIBarButtonSystemItemDone 
                                       target: [self editView] 
                                       action: @selector(resignFirstResponder)];
//        [doneButton setStyle: UIBarButtonItemStyleDone];
        UIBarButtonItem *toolBarDeleteButton = [[UIBarButtonItem alloc] initWithTitle: @"Delete" 
                                                                                style: UIBarButtonSystemItemCancel 
                                                                               target: self action: @selector(removeCommentAndSelectionRectFromSuperview)];
//        UIBarButtonItem *shotButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action: @selector(takeWebViewShot)];
        UIToolbar *keyBoardToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 10, 320, 23)];
        [keyBoardToolBar setAlpha: 0.75];
        [keyBoardToolBar setBarStyle: UIBarStyleBlackTranslucent];
        if ([[self delegate] respondsToSelector: @selector(switchToNextComment:)]) {
            UIBarButtonItem *nextCommentButton = [[UIBarButtonItem alloc] 
                                                  initWithBarButtonSystemItem: UIBarButtonSystemItemAction 
                                                  target:self 
                                                  action: @selector(switchToNextComment)];
            [keyBoardToolBar setItems: [NSArray arrayWithObjects: 
                                        doneButton, 
//                                        shotButton, 
                                        toolBarDeleteButton,
                                        nextCommentButton,  
                                        nil]];
        } else {
            [keyBoardToolBar setItems: [NSArray arrayWithObjects: 
                                        doneButton, 
//                                        shotButton,
                                        toolBarDeleteButton,
                                        nil]];
        }
        [[self editView] setInputAccessoryView: keyBoardToolBar];
        [self setIsEdit: YES];
    }
    return self;
}


/*
 Only override drawRect: if you perform custom drawing.
 An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void) toFixed
{
    CGRect tmp = [[self editView] frame];
    [UIView animateWithDuration: 0.5 animations:^{
        [[self editView] setFrame: CGRectMake([[self editView] frame].origin.x, [[self editView] frame].origin.y, 0, 0)];
        [self setFrame: CGRectMake([self frame].origin.x, [self frame].origin.y, [[self fixedView] frame].size.width, [[self fixedView] frame].size.height)];
        [[self editView] setAlpha: 0.0];
    } completion:^(BOOL finished) {
        [[self fixedView] setHidden: NO];
        [[self fixedView] setAlpha: 1.0];
        [[self editView] setHidden: YES];
        [[self editView] setFrame: tmp];
        [self setIsEdit: NO];
        [self setNeedsDisplay];
//        [[self fixedView] setNeedsDisplay];
    }];
}

- (void) toEdit
{
    CGRect tmp = [[self editView] frame];
    [[self editView] setFrame: CGRectMake([[self editView] frame].origin.x, [[self editView] frame].origin.y, 0, 0)];
    [UIView animateWithDuration: 0.5 animations:^{
        [[self fixedView] setAlpha: 0.0];
        [[self fixedView] setHidden: YES];
        [[self editView] setAlpha: 1.0];
        [[self editView] setHidden: NO];
        [[self editView] setFrame: CGRectMake([[self editView] frame].origin.x, [[self editView] frame].origin.y, tmp.size.width, tmp.size.height)];
        [self setFrame: CGRectMake([self frame].origin.x, [self frame].origin.y, tmp.size.width, tmp.size.height)];
        [[[[self editView] subviews] objectAtIndex: 1] setHidden: NO];
    } completion:^(BOOL finished) {
        [self setIsEdit: YES];
        [self setNeedsDisplay];
    }];
}

- (void) removeCommentAndSelectionRectFromSuperview
{
    if ([self selectionRectangle] != nil) {
        [[self selectionRectangle] removeFromSuperview];
    }
    [self removeFromSuperview];
    [self setIsDeleted: YES];
}

- (void) handleLongPress: (UILongPressGestureRecognizer*) recognizer
{
    UIView *menuView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 120, 200)];
    [menuView setCenter: [[[recognizer view] window] center]];
    UIButton *toggleButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [toggleButton setCenter: [menuView center]];
    [toggleButton setFrame: CGRectMake([toggleButton frame].origin.x, 
                                       40, 
                                       100, 40)];
    [toggleButton addTarget: self 
                     action: [self isEdit] ? @selector(toFixed) : @selector(toEdit)
           forControlEvents: UIControlEventTouchUpInside];
    [menuView addSubview: toggleButton];
}

- (void) handlePan:(UIPanGestureRecognizer *)recognizer

{
	CGPoint translatedPoint = [recognizer translationInView:[self superview]];
    if ([recognizer state] != UIGestureRecognizerStateEnded && [recognizer state] != UIGestureRecognizerStateFailed){ 
        
    }
    if([recognizer state] == UIGestureRecognizerStateBegan)
    {
        [self setFirstTouchOrigin: CGPointMake([[recognizer view] center].x, [[recognizer view] center].y)];
        [self setOriginalOrigin: [self center]];
    }
    translatedPoint = CGPointMake([self firstTouchOrigin].x + translatedPoint.x, [self firstTouchOrigin].y + translatedPoint.y);
    [[recognizer view] setCenter:translatedPoint];
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        [[self delegate] commentPositionChangedFrom: [self originalOrigin]
                                                 To: [self center]];
    }
}


- (void) fadeView: (UIView*) view toAlpha: (CGFloat) alpha in: (CGFloat) seconds
{
[UIView beginAnimations:nil context:NULL];
[UIView setAnimationDuration:seconds];
[view setAlpha: alpha];
[UIView commitAnimations];
}

- (void)takeShotOfView: (UIView*) passedView
{
    NSLog(@"passedView is: %@", passedView);
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [passedView bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    [[passedView layer] renderInContext: UIGraphicsGetCurrentContext()];
    for (UIView *view in [passedView subviews]) {
        NSLog(@"View is: %@", view);
        // -renderInContext: renders in the coordinate space of the layer,
        // so we must first apply the layer's geometry to the graphics context
        CGContextSaveGState(context);
        // Center the context around the view's anchor point
        CGContextTranslateCTM(context, [view center].x, [view center].y);
        // Apply the view's transform about the anchor point
        CGContextConcatCTM(context, [view transform]);
        // Offset by the portion of the bounds left of and above the anchor point
        CGContextTranslateCTM(context,
                              -[view bounds].size.width * [[view layer] anchorPoint].x,
                              -[view bounds].size.height * [[view layer] anchorPoint].y);
        
        // Render the layer hierarchy to the current context
        [[view layer] renderInContext:context];
        
        // Restore the context
        CGContextRestoreGState(context);
        
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);  
}

- (void) shotSuperView
{
    [self takeShotOfView: [self superview]];
}
- (void) switchToNextComment
{
    [[self delegate] switchToNextComment: self];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    ![self isEdit] ? NSLog(@"toEdit") : NSLog(@"toFixed");
    ![self isEdit] ? [self toEdit] : [self toFixed];
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (![self isEdit]) {
        [self toEdit];
    }
    [UIView beginAnimations:nil context:nil];
    [[[textView subviews] objectAtIndex: 1] setHidden: YES];
    [UIView commitAnimations];
    return YES;
}
@end
