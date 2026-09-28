import Foundation
import AVFoundation

enum Channel: Int, CaseIterable {
    case background
    case effect
    case extra
}

@MainActor
final class MusicManager {
    static let shared = MusicManager()
    static let defaultBackgroundVolume: Float = 1.0
    private var players: [AVAudioPlayer?] = Array(repeating: nil, count: Channel.allCases.count)

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    @discardableResult
    func play(_ music: Music, on channel: Channel, volume: Float = 1.0, loop: Int = 0) -> Bool {
        guard !music.FileName.isEmpty else {
            stop(channel)
            return true
        }

        guard let url = Bundle.main.url(forResource: music.FileName, withExtension: music.Extension) else {
            assertionFailure("Missing audio file: \(music.FileName)")
            print("Missing audio file: \(music.FileName)")
            return false
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.numberOfLoops = loop
            player.prepareToPlay()

            players[channel.rawValue]?.stop()
            player.play()
            players[channel.rawValue] = player
            return true
        } catch {
            print("Could not play \(music.FileName): \(error)")
            return false
        }
    }

    func setVolume(_ volume: Float, on channel: Channel) {
        players[channel.rawValue]?.volume = volume
    }

    func stop(_ channel: Channel) {
        players[channel.rawValue]?.stop()
        players[channel.rawValue] = nil
    }

    func stopAll() {
        Channel.allCases.forEach { stop($0) }
    }
}
