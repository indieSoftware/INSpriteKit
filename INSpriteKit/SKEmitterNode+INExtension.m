// SKEmitterNode+INExtension.m
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


#import "SKEmitterNode+INExtension.h"
#import "SKNode+INExtension.h"


@implementation SKEmitterNode (INExtension)

+ (instancetype)emitterNodeWithFileNamed:(NSString *)sksFile {
	NSString *path = [[NSBundle mainBundle] pathForResource:sksFile ofType:nil];
	if (path == nil) {
		path = [[NSBundle mainBundle] pathForResource:sksFile ofType:@"sks"];
	}
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (CGFloat)emitterLife {
    if (self.numParticlesToEmit == 0) {
        return NAN;
    }
    if (self.particleBirthRate == 0.0) {
        return 0.0;
    }
    CGFloat emitterLife = self.numParticlesToEmit / self.particleBirthRate + self.particleLifetime + self.particleLifetimeRange / 2.0;
    return emitterLife;
}

- (void)runActionToRemoveWhenFinished {
    CGFloat emitterLife = self.emitterLife;
    if (isnan(emitterLife)) return;
    [self runActions:@[[SKAction waitForDuration:emitterLife], [SKAction removeFromParent]]];
}


@end
