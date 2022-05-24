//
//  SpeechRecognizerModel.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/11/22.
//

import AVKit
import Speech

class SpeechRecognizerModel: ObservableObject {
    @Published var transcript: [String: String] = [:]
    @Published var isListening = false
    @Published var dictationEnabled = true
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    private var activeTextFieldId: String?
    
    // MARK: - Listening Methods
    public func startListening(with textFieldId: String) {
        guard dictationEnabled else {
            return
        }
        
        self.activeTextFieldId = textFieldId
        
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
                DispatchQueue.main.async {
                    self.reset(with: textFieldId)
                }
            }
        }
    }
    
    public func stopListening(with textFieldId: String) {
        reset(with: textFieldId)
    }
    
    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
            
            DispatchQueue.main.async {
                self.reset(with: nil, force: true)
            }
        }
        
        if let result = result {
            speak(result.bestTranscription.formattedString)
        }
    }
    
    private func speak(_ message: String) {
        guard let activeTextFieldId = activeTextFieldId else {
            return
        }

        DispatchQueue.main.async {
            self.transcript[activeTextFieldId] = message
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
    
    private func reset(with textFieldId: String?, force: Bool = false) {
        guard activeTextFieldId == textFieldId || force else {
            return
        }
        
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
        activeTextFieldId = nil
        isListening = false
    }
    
    // MARK: - init
    init() {
        recognizer = SFSpeechRecognizer()
        Self.setupPermissions()
    }
    
    static func setupPermissions() {
        PermissionModel.shared.getPermissionState(permission: .microphone) { permissionState in
            guard permissionState == .authorized else {
                return
            }
            
            PermissionModel.shared.getPermissionState(permission: .speechRecognition) { _ in }
        }
    }
}
