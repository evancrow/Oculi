/*:
 # Quick Actions
 Sometimes it’s nice to quickly trigger an event without having to move the cursor. Introducing: Quick Actions, the fastest way to get around. Quick Actions are context based and adapt to what you are currently doing. Using dictation? Trigger a quick action to quickly return what you said. Screen modal pop-up? Quick Action to dismiss. Take a photo, screenshot? Go home? Tap a notification? There are limitless possibilities.

 All you have to do to trigger a quick action is blink 3 times anywhere on the screen. You can identify what object is attached to a quick action by looking for a mint outline:


 > // add example image

 ## Get To It!
 To begin, open the live preview and tap Run My Code. Same as the previous page, move your head to drag the cursor over a button to interact with it using your eyes or use a Quick Action to interact effortlessly. Each object has it’s own special action, feel free to mess around and have fun!


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
