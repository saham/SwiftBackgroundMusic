//
//  ViewController.swift
//  SwiftBackgroundMusic
//
//  Created by Saham Ghazavi on 2023-12-04.
//

import UIKit

class ViewController: UIViewController {
    var viewModel:[[Music]] = []
    var musicManager = MusicManager(NumberOfPlayers: 2)
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        musicManager.setVolume(forPlayer: 0,volume: sender.value)
    }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        musicManager.delegate = self
        viewModel = [
            [
                Music(urlStr: "https://pixabay.com/music/ambient-the-flashback-60sec-2-174160/",
                      name: "The Flashback",
                      FileName: "the-flashback_60sec-2-174160"),
                Music(urlStr: "https://pixabay.com/music/solo-guitar-ambient-classical-guitar-144998/",
                      name: "Ambient Classical Guitar",
                      FileName: "ambient-classical-guitar-144998")
            ],
            [
                Music(name: "SwitchLight" ,FileName: "switch-light-04-82204"),
                Music(name: "Coins", FileName: "coin-dropped-81172")
            ]
        ]
        tableView.delegate = self
        tableView.dataSource = self
        // The following two methods do the same thing
        /*
        musicManager.PlaySound(fileName: viewModel[0][0].FileName, extension: viewModel[0][0].Extension, playerNumber: 0, volume: 1.0, loop: -1)
        musicManager.PlaySound(music: viewModel[0][0], playerNumber: 0, volume: 1.0, loop: -1)
         */
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel[section].count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Background"
        } else {
            return "Sound Effect"
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.Name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            musicManager.PlaySound(music: model, playerNumber: 0, volume: 1.0, loop: -1)
            
            // Alternate method
            /*
            musicManager.PlaySound(fileName: model.FileName, extension: model.Extension, playerNumber: 0, volume: 1.0, loop: -1)
             */
            
        } else if indexPath.section == 1 {
            musicManager.PlaySound(music: model, playerNumber: 1, volume: 1.0, loop: 0)
            
            // Alternate method
            /*
            musicManager.PlaySound(fileName: model.FileName, extension: model.Extension, playerNumber: 1, volume: 1.0, loop: 0)
             */
        }
    }
}
extension UIViewController: MusicManagerProtocol {
    func audioPlayerDidFinishPlaying(playerNumber: Int, successfully flag: Bool) {
        print("Implement this")
    }
    
    func audioPlayerDecodeErrorDidOccur(playerNumber: Int, error: Error?) {
        print("Implement this")
    }
}
