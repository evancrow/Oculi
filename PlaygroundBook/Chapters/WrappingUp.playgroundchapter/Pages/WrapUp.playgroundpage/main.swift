/*:
 # Sandbox Demo
 Congrats! You’ve learned all the basics of Oculi, though you’ve only scratched the surface of this powerful tool. For this final demo there are new objects to try using your new skills on.


 ## What Are You Waiting For?
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
