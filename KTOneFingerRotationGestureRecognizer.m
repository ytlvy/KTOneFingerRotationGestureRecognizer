//
//  KTOneFingerRotationGestureRecognizer.m
//
//  Created by Kirby Turner on 4/22/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "KTOneFingerRotationGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@implementation KTOneFingerRotationGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Fail when more than 1 finger detected.
    if ([[event touchesForGestureRecognizer:self] count] > 1) {
        [self setState:UIGestureRecognizerStateFailed];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self state] == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateBegan];
    } else {
        [self setState:UIGestureRecognizerStateChanged];
    }
    
    // We can look at any touch object since we know we
    // have only 1. If there were more than 1 then
    // touchesBegan:withEvent: would have failed the recognizer.
    UITouch *touch = [touches anyObject];
    
    // To rotate with one finger, we simulate a second finger.
    // The second figure is on the opposite side of the virtual
    // circle that represents the rotation gesture.
    
    UIView *view = [self view];
    CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
    CGPoint currentTouchPoint = [touch locationInView:view];
    CGPoint previousTouchPoint = [touch previousLocationInView:view];
    
    if(self.referenceView) {
        self.lastPoint = [touch previousLocationInView:self.referenceView];
        self.currentPoint = [touch locationInView:self.referenceView];
    }
    else {
        CGFloat angleInRadians = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x);
        
        [self setRotation:angleInRadians];
        
        CGPoint ab = CGPointMake(center.x-currentTouchPoint.x, center.y-currentTouchPoint.y);
        CGPoint cb = CGPointMake(center.x-previousTouchPoint.x, center.y-previousTouchPoint.y);
        [self setScale: sqrt(ab.x*ab.x + ab.y*ab.y) / sqrt(cb.x*cb.x + cb.y*cb.y)];
    }
}

- (CGFloat)rotationFromCenter:(CGPoint)center {
    return atan2f(self.currentPoint.y - center.y, self.currentPoint.x - center.x) - atan2f(self.lastPoint.y - center.y, self.lastPoint.x - center.x);
}

- (CGFloat)rotationFromCenterV2:(CGPoint)center {
    CGPoint ab = CGPointMake(self.currentPoint.x - center.x, self.currentPoint.y -center.y);
    CGPoint cb = CGPointMake(self.lastPoint.x - center.x, self.lastPoint.y - center.y);
    
    float dot = (ab.x * cb.x + ab.y * cb.y); // dot product
    float cross = (ab.x * cb.y - ab.y * cb.x); // cross product
    return  atan2(cross, dot);
}

- (CGFloat)scaleFromCenter:(CGPoint)center {
    CGPoint ab = CGPointMake(center.x-self.currentPoint.x, center.y-self.currentPoint.y);
    CGPoint cb = CGPointMake(center.x-self.lastPoint.x, center.y-self.lastPoint.y);
    return sqrt(ab.x*ab.x + ab.y*ab.y) / sqrt(cb.x*cb.x + cb.y*cb.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self state] == UIGestureRecognizerStateChanged) {
        [self setState:UIGestureRecognizerStateEnded];
    } else {
        [self setState:UIGestureRecognizerStateFailed];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setState:UIGestureRecognizerStateFailed];
}

@end
