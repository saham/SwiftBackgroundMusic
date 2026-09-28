what about read.me 
# SwiftBackgroundMusic
You can add background music and sound effects to any iOS app

You just add music file(s) to the project and play them anytime you want

To play two or more musics cuncurrently,play each on a separate player.

MusicManager initializer takes one parameter and that is number of players.

Feel free to update the code to add/remove players as it may fit to your project

The README is clear about the idea, but it's short and has a few rough spots.

Fixes

"cuncurrently" should be "concurrently", and "musics" should be "music" (or "tracks").
"play each on a separate player" doesn't say how. A short code example fixes that.
It describes the initializer as taking a number of players, but you settled on channels indexed by an enum (background, effect, extra). If that's what the code does now, the README should describe the enum, since that's how people will add players.
It's missing requirements (iOS version, Swift version), how to add audio files to the target, and a license.

Suggested rewrite

markdown
# SwiftBackgroundMusic

Add background music and sound effects to any iOS app, using Swift and AVAudioPlayer.

Drop your audio files into the project and play them whenever you want. You can play
background music and sound effects at the same time, because each one runs on its own player.

## Features
- Background music and sound effects playing concurrently
- One player per channel, so sounds don't cut each other off
- Easy to add channels for your own needs
- Demo app with a table view of sample music and effects

## Requirements
- iOS 13+ / Swift 5+
- Audio files added to your app target (Copy Bundle Resources)

## Usage
1. Copy `MusicManager.swift` into your project.
2. Add your audio files to the project.
3. Play a track on a channel:

    // Adjust to match your actual API
    MusicManager.shared.play("song.mp3", on: .background)
    MusicManager.shared.play("click.wav", on: .effect)

## Adding more players
Each player is a case in the `Channel` enum. Add a case (e.g. `.voiceover`) and
`MusicManager` creates a player for it. Playing two sounds on the same channel
replaces the first one, so use separate channels for anything that should overlap.

## Demo
Run the project to see a table view listing background tracks and sound effects.
Tap a background track and then a sound effect to hear both together.



You can either use the Music class or just simply pass File name and Extension of the music file to a player in MusicManager and play it
<img width="1206" height="2622" alt="Screenshot iPhone 17 2026-09-27 at 20 17 14" src="https://github.com/user-attachments/assets/87907e67-0fd1-4706-a657-1cee2d80633c" />
