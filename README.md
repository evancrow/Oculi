# Oculi
**Winner** - WWDC22 Swift Student Challenge

Oculi is a revolutionary new framework that adds an easy-to-use, facial navigation and interaction interface to any SwiftUI app. Oculi works by tracking the user’s face to control a cursor, watching for different styles of blinks for interaction, and listening to the user’s speech for text input.

Oculi uses the Apple frameworks AVKit, Vision, and Speech for retrieving different forms of data.

Data from the front-facing camera suite is retrieved by AVKit. This is a constant feed of frame updates, upon which each is passed to Vision for analysis.

Using Vision, Oculi converts each frame from AVKit into three different types of data on the user’s face: Quality, Landmarks, and Rectangles. Quality is how accurate the results from Vision are. Landmarks are facial features, such as your nose, mouth, and eyes. Each landmark is then broken down into information on its frame and position. Finally, Rectangles are information about the face's movement (pitch, roll, yaw). 

Oculi uses a proprietary framework to process all of the data, named Tracker. Oculi's cursor moves based on the delta of the head’s rectangle. Tracker watches for changes in the pitch (y) and yaw (x), then moves the cursor based on that difference. Tracker also identifies changes in the eye's blinking state. By looking at each eye’s landmark points, Tracker builds a frame and checks if the height is below a certain threshold. When the eye height dips below that threshold the state is updated to blinking, and vice versa.

A calibration system is used to create a consistent experience, regardless of lighting, face, and environment. Before tracking starts, Oculi asks the user to complete a calibration task, creating a baseline to compare differences with.

To provide a complete accessibility experience, Oculi uses Speech to enable voice to text. Oculi’s wrapper around Speech quickly translates the feed from the user's microphone into a String. Any object can connect to the Speech wrapper and listen to what the user is saying. As a convenience, whenever a TextField is focused, dictation is automatically enabled so all the user has to do is talk.

