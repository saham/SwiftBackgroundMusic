//
//  MusicManager.swift
//  MasterMind
//
//  Created by Saham Ghazavi on 2023-11-21.
//

import Foundation
import AVFoundation
protocol MusicManagerProtocol {
    func audioPlayerDidFinishPlaying(playerNumber:Int,successfully flag: Bool)
    func audioPlayerDecodeErrorDidOccur(playerNumber:Int,error: Error?)
}
class MusicManager:NSObject {
    internal init(NumberOfPlayers: Int = 1) {
        self.NumberOfPlayers =  NumberOfPlayers < 1 ? 1 : NumberOfPlayers
        self.Players = [AVAudioPlayer](repeating: AVAudioPlayer(), count: NumberOfPlayers)
        
    }
    
    var Players:[AVAudioPlayer] = []
    var NumberOfPlayers:Int
    var delegate:MusicManagerProtocol?
    var currentPlayerNumber:Int = 0
    func PlaySound(fileName:String,extension ext:String, playerNumber:Int, volume:Float,loop:Int, completion: ((Error?) -> Void)? = nil) {
        guard (playerNumber >= 0 && playerNumber < self.Players.count) else {return}
        guard !fileName.isEmpty else {
            Players[playerNumber].stop()
            return
        }
        
        if let path = Bundle.main.path(forResource: fileName, ofType: ext) {
            let AssortedMusics = URL(fileURLWithPath: path)
            do{
                Players[playerNumber] = try AVAudioPlayer(contentsOf: AssortedMusics)
                Players[playerNumber].delegate = self
                currentPlayerNumber = playerNumber
                Players[playerNumber].volume = volume
                Players[playerNumber].prepareToPlay()
                Players[playerNumber].numberOfLoops = loop
                if volume > 0.0 {
                    Players[playerNumber].play()
                } else {
                    Players[playerNumber].stop()
                }
            } catch {
                completion?(error)
            }
        }
    }
    
    func PlaySound(music:Music, playerNumber:Int, volume:Float,loop:Int, completion: ((Error?) -> Void)? = nil) {
        guard (playerNumber >= 0 && playerNumber < self.Players.count) else {return}
        guard !music.FileName.isEmpty else {
            Players[playerNumber].stop()
            return
        }
        if let path = Bundle.main.path(forResource: music.FileName, ofType: music.Extension) {
            let AssortedMusics = URL(fileURLWithPath: path)
            do{
                Players[playerNumber] = try AVAudioPlayer(contentsOf: AssortedMusics)
                Players[playerNumber].delegate = self
                currentPlayerNumber = playerNumber
                Players[playerNumber].volume = volume
                Players[playerNumber].prepareToPlay()
                Players[playerNumber].numberOfLoops = loop
                if volume > 0.0 {
                    Players[playerNumber].play()
                } else {
                    Players[playerNumber].stop()
                }
            } catch {
             completion?(error)
            }
        }
    }
    
    func setVolume(forPlayer playerNumber:Int,volume:Float) {
        guard (playerNumber >= 0 && playerNumber < self.Players.count) else {return}
        if volume == 0 {
            Players[playerNumber].stop()
        } else {
            Players[playerNumber].play()
            Players[playerNumber].volume = volume
        }
    }
}
extension MusicManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.audioPlayerDidFinishPlaying(playerNumber: currentPlayerNumber, successfully: flag)
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        delegate?.audioPlayerDecodeErrorDidOccur(playerNumber: currentPlayerNumber, error: error)
    }
}
