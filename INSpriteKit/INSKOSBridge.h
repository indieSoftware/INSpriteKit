// INSKOSBridge.h
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


#if TARGET_OS_IPHONE
// These bridges are only for iOS so using OS X code in an iOS project will be easier.

#define NSImage UIImage
#define NSPoint CGPoint


@interface NSValue (Bridge)

/// @see valueWithCGPoint:
+ (NSValue *)valueWithPoint:(NSPoint)point;

/// @see CGPointValue
- (CGPoint)pointValue;

@end


#else // OS X
// These bridges are only for OS X so using iOS code in an OS X project will be easier.

#define UIImage NSImage


static inline NSString* NSStringFromCGPoint(CGPoint point) {
    return [NSString stringWithFormat:@"{%.0f, %.0f}", point.x, point.y];
}


@interface NSImage (Bridge)

/// @see CGImageForProposedRect:context:hints:
- (CGImageRef)CGImage;

/// @see initWithContentsOfFile:
+ (UIImage *)imageWithContentsOfFile:(NSString *)path;

/// @see initWithCGImage:size:
+ (UIImage *)imageWithCGImage:(CGImageRef)imageRef;

@end


@interface NSValue (Bridge)

/// @see valueWithPoint:
+ (NSValue *)valueWithCGPoint:(CGPoint)point;

/// @see pointValue
- (CGPoint)CGPointValue;

@end



#endif

