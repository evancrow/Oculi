//
//  SoundEffectHelper.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/6/22.
//

import AVFoundation

enum AudioFiles: String {
    case onAction = "OnAction"
    case onBlink = "OnBlink"
    case onComplete = "OnComplete"
}

class SoundEffectHelper: NSObject, ObservableObject {
    static let shared  = SoundEffectHelper()
    
    /// Controls wether effects should be played when a user interaction event occurs.
    @Published public var shouldPlaySoundEffects = true
    private var players: [AVAudioPlayer] = []
    
    public func playAudio(for event: AudioFiles) {
        guard shouldPlaySoundEffects else {
            return
        }
        
        playAudio(filename: event.rawValue)
    }
    
    private func playAudio(filename: String) {
       guard let path = Bundle.main.path(forResource: filename, ofType: "wav") else {
            print("Failed to find path for file: \(filename)")
            return
        }
        
        let url = URL(fileURLWithPath: path)

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
            player.delegate = self
            
            players.append(player)
        } catch {
            print("Unable to load AVFile: ", filename)
        }
    }
}

extension SoundEffectHelper: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        players.removeAll { $0 == player }
    }
}
