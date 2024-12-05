import AVFoundation

class MusicPlayerManager {
    static let shared = MusicPlayerManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    private init() {
        setupAudioSession()
        setupPlayer()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "mood_bgm", withExtension: "mp3") else {
            print("Failed to find background music")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 无限循环
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    var playing: Bool {
        return isPlaying
    }
} 