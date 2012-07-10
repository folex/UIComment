//
//  ViewController.h
//  tryingNiceRectangles
//
//  Created by Alexey on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ResizableRectangle, UIComment;
@protocol UICommentDelegate;

@interface ViewController : UIViewController <UICommentDelegate>
@property UILongPressGestureRecognizer *longPressureRecognizer;
@property ResizableRectangle *rect;
@property UIComment *comment;
@end
