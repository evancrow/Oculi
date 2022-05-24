import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: EyeTrackerModel
    @EnvironmentObject var interactionManager: InteractionManager
    
    @ObservedObject var soundEffectHelper: SoundEffectHelper = SoundEffectHelper.shared
    
    @State var showWelcomeView = true
    @State var enableStartTrackingQuickAction = false
    
    public var body: some View {
        VStack {
            VStack {
                HStack(alignment: .top) {
                    Spacer()
                    
                    BlinkButton(name: "toggle-sound-effects") {
                        soundEffectHelper.shouldPlaySoundEffects.toggle()
                    } label: {
                        Text(soundEffectHelper.shouldPlaySoundEffects ? "disable sound fx" : "allow sound fx")
                    }
                    
                    BlinkButton(name: "toggle-tracking-state") {
                        model.toggleTrackingState()
                    } label: {
                        Text(model.isTracking ? "stop tracking" : "start tracking")
                    }.disabled(!model.blinkingHasBeenCalibrated)

                    StatsView()
                }.padding(.top)
            }
            
            ZStack {
                if showWelcomeView {
                    WelcomeView {
                        withAnimation {
                            showWelcomeView = false
                            
                            if !model.isTracking {
                                enableStartTrackingQuickAction = true
                            }
                        }
                    }.frame(maxWidth: 700, maxHeight: 750)
                } else {
                    DemoView()
                }
                
                if model.showBlinkingCalibrationView { 
                    Color(uiColor: .systemBackground)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    EyeBlinkingCalibrationView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(EyeTrackerModel())
            .environmentObject(InteractionManager())
            .environmentObject(GeometryProxyValue())
    }
}
