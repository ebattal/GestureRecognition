//
//  CustomView.m
//  WordGuess
//
//  Created by EBattal on 8/3/10.
//

#import "CustomView.h"
#import "math.h"

@implementation CustomView
@synthesize delegate,label0,label1,label2,label3,label4,label5,state;
@synthesize positions,instantPositions;
@synthesize touchCount,maxTouchCount;
@synthesize isInstantDetection, isRotationDetection, isVerticalDetection, isHorizontalDetection, isUseMinDisplacement,isMultiDimensionDetection;
@synthesize rotationThreshold, slideThreshold;
@synthesize	distortionInMovDirection;

-(id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
        // Initialization code
    }
	
	self.touchCount = [NSNumber numberWithInt:0];
	self.maxTouchCount = [NSNumber numberWithInt:0];
	self.state = [NSNumber numberWithInt:0];
	
	self.isHorizontalDetection = YES;
	self.isVerticalDetection = YES;
	self.isRotationDetection = NO;
	self.isInstantDetection = NO;
	self.isUseMinDisplacement = NO;			//Use minimium displacement or maximum displacement as a parameter to functions
	self.isMultiDimensionDetection = YES;
	self.slideThreshold = 35;
	self.distortionInMovDirection = 4;		//Distortion that is acceptable in the movement direction -- Above 5 may cause frequent miscalculations
	self.rotationThreshold = 20.0;
    return self;
	
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	label0.text = @"touchesBegan";
	NSLog(@"touchBegan");
	
	NSArray *touchesarray = [touches allObjects];
	
	NSMutableArray *target;
	if(self.isInstantDetection) {
		target = self.instantPositions;
	} else {
		target = self.positions;
	}
	
	//if there has been no previous touches
	if([self.state intValue] ==0) {
		target = [NSMutableArray array];
		
		for(int i=0; i<[touchesarray count];i++) {
			
			NSNumber *x = [NSNumber numberWithFloat: [[touchesarray objectAtIndex:i] locationInView:self].x]; 
			NSNumber *y = [NSNumber numberWithFloat: [[touchesarray objectAtIndex:i] locationInView:self].y]; 
			
			[target addObject:[NSMutableArray array]];
			[[target objectAtIndex:i] addObject:[NSMutableArray array]];				
			[[[target objectAtIndex:i] lastObject] addObject: x];
			[[[target objectAtIndex:i] lastObject] addObject: y];
			
			//		NSLog(@"Initially Touched: %@,%@",x,y);
			
			//increment touch counter
			self.touchCount=[NSNumber numberWithInt:[self.touchCount intValue]+1];
			self.maxTouchCount=[NSNumber numberWithInt:[self.maxTouchCount intValue]+1];
			
		}
		
		if(self.isInstantDetection) {
			self.instantPositions = target;
		} else {
			self.positions = target;
		}
		
		//Set the state to "new touches will be appended" 
		self.state = [NSNumber numberWithInt:1];
		
	} else { //if the screen already touched
		
		//Add  touched points with previous fingers to array 
		for(int j=0; j<[target count]; j++) {
			
			NSNumber *lastX = [[[target objectAtIndex:j] lastObject] objectAtIndex:0];
			NSNumber *lastY = [[[target objectAtIndex:j] lastObject] objectAtIndex:1];
			
			[[target objectAtIndex:j] addObject:[NSMutableArray array]];
			
			[[[target objectAtIndex:j] lastObject] addObject: lastX];
			[[[target objectAtIndex:j] lastObject] addObject: lastY];
		}
		
		//Add touch points with new fingers to array
		for(int i=0; i<[touchesarray count]; i++) {
			
			//add point array for new touchs with previous values as -1
			[target addObject:[NSMutableArray array]];
			for(int j=0;j<[[target objectAtIndex:0] count]-1;j++) {
				[[target lastObject] addObject:[NSMutableArray array]];
				
				[[[target lastObject] lastObject] addObject: [NSNumber numberWithInt:-1]];
				[[[target lastObject] lastObject] addObject: [NSNumber numberWithInt:-1]];
			}
			
			//Create an array for new touch dimensions
			[[target lastObject] addObject:[NSMutableArray array]];
			
			//add present x y points to the end of the latest added touch arrays
			NSNumber *x = [NSNumber numberWithFloat: [[touchesarray objectAtIndex:i] locationInView:self].x]; 
			NSNumber *y = [NSNumber numberWithFloat: [[touchesarray objectAtIndex:i] locationInView:self].y]; 
			
			[[[target lastObject] lastObject] addObject: x];
			[[[target lastObject] lastObject] addObject: y];
			
			//		NSLog(@"Late Touched: %@,%@",x,y);
			
			//incremenet touch counter
			if([self.touchCount intValue]==[self.maxTouchCount intValue]) {
				self.maxTouchCount=[NSNumber numberWithInt:[self.maxTouchCount intValue]+1];
			}
			self.touchCount=[NSNumber numberWithInt:[self.touchCount intValue]+1];
		}
		if(self.isInstantDetection & [[self.instantPositions objectAtIndex:0] count] >2) {
			for(int i = 0; i<[self.instantPositions count]; i++) {
				[[self.instantPositions objectAtIndex:i] removeObjectAtIndex:0];
			}
		}
	}
	if(self.isInstantDetection) {
		NSLog(@"Instant Points Array : %@",self.instantPositions);
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	label0.text = @"touchesMoved";
	NSLog(@"touchMoved");
	
	NSMutableArray *touchesArray = [NSMutableArray arrayWithArray:[touches allObjects]];
	
	NSMutableArray *target;
	if(self.isInstantDetection) {
		target = self.instantPositions;
	} else {
		target = self.positions;
	}
	
	//int finalIndex=[[self.positions objectAtIndex:0] count]-1;
	
	/* test for containsInteger
	 
	 [locatedPlaces addObject:[NSNumber numberWithInt:13]];
	 [locatedPlaces addObject:[NSNumber numberWithInt:12]];
	 [locatedPlaces addObject:[NSNumber numberWithInt:11]];
	 [locatedPlaces removeObjectAtIndex:1];
	 NSLog(@"content:%@,%@",locatedPlaces,[locatedPlaces objectAtIndex:1]);
	 NSLog(@"content count: %d",[touchesarray count]);
	 
	 //NSLog(@"contains: %d, not contains: %d",[self containsInteger:locatedPlaces:13],[self containsInteger:locatedPlaces:10]);
	 for(int i=0;i<[touchesarray count];i++) {
	 NSLog(@"prevLoc%d: %d",i, [[NSNumber numberWithFloat: [[touchesarray objectAtIndex:i] previousLocationInView:self].x] intValue]);
	 NSLog(@"prevLoc%d: %d",i, [[NSNumber numberWithFloat: [[touchesarray objectAtIndex:i] previousLocationInView:self].y] intValue]);
	 }
	 */
	
	
	/******************  TOUCH POINT TRACER BEGIN ******************/
	
	//Use this length value to add points of non-moving fingers.
	int arrayLength=0;
	
	NSMutableArray *locatedPlaces = [NSMutableArray array];
	
	int infinitePreventor=0;
	while([touchesArray count]!=0) {
		NSNumber *x = [NSNumber numberWithFloat: [[touchesArray lastObject] locationInView:self].x]; 
		NSNumber *y = [NSNumber numberWithFloat:[[touchesArray lastObject] locationInView:self].y];
		int prevX = [[NSNumber numberWithFloat:[[touchesArray lastObject] previousLocationInView:self].x] intValue];
		int prevY = [[NSNumber numberWithFloat:[[touchesArray lastObject] previousLocationInView:self].y] intValue];
		
		//		NSLog(@"Present: %@,%@. Past: %d,%d",x,y,prevX,prevY);
		
		//find whether the targetIndex is already used
		int targetIndex=0;
		while ([self containsInteger:locatedPlaces:targetIndex]) {
			targetIndex++;
		}
		
		for(int j = targetIndex; j < [target count]; j++) {
			if(![self containsInteger:locatedPlaces:j]) {
				int targetPrevX = [[[[target objectAtIndex:j] lastObject] objectAtIndex:0] intValue];
				int targetPrevY = [[[[target objectAtIndex:j] lastObject] objectAtIndex:1] intValue];
				if(prevX == targetPrevX & prevY  == targetPrevY ) {
					[[target objectAtIndex:j] addObject: [NSMutableArray array]];
					[[[target objectAtIndex:j] lastObject] addObject:x];
					[[[target objectAtIndex:j] lastObject] addObject:y];
					
					[locatedPlaces addObject:[NSNumber numberWithInt:j]];
					
					[touchesArray removeLastObject];
					
					if([touchesArray count]==0) {
						arrayLength = [[target objectAtIndex:j] count];
					}
					break;
				}
			}
		}
		
		infinitePreventor++;
		if(infinitePreventor>50) {
			NSLog(@"!!!!Infinite Loop Detected!!!!");
			break;
		}
	}
	
	//add same values with the previous values for non-moving fingers
	for (int i = 0; i < [target count]; i++) {
		if([[target objectAtIndex:i] count] != arrayLength) {
			NSNumber *lastX = [[[target objectAtIndex:i] lastObject] objectAtIndex:0];
			NSNumber *lastY = [[[target objectAtIndex:i] lastObject] objectAtIndex:1];
			[[target objectAtIndex:i] addObject:[NSMutableArray array]];
			[[[target objectAtIndex:i] lastObject] addObject: lastX];
			[[[target objectAtIndex:i] lastObject] addObject: lastY];
		}
	}
	
	if(self.isInstantDetection & [[self.instantPositions objectAtIndex:0] count] >2) {
		for(int i = 0; i<[self.instantPositions count]; i++) {
			[[self.instantPositions objectAtIndex:i] removeObjectAtIndex:0];
		}
	}		
	
	/*if(self.isInstantDetection) {
	 NSLog(@"Instant Points Array : %@",self.instantPositions);
	 }
	 
	 /*************************************************************/
	
		
	//Do analysis with 2 points
	[self analyseGestureInstantly];
}



- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	label0.text = @"touchesEnded";
	NSLog(@"touchEnded");
	
	/*** temporary code ***/
	self.touchCount=[NSNumber numberWithInt:[self.touchCount intValue]-[touches count]];
	
	NSMutableArray *touchesArray = [NSMutableArray arrayWithArray:[touches allObjects]];
	NSMutableArray *target;
	if(self.isInstantDetection) {
		target = self.instantPositions;
	} else {
		target = self.positions;
	}
	
	//Print Obtained Touch Count
	//	NSLog(@"Obtained Touch Count: %d",[touchesArray count]);
	
	
	/******************  TOUCH POINT TRACER BEGIN ******************/
	
	int arrayLength=0;
	NSMutableArray *locatedPlaces = [NSMutableArray array];
	
	int infinitePreventor=0;
	while([touchesArray count]!=0) {
		int x = [[NSNumber numberWithFloat: [[touchesArray lastObject] locationInView:self].x] intValue]; 
		int y = [[NSNumber numberWithFloat: [[touchesArray lastObject] locationInView:self].y] intValue];
		int prevX = [[NSNumber numberWithFloat: [[touchesArray lastObject] previousLocationInView:self].x] intValue]; 
		int prevY = [[NSNumber numberWithFloat: [[touchesArray lastObject] previousLocationInView:self].y] intValue];
		
		NSLog(@"Ended Touches: %d,%d",x,y);
		if(self.isInstantDetection) 
		{
			for(int j=0;j<[target count]; j++) {
				int targetPrevX = [[[[target objectAtIndex:j] lastObject] objectAtIndex:0] intValue];
				int targetPrevY = [[[[target objectAtIndex:j] lastObject] objectAtIndex:1] intValue];
				
				if((x == targetPrevX && y  == targetPrevY ) || (prevX == targetPrevX && prevY  == targetPrevY )) {
					[target removeObjectAtIndex:j];
					[touchesArray removeLastObject];
					if([touchesArray count]==0) {
						if([target count]>0) {
							arrayLength = [[target objectAtIndex:0] count];
						}else {
							arrayLength = 0;
						}
						break;
					}
				}
			}
		} else {
			//find whether the targetIndex is already used
			int targetIndex=0;
			while ([self containsInteger:locatedPlaces:targetIndex]) {
				targetIndex++;
			}
			
			for(int j=targetIndex; j<[target count]; j++) {
				if(![self containsInteger:locatedPlaces:j]) {
					int targetPrevX = [[[[target objectAtIndex:j] lastObject] objectAtIndex:0] intValue];
					int targetPrevY = [[[[target objectAtIndex:j] lastObject] objectAtIndex:1] intValue];
					if((x == targetPrevX && y  == targetPrevY )|| (prevX == targetPrevX && prevY  == targetPrevY )) {
						
						[[target objectAtIndex:j] addObject: [NSMutableArray array]];
						[[[target objectAtIndex:j] lastObject] addObject:[NSNumber numberWithInt: -1]];
						[[[target objectAtIndex:j] lastObject] addObject:[NSNumber numberWithInt: -1]];
						
						[locatedPlaces addObject:[NSNumber numberWithInt:j]];
						
						[touchesArray removeLastObject];
						
						if([touchesArray count]==0) {
							arrayLength = [[target objectAtIndex:j] count];
						}
						break;
					}
				}
			}
		}
		
		infinitePreventor++;
		if(infinitePreventor>50) {
			NSLog(@"!!!!Infinite Loop Detected!!!!");
			break;
		}
	}
	
	
	//add same values with the previous values for non-moving fingers
	for (int i=0;i<[target count]; i++) {
		if([[target objectAtIndex:i] count] !=arrayLength) {
			NSNumber *lastX = [[[target objectAtIndex:i] lastObject] objectAtIndex:0];
			NSNumber *lastY = [[[target objectAtIndex:i] lastObject] objectAtIndex:1];
			[[target objectAtIndex:i] addObject:[NSMutableArray array]];
			[[[target objectAtIndex:i] lastObject] addObject: lastX];
			[[[target objectAtIndex:i] lastObject] addObject: lastY];
		}
	}
	
	/*************************************************************/
	if(self.isInstantDetection & [self.touchCount intValue] >0){
		if([[self.instantPositions objectAtIndex:0] count] >2) {
			for(int i = 0; i<[self.instantPositions count]; i++) {
				[[self.instantPositions objectAtIndex:i] removeObjectAtIndex:0];
			}
		}
	}		
	
	if([self.touchCount intValue] != 0) {
		//print all touch arrays content
		for(int j=0; j<[[target objectAtIndex:0] count];j++) {
			for(int i=0;i<[target count];i++) {
				printf("%d,%d \t",[self getPosition:target:i:j:0], [self getPosition:target:i:j:1]);
			}
			printf("\n");
		}
	}
	
	printf("Touch Count : %d\n",[self.touchCount intValue]);
	
	NSLog(@"Max Touch: %@",self.maxTouchCount);
	
	//When all touches end, analyse the gesture
	if([self.touchCount intValue] == 0) {
		if(!self.isInstantDetection) {
			[self analyseGestureAfter];
		}
		positions=nil;
		self.state =[NSNumber numberWithInt:0];
		self.maxTouchCount = [NSNumber numberWithInt:0];
	}
	
}

-(BOOL) containsInteger:(NSMutableArray *) array:(int) integer {
	for(int i = 0; i < [array count]; i++) {
		if([[array objectAtIndex:i] intValue] == integer) {
			return YES;
		}
	}
	return NO;
}

-(void) analyseGestureInstantly {	
	
	if(self.isInstantDetection & [self.maxTouchCount intValue] == 2 & [self.touchCount intValue]== 2) {
		int direction=-1;
		int directionX=-1;
		int directionY=-1;
		int displacementX=0;
		int displacementY=0;
		
	//	NSLog(@"Content : %@", self.instantPositions);

		//Check Up-Down
		if(self.isVerticalDetection ) {
			int diff1 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:0]:0];
			int diff2 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:1]:0];
			int absDiff1 = abs(diff1);
			int absDiff2 = abs(diff2);
	//		NSLog(@"Vert: diff1 %d, diff2 %d",diff1,diff2);
			displacementY = self.isUseMinDisplacement ? (absDiff1<absDiff2 ? absDiff1 : absDiff2) : (absDiff1>absDiff2 ? absDiff1 : absDiff2);			
			
			if( diff1<=0 && diff2<=0 && (diff1!=0 || diff2!=0)) {
				directionY = 0;
			}else if(diff1>=0 && diff2>=0 && (diff1!=0 || diff2!=0)) {
				directionY = 2;
			}
	//		NSLog(@"direction-Y %d displacement Y: %d",directionY, displacementY);

		}
		
		//Check Left - Right
		if(self.isHorizontalDetection) { 
			int diff1 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:0]:1];
			int diff2 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:1]:1];
			int absDiff1 = abs(diff1);
			int absDiff2 = abs(diff2);
	//		NSLog(@"Horiz: diff1 %d, diff2 %d",diff1,diff2);
			displacementX = self.isUseMinDisplacement ? (absDiff1<absDiff2 ? absDiff1 : absDiff2) : (absDiff1>absDiff2 ? absDiff1 : absDiff2);			

			if( diff1<=0 && diff2<=0 && (diff1!=0 || diff2!=0)) {
				directionX = 1;
			}else if(diff1>=0 && diff2>=0 && (diff1!=0 || diff2!=0)) {
				directionX = 3;
			}	
	//		NSLog(@"direction-X %d, displacement-X: %d",directionX, displacementX);

		}
		
		if(!self.isMultiDimensionDetection) 
			direction = (displacementX<displacementY) ? directionY : directionX;
		else {
			if(directionX != -1 & directionY != -1) {
				direction = (directionY==0) ? ((directionX==1) ? 4 : 7) : ((directionX==1) ? 5 : 6);
			} else {
				direction = (directionX==-1) ? directionY : directionX;
			}
		}
		
		switch(direction) {
			case 0:
				[[self delegate] doubleFingerSlideUp:displacementY];
				break;
			case 1:
				[[self delegate] doubleFingerSlideLeft:displacementX];
				break;
			case 2:
				[[self delegate] doubleFingerSlideDown:displacementY];
				break;
			case 3:
				[[self delegate] doubleFingerSlideRight:displacementX];
				break;
			case 4:
				[[self delegate] doubleFingerSlideUpLeft:displacementX:displacementY];
				break;
			case 5:
				[[self delegate] doubleFingerSlideDownLeft:displacementX:displacementY];
				break;
			case 6:
				[[self delegate] doubleFingerSlideDownRight:displacementX:displacementY];
				break;
			case 7:
				[[self delegate] doubleFingerSlideUpRight:displacementX:displacementY];
				break;
			default:
				break;
		}
		
		if(self.isRotationDetection) {
			int rotation = [self isRotationInstant:[self.instantPositions objectAtIndex:0]:[self.instantPositions objectAtIndex:1]];
			if(rotation!=0) {
				[[self delegate] doRotation:rotation];
			}
		}
		
	} else if(self.isInstantDetection & [self.maxTouchCount intValue] == 3 & [self.touchCount intValue]== 3) {
		int direction=-1;
		int directionX=-1;
		int directionY=-1;
		int displacementX=0;
		int displacementY=0;
		if(self.isVerticalDetection ) {
			int diff1 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:0]:0];
			int diff2 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:1]:0];
			int diff3 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:2]:0];
			int absDiff1 = abs(diff1);
			int absDiff2 = abs(diff2);
			int absDiff3 = abs(diff3);
			NSLog(@"3 - Vert: diff1 %d, diff2 %d, diff3 %d",diff1,diff2,diff3);
			displacementY = self.isUseMinDisplacement ? (absDiff1<absDiff2 ? (absDiff3<absDiff1 ? absDiff3 : absDiff1) : (absDiff3 <absDiff2 ? absDiff3 : absDiff2)) : (absDiff1>absDiff2 ? (absDiff3>absDiff1 ? absDiff3 : absDiff1) : (absDiff3 >absDiff2 ? absDiff3 : absDiff2));			
			
			if( diff1<=0 && diff2<=0 && diff3 <=0 && (diff1!=0 || diff2!=0 || diff3 !=0) ) {
				directionY = 0;
			}else if(diff1>=0 && diff2>=0 && diff3>=0 && (diff1!=0 || diff2!=0 || diff3 !=0)) {
				directionY = 2;
			}
			NSLog(@"3 - direction-Y %d displacement Y: %d",directionY, displacementY);
			
		}
		
		if(self.isHorizontalDetection ) {
			int diff1 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:0]:1];
			int diff2 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:1]:1];
			int diff3 = [self isLinearMovementInstant:[self.instantPositions objectAtIndex:2]:1];
			int absDiff1 = abs(diff1);
			int absDiff2 = abs(diff2);
			int absDiff3 = abs(diff3);
			NSLog(@"3 - Horiz: diff1 %d, diff2 %d, diff3 %d",diff1,diff2,diff3);
			displacementX = self.isUseMinDisplacement ? (absDiff1<absDiff2 ? (absDiff3<absDiff1 ? absDiff3 : absDiff1) : (absDiff3 <absDiff2 ? absDiff3 : absDiff2)) : (absDiff1>absDiff2 ? (absDiff3>absDiff1 ? absDiff3 : absDiff1) : (absDiff3 >absDiff2 ? absDiff3 : absDiff2));			
			
			if( diff1<=0 && diff2<=0 && diff3 <=0 && (diff1!=0 || diff2!=0 || diff3 !=0) ) {
				directionX = 1;
			}else if(diff1>=0 && diff2>=0 && diff3>=0 && (diff1!=0 || diff2!=0 || diff3 !=0)) {
				directionX = 3;
			}
			NSLog(@"3 - direction-X %d displacement Y: %d",directionX, displacementX);
			
		}
		
		if(!self.isMultiDimensionDetection) 
			direction = (displacementX < displacementY) ? directionY : directionX;
		else {
			if(directionX != -1 && directionY != -1) {
				direction = (directionY==0) ? ((directionX==1) ? 4 : 7) : ((directionX==1) ? 5 : 6);
			} else {
				direction = (directionX==-1) ? directionY : directionX;
			}
		}
		
		switch(direction) {
			case 0:
				[[self delegate] threeFingerSlideUp:displacementY];
				break;
			case 1:
				[[self delegate] threeFingerSlideLeft:displacementX];
				break;
			case 2:
				[[self delegate] threeFingerSlideDown:displacementY];
				break;
			case 3:
				[[self delegate] threeFingerSlideRight:displacementX];
				break;
			case 4:
				[[self delegate] threeFingerSlideUpLeft:displacementX:displacementY];
				break;
			case 5:
				[[self delegate] threeFingerSlideDownLeft:displacementX:displacementY];
				break;
			case 6:
				[[self delegate] threeFingerSlideDownRight:displacementX:displacementY];
				break;
			case 7:
				[[self delegate] threeFingerSlideUpRight:displacementX:displacementY];
				break;
			default:
				break;
		}
	}
}

-(void) analyseGestureAfter {
	int maxInitialOffset = 7;
	int maxFinalOffset = 10;
	
	if([self.positions count] == 2) {
		if([self detectInitialOffset:[self.positions objectAtIndex:0]] <= maxInitialOffset & [self detectFinalOffset:[self.positions objectAtIndex:0]] <= maxFinalOffset & [self detectInitialOffset:[self.positions objectAtIndex:1]] <= maxInitialOffset & [self detectFinalOffset:[self.positions objectAtIndex:1]] <= maxFinalOffset) {
			int direction=-1;
			int directionX=-1;
			int directionY=-1;
			int displacementX=0;
			int displacementY=0;
			
			//Check Up-Down
			if(self.isVerticalDetection ) {
				int diff1,diff2;
				
				if( (diff1 = [self isLinearMovement:[self.positions objectAtIndex:0]:0]) & (diff2 = [self isLinearMovement:[self.positions objectAtIndex:1]:0]) ) {
					displacementY = self.isUseMinDisplacement ? (diff1<diff2 ? diff1 : diff2) : diff1>diff2 ? diff1 : diff2;
					directionY = 0;
				}else if((diff1 = [self isLinearMovement:[self.positions objectAtIndex:0]:2]) & (diff2 = [self isLinearMovement:[self.positions objectAtIndex:1]:2])) {
					displacementY = self.isUseMinDisplacement ? (diff1<diff2 ? diff1 : diff2) : diff1>diff2 ? diff1 : diff2;
					directionY = 2;
				}
			} 
			
			//Check Left - Right
			if(self.isHorizontalDetection) { 
				int diff1,diff2;
				
				if( (diff1 = [self isLinearMovement:[self.positions objectAtIndex:0]:1]) & (diff2 =  [self isLinearMovement:[self.positions objectAtIndex:1]:1]) ) {
					displacementX = self.isUseMinDisplacement ? (diff1<diff2 ? diff1 : diff2) : diff1>diff2 ? diff1 : diff2;
					directionX = 1;
				} else if( (diff1 = [self isLinearMovement:[self.positions objectAtIndex:0]:3]) & (diff2 = [self isLinearMovement:[self.positions objectAtIndex:1]:3])) {
					displacementX = self.isUseMinDisplacement ? (diff1<diff2 ? diff1 : diff2) : diff1>diff2 ? diff1 : diff2;
					directionX = 3;
				}	
			}
			
			if(!self.isMultiDimensionDetection) 
				direction = (displacementX<displacementY) ? directionY : directionX;
			else {
				if(directionX != -1 & directionY != -1) {
					direction = (directionY==0) ? ((directionX==1) ? 4 : 7) : ((directionX==1) ? 5 : 6);
				} else {
					direction = (directionX==-1) ? directionY : directionX;
				}
			}
			
			switch(direction) {
				case 0:
					[[self delegate] doubleFingerSlideUp:displacementY];
					break;
				case 1:
					[[self delegate] doubleFingerSlideLeft:displacementX];
					break;
				case 2:
					[[self delegate] doubleFingerSlideDown:displacementY];
					break;
				case 3:
					[[self delegate] doubleFingerSlideRight:displacementX];
					break;
				case 4:
					[[self delegate] doubleFingerSlideUpLeft:displacementX:displacementY];
					break;
				case 5:
					[[self delegate] doubleFingerSlideDownLeft:displacementX:displacementY];
					break;
				case 6:
					[[self delegate] doubleFingerSlideDownRight:displacementX:displacementY];
					break;
				case 7:
					[[self delegate] doubleFingerSlideUpRight:displacementX:displacementY];
					break;
				default:
					break;
			}
			
			if(self.isRotationDetection) {
				int rotation = [self isRotation:[self.positions objectAtIndex:0]:[self.positions objectAtIndex:1]];
				if(rotation!=0) {
					[[self delegate] doRotation:rotation];
				}
			}
		}
	} else if([self.positions count] == 3) {
		if([self detectInitialOffset:[self.positions objectAtIndex:0]] <= maxInitialOffset & [self detectFinalOffset:[self.positions objectAtIndex:0]] <= maxFinalOffset & [self detectInitialOffset:[self.positions objectAtIndex:1]] <= maxInitialOffset & [self detectFinalOffset:[self.positions objectAtIndex:1]] <= maxFinalOffset & [self detectInitialOffset:[self.positions objectAtIndex:2]] <= maxInitialOffset & [self detectFinalOffset:[self.positions objectAtIndex:2]] <= maxFinalOffset) {
			int direction=-1;
			int directionX=-1;
			int directionY=-1;
			int displacementX=0;
			int displacementY=0;
			
			//Check Up-Down
			if(self.isVerticalDetection ) {
				int diff1,diff2,diff3;
				
				if( (diff1 = [self isLinearMovement:[self.positions objectAtIndex:0]:0]) & (diff2 = [self isLinearMovement:[self.positions objectAtIndex:1]:0]) & (diff3 = [self isLinearMovement:[self.positions objectAtIndex:2]:0])) {
					displacementY = self.isUseMinDisplacement ? (diff1<diff2 ? (diff3<diff1 ? diff3 : diff1) : (diff3 <diff2 ? diff3 : diff2)) : (diff1>diff2 ? (diff3>diff1 ? diff3 : diff1) : (diff3 >diff2 ? diff3 : diff2));			
					directionY = 0;
				}else if((diff1 = [self isLinearMovement:[self.positions objectAtIndex:0]:2]) & (diff2 = [self isLinearMovement:[self.positions objectAtIndex:1]:2]) & (diff3 = [self isLinearMovement:[self.positions objectAtIndex:2]:2]) ) {
					displacementY = self.isUseMinDisplacement ? (diff1<diff2 ? (diff3<diff1 ? diff3 : diff1) : (diff3 <diff2 ? diff3 : diff2)) : (diff1>diff2 ? (diff3>diff1 ? diff3 : diff1) : (diff3 >diff2 ? diff3 : diff2));			
					directionY = 2;
				}
			} 
			
			//Check Left - Right
			if(self.isHorizontalDetection) { 
				int diff1,diff2,diff3;
				
				if( (diff1 = [self isLinearMovement:[self.positions objectAtIndex:0]:1]) & (diff2 =  [self isLinearMovement:[self.positions objectAtIndex:1]:1]) & (diff3 = [self isLinearMovement:[self.positions objectAtIndex:2]:1])  ) {
					displacementX = self.isUseMinDisplacement ? (diff1<diff2 ? (diff3<diff1 ? diff3 : diff1) : (diff3 <diff2 ? diff3 : diff2)) : (diff1>diff2 ? (diff3>diff1 ? diff3 : diff1) : (diff3 >diff2 ? diff3 : diff2));			
					directionX = 1;
				} else if( (diff1 = [self isLinearMovement:[self.positions objectAtIndex:0]:3]) & (diff2 = [self isLinearMovement:[self.positions objectAtIndex:1]:3]) & (diff3 = [self isLinearMovement:[self.positions objectAtIndex:2]:3])) {
					displacementX = self.isUseMinDisplacement ? (diff1<diff2 ? (diff3<diff1 ? diff3 : diff1) : (diff3 <diff2 ? diff3 : diff2)) : (diff1>diff2 ? (diff3>diff1 ? diff3 : diff1) : (diff3 >diff2 ? diff3 : diff2));			
					directionX = 3;
				}	
			}
			
			if(!self.isMultiDimensionDetection) 
				direction = (displacementX<displacementY) ? directionY : directionX;
			else {
				if(directionX != -1 & directionY != -1) {
					direction = (directionY==0) ? ((directionX==1) ? 4 : 7) : ((directionX==1) ? 5 : 6);
				} else {
					direction = (directionX==-1) ? directionY : directionX;
				}
			}
			
			switch(direction) {
				case 0:
					[[self delegate] threeFingerSlideUp:displacementY];
					break;
				case 1:
					[[self delegate] threeFingerSlideLeft:displacementX];
					break;
				case 2:
					[[self delegate] threeFingerSlideDown:displacementY];
					break;
				case 3:
					[[self delegate] threeFingerSlideRight:displacementX];
					break;
				case 4:
					[[self delegate] threeFingerSlideUpLeft:displacementX:displacementY];
					break;
				case 5:
					[[self delegate] threeFingerSlideDownLeft:displacementX:displacementY];
					break;
				case 6:
					[[self delegate] threeFingerSlideDownRight:displacementX:displacementY];
					break;
				case 7:
					[[self delegate] threeFingerSlideUpRight:displacementX:displacementY];
					break;
				default:
					break;
			}
			
			if(self.isRotationDetection) {
				int rotation = [self isRotation:[self.positions objectAtIndex:0]:[self.positions objectAtIndex:1]];
				if(rotation!=0) {
					[[self delegate] doRotation:rotation];
				}
			}		
		} 
	}
}

-(CGFloat) isRotationInstant:(NSMutableArray *) finger1:(NSMutableArray *) finger2 {

	//initial point (x-y)
	int initX1 = [[[finger1 objectAtIndex:0] objectAtIndex:0] intValue];
	int initY1 = [[[finger1 objectAtIndex:0] objectAtIndex:1] intValue];
	
	int initX2 = [[[finger2 objectAtIndex:0] objectAtIndex:0] intValue];
	int initY2 = [[[finger2 objectAtIndex:0] objectAtIndex:1] intValue];
	
	int finalX1 = [[[finger1 objectAtIndex:1] objectAtIndex:0] intValue];
	int finalY1 = [[[finger1 objectAtIndex:1] objectAtIndex:1] intValue];
	
	int finalX2 = [[[finger2 objectAtIndex:1] objectAtIndex:0] intValue];
	int finalY2 = [[[finger2 objectAtIndex:1] objectAtIndex:1] intValue];
	
	CGFloat degreesInRadians=0;
	
	CGFloat deltaX1 = initX2 - initX1;
	CGFloat deltaY1 = initY1 - initY2;
	CGFloat deltaX2 = finalX2 - finalX1;
	CGFloat deltaY2 = finalY1 - finalY2;
	
	CGFloat line1Slope = deltaY1 / deltaX1;
	CGFloat line2Slope = deltaY2 / deltaX2;
	
	CGFloat degs = (acosf(((deltaX1*deltaX2) + (deltaY1*deltaY2)) / ((sqrt(deltaX1*deltaX1 + deltaY1*deltaY1)) * (sqrt(deltaX2*deltaX2 + deltaY2*deltaY2)))))*180/M_PI;
	if(line2Slope>line1Slope) {
		degreesInRadians = degreesInRadians + degs;
		NSLog(@"Change in degrees : +%f",degs);
	} else {
		NSLog(@"Change in degrees : %f",0-degs);
		degreesInRadians = degreesInRadians - degs;
	}	
	return degreesInRadians;
}

-(int) isRotation:(NSMutableArray *) finger1:(NSMutableArray *) finger2 {
	//temporary offset values
	int initialOffset1 = [self detectInitialOffset:finger1];	//initial offset for values of finger 
	int finalOffset1 = [self detectFinalOffset:finger1];		//final offset for values of finger 1
	int initialOffset2 = [self detectInitialOffset:finger2];	//initial offset for values of finger 
	int finalOffset2 = [self detectFinalOffset:finger2];		//final offset for values of finger 1
	
	int initialOffset = 0;
	int finalOffset = 0;
	
	if(initialOffset1>=initialOffset2) {
		initialOffset = initialOffset1;
	} else{
		initialOffset = initialOffset2;
	}
	
	if(finalOffset1>=finalOffset2) {
		finalOffset = finalOffset1;
	} else{
		finalOffset = finalOffset2;
	}	
	
	//initial point (x-y)
	int initX1 = [[[finger1 objectAtIndex:initialOffset] objectAtIndex:0] intValue];
	int initY1 = [[[finger1 objectAtIndex:initialOffset] objectAtIndex:1] intValue];
	int initX2 = [[[finger2 objectAtIndex:initialOffset] objectAtIndex:0] intValue];
	int initY2 = [[[finger2 objectAtIndex:initialOffset] objectAtIndex:1] intValue];
	int tempX1 = initX1;
	int tempY1 = initY1;
	int tempX2 = initX2;
	int tempY2 = initY2;
	
	CGFloat degreesInRadians=0;
	
	//if there are more than one touch points
	if([finger1 count]>(initialOffset+finalOffset+1) && [finger2 count]>(initialOffset+finalOffset+1) ) {
		//start from the initial offset and end with the final offset
		for(int i = initialOffset + 1; i<([finger1 count]-finalOffset); i++) {
			int x1 = [[[finger1 objectAtIndex:i] objectAtIndex:0] intValue];
			int y1 = [[[finger1 objectAtIndex:i] objectAtIndex:1] intValue];
			int x2 = [[[finger2 objectAtIndex:i] objectAtIndex:0] intValue];
			int y2 = [[[finger2 objectAtIndex:i] objectAtIndex:1] intValue];
			CGFloat deltaX1 = tempX2 - tempX1;
			CGFloat deltaY1 = tempY1 - tempY2;
			CGFloat deltaX2 = x2 - x1;
			CGFloat deltaY2 = y1 - y2;
			
			CGFloat line1Slope = deltaY1 / (tempX2 - tempX1);
			CGFloat line2Slope = deltaY2 / (x2 - x1);
			
			CGFloat degs = (acosf(((deltaX1*deltaX2) + (deltaY1*deltaY2)) / ((sqrt(deltaX1*deltaX1 + deltaY1*deltaY1)) * (sqrt(deltaX2*deltaX2 + deltaY2*deltaY2)))))*180/M_PI;
			if(line2Slope>line1Slope) {
				degreesInRadians = degreesInRadians + degs;
				NSLog(@"Change in degrees : +%f",degs);
			} else {
				NSLog(@"Change in degrees : %f",0-degs);
				degreesInRadians = degreesInRadians - degs;
			}
			
			//check if enough change in the angle occurred
			if(i==[finger1 count]-finalOffset-1) {				
				//if the displacement isn't enough, return false
				if(abs(degreesInRadians)<self.rotationThreshold) {
					return 0;
				}
			}
			//set the next test point
			tempX1 = x1;
			tempY1 = y1;
			tempX2 = x2;
			tempY2 = y2;
			
		}
	} else { 
		return 0;
	}
	
	return (int) degreesInRadians;
}

- (int) isLinearMovementInstant:(NSMutableArray *) array:(int) axis {
	
	//initial point (x-y)
	int firstX = [[[array objectAtIndex:0] objectAtIndex:0] intValue];
	int firstY = [[[array objectAtIndex:0] objectAtIndex:1] intValue];
	int nextX =	[[[array objectAtIndex:1] objectAtIndex:0] intValue];
	int nextY = [[[array objectAtIndex:1] objectAtIndex:1] intValue];
	
	switch (axis) {
			//Check Vertical
		case 0:					
			return nextY-firstY;
			break;
		case 1:
			//Check Horizontal
			return nextX-firstX;
			break;
		default:
			return 0;
			break;
	}
	return 0;
}

- (int) isLinearMovement:(NSMutableArray *) array:(int) direction {
	
	int initialOffset = [self detectInitialOffset:array]; //initial offset for touch values
	int finalOffset = [self detectFinalOffset:array]; //final offset for values
	
	//initial point (x-y)
	int initX = [[[array objectAtIndex:initialOffset] objectAtIndex:0] intValue];
	int initY = [[[array objectAtIndex:initialOffset] objectAtIndex:1] intValue];
	int tempX = initX;
	int tempY = initY;
	
	//if there are more than one touch points
	if([array count]!=(initialOffset+finalOffset+1)) {
		//start from the initial offset and end with the final offset
		for(int i = initialOffset+1; i<([array count]-finalOffset); i++) {
			int x = [[[array objectAtIndex:i] objectAtIndex:0] intValue];
			int y = [[[array objectAtIndex:i] objectAtIndex:1] intValue];
			
			switch (direction) {
					//upward direction check
				case 0:					
					//check movement in y-direction and distortion in x-direction (if necessary)
					if(tempY>= (y-self.distortionInMovDirection) ) 
						tempY=y;
					else 
						return 0;
					break;
				case 1:
					//check distortion in y-direction and movement in x-direction
					if(tempX>=(x-self.distortionInMovDirection)) 
						tempX=x;
					else 
						return 0;
					break;
				case 2:					
					//check distortion in x-direction and movement in y-direction
					if(tempY<=(y+self.distortionInMovDirection))
						tempY=y;
					else 
						return 0;					
					break;
				case 3:
					
					//check distortion in y-direction and movement in x-direction
					if(tempX<=(x+self.distortionInMovDirection))
						tempX=x;
					else
						return 0;					
					break;
					
				default:
					return 0;
					break;
			}
			
			//check if enough displacement occurred
			if(i==[array count]-finalOffset-1) {
				
				if(direction == 0 | direction == 2) {
					int yDiff = abs(initY-y);
					//					NSLog(@"Distance-Y: %d ",yDiff);
					
					if(yDiff <self.slideThreshold) {
						//						NSLog(@"Under Y-Threshold");
						return 0;
					}
				} else {
					int xDiff = abs(initX-x);
					
					//					NSLog(@"Distance-X: %d",xDiff);
					
					if(xDiff <self.slideThreshold) {
						//						NSLog(@"Under X-Threshold");
						return 0;
					}
				}
			}
		}
	} else { //if there isn't more than one data point, return false
		return 0;
	}
	if(abs(initY-tempY) != 0) {
		//		NSLog(@"Final Distance-Y: %d",abs(initY-tempY));
		
		return abs(initY-tempY);
	}else {
		//NSLog(@"Final Distance-X: %d",abs(initX-tempX));
		
		return abs(initX-tempX);
	}
}

//get the initial (-1) offset in the array 
- (int) detectInitialOffset:(NSMutableArray *) array{
	int initialOffset = 0;
	
	while([[[array objectAtIndex:initialOffset] objectAtIndex:0] intValue]==-1 && [[[array objectAtIndex:initialOffset] objectAtIndex:1] intValue] ==-1) {
		initialOffset++;
	}
	
	return initialOffset;
}

//get the final (-1) offset in the array 
- (int) detectFinalOffset:(NSMutableArray *) array{
	int finalOffset = 0;
	
	while([[[array objectAtIndex:([array count]-finalOffset-1)] objectAtIndex:0] intValue] == -1 && [[[array objectAtIndex:([array count]-finalOffset-1)] objectAtIndex:1] intValue]==-1){
		finalOffset++;
	}
	
	return finalOffset;
}

-(int) getPosition:(NSMutableArray*) array:(int) touch:(int) sequence:(int) xory {
	return [[[[array objectAtIndex:touch] objectAtIndex:sequence] objectAtIndex:xory] intValue];
}

-(NSMutableArray *) getPositionArray:(NSUInteger) touch:(NSUInteger) sequence{
	return [[self.positions objectAtIndex:touch] objectAtIndex:sequence];
}

- (void)dealloc {
    [super dealloc];
}

@end
