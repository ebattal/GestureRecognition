//
//  WordGuessAppDelegate.h
//  WordGuess
//
//  Created by EBattal on 8/3/10.
//

#import <UIKit/UIKit.h>
#import "CustomView.h"
@interface WordGuessAppDelegate : NSObject <UIApplicationDelegate,TouchGestures> {
	UIWindow *window;
	CustomView *view;

}

@property (nonatomic, retain) IBOutlet CustomView *view;
@property (nonatomic, retain) IBOutlet UIWindow *window;


-(void) doubleFingerSlideUp:(int)displacement;
-(void) doubleFingerSlideDown:(int)displacement;
-(void) doubleFingerSlideLeft:(int)displacement;
-(void) doubleFingerSlideRight:(int)displacement;
-(void) doubleFingerSlideUpLeft:(int)displacementX:(int)displacementY;
-(void) doubleFingerSlideDownLeft:(int)displacementX:(int)displacementY;
-(void) doubleFingerSlideDownRight:(int)displacementX:(int)displacementY;
-(void) doubleFingerSlideUpRight:(int)displacementX:(int)displacementY;

-(void) threeFingerSlideUp:(int)displacement;
-(void) threeFingerSlideDown:(int)displacement;
-(void) threeFingerSlideLeft:(int)displacement;
-(void) threeFingerSlideRight:(int)displacement;
-(void) threeFingerSlideUpLeft:(int)displacementX:(int)displacementY;
-(void) threeFingerSlideDownLeft:(int)displacementX:(int)displacementY;
-(void) threeFingerSlideDownRight:(int)displacementX:(int)displacementY;
-(void) threeFingerSlideUpRight:(int)displacementX:(int)displacementY;
-(void) doRotation :(int) rotation;
@end

