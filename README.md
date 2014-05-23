# INSpriteKit

[![CocoaDocs](http://cocoapod-badges.herokuapp.com/v/INSpriteKit/badge.png)](http://cocoadocs.org/docsets/INSpriteKit)

This library consists of

### Math functions
- Different vector calculation methods for CGPoint and methods to convert.
- Methods for scalars like ScalarNearOther() to determine if a CGFloat is the same as another plus minus epsilon.
- Angular convertions and calculations.

### INSKScrollNode: A UIScrollView adaption for Sprite Kit
- Has full support for scrolling a content node into all directions.
- The scroll out behavior can be chosen from different presets.
- Paging is also supported.

### INSKButtonNode: A UIButton adaption for Sprite Kit
- Has full support for touch and state handling.
- Set different visual representations for the states disabled, normal, highlighted, selected and selected+highlighted.
- Get called back when the button is being pressed, released and released inside of its frame.

### INSKView: A SKView replacement for a better touch delivery
- Replaces Sprite Kit's touch delivery system with its own to respect a SKNode's `userInteractionEnabled` property.
- SKNode may use `touchPriority` to get touches even when not on top of all other nodes.
- Add global touch observing nodes which get informed about touch events regardless of their position and visibility state. Nodes may also get touches this way when not on the scene tree.

### A tiled image node for huge sprites
- INSKTiledImageNode can present images which are otherwise too huge for being used as a texture.
- Present images which are greater than 1024x1024 (respectively 2048x2048).

### Some categories
- SKNode: `bringToFront` and `sendToBack` for manipulating the tree order.
- SKNode: `changeParent:` replaces the node's parent and converts its position.
- SKSpriteNode: `isPositionInside:` checks if a position is inside of the sprite node.
- SKEmitterNode: `emitterLife` calculates an emitter's total life time.
- SKEmitterNode: `runActionToRemoveWhenFinished` adds an action which will remove the emitter if finished emitting.
- ... and some more additionals.


## Examples

To run the example project; clone the repo, and run `pod install` from the Example directory first.
Then open the workspace file INSpriteKitExample.xcworkspace with Xcode and run the example or the tests.
The example scenes are within the 'Scenes' group in 'INSpriteKitExample', just go through them to see how to use the library.


## Requirements

iOS 7+, ARC enabled

Needs the following Frameworks:
- SpriteKit
- GLKit


## Installation

Add the following line to your Podfile:

	pod 'INSpriteKit', :git => 'https://github.com/indieSoftware/INSpriteKit.git'

or clone the repo manually and add the INSpriteKit directory to your project.

Add the necessary frameworks mentioned in the requirements section to your project.
Include the INSpriteKit.h header file to get access to all additions.

**TODO** make available through CocoaPods

INSpriteKit is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "INSpriteKit"


## Version

Currently in work, no version released, yet!

[ChangeLog](./CHANGELOG.md)


## License

INSpriteKit is available under the MIT license. See the LICENSE file for more info.

