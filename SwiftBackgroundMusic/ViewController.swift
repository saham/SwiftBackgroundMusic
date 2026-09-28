import UIKit

// MARK: - Gradient header

final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setColors(_ colors: [UIColor], animated: Bool) {
        let cgColors = colors.map { $0.resolvedColor(with: traitCollection).cgColor }
        if animated {
            let anim = CABasicAnimation(keyPath: "colors")
            anim.fromValue = gradientLayer.colors
            anim.toValue = cgColors
            anim.duration = 0.4
            gradientLayer.add(anim, forKey: "colors")
        }
        gradientLayer.colors = cgColors
    }
}

// MARK: - Cell

final class MusicCell: UITableViewCell {
    static let reuseID = "MusicCell"

    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let playingView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildLayout() {
        iconContainer.layer.cornerRadius = 12
        iconContainer.layer.cornerCurve = .continuous
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        playingView.image = UIImage(systemName: "waveform")
        playingView.contentMode = .scaleAspectFit
        playingView.translatesAutoresizingMaskIntoConstraints = false
        playingView.isHidden = true

        contentView.addSubview(iconContainer)
        contentView.addSubview(textStack)
        contentView.addSubview(playingView)

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            iconContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: playingView.leadingAnchor, constant: -8),

            playingView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            playingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playingView.widthAnchor.constraint(equalToConstant: 24),
            playingView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(title: String, subtitle: String, symbol: String, color: UIColor, isPlaying: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconView.image = UIImage(systemName: symbol)
        iconContainer.backgroundColor = color
        playingView.tintColor = color
        playingView.isHidden = !isPlaying

        if #available(iOS 17.0, *) {
            if isPlaying {
                playingView.addSymbolEffect(.variableColor.iterative.reversing)
            } else {
                playingView.removeAllSymbolEffects()
            }
        }
    }

    /// Quick "pop" so a sound-effect tap feels responsive.
    func pulse() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut]) {
            self.iconContainer.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        } completion: { _ in
            UIView.animate(withDuration: 0.35, delay: 0,
                           usingSpringWithDamping: 0.45, initialSpringVelocity: 8) {
                self.iconContainer.transform = .identity
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconContainer.transform = .identity
    }
}

// MARK: - View controller

class ViewController: UIViewController {
    private var viewModel: [[Music]] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let headerView = GradientView()
    private let nowPlayingCaption = UILabel()
    private let nowPlayingLabel = UILabel()
    private let volumeSlider = UISlider()
    private let volumeLabel = UILabel()

    private var selectedBackgroundIndexPath: IndexPath?

    private let backgroundColors: [UIColor] = [.systemIndigo, .systemPink, .systemTeal]
    private let effectColors: [UIColor] = [.systemOrange, .systemGreen, .systemYellow]
    private let idleGradient: [UIColor] = [.systemGray, .systemGray2]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sounds"
        view.backgroundColor = .systemGroupedBackground

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

        setUpHeader()
        setUpTableView()
    }

    // MARK: Colors

    private func color(for indexPath: IndexPath) -> UIColor {
        let palette = indexPath.section == 0 ? backgroundColors : effectColors
        return palette[indexPath.row % palette.count]
    }

    // MARK: Setup

    private func setUpHeader() {
        headerView.setColors(idleGradient, animated: false)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        nowPlayingCaption.text = "NOW PLAYING"
        nowPlayingCaption.font = .systemFont(ofSize: 11, weight: .semibold)
        nowPlayingCaption.textColor = UIColor.white.withAlphaComponent(0.75)

        nowPlayingLabel.text = "Pick a background track"
        nowPlayingLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nowPlayingLabel.textColor = .white
        nowPlayingLabel.numberOfLines = 2

        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = MusicManager.defaultBackgroundVolume
        volumeSlider.minimumTrackTintColor = .white
        volumeSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        volumeSlider.thumbTintColor = .white
        volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)

        let speakerIcon = UIImageView(image: UIImage(systemName: "speaker.wave.2.fill"))
        speakerIcon.tintColor = .white
        speakerIcon.setContentHuggingPriority(.required, for: .horizontal)

        volumeLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        volumeLabel.textColor = .white
        volumeLabel.textAlignment = .right
        volumeLabel.text = percentString(for: volumeSlider.value)
        volumeLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true

        let sliderRow = UIStackView(arrangedSubviews: [speakerIcon, volumeSlider, volumeLabel])
        sliderRow.axis = .horizontal
        sliderRow.spacing = 10
        sliderRow.alignment = .center

        let content = UIStackView(arrangedSubviews: [nowPlayingCaption, nowPlayingLabel, sliderRow])
        content.axis = .vertical
        content.spacing = 6
        content.setCustomSpacing(16, after: nowPlayingLabel)
        content.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(content)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            content.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 18),
            content.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),
            content.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
        ])
    }

    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(MusicCell.self, forCellReuseIdentifier: MusicCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Actions

    @objc private func volumeChanged(_ sender: UISlider) {
        MusicManager.shared.setBackgroundVolume(sender.value)
        volumeLabel.text = percentString(for: sender.value)
    }

    private func percentString(for value: Float) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private func showNowPlaying(name: String, accent: UIColor) {
        nowPlayingLabel.text = name
        headerView.setColors([accent, .systemPurple], animated: true)
    }
}

// MARK: - Table

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Background" : "Sound Effect"
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        header.textLabel?.textColor = section == 0 ? .systemIndigo : .systemOrange
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MusicCell.reuseID, for: indexPath) as! MusicCell
        let model = viewModel[indexPath.section][indexPath.row]
        let isBackground = indexPath.section == 0

        cell.configure(
            title: model.Name,
            subtitle: isBackground ? "Loops until you pick another" : "Tap to play",
            symbol: isBackground ? "music.note" : "sparkles",
            color: color(for: indexPath),
            isPlaying: isBackground && indexPath == selectedBackgroundIndexPath
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = viewModel[indexPath.section][indexPath.row]

        if indexPath.section == 0 {
            // Background music: replaces whatever is currently playing.
            let previous = selectedBackgroundIndexPath
            selectedBackgroundIndexPath = indexPath
            MusicManager.shared.PlayBackground(music: model, loop: -1)
            showNowPlaying(name: model.Name, accent: color(for: indexPath))

            var rows = [indexPath]
            if let previous, previous != indexPath { rows.append(previous) }
            tableView.reloadRows(at: rows, with: .none)
        } else {
            // Sound effect: plays once, can overlap with background and other effects.
            MusicManager.shared.PlaySoundEffect(music: model, loop: 0)
            (tableView.cellForRow(at: indexPath) as? MusicCell)?.pulse()
        }
    }
}
