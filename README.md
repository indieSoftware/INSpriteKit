# INSpriteKit

[![CocoaDocs](http://cocoapod-badges.herokuapp.com/v/INSpriteKit/badge.png)](http://cocoadocs.org/docsets/INSpriteKit)

INSpriteKit adds some functionality to use with Sprite Kit.
This library is designed prior for iOS, but may also be used with OS X. On OS X mouse events (especially left mouse button clicks) are interpreted as touches.


## Features

### INSKView: A SKView replacement for a better touch delivery
- Replaces Sprite Kit's touch delivery system with its own to workaround some touch detection bugs in Sprite Kit:
  - Respect a SKNode's `userInteractionEnabled` property.
  - Use a sprite node's frame instead of an extended bounding box with all children inside.
  - Use the visual representation of a sprite node even when rotated and not the extended frame.
- SKNodes may use `touchPriority` to get touches even when not on top of all other nodes.
- Add global touch observing nodes which get informed about touch events regardless of their position and visibility state. Nodes may also get touches this way even when not on the scene tree.
- Support the right mouse button in a Sprite Kit scene on OS X per default with the option to use AppKit's default behavior for context menus.

### INSKButtonNode: A UIButton adaption for Sprite Kit
- Has full support for touch and state handling.
- Set different visual representations for the states disabled, normal, highlighted, selected and selected+highlighted.
- Get called back with selectors or via delegate when the button is being pressed, released and released inside of its frame.
- Shortcut method buttonNodeWithTitle:fontSize: for creating labeled buttons in a test environment.

### INSKScrollNode: A UIScrollView adaption for Sprite Kit
- Has full support for scrolling a content node into all directions.
- The scroll out behavior can be chosen from different presets.
- Paging is also supported.

### INSKTiledImageNode: A SKSpriteNode for huge sprites
- A sprite node to present images which are otherwise too huge for being used as a texture.
- Present images which are greater than 1024x1024 (respectively 2048x2048).
- Tile a huge image, save the tiles to disc, load them later and pass them to a INSKTiledImageNode instead of a single huge file.

### Math functions
- Different vector calculation methods for CGPoint and appropriate converting methods.
- Methods for scalars like `ScalarNearOther()` to determine if a CGFloat is the same as another plus minus epsilon.
- Angular conversions and calculations.

### Some categories
- SKNode
  - `insertChildOrNil:atIndex:` as a working replacement for `insertChild:atIndex:` which is buggy on iOS 7.
  - `bringToFront` and `sendToBack` for manipulating the tree order.
  - `changeParent:` replaces the node's parent and converts its position.
  - `stringifyNodeTree` creates a NSString from a node's tree for debugging purposes.
- SKSpriteNode
  - `isPointInside:` checks if a position point is inside of the sprite node's texture.
  - `sizeUnscaled` returns the sprite's non-scaled size.
- SKEmitterNode
  - `emitterLife` calculates an emitter's total life time.
  - `runActionToRemoveWhenFinished` adds an action which will remove the emitter if finished emitting.


## Examples

There are two example projects one for iOS and the other for OS X. They both use the same example scenes and tests and can be found inside of the 'Example' directory.
To run an example project run `pod install` from the project directory first (cocoapods installed required).
Then open the workspace file `INSpriteKitExample.xcworkspace` with Xcode and run the example or the tests.
The example scenes are within the 'ExampleScenes' directory, just go through them to see how to use the library.

To see the difference in behavior between INSKView and SKView just rename the skView classes' name in the Storyboard (WindowController.xib file for the OS X project) from INSKView to SKView.


## Requirements

iOS 7+ or OS X 10.9+, ARC enabled

Needs the following Frameworks:
- SpriteKit
- GLKit


## Installation

INSpriteKit is available through [CocoaPods](http://cocoapods.org), to install it simply add the following line to your Podfile:

    pod "INSpriteKit"

or clone the repo manually, add the INSpriteKit directory to your project and add the necessary frameworks mentioned in the requirements section to your project.

Include the INSpriteKit.h header file into your project to get access to all additions.

If using OS X and iOS code in the same project it may be handy to also include INSKOSBridge.h which adds some types and methods which are otherwise not available for the other OS.


## Known Bugs

### OS X touch delivery with AppKit controls over a Sprite Kit scene
On OS X there may occur a touch delivery bug when having AppKit controls over the Sprite Kit scene. Some mouse up events may be lost.

To reproduce the bug run the OS X example project and start the TouchHandlingScene. Move the mouse over the upper left corner of the AppKit button at the bottom of the scene so the mouse is also over the red button pointing to both buttons.
Pressing the left mouse button will now trigger the AppKit button and pressing the right mouse button will trigger the red Sprite Kit button.

However, when pressing and holding the left mouse button there, then pressing and holding the right mouse button and afterwards releasing the left mouse button prior the right will result in a lost event. In this case the mouse down event of the right mouse button won't be delivered to the scene, but the right mouse button up event so it will be overreleased.

Reverting the order will produce a click down event which will not be lifted. So when pressing and holding the right mouse button there, then pressing and holding the left mouse button and afterwards releasing the right mouse button prior the left will also result in a lost event. In this case the mouse up event of the right mouse button won't be delivered.

You can see the lost events by watching the little green/cyan square at the right of the buttons. When the total number of buttons pressed is negative the square will disappear and when a click is not released the size of the square won't shrink back to the normal size.

Using [NSEvent addLocalMonitorForEventsMatchingMask:handler:] for event observing instead will result in a likewise buggy behavior, because clicks on the table view's cells won't deliver the corresponding touch up events.

Any help will be appreciated, so if anybody can fix this or point me to a good direction don't hesitate to drop me a message.


## Changelog

[CHANGELOG.md](./CHANGELOG.md)


## License

INSpriteKit is available under the MIT license. See the LICENSE file for more info.

