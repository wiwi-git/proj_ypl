//
//  viewController.swift
//  PlojectYPL
//
//  Created by 위대연 on 8/10/24.
//

import UIKit
import AVFoundation
import MediaPlayer

extension NSNotification.Name {
  static let changedContInfo = NSNotification.Name(rawValue: "changed_cont_info")
}

class ContBarViewController: UIViewController {
  let buttonSize: CGSize
  let buttonPadding: CGFloat
  let buttonSpace: CGFloat
  
  lazy var contBarView: ContBarView = {
    let contBarView: ContBarView = .init(frame: .zero, buttonSize: buttonSize, buttonPadding: buttonPadding, buttonSpace: buttonSpace)
    contBarView.preButton.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
    contBarView.playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
    contBarView.nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
    return contBarView
  }()
  
  var paused: Bool = false
  
  var isRemoteCommandCenteSetup: Bool = false
  
  lazy var avPlayer: AVAudioPlayer = {
    let player = AVAudioPlayer()
    player.delegate = self
    player.numberOfLoops = 0
    return player
  }()
  
  var playList: PlayList = .shared
  
  init(buttonSize: CGSize, buttonPadding: CGFloat = 8, buttonSpace: CGFloat = 20) {
    self.buttonSize = buttonSize
    self.buttonPadding = buttonPadding
    self.buttonSpace = buttonSpace
    super.init(nibName: nil, bundle: nil)
  }
  
  // 스토리보드 생성은 패스
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    print("ContBarVC deinit endReceivingRemoteControlEvents")
    UIApplication.shared.endReceivingRemoteControlEvents()
  }
  
  override func viewDidLoad() {
    self.view.addSubview(contBarView)
    contBarView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contBarView.topAnchor.constraint(equalTo: self.view.topAnchor),
      contBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      contBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      contBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
    ])
    
    if !isRemoteCommandCenteSetup {
//      mpRemoteCommandCenteSetting()
      do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)
      } catch {
        NSLog("error: Failed to set audio session: \(error)")
        print("error: Failed to set audio session: \(error)")
      }
      remoteCommandCenterSetting()
      remoteCommandInfoCenterSetting()
      
      isRemoteCommandCenteSetup = true
    }
  }
  
  @objc func playButtonAction() -> Bool {
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
  
  @objc func previousAction() -> Bool {
    _ = playList.previus()
    let url = playList.currentMusic?.url
    guard url != nil else {
      print("play url is nil")
      return false
    }
    
    return play(url: url!)
  }
  
  @objc func nextAction() -> Bool {
    print("called nextAction")
    _ = playList.next()
    let url = playList.currentMusic?.url
    guard url != nil else {
      print("play url is nil")
      return false
    }
    return play(url: url!)
  }
  
  private func play(url: URL?) -> Bool{
    defer {
      
      contBarView.setPlayIcon(isPlay: avPlayer.isPlaying)
      
      remoteCommandInfoCenterSetting()
      
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    
    do {
      //      try AVAudioSession.sharedInstance().setActive(true)
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
      contBarView.setPlayIcon(isPlay: avPlayer.isPlaying)
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    //    do {
    //      avPlayer.pause()
    //      try AVAudioSession.sharedInstance().setActive(false)
    //      paused = true
    //    } catch {
    //      NSLog("error: \(error)")
    //      return false
    //    }
    avPlayer.pause()
    paused = true
    return true
  }
  
  func remoteCommandCenterSetting() {
    // remote control event 받기 시작
    UIApplication.shared.beginReceivingRemoteControlEvents()
    let center = MPRemoteCommandCenter.shared()
    center.playCommand.removeTarget(nil)
    center.pauseCommand.removeTarget(nil)
    
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
      MPNowPlayingInfoCenter.default()
        .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.avPlayer.currentTime)
      // 일시정지 할 땐 now playing item의 rate를 0으로 설정하여 시간이 흐르지 않도록 합니다.
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
      return .success
    }
    center.playCommand.isEnabled = true
    center.pauseCommand.isEnabled = true
  }
  func remoteCommandInfoCenterSetting() {
      let center = MPNowPlayingInfoCenter.default()
      var nowPlayingInfo = center.nowPlayingInfo ?? [String: Any]()
      
      nowPlayingInfo[MPMediaItemPropertyTitle] = "콘텐츠 제목"
      nowPlayingInfo[MPMediaItemPropertyArtist] = "콘텐츠 아티스트"
      if let albumCoverPage = UIImage(named: "Pingu") {
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
//  func mpRemoteCommandCenteSetting() {
//    print("call mpRemoteCommandCenteSetting")
//    defer {
//      isRemoteCommandCenteSetup = true
//    }
//    
//    guard isRemoteCommandCenteSetup == false else {
//      print("이미 설정한 내용")
//      return
//    }
//    
//    UIApplication.shared.beginReceivingRemoteControlEvents()
//    
//    let center = MPRemoteCommandCenter.shared()
//    
//    center.skipForwardCommand.isEnabled = true
//    center.skipBackwardCommand.isEnabled = true
//    
//    center.playCommand.addTarget { [weak self] _ in
//      return self?.playButtonAction() ?? false ? .success : .commandFailed
//    }
//    center.pauseCommand.addTarget { [weak self] _ in
//      return self?.pause() ?? false ? .success : .commandFailed
//    }
//    center.skipForwardCommand.addTarget { [weak self] _ in
//      return self?.nextAction() ?? false ? .success : .commandFailed
//    }
//    center.skipBackwardCommand.addTarget { [weak self] _ in
//      return self?.previousAction() ?? false ? .success : .commandFailed
//    }
//  }
}


extension ContBarViewController: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    print("audioPlayerDidFinishPlaying > successfully :\(flag)")
    _ = nextAction()
  }
  
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
    let alert = UIAlertController()
    alert.title = "DECODE ERROR"
    alert.message = error?.localizedDescription ?? "audioPlayerDecodeErrorDidOccur"
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    self.present(alert, animated: false)
  }
}
