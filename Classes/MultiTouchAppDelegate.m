//
//  WordGuessAppDelegate.m
//  WordGuess
//
//  Created by EBattal on 8/3/10.
//

#import "MultiTouchAppDelegate.h"

@implementation WordGuessAppDelegate

@synthesize view,window;

-(IBAction) buttonClicked:(UIButton*) sender {
}
-(void) doubleFingerSlideUp:(int) displacement {
	NSLog(@"Double Finger SLIDE UP, %d",displacement );
}

-(void) doubleFingerSlideDown:(int)displacement{
	NSLog(@"Double Finger SLIDE DOWN, %d",displacement);
}

-(void) doubleFingerSlideLeft:(int)displacement {
	NSLog(@"Double Finger Slide LEFT, %d",displacement);
}

-(void) doubleFingerSlideRight:(int)displacement {
	NSLog(@"Double Finger Slide RIGHT, %d",displacement);
}
-(void) doubleFingerSlideUpLeft:(int)displacementX:(int)displacementY {
	NSLog(@"Double Finger Slide UP-LEFT: %d,%d",displacementX,displacementY);
}
-(void) doubleFingerSlideDownLeft:(int)displacementX:(int)displacementY {
	NSLog(@"Double Finger Slide DOWN-LEFT: %d,%d",displacementX,displacementY);
}
-(void) doubleFingerSlideDownRight:(int)displacementX:(int)displacementY {
	NSLog(@"Double Finger Slide DOWN-RIGHT : %d,%d",displacementX,displacementY);
}
-(void) doubleFingerSlideUpRight:(int)displacementX:(int)displacementY {
	NSLog(@"Double Finger Slide UP-RIGHT: %d,%d",displacementX,displacementY);
}


-(void) threeFingerSlideUp:(int) displacement {
	NSLog(@"three Finger SLIDE UP, %d",displacement );
}

-(void) threeFingerSlideDown:(int)displacement{
	NSLog(@"three Finger SLIDE DOWN, %d",displacement);
}

-(void) threeFingerSlideLeft:(int)displacement {
	NSLog(@"three Finger Slide LEFT, %d",displacement);
}

-(void) threeFingerSlideRight:(int)displacement {
	NSLog(@"three Finger Slide RIGHT, %d",displacement);
}
-(void) threeFingerSlideUpLeft:(int)displacementX:(int)displacementY {
	NSLog(@"three Finger Slide UP-LEFT: %d,%d",displacementX,displacementY);
}
-(void) threeFingerSlideDownLeft:(int)displacementX:(int)displacementY {
	NSLog(@"three Finger Slide DOWN-LEFT: %d,%d",displacementX,displacementY);
}
-(void) threeFingerSlideDownRight:(int)displacementX:(int)displacementY {
	NSLog(@"three Finger Slide DOWN-RIGHT : %d,%d",displacementX,displacementY);
}
-(void) threeFingerSlideUpRight:(int)displacementX:(int)displacementY {
	NSLog(@"three Finger Slide UP-RIGHT: %d,%d",displacementX,displacementY);
}



-(void) doRotation :(int) rotation {
	NSLog(@"Rotation: %d degrees",rotation);
	
	/* test code for rotation
	 
	 
	 CGFloat currentAngle = angleBetweenLinesInRadians([first previousLocationInView:self.view], [second previousLocationInView:self.view], [first locationInView:self.view], [second locationInView:self.view]);
	 
	 label.transform = CGAffineTransformRotate(label.transform, currentAngle);
	 
	 */
}
- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
	[window addSubview:view];
	[view setDelegate:self];
    [window makeKeyAndVisible];
	
}
- (void)dealloc {
    [view release];
    [super dealloc];
}


@end
