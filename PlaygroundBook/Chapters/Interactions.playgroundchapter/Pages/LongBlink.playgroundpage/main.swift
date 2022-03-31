/*:
 # Long Blink
 Just as long presses can be used as secondary actions, long blinks act in the same way. Triggering a long blink works the same way as a blink action, just hover over an intractable object and blink for the duration indicated (always in seconds).

 An identifier is always attached to an object, notice for long blinks the eye is filled in (while blinks are just an outline):


 > // add example image


 ## Test It Out!
 To begin, open the live preview and tap Run My Code. Same as the previous page, move your head to drag the cursor over a button to interact with it using your eyes. Each button has it’s own special action, feel free to mess around and have fun!


 ## Customizing.
 Want to change the speed of the cursor? Try adjusting it below:
 
*/
//#-editable-code
let speedX: CGFloat = 12
let speedY: CGFloat = 15
//#-end-editable-code
//#-hidden-code

import CoreGraphics
import EyeTracker

UXDefaults.movmentMultiplier = CGSize(width: speedX, height: speedY)
//#-end-hidden-code
//: When you're ready, [go to the next page](@next).
