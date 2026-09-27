import UIKit

class ViewController: UIViewController {
    private var viewModel: [[Music]] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let volumeSlider = UISlider()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
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
                Music(name: "SwitchLight", FileName: "switch-light-04-82204"),
                Music(name: "Coins", FileName: "coin-dropped-81172")
            ]
        ]

        setUpVolumeSlider()
        setUpTableView()
    }

    private func setUpVolumeSlider() {
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = MusicManager.defaultBackgroundVolume
        volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(volumeSlider)

        NSLayoutConstraint.activate([
            volumeSlider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            volumeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func volumeChanged(_ sender: UISlider) {
        MusicManager.shared.setBackgroundVolume(sender.value)
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
        section == 0 ? "Background" : "Sound Effect"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.Name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = viewModel[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            // Background music: replaces whatever is currently playing.
            MusicManager.shared.PlayBackground(music: model, loop: -1)
        } else {
            // Sound effect: plays once, can overlap with background music
            // and with other sound effects.
            MusicManager.shared.PlaySoundEffect(music: model, loop: 0)
        }
    }
}
