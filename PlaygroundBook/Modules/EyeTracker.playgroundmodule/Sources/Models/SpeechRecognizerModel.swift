//
//  SpeechRecognizerModel.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/11/22.
//

import AVKit
import Speech

class SpeechRecognizerModel: ObservableObject {
    @Published var transcript: String = ""
    @Published var isListening = false
    @Published var dictationEnabled: Bool = true {
        didSet {
            if isListening && !dictationEnabled {
                stopListening()
            }
        }
    }
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    // MARK: - Listening Methods
    public func startListening() {
        guard dictationEnabled else {
            return
        }
        
        DispatchQueue(label: "Speech Recognizer Queue", qos: .background).async { [weak self] in
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                return
            }
            
            do {
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                self.task = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
                
                DispatchQueue.main.async {
                    self.isListening = true
                }
            } catch {
                self.reset()
            }
        }
    }
    
    public func stopListening() {
        reset()
    }
    
    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
            
            DispatchQueue.main.async {
                self.isListening = false
            }
        }
        
        if let result = result {
            speak(result.bestTranscription.formattedString)
        }
    }
    
    private func speak(_ message: String) {
        DispatchQueue.main.async {
            self.transcript = message
        }
    }
    
    // MARK: - Private Methods
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    private func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
        
        DispatchQueue.main.async {
            self.isListening = false
        }
    }
    
    // MARK: - init
    init() {
        recognizer = SFSpeechRecognizer()
        
        PermissionModel.shared.getPermissionState(permission: .microphone) { permissionState in
            guard permissionState == .authorized else {
                return
            }
            
            // PermissionModel.shared.getPermissionState(permission: .speechRecognition) { _ in }
        }
    }
    
    deinit {
        reset()
    }
}
