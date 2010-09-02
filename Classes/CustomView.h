//
//  CustomView.h
//  WordGuess
//
//  Created by EBattal on 8/3/10.
//

#import <UIKit/UIKit.h>

@protocol TouchGestures

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

@interface CustomView : UIView {
	UILabel *label0;
	UILabel *label1;
	UILabel *label2;
	UILabel *label3;
	UILabel *label4;
	UILabel *label5;
	NSMutableArray *positions;
	NSMutableArray *instantPositions;
	NSNumber *state;
	NSNumber *touchCount;
	NSNumber *maxTouchCount;
	id<TouchGestures> delegate;
	
	BOOL		isInstantDetection;
	BOOL		isRotationDetection;
	BOOL		isVerticalDetection;
	BOOL		isHorizontalDetection;
	BOOL		isUseMinDisplacement;
	BOOL		isMultiDimensionDetection;

	CGFloat		rotationThreshold;
	int			slideThreshold;
	int			distortionInMovDirection;
@private
	int			presentSlideDistances;
}

@property (nonatomic, assign) id<TouchGestures> delegate;
@property (nonatomic, retain) IBOutlet UILabel *label0;
@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;
@property (nonatomic, retain) IBOutlet UILabel *label3;
@property (nonatomic, retain) IBOutlet UILabel *label4;
@property (nonatomic, retain) IBOutlet UILabel *label5;
@property (nonatomic, retain) NSMutableArray *instantPositions;
@property (nonatomic, retain) NSMutableArray *positions;
@property (nonatomic, retain) NSNumber *state;
@property (nonatomic, retain) NSNumber *touchCount;
@property (nonatomic, retain) NSNumber *maxTouchCount;
@property BOOL		isInstantDetection;
@property BOOL		isRotationDetection;
@property BOOL		isVerticalDetection;
@property BOOL		isHorizontalDetection;
@property BOOL		isUseMinDisplacement;
@property BOOL		isMultiDimensionDetection;
@property CGFloat	rotationThreshold;
@property int		slideThreshold;
@property int		distortionInMovDirection;

-(BOOL) containsInteger:(NSMutableArray *) array:(int) integer;
-(int) detectFinalOffset:(NSMutableArray *) array;
-(int) detectInitialOffset:(NSMutableArray *) array;
-(int) getPosition:(NSMutableArray *) array:(int) touch:(int) sequence:(int) xory;
-(int) isRotation:(NSMutableArray *) finger1:(NSMutableArray *) finger2;
-(CGFloat) isRotationInstant:(NSMutableArray *) finger1:(NSMutableArray *) finger2;

-(int) isLinearMovementInstant:(NSMutableArray *) array:(int) axis;
-(int) isLinearMovement:(NSMutableArray *) array:(int) direction;

-(void) analyseGestureInstantly;
-(void) analyseGestureAfter;
@end
