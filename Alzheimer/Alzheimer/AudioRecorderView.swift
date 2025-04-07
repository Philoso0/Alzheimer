//
//  AudioRecorderView.swift
//  Alzheimer
//
//  Created by Philoso on 2025/4/8.
//

import SwiftUI

struct AudioView: View {
    @StateObject var audioManager = AudioManager()
    
    var body: some View {
        VStack(spacing: 30) {
            Button(action: {
                if audioManager.isRecording {
                    audioManager.stopRecording()
                } else {
                    audioManager.startRecording()
                }
            }) {
                Text(audioManager.isRecording ? "停止录音" : "开始录音")
                    .foregroundColor(.white)
                    .padding()
                    .background(audioManager.isRecording ? Color.red : Color.blue)
                    .clipShape(Capsule())
            }
            
            Text("录音时长: \(Int(audioManager.recordingDuration)) 秒")
                .font(.headline)
            
            Button("播放录音") {
                audioManager.playRecording()
            }
            .disabled(audioManager.isRecording || !FileManager.default.fileExists(atPath: audioManager.audioFilename.path))
            .foregroundColor(.white)
            .padding()
            .background(
                (audioManager.isRecording || !FileManager.default.fileExists(atPath: audioManager.audioFilename.path))
                ? Color.gray : Color.green
            )
            .clipShape(Capsule())
        }
        .padding()
        .onAppear {
            /// ✅ 请求麦克风权限
            audioManager.requestMicrophonePermission()
        }
        .alert("需要麦克风权限", isPresented: $audioManager.showPermissionAlert) {
            Button("设置", role: .none) {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsUrl)
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("请在设置中启用麦克风权限以使用录音功能")
        }
    }
}

#Preview {
    AudioView()
}
