import SwiftUI
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var showPermissionAlert = false
    @Published var recordingDuration: TimeInterval = 0
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("recording.wav")
    
    private var timer: Timer?

    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("音频会话设置失败: \(error.localizedDescription)")
        }
    }
    
    func requestMicrophonePermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                self?.handlePermissionResult(granted: granted)
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                self?.handlePermissionResult(granted: granted)
            }
        }
    }
    
    private func handlePermissionResult(granted: Bool) {
        DispatchQueue.main.async {
            if !granted {
                self.showPermissionAlert = true
            }
        }
    }
    
    func startRecording() {
        guard hasMicrophonePermission() else {
            showPermissionAlert = true
            return
        }
        
        guard audioRecorder?.isRecording != true else { return }
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
            startTimer()
            print("录音开始")
        } catch {
            print("录音启动失败: \(error.localizedDescription)")
            isRecording = false
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()
        print("录音结束")
    }
    
    func playRecording() {
        guard FileManager.default.fileExists(atPath: audioFilename.path) else {
            print("录音文件不存在")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            print("播放中...")
        } catch {
            print("播放失败: \(error.localizedDescription)")
            isPlaying = false
        }
    }
    
    private func hasMicrophonePermission() -> Bool {
           if #available(iOS 17.0, *) {
               return AVAudioApplication.shared.recordPermission == .granted
           } else {
               return AVAudioSession.sharedInstance().recordPermission == .granted
           }
       }
    
    private func startTimer() {
        recordingDuration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.recordingDuration += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
