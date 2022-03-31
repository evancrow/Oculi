/*:
 # Welcome!
 Today, 1 in 50 people suffer from paralysis. For some of them, interacting with technology is something close to impossible. All of that is about to change.

 Introducing Oculi, the first program you can control using only your face and eyes. With Oculi, you move your head up and down and side to side, just like a mouse or dragging your finger to move a cursor. Oculi also makes interacting with common elements a breeze all you have to do is blink.

 There are three types of element interactions:
 - 👁 **Blinks**: Similar to tapping the screen, blink clearly and concisely
 - 🔄 **Long blinks**: Similar to pressing the screen, blink and hold for a duration (seconds)
 - 💨 **Quick actions**: Context-based actions that can be triggered by blinking 3 times anywhere

 Don't worry, you'll learn about each of these interactions later in the playground.

 
 ## Setting Up.
 To get started, open the live preview and tap Run My Code.  Once the view loads, try moving your head (while keeping your device in the same place) to move the cursor around.

  
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
