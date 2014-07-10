// INSKMath.h
//
// Copyright (c) 2014 Sven Korset
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <GLKit/GLKMath.h>


// ------------------------------------------------------------
#pragma mark - definitions
// ------------------------------------------------------------
/// @name definitions

/**
 Epsilon architecture independent.
 */
#if CGFLOAT_IS_DOUBLE
#define INSK_EPSILON DBL_EPSILON
#else
#define INSK_EPSILON FLT_EPSILON
#endif

/**
 M_PI/180
 */
static double const M_PI_180 = 0.01745329251994329547437168059786927;
/**
 180/M_PI
 */
static double const M_180_PI = 57.29577951308232286464772187173366547;

/**
 M_PI*2
 */
static double const M_PI_X_2 = 6.28318530717958623199592693708837032;


#ifdef __cplusplus
extern "C" {
#endif
	

// ------------------------------------------------------------
#pragma mark - CGPoint convertions
// ------------------------------------------------------------
/// @name CGPoint convertions

/**
 Converts a CGSize directly into a CGPoint.
 
 @param size The size.
 @return A CGPoint.
 */
static inline CGPoint CGPointFromSize(CGSize size) {
    return CGPointMake(size.width, size.height);
}

/**
 Converts a CGPoint directly into a CGSize.
 
 @param point The point.
 @return A CGSize.
 */
static inline CGSize CGSizeFromPoint(CGPoint point) {
    return CGSizeMake(point.x, point.y);
}

/**
 Converts a CGVector into a CGPoint.
 
 @param vector A CGVector.
 @return A CGPoint.
 */
static inline CGPoint CGPointFromCGVector(CGVector vector) {
    return CGPointMake(vector.dx, vector.dy);
}

/**
 Converts a CGPoint into a CGVector.
 
 @param point A CGPoint.
 @return A CGVector.
 */
static inline CGVector CGVectorFromCGPoint(CGPoint point) {
    return CGVectorMake(point.x, point.y);
}

/**
 Converts a GLKVector2 into a CGPoint.
 
 @param vector A GLKVector2.
 @return A CGPoint.
 */
static inline CGPoint CGPointFromGLKVector2(GLKVector2 vector) {
    return CGPointMake(vector.x, vector.y);
}

/**
 Converts a CGPoint into a GLKVector2 so it can be used with the GLKMath functions from GL Kit.
 
 @param point A CGPoint.
 @return A GLKVector2.
 */
static inline GLKVector2 GLKVector2FromCGPoint(CGPoint point) {
    return GLKVector2Make(point.x, point.y);
}


// ------------------------------------------------------------
#pragma mark - scalar calculations
// ------------------------------------------------------------
/// @name scalar calculations

/**
 Ensures that a scalar value stays within the range [min..max], inclusive.
 
 @param value The value to clamp.
 @param min The minimum the value shouldn't exceed.
 @param max The maximum the value shouldn't exceed.
 @return The value clamped.
 */
static inline CGFloat Clamp(CGFloat value, CGFloat min, CGFloat max) {
    return ((value < min) ? min : ((value > max) ? max : value));
}

/**
 Returns only YES if two scalars are approximately equal within a given variance.
 
 @param value A value.
 @param other Another value.
 @param variance The delta in which both values may vary.
 @return True if both values are approximately equal.
 */
static inline BOOL ScalarNearOtherWithVariance(CGFloat value, CGFloat other, CGFloat variance) {
    if (value <= other + variance && value >= other - variance) {
        return YES;
    }
    return NO;
}
    
/**
 Returns only YES if two scalars are approximately equal, only within a difference of the value defined by INSK_EPSILON.
 
 @param value A value.
 @param other Another value.
 @return True if both values are approximately equal.
 */
static inline BOOL ScalarNearOther(CGFloat value, CGFloat other) {
    if (value <= other + INSK_EPSILON && value >= other - INSK_EPSILON) {
        return YES;
    }
    return NO;
}

/**
 Returns 1.0 if a floating point value is positive, including zero or returns -1.0 if it is negative.
 
 @param value A value.
 @return +1.0 if the value is positive or zero, -1.0 if it is negative.
 */
static inline CGFloat ScalarSign(CGFloat value) {
    return ((value >= 0.0) ? 1.0 : -1.0);
}


// ------------------------------------------------------------
#pragma mark - CGPoint calculations
// ------------------------------------------------------------
/// @name CGPoint calculations

/**
 Adds an offset (dx, dy) to the point.
 
 @param point The point.
 @param dx The X offset.
 @param dy The y offset.
 @return A new point.
 */
static inline CGPoint CGPointOffset(CGPoint point, CGFloat dx, CGFloat dy) {
    return CGPointFromGLKVector2(GLKVector2Add(GLKVector2FromCGPoint(point), GLKVector2Make(dx, dy)));
}

/**
 Adds two CGPoint values and returns the result as a new CGPoint.
 
 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGPoint CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointFromGLKVector2(GLKVector2Add(GLKVector2FromCGPoint(point1), GLKVector2FromCGPoint(point2)));
}

/**
 Subtracts point2 from point1 and returns the result as a new CGPoint.
 
 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGPoint CGPointSubtract(CGPoint point1, CGPoint point2) {
    return CGPointFromGLKVector2(GLKVector2Subtract(GLKVector2FromCGPoint(point1), GLKVector2FromCGPoint(point2)));
}

/**
 Multiplies two CGPoint values and returns the result as a new CGPoint.
 
 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGPoint CGPointMultiply(CGPoint point1, CGPoint point2) {
    return CGPointFromGLKVector2(GLKVector2Multiply(GLKVector2FromCGPoint(point1), GLKVector2FromCGPoint(point2)));
}

/**
 Multiplies the x and y fields of a CGPoint with the same scalar value and returns the result as a new CGPoint.

 @param point A point.
 @param value A scalar.
 @return A new point.
 */
static inline CGPoint CGPointMultiplyScalar(CGPoint point, CGFloat value) {
    return CGPointFromGLKVector2(GLKVector2MultiplyScalar(GLKVector2FromCGPoint(point), value));
}

/**
 Divides point1 by point2 and returns the result as a new CGPoint.

 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGPoint CGPointDivide(CGPoint point1, CGPoint point2) {
    return CGPointFromGLKVector2(GLKVector2Divide(GLKVector2FromCGPoint(point1), GLKVector2FromCGPoint(point2)));
}

/**
 Divides the x and y fields of a CGPoint by the same scalar value and returns the result as a new CGPoint.

 @param point A point.
 @param value A scalar.
 @return A new point.
 */
static inline CGPoint CGPointDivideScalar(CGPoint point, CGFloat value) {
    return CGPointFromGLKVector2(GLKVector2DivideScalar(GLKVector2FromCGPoint(point), value));
}

/**
 Returns the length (magnitude) of the vector described by a CGPoint.

 @param point A point.
 @return The length scalar.
 */
static inline CGFloat CGPointLength(CGPoint point) {
    return GLKVector2Length(GLKVector2FromCGPoint(point));
}

/**
 Returns the square length by not calling sqrt() when calculating the length.

 @param point A point.
 @return The squared length.
 */
static inline CGFloat CGPointLengthSq(CGPoint point) {
    GLKVector2 vector = GLKVector2FromCGPoint(point);
	return GLKVector2DotProduct(vector, vector);
}

/**
 Normalizes the vector described by a CGPoint to length 1.0 and returns the result as a new CGPoint.

 @param point A point.
 @return A new point.
 */
static inline CGPoint CGPointNormalize(CGPoint point) {
    return CGPointFromGLKVector2(GLKVector2Normalize(GLKVector2FromCGPoint(point)));
}

/**
 Calculates the distance between two CGPoints.

 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGFloat CGPointDistance(CGPoint point1, CGPoint point2) {
    return GLKVector2Distance(GLKVector2FromCGPoint(point1), GLKVector2FromCGPoint(point2));
}

/**
 Calculates the square distance between two CGPoints by not calling sqrt() when calculating the distance.

 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGFloat CGPointDistanceSq(CGPoint point1, CGPoint point2) {
	return CGPointLengthSq(CGPointSubtract(point1, point2));
}

/**
 Negates a point by multiplying x and y with -1 and returns the result as a new CGPoint.

 @param point A point.
 @return A new point.
 */
static inline CGPoint CGPointNegate(CGPoint point) {
    return CGPointFromGLKVector2(GLKVector2Negate(GLKVector2FromCGPoint(point)));
}

/**
 Performs a linear interpolation between two CGPoint values.
 point1 will be the start point and point2 the end point while t gives the percentag in the range of 0 to 1.

 @param point1 A point.
 @param point2 Another point.
 @param t The percentage from 0 to 1 for interpolating point1 to point2.
 @return A new point.
 */
static inline CGPoint CGPointLerp(CGPoint point1, CGPoint point2, CGFloat t) {
    return CGPointFromGLKVector2(GLKVector2Lerp(GLKVector2FromCGPoint(point1), GLKVector2FromCGPoint(point2), t));
}

/**
 Returns the dot product of the two CGPoint values.

 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGFloat CGPointDotProduct(CGPoint point1, CGPoint point2) {
    return GLKVector2DotProduct(GLKVector2FromCGPoint(point1), GLKVector2FromCGPoint(point2));
}

/**
 Returns the cross product of the two CGPoint values.

 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGFloat CGPointCrossProduct(CGPoint point1, CGPoint point2) {
	return point1.x * point2.y - point1.y * point2.x;
}

/**
 Returns the projection of point1 over point2.

 @param point1 A point.
 @param point2 Another point.
 @return A new point.
 */
static inline CGPoint CGPointProject(CGPoint point1, CGPoint point2) {
    return CGPointFromGLKVector2(GLKVector2Project(GLKVector2FromCGPoint(point1), GLKVector2FromCGPoint(point2)));
}

/**
 Returns a CGPoint next to point, but between min and max inclusive.

 @param point A point.
 @param min A minimum point.
 @param max A maximum point.
 @return A new point.
 */
static inline CGPoint CGPointClamp(CGPoint point, CGPoint min, CGPoint max) {
    return CGPointMake(Clamp(point.x, min.x, max.x), Clamp(point.y, min.y, max.y));
}

/**
 Uniforms a point to a rect by substracting the rect's origin from the point vector and
 uniforming it afterwards to the rect's size so it will be scaled procentually.

 @param point A point.
 @param rect A rectangle.
 @return A new point.
 */
static inline CGPoint CGPointNormalizedInRect(CGPoint point, CGRect rect) {
    GLKVector2 relativePoint = GLKVector2Subtract(GLKVector2FromCGPoint(point), GLKVector2FromCGPoint(rect.origin));
    return CGPointFromGLKVector2(GLKVector2Divide(relativePoint, GLKVector2Make(rect.size.width, rect.size.height)));
}

/**
 Uniforms the point to the size so the point will be procentually long to the size.

 @param point A point.
 @param size A size.
 @return A new point.
 */
static inline CGPoint CGPointNormalizedInSize(CGPoint point, CGSize size) {
    return CGPointFromGLKVector2(GLKVector2Divide(GLKVector2FromCGPoint(point), GLKVector2Make(size.width, size.height)));
}

/**
 Returns true if two CGPoints are nearly equal within a variance, otherwise false.

 @param point1 A point.
 @param point2 Another point.
 @param variance A small delta scalar.
 @return True if both points are within the variance, otherwise false.
 */
static inline BOOL CGPointNearToPointWithVariance(CGPoint point1, CGPoint point2, CGFloat variance) {
    if (point1.x <= point2.x + variance && point1.x >= point2.x - variance) {
		if (point1.y <= point2.y + variance && point1.y >= point2.y - variance) {
			return YES;
		}
	}
	return NO;
}

/**
 Returns true if the CGPoints are nearly equal within a variance of INSK_EPSILON.

 @param point1 A point.
 @param point2 Another point.
 @return True if bot points are approximately equal.
 */
static inline BOOL CGPointNearToPoint(CGPoint point1, CGPoint point2) {
    return CGPointNearToPointWithVariance(point1, point2, INSK_EPSILON);
}


// ------------------------------------------------------------
#pragma mark - CGSize calculations
// ------------------------------------------------------------
/// @name CGSize calculations

/**
 Scales a CGSize to fit a destination size respecting the aspect ratio and returns the scale factor. The new size will be smaller than the destination.
 
 @param origSize The current size of an object which has to be scaled.
 @param destSize The max size to which an object has to be scaled.
 @return The scale factor to fit an object into respecting the aspect ratio.
 */
static inline CGFloat CGSizeScaleFactorToSizeAspectFit(CGSize origSize, CGSize destSize) {
    CGFloat ratioWidth = destSize.width / origSize.width;
    CGFloat ratioHeight = destSize.height / origSize.height;
    return MIN(ratioWidth, ratioHeight);
}

/**
 Scales a CGSize to fit a destination size respecting the aspect ratio.
 
 Uses CGSizeScaleFactorToSizeAspectFit(CGSize, CGSize) to determine the scale factor with which the size will be multiplied.

 @param origSize The current size of an object which has to be scaled.
 @param destSize The max size to which an object has to be scaled.
 @return The scaled size .
 */
static inline CGSize CGSizeScaledToSizeAspectFit(CGSize origSize, CGSize destSize) {
    CGFloat scaleFactor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    return CGSizeMake(origSize.width * scaleFactor, origSize.height * scaleFactor);
}

/**
 Scales a CGSize to fill a destination size respecting the aspect ratio and returns the scale factor. The new size will be greater than the destination.

 @param origSize The current size of an object which has to be scaled.
 @param destSize The max size to which an object has to be scaled.
 @return The scale factor to fill an object into respecting the aspect ratio.
 */
static inline CGFloat CGSizeScaleFactorToSizeAspectFill(CGSize origSize, CGSize destSize) {
    CGFloat ratioWidth = destSize.width / origSize.width;
    CGFloat ratioHeight = destSize.height / origSize.height;
    return MAX(ratioWidth, ratioHeight);
}

/**
 Scales a CGSize to fill a destination size respecting the aspect ratio.

 Uses CGSizeScaleFactorToSizeAspectFill(CGSize, CGSize) to determine the scale factor with which the size will be multiplied.

 @param origSize The current size of an object which has to be scaled.
 @param destSize The max size to which an object has to be scaled.
 @return The scaled size .
 */
static inline CGSize CGSizeScaledToSizeAspectFill(CGSize origSize, CGSize destSize) {
    CGFloat scaleFactor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    return CGSizeMake(origSize.width * scaleFactor, origSize.height * scaleFactor);
}


// ------------------------------------------------------------
#pragma mark - angular convertions and calculations
// ------------------------------------------------------------
/// @name angular convertions and calculations

/**
 Converts an angle in degrees to radians.
 
 @param degrees An angle in degrees.
 @return The angle in radians.
 */
static inline CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI_180;
}

/**
 Converts an angle in radians to degrees.
 
 @param radians An angle in radians.
 @return The angle in degrees.
 */
static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * M_180_PI;
}

/**
 Given an angle in radians, creates a vector of length 1.0 and returns the result as a new CGPoint.
 An angle of 0 is assumed to point to the right so the point (x=1,y=0) will be returned in this case.
 
 @param angle An angle in radians.
 @return A CGPoint as a vector.
 */
static inline CGPoint CGPointForAngle(CGFloat angle) {
    return CGPointMake(cos(angle), sin(angle));
}

/**
 Returns the angle in radians of the vector described by a CGPoint.
 The range of the angle is -M_PI to M_PI with an angle of 0 points to the right.
 An angle of M_PI will point to the left, a negative angle points down and a positive value up.
 
 @param point A point as a vector.
 @return The angle in radians.
 */
static inline CGFloat CGPointToAngle(CGPoint point) {
    return atan2(point.y, point.x);
}

/**
 Wraps a radian angle around so it stays in the range of 0 to 2 * M_PI.
 
 @param angle An angle in radians from -M_PI to M_PI.
 @return The angle in radians from 0 to 2*M_PI.
 */
static inline CGFloat AngleIn2Pi(CGFloat angle) {
    while (angle >= M_PI_X_2) {
        angle -= M_PI_X_2;
    }
    while (angle < 0.0) {
        angle += M_PI_X_2;
    }
    return angle;
}
    
/**
 Wraps a radian angle around so it stays in the range of -M_PI to M_PI.
 
 @param angle An angle in radians from 0 to 2*M_PI.
 @return The angle in radians from -M_PI to M_PI.
 */
static inline CGFloat AngleInPi(CGFloat angle) {
    while (angle >= M_PI) {
        angle -= M_PI_X_2;
    }
    while (angle < -M_PI) {
        angle += M_PI_X_2;
    }
    return angle;
}
    
/**
 Returns the shortest angle between two radian angles. The result is always between -M_PI and M_PI.
 
 If the angle1 is smaller than angle2 a negative angle will be returned.
 If angle1 is bigger than angle2 a positive angle will be returned.
 
 @param angle1 The first angle in radians.
 @parma angle2 The second angle in radians.
 @return The difference angle in radians. A positive value means a clockwise, a negative counterclockwise direction.
 */
static inline CGFloat ShortestAngleBetween(CGFloat angle1, CGFloat angle2) {
    if (angle1 < 0.0) {
        angle1 += M_PI_X_2;
    }
    if (angle2 < 0.0) {
        angle2 += M_PI_X_2;
    }
    CGFloat angle = angle2 - angle1;
    while (angle > M_PI) {
        angle -= M_PI_X_2;
    }
    while (angle < -M_PI) {
        angle += M_PI_X_2;
    }
    return angle;
}


#ifdef __cplusplus
}
#endif
