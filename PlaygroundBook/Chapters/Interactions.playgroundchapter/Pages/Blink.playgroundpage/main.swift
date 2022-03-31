/*:
 # Blink
 Everybody blinks. It’s just as natural as tapping your phone screen, making it perfect for interacting with your device. To tap a button with Oculi, just hover a button or another compatible object and blink twice, clearly and concisely.

 Some objects might have a different number of required blinks. Every blink compatible object will have tag attached with the number of blinks required. See below for an example:


 > // add example image


 ## Try It!
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
