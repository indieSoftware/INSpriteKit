// SKEmitterNode+INExtension.h
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


#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNode (INExtension)


/**
 Creates and initializes a new emitter node using a sks file stored in the app bundle.
 
 @param sksFile The name of the sks file. If no file coult be found with the given name the extension "sks" will be appended to the name and retried.
 @return A new emitter node.
 */
+ (instancetype)emitterNodeWithFileNamed:(NSString *)sksFile;


/**
 Returns the maximal life time of this emitter.
 
 Calculates the maximum seconds this emitter will have some particles to show at total.
 
 @return The emitter's life time in seconds. 0 if no particles will be shown and NAN if the emitter last for infinity.
 */
- (CGFloat)emitterLife;


/**
 Creates and runs a new action which will remove this emitter from the parent node after the emitter's life has passed.
 
 For calculating the method emitterLife will be used and a new action will only be created if the result value is not NAN.
 */
- (void)runActionToRemoveWhenFinished;


@end
