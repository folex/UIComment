//
//  UIComment.h
//  tryingImplementCommentNotes
//
//  Created by Alexey on 02.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIComment, ResizableRectangle;
@protocol UICommentDelegate
@optional
- (void) switchToNextComment: (UIComment*) currentComment;
- (void) commentPositionChangedFrom: (CGPoint) old To: (CGPoint) new;
@end

@interface UIComment : UIView <UITextViewDelegate>
//That's how comment will look like when editing
@property UITextView *editView;
//That's how comment will look like when finished(after) editing
@property UIButton *fixedView;

@property UILongPressGestureRecognizer *longPressRecognizer;
@property UIPanGestureRecognizer *panRecognizer;
@property CGPoint firstTouchOrigin;
@property CGPoint originalOrigin;
@property id delegate;
@property BOOL isEdit;
@property NSNumber *commentNumber;
@property ResizableRectangle *selectionRectangle;
@property BOOL isDeleted;
- (void) toEdit;
- (void) toFixed;
- (id) initWithFrame:(CGRect) frame delegate:(id<UICommentDelegate>)deleg;
- (id) initWithFrame:(CGRect)frame delegate:(id<UICommentDelegate>)deleg AndCommentNumber: (NSNumber*) number;
- (id) initWithFrame:(CGRect)frame delegate:(id<UICommentDelegate>)deleg CommentNumber: (NSNumber*) number AndSelectionRectangle: (ResizableRectangle*) selectionRectangle;
- (void) removeCommentAndSelectionRectFromSuperview;
@end


