# INSpriteKit CHANGELOG

## 1.1

- Added the possibility to call changeParent: on SKNode even when a node is not in a scene
- Added ScalarNearOtherWithVariance() to the math
- Added stringifyNodeTree to SKNode+INExtension


## 1.0.2

- Fixed sendToBack in SKNode+INExtension
- Fixed insertChildOrNil:atIndex: in SKNode+INExtension
- Added another test cases in the tree manipulating test scene


## 1.0.1

- Fixed insertChildOrNil:atIndex as a replacement for the buggy insertChild:atIndex:
- Added a test scene for the tree order manipulation by bringToFront, sendToBack and insertChildOrNil:atIndex:


## 1.0.0

Initial release includes:
- INSKView: A SKView replacement for a better touch delivery
- INSKButtonNode: A UIButton adaption for Sprite Kit
- INSKScrollNode: A UIScrollView adaption for Sprite Kit
- INSKTiledImageNode: A SKSpriteNode for huge sprites
- Math functions
- Some categories
