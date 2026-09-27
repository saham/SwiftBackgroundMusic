
import Foundation
import AVFoundation

final class MusicManager: NSObject {
    static let shared = MusicManager()
    static let defaultBackgroundVolume: Float = 1.0
    private var backgroundPlayer = AVAudioPlayer()
    private var activeSoundEffectPlayers: [AVAudioPlayer] = []

    private override init() {
        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to configure audio session: \(error)")
            }
        }
    }

    func PlaySoundEffect(music: Music, loop: Int = 0, completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard !music.FileName.isEmpty else {
            DispatchQueue.main.async {
                self.activeSoundEffectPlayers.forEach { $0.stop() }
                self.activeSoundEffectPlayers.removeAll()
            }
            return
        }

        guard let path = Bundle.main.path(forResource: music.FileName, ofType: music.Extension) else {
            completion(nil)
            return
        }
        let url = URL(fileURLWithPath: path)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 1.0
                player.numberOfLoops = loop
                player.delegate = self
                player.prepareToPlay()

                DispatchQueue.main.async {
                    self.activeSoundEffectPlayers.append(player)
                    player.play()
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    func PlayBackground(music: Music, volume: Float = MusicManager.defaultBackgroundVolume, loop: Int = -1, completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard !music.FileName.isEmpty else {
            DispatchQueue.main.async {
                self.backgroundPlayer.stop()
            }
            return
        }

        guard let path = Bundle.main.path(forResource: music.FileName, ofType: music.Extension) else {
            completion(nil)
            return
        }
        let url = URL(fileURLWithPath: path)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = volume
                player.numberOfLoops = loop
                player.prepareToPlay()

                DispatchQueue.main.async {
                    self.backgroundPlayer = player
                    self.backgroundPlayer.play()
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    func setBackgroundVolume(_ volume: Float) {
        DispatchQueue.main.async {
            self.backgroundPlayer.volume = volume
        }
    }

    func stopBackground() {
        DispatchQueue.main.async {
            self.backgroundPlayer.stop()
        }
    }

    func stopAllSoundEffects() {
        DispatchQueue.main.async {
            self.activeSoundEffectPlayers.forEach { $0.stop() }
            self.activeSoundEffectPlayers.removeAll()
        }
    }
}

extension MusicManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.activeSoundEffectPlayers.removeAll { $0 === player }
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.activeSoundEffectPlayers.removeAll { $0 === player }
        }
    }
}
