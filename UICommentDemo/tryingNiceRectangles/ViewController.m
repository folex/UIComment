#import "ViewController.h"
#import "ResizableRectangle.h"
#import "UIComment.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize longPressureRecognizer;
@synthesize rect;
@synthesize comment;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLongPressureRecognizer: [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(handleLongPress:)]];
    [[self view] addGestureRecognizer: [self longPressureRecognizer]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) handleLongPress: (UILongPressGestureRecognizer *) recongizer
{
    CGRect rectFrame = {[recongizer locationInView: [recongizer view]], {0, 0}};
    switch ([recongizer state]) {
        case UIGestureRecognizerStateBegan:
        {
            [self setRect: [[ResizableRectangle alloc] initWithFrame: rectFrame]];
            [[self view] addSubview: [self rect]];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGRect newRect = {[[self rect] frame].origin, 
                {rectFrame.origin.x - [[self rect] frame].origin.x, 
                 rectFrame.origin.y - [[self rect] frame].origin.y}};
            [[self rect] setFrame: newRect];
            [[self rect] setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"State ended");
            CGRect winBounds = [[self view] bounds];
            CGRect commentRect = {
                {[[self rect] frame].origin.x + [[self rect] frame].size.width,
                    [[self rect] frame].origin.y + [[self rect] frame].size.height/2},
                {120,120}};
            int commentRightBound = [[self rect] frame].origin.x + [[self rect] frame].size.width + commentRect.size.width;
            int commentBottomBound = [[self rect] frame].origin.y + [[self rect] frame].size.height/2 + commentRect.size.width;
            if (commentRightBound > winBounds.size.width) {
                commentRect.origin.x -= commentRightBound - winBounds.size.width;
            }
            if (commentBottomBound > winBounds.size.height) {
                commentRect.origin.y -= commentBottomBound - winBounds.size.height;
            }
            
            [self setComment: [[UIComment alloc] initWithFrame: commentRect 
                                                      delegate: self 
                                                 CommentNumber:[NSNumber numberWithInt: 1] 
                                         AndSelectionRectangle: [self rect]]];
            
            [[self view] addSubview: [self comment]];
            break;
        }
        case UIGestureRecognizerStateFailed:
        {
            NSLog(@"State failed");
            break;
        }
        case UIGestureRecognizerStatePossible:
        {
            NSLog(@"State possible");
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"State cancelled");
            break;
        }            
        default:
        {
            break;
        }
    }
}

- (void) switchToNextComment: (UIComment*) currentComment
{
    
}

- (void) commentPositionChangedFrom:(CGPoint)old To:(CGPoint)new
{
    
}
@end