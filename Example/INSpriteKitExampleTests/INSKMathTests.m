// INSKMathTests.m
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


#import <XCTest/XCTest.h>

@interface INSKMathTests : XCTestCase

@end

@implementation INSKMathTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - convertions

- (void)test_convertions_returnsCorrectStructs {
    CGPoint point = CGPointMake(100, 200);
    CGSize size = CGSizeMake(300, 400);
    CGVector vector = CGVectorMake(500, 600);
    GLKVector2 glkVector = GLKVector2Make(700, 800);
    
    CGPoint resultPoint = CGPointFromSize(size);
    XCTAssert(resultPoint.x == size.width && resultPoint.y == size.height, @"convertion is not correct");
    
    CGSize resultSize = CGSizeFromPoint(point);
    XCTAssert(resultSize.width == point.x && resultSize.height == point.y, @"convertion is not correct");
    
    resultPoint = CGPointFromCGVector(vector);
    XCTAssert(resultPoint.x == vector.dx && resultPoint.y == vector.dy, @"convertion is not correct");
    
    CGVector resultVector = CGVectorFromCGPoint(point);
    XCTAssert(resultVector.dx == point.x && resultVector.dy == point.y, @"convertion is not correct");
    
    resultPoint = CGPointFromGLKVector2(glkVector);
    XCTAssert(resultPoint.x == glkVector.x && resultPoint.y == glkVector.y, @"convertion is not correct");
    
    GLKVector2 resultVector2 = GLKVector2FromCGPoint(point);
    XCTAssert(resultVector2.x == point.x && resultVector2.y == point.y, @"convertion is not correct");
}


#pragma mark - Clamp()

- (void)test_clamp_withValueInside_returnsSameValue {
    CGFloat result = Clamp(5.4, 2.3, 7.8);
    XCTAssert(ScalarNearOther(result, 5.4), @"%f not the correct result value", result);

    result = Clamp(2.3, 2.3, 7.8);
    XCTAssert(ScalarNearOther(result, 2.3), @"%f not the correct result value", result);

    result = Clamp(7.8, 2.3, 7.8);
    XCTAssert(ScalarNearOther(result, 7.8), @"%f not the correct result value", result);
}

- (void)test_clamp_withValueTooLow_returnsLowerBoundary {
    CGFloat result = Clamp(1.2, 2.3, 7.8);
    XCTAssert(ScalarNearOther(result, 2.3), @"%f not the correct result value", result);
}

- (void)test_clamp_withValueTooHigh_returnsHigherBoundary {
    CGFloat result = Clamp(8.9, 2.3, 7.8);
    XCTAssert(ScalarNearOther(result, 7.8), @"%f not the correct result value", result);
}


#pragma mark - ScalarNearOther()

- (void)test_scalarNearOther_withSameValues_returnsTrue {
    BOOL result = ScalarNearOther(5.6, 5.6);
    XCTAssert(result == YES, @"same values should be near each other");
}

- (void)test_scalarNearOther_withDifferentValues_returnsFalse {
    BOOL result = ScalarNearOther(1.2, 5.6);
    XCTAssert(result == NO, @"different values should not be near each other");
}


#pragma mark - ScalarSign()

- (void)test_scalarSign_withNegativeValue_returnsMinusOne {
    CGFloat sign = ScalarSign(-4.5);
    XCTAssert(ScalarNearOther(sign, -1) == YES, @"%f is the wrong value", sign);
}

- (void)test_scalarSign_withPositiveValue_returnsPlusOne {
    CGFloat sign = ScalarSign(4.5);
    XCTAssert(ScalarNearOther(sign, 1) == YES, @"%f is the wrong value", sign);
}

- (void)test_scalarSign_withZeroValue_returnsPlusOne {
    CGFloat sign = ScalarSign(0.0);
    XCTAssert(ScalarNearOther(sign, 1) == YES, @"%f is the wrong value", sign);
}


#pragma mark - CGPoint calculations

// TODO create some tests


#pragma mark - CGSize calculations

- (void)test_CGSizeScaleFactorToSizeAspectFit_withSmallerOrigSize_returnsFactorGreaterOne {
    CGSize origSize = CGSizeMake(200, 300);
    CGSize destSize = CGSizeMake(600, 600);
    CGFloat factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 2), @"the factor %f is not correct", factor);

    origSize = CGSizeMake(300, 200);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 2), @"the factor %f is not correct", factor);

    origSize = CGSizeMake(200, 200);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 3), @"the factor %f is not correct", factor);

    destSize = CGSizeMake(800, 600);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 3), @"the factor %f is not correct", factor);
    
    destSize = CGSizeMake(600, 800);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 3), @"the factor %f is not correct", factor);
}

- (void)test_CGSizeScaleFactorToSizeAspectFit_withGreaterOrigSize_returnsFactorSmallerOne {
    CGSize origSize = CGSizeMake(400, 800);
    CGSize destSize = CGSizeMake(200, 200);
    CGFloat factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.25), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(800, 400);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.25), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(400, 400);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.5), @"the factor %f is not correct", factor);

    destSize = CGSizeMake(100, 200);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.25), @"the factor %f is not correct", factor);

    destSize = CGSizeMake(200, 100);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.25), @"the factor %f is not correct", factor);
}

- (void)test_CGSizeScaleFactorToSizeAspectFit_withSameSize_returnsOne {
    CGSize origSize = CGSizeMake(400, 800);
    CGSize destSize = CGSizeMake(400, 800);
    CGFloat factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 1), @"the factor %f is not correct", factor);

    origSize = CGSizeMake(500, 300);
    destSize = CGSizeMake(500, 300);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 1), @"the factor %f is not correct", factor);

    origSize = CGSizeMake(100, 100);
    destSize = CGSizeMake(100, 100);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 1), @"the factor %f is not correct", factor);
}

- (void)test_CGSizeScaleFactorToSizeAspectFit_withOneSideGreaterAndTheOtherSideSmaller_returnsFactorSmallerOne {
    CGSize origSize = CGSizeMake(200, 800);
    CGSize destSize = CGSizeMake(400, 400);
    CGFloat factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.5), @"the factor %f is not correct", factor);

    origSize = CGSizeMake(600, 100);
    destSize = CGSizeMake(300, 300);
    factor = CGSizeScaleFactorToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.5), @"the factor %f is not correct", factor);
}


- (void)test_CGSizeScaleFactorToSizeAspectFill_withSmallerOrigSize_returnsFactorGreaterOne {
    CGSize origSize = CGSizeMake(200, 300);
    CGSize destSize = CGSizeMake(600, 600);
    CGFloat factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 3), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(300, 200);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 3), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(300, 300);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 2), @"the factor %f is not correct", factor);
    
    destSize = CGSizeMake(900, 600);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 3), @"the factor %f is not correct", factor);
    
    destSize = CGSizeMake(900, 800);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 3), @"the factor %f is not correct", factor);
}

- (void)test_CGSizeScaleFactorToSizeAspectFill_withGreaterOrigSize_returnsFactorSmallerOne {
    CGSize origSize = CGSizeMake(400, 800);
    CGSize destSize = CGSizeMake(200, 200);
    CGFloat factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.5), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(800, 400);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.5), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(800, 800);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.25), @"the factor %f is not correct", factor);
    
    destSize = CGSizeMake(100, 200);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.25), @"the factor %f is not correct", factor);
    
    destSize = CGSizeMake(200, 100);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 0.25), @"the factor %f is not correct", factor);
}

- (void)test_CGSizeScaleFactorToSizeAspectFill_withSameSize_returnsOne {
    CGSize origSize = CGSizeMake(400, 800);
    CGSize destSize = CGSizeMake(400, 800);
    CGFloat factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 1), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(500, 300);
    destSize = CGSizeMake(500, 300);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 1), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(100, 100);
    destSize = CGSizeMake(100, 100);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 1), @"the factor %f is not correct", factor);
}

- (void)test_CGSizeScaleFactorToSizeAspectFill_withOneSideGreaterAndTheOtherSideSmaller_returnsFactorGreaterOne {
    CGSize origSize = CGSizeMake(200, 800);
    CGSize destSize = CGSizeMake(400, 400);
    CGFloat factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 2), @"the factor %f is not correct", factor);
    
    origSize = CGSizeMake(600, 100);
    destSize = CGSizeMake(300, 300);
    factor = CGSizeScaleFactorToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(factor, 3), @"the factor %f is not correct", factor);
}

- (void)test_CGSizeScaledToSizeAspectFit_withSizes_returnsScaledSize {
    CGSize origSize = CGSizeMake(200, 800);
    CGSize destSize = CGSizeMake(400, 400);
    CGSize scaledSize = CGSizeScaledToSizeAspectFit(origSize, destSize);
    XCTAssert(ScalarNearOther(scaledSize.width, 100) && ScalarNearOther(scaledSize.height, 400), @"the scaled size is not correct");
}

- (void)test_CGSizeScaledToSizeAspectFill_withSizes_returnsScaledSize {
    CGSize origSize = CGSizeMake(200, 800);
    CGSize destSize = CGSizeMake(400, 400);
    CGSize scaledSize = CGSizeScaledToSizeAspectFill(origSize, destSize);
    XCTAssert(ScalarNearOther(scaledSize.width, 400) && ScalarNearOther(scaledSize.height, 1600), @"the scaled size is not correct");
}


#pragma mark - angular convertions and calculations

// TODO create some tests



@end
