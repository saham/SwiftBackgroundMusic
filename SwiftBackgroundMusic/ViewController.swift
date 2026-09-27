import UIKit

class ViewController: UIViewController {
    private var viewModel: [[Music]] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let volumeSlider = UISlider()
    private let volumeLabel = UILabel()
    private let nowPlayingLabel = UILabel()

    private var selectedBackgroundIndexPath: IndexPath?
    private var recentlyTappedEffectIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sounds"
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

        setUpNowPlayingLabel()
        setUpVolumeSlider()
        setUpTableView()
    }
    private func setUpNowPlayingLabel() {
        nowPlayingLabel.font = .preferredFont(forTextStyle: .footnote)
        nowPlayingLabel.textColor = .secondaryLabel
        nowPlayingLabel.text = "Nothing playing"
        nowPlayingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nowPlayingLabel)

        NSLayoutConstraint.activate([
            nowPlayingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            nowPlayingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nowPlayingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setUpVolumeSlider() {
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = MusicManager.defaultBackgroundVolume
        volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false

        let speakerIcon = UIImageView(image: UIImage(systemName: "speaker.wave.2.fill"))
        speakerIcon.tintColor = .secondaryLabel
        speakerIcon.translatesAutoresizingMaskIntoConstraints = false

        volumeLabel.font = .preferredFont(forTextStyle: .caption1)
        volumeLabel.textColor = .secondaryLabel
        volumeLabel.textAlignment = .right
        volumeLabel.text = percentString(for: volumeSlider.value)
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [speakerIcon, volumeSlider, volumeLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: nowPlayingLabel.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            volumeLabel.widthAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: volumeSlider.superview!.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    @objc private func volumeChanged(_ sender: UISlider) {
        MusicManager.shared.setBackgroundVolume(sender.value)
        volumeLabel.text = percentString(for: sender.value)
    }

    private func percentString(for value: Float) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private func updateNowPlayingLabel(name: String) {
        nowPlayingLabel.text = "Now playing: \(name)"
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
        cell.imageView?.image = UIImage(
            systemName: indexPath.section == 0 ? "music.note" : "speaker.wave.1"
        )
        cell.imageView?.tintColor = .secondaryLabel

        if indexPath.section == 0 {
            cell.accessoryType = (indexPath == selectedBackgroundIndexPath) ? .checkmark : .none
        } else {
            // Brief "just played" indicator for the tapped sound effect row.
            cell.accessoryType = (indexPath == recentlyTappedEffectIndexPath) ? .checkmark : .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = viewModel[indexPath.section][indexPath.row]

        if indexPath.section == 0 {
            let previous = selectedBackgroundIndexPath
            selectedBackgroundIndexPath = indexPath
            MusicManager.shared.PlayBackground(music: model, loop: -1)
            updateNowPlayingLabel(name: model.Name)

            var rowsToReload = [indexPath]
            if let previous, previous != indexPath {
                rowsToReload.append(previous)
            }
            tableView.reloadRows(at: rowsToReload, with: .automatic)
        } else {
            MusicManager.shared.PlaySoundEffect(music: model, loop: 0)

            let previous = recentlyTappedEffectIndexPath
            recentlyTappedEffectIndexPath = indexPath
            var rowsToReload = [indexPath]
            if let previous, previous != indexPath {
                rowsToReload.append(previous)
            }
            tableView.reloadRows(at: rowsToReload, with: .none)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self, self.recentlyTappedEffectIndexPath == indexPath else { return }
                self.recentlyTappedEffectIndexPath = nil
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
}
