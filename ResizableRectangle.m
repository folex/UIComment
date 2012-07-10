//
//  resizableRectangle.m
//  tryingNiceRectangles
//
//  Created by Alexey on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResizableRectangle.h"
#import "UIComment.h"
#import <QuartzCore/QuartzCore.h>

@implementation ResizableRectangle
@synthesize triangleHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque: NO];
        [self setAlpha: 0.5];
        [self setBackgroundColor: [UIColor clearColor]];
        [[self layer] setCornerRadius: 5.0];
        [[self layer] setMasksToBounds: YES];
        [self setTriangleHeight: 15];
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef cx = UIGraphicsGetCurrentContext();
    CGSize mainRectSize = {[self frame].size.width - [self triangleHeight], [self frame].size.height};
    CGRect mainRect = {{0,0}, mainRectSize};
    UIBezierPath* aPath = [UIBezierPath bezierPathWithRoundedRect:mainRect cornerRadius:5];
    CGPoint middleVertex = {CGRectGetMaxX(mainRect) + [self triangleHeight], CGRectGetMidY(mainRect)};
    CGPoint upperVertex = {middleVertex.x - [self triangleHeight], middleVertex.y - [self triangleHeight]*2/3};
    CGPoint bottomVertex = {middleVertex.x - [self triangleHeight], middleVertex.y + [self triangleHeight]*2/3};
    [aPath moveToPoint: upperVertex];
    [aPath addLineToPoint: middleVertex];
    [aPath addLineToPoint: bottomVertex];
    [[UIColor clearColor] setStroke];
    [[UIColor redColor] setFill];        
    aPath.lineWidth = 0; //5 better.
    [aPath fill];
    [aPath stroke];
    CGContextSaveGState(cx);
//    CGContextClip(cx);
    CGContextRestoreGState(cx);
}

- (void) switchToNextComment: (UIComment*) currentComment
{
    
}

- (void) commentPositionChangedFrom: (CGPoint) old To: (CGPoint) new
{
    
}

@end