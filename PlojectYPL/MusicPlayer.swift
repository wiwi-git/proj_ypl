//
//  MusicPlayer.swift
//  PlojectYPL
//
//  Created by 위대연 on 11/26/24.
//

import Foundation
import AVFoundation
import MediaPlayer

class MusicPlayer : NSObject {
  static var shared: MusicPlayer = .init()
  
  var avPlayer: AVAudioPlayer = .init()
  var playList: PlayList = .shared
  var paused: Bool = false
  var isPlaying: Bool {
    get {
      return self.avPlayer.isPlaying
    }
  }
  
  private override init() {
    super.init()
    initPlayer()
    remoteCommandCenterSetting()
  }
  
  private func initPlayer() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      /// 이유를 모르겠다 옵션즈에 값을 넣으면 락스크린에 컨트롤바가 안생김....
//      try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try audioSession.setCategory(.playback, mode: .default, options: [])
    } catch let error as NSError {
      print("audioSession 설정 오류 : \(error.localizedDescription)")
    }
  }
  
  private func remoteCommandCenterSetting() {
    // remote control event 받기 시작
    UIApplication.shared.beginReceivingRemoteControlEvents()
    let center = MPRemoteCommandCenter.shared()
    center.playCommand.removeTarget(nil)
    center.pauseCommand.removeTarget(nil)
    center.nextTrackCommand.removeTarget(nil)
    center.previousTrackCommand.removeTarget(nil)
    
    // 제어 센터 재생버튼 누르면 발생할 이벤트를 정의합니다.
    center.playCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
      self.avPlayer.play()
      MPNowPlayingInfoCenter.default()
        .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.avPlayer.currentTime)
      // 재생 할 땐 now playing item의 rate를 1로 설정하여 시간이 흐르도록 합니다.
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
      return .success
    }
    
    // 제어 센터 pause 버튼 누르면 발생할 이벤트를 정의합니다.
    center.pauseCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
      self.avPlayer.pause()
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.avPlayer.currentTime)
      // 일시정지 할 땐 now playing item의 rate를 0으로 설정하여 시간이 흐르지 않도록 합니다.
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
      return .success
    }
    
    center.nextTrackCommand.addTarget { event in
      guard self.nextMusic() else {
        return .noSuchContent
      }
      /* TODO: ~ 뭐 해줘야 하는게 있던가? ~ */
      
      return .success
    }
    
    center.previousTrackCommand.addTarget { event in
      guard self.previousMusic() else {
        return .noSuchContent
      }
      
      return .success
    }
    
    center.playCommand.isEnabled = true
    center.pauseCommand.isEnabled = true
    center.nextTrackCommand.isEnabled = true
    center.previousTrackCommand.isEnabled = true
  }
  
  func remoteCommandInfoCenterSetting() {
    let center = MPNowPlayingInfoCenter.default()
    var nowPlayingInfo = center.nowPlayingInfo ?? [String: Any]()
    
    guard let currentMusic: MusicInfo = playList.currentMusic else {
      print("리스트에 곡이 없음")
      return
    }
    
    nowPlayingInfo[MPMediaItemPropertyTitle] = currentMusic.title
    nowPlayingInfo[MPMediaItemPropertyArtist] = currentMusic.artist
    
    if let albumCoverPage = currentMusic.artworkImage {
      nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: albumCoverPage.size, requestHandler: { size in
        return albumCoverPage
      })
    }
    
    // 콘텐츠 총 길이
    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.avPlayer.duration
    // 콘텐츠 재생 시간에 따른 progressBar 초기화
    nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
    // 콘텐츠 현재 재생시간
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.avPlayer.currentTime)
    
    center.nowPlayingInfo = nowPlayingInfo
  }
  
  
  @objc func previousMusic() -> Bool {
    guard !playList.isFirst else { return false }
    if playList.isFirst {
      return false
    }
    
    _ = playList.previus()
    let url = playList.currentMusic?.url
    guard url != nil else {
      print("play url is nil")
      return false
    }
    
    return play(url: url!)
  }
  
  @objc func nextMusic() -> Bool {
    guard !playList.isLast else { return false }
    
    _ = playList.next()
    let url = playList.currentMusic?.url
    guard url != nil else {
      print("play url is nil")
      return false
    }
    return play(url: url!)
  }
  func play() -> Bool {
    if avPlayer.isPlaying {
      // 재생 중에
      return pause()
    } else {
      var url: URL?
      if !paused {
        url = playList.currentMusic?.url
        guard url != nil else {
          print("play url is nil")
          return false
        }
      }
      return play(url: url)
    }
  }
  
  private func play(url: URL?) -> Bool{
    defer {
      remoteCommandInfoCenterSetting()
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    
    do {
      paused = false
      
      if avPlayer.isPlaying == false, paused {
        avPlayer.play()
        return true
      }
      
      guard url != nil else {
        return false
      }
      // TODO: avplayer를 재사용하려고했더니 딱히 방법이없다 AVQueuePlayer로 변경해야할거같다 그냥 처음부터 이거만 있지 왜 오디오플레이어가 따로 존재할까
      avPlayer = try AVAudioPlayer(contentsOf: url!)
      avPlayer.delegate = self
      avPlayer.prepareToPlay()
      avPlayer.play()
      
    } catch  {
      NSLog(error.localizedDescription)
      print(error.localizedDescription)
      return false
    }
    
    return true
  }
  
  private func pause() -> Bool {
    defer {
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    avPlayer.pause()
    paused = true
    return true
  }
  
  
}
extension MusicPlayer: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    _ = nextMusic()
  }
  
//  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
//    let alert = UIAlertController()
//    alert.title = "DECODE ERROR"
//    alert.message = error?.localizedDescription ?? "audioPlayerDecodeErrorDidOccur"
//    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
//    self.present(alert, animated: false)
//  }
}


