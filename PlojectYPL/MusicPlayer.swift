//
//  MusicPlayer.swift
//  PlojectYPL
//
//  Created by 위대연 on 11/26/24.
//

import Foundation
import AVFoundation
import MediaPlayer
import SwiftUI

/// 0이 노말, 루프, 원루프 순 ++
enum PlayMode: Int, CaseIterable {
  // normal > 음악목록 1회씩 재생,loop > 음악목록 끝나면 처음으로 가서 재생, one_loop > 현 재생 곡 계속 반복
  // 전체 반복이 그냥 loop로 해놔도 되나?
  case normal = 0, loop, one_loop
}

class MusicPlayer : NSObject, ObservableObject {
  @Published var currentTime: TimeInterval = 0
  @Published var duration: TimeInterval = 0
  @Published var isPlaying: Bool = false
  @Published var musicData: [MusicInfo] = []
  @Published private(set) var playMode: PlayMode = .normal
  
  var avPlayer: AVAudioPlayer = .init()
  var paused: Bool = false
  private var updateTimer: Timer?
  
  
  // 데이터가 비었을땐 false를 반환
  var isFirst: Bool {
    get {
      if musicData.isEmpty { return false }
      return currentIndex == 0
    }
  }
  
  // 데이터가 비었을땐 false를 반환
  var isLast: Bool {
    get {
      if musicData.isEmpty { return false }
      return currentIndex == musicData.count - 1
    }
  }
  
  @Published private(set) var currentIndex: Int = 0
  
//  var currentIndex: Int {
//    get {
//      return index
//    }
//  }
//  
//  private var index: Int = 0
  
  var currentMusic: MusicInfo? {
    get {
      guard currentIndex < musicData.count else { return nil }
      return musicData[currentIndex]
    }
  }
  
  
  override init() {
    super.init()
    initPlayer()
    remoteCommandCenterSetting()
  }
  
  func chnagePlayeMode() -> Bool {
    let oldValue: Int = self.playMode.rawValue
    let modeCount: Int = PlayMode.allCases.count
    let newValue = oldValue + 1
    
    
    if newValue < modeCount, let newMode = PlayMode(rawValue: newValue) {
      playMode = newMode
      return true
    }
    else if newValue == modeCount, let newMode = PlayMode(rawValue: 0) {
      // 노말 모드로 변경
      playMode = newMode
      return true
    }
    else {
      // 에러
      print("error: 이상한 값이 되었다? oldValue:\(oldValue), newValue\(newValue), modeCount:\(modeCount)")
      return false
    }
    
//    return false
  }
  
  // index만 변경되서 다음곡으로 넘어가는 등의 이벤트가 겹칠경우 문제가 발생할수 있다 변경하기전에 플레이를 중지시키자
  func setCurrentIndex(at new: Int) {    
    guard !musicData.isEmpty,
          new >= 0,
          new < musicData.count else { return }
    currentIndex = new
  }
  
  func loadList() { 
    
    let fileManager = FileManager.default
    let documentsUrl: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let filePath: URL = documentsUrl.appendingPathComponent("ypl_music")
    
    if !fileManager.fileExists(atPath: filePath.path) {
      do {
        try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        NSLog("error: Couldn't create document directory")
        print("error: Couldn't create document directory")
      }
    }
    
    do {
      let directoryContents: [String] = try fileManager.contentsOfDirectory(atPath: filePath.path)
      print(directoryContents)
      if directoryContents.isEmpty {
        musicData = []
        return
      }
      
      var infos: [MusicInfo] = []
      
      for item in directoryContents {
        let fileURL = filePath.appendingPathComponent(item)
        
        if fileURL.pathExtension != "mp3" {
          continue
        }
        /// TODO: 앨범자킷?
        let datum: MusicInfo = .init(title: fileURL.lastPathComponent, artist: "", url: fileURL)
        infos.append(datum)
      }
      
      self.musicData = infos
    } catch  {
      NSLog(error.localizedDescription)
      print(error.localizedDescription)
    }
    
    print("loaded urls.... count:\(self.musicData.count)")
  }
  
  /// 플레이 인덱스를 다음으로 설정 후 현재 인덱스 반환, 인덱스가 넘어갈시 0
  ///
  func next() -> Int {
    guard !musicData.isEmpty else { return -1 }
    let temp: Int = currentIndex + 1
    currentIndex = temp < musicData.count ? temp : 0
    return currentIndex
  }
  
  /// 플레이 인덱스를 이전으로 설정 후 현재 인덱스 반환, 인덱스가 0 보다 작을시 count -1으로
  func previus() -> Int {
    guard !musicData.isEmpty else { return -1 }
    let temp: Int = currentIndex - 1
    currentIndex = temp < 0 ? musicData.count - 1 : temp
    return currentIndex
  }
  
  private func initPlayer() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      /// 이유를 모르겠다 옵션즈에 값을 넣으면 락스크린에 컨트롤바가 안생김....
      //      try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try audioSession.setCategory(.playback, mode: .default, options: [])
      
      try audioSession.setActive(true)
      
    } catch let error as NSError {
      print("audioSession 설정 오류 : \(error.localizedDescription)")
    }
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleInterruption),
                                           name: AVAudioSession.interruptionNotification,
                                           object: AVAudioSession.sharedInstance())
  }
  
  @objc func handleInterruption(notification: Notification) {
    guard let userInfo = notification.userInfo,
          let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
          let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
      return
    }
    
    switch type {
    case .began:
      if self.isPlaying {
        _ = self.pause()
      }
      
    case .ended:
      // An interruption ended. Resume playback, if appropriate.
      
      guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
      
      let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
      
      if options.contains(.shouldResume) {
        // An interruption ended. Resume playback.
        _ = self.play()
      } else {
        // An interruption ended. Don't resume playback.
      }
    default:
      break
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
    center.playCommand.addTarget {[weak self] (commandEvent) -> MPRemoteCommandHandlerStatus in
      guard let self = self else { return .commandFailed }
      
      //      self.avPlayer.play()
      _ = self.play()
      
      MPNowPlayingInfoCenter.default()
        .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.avPlayer.currentTime)
      // 재생 할 땐 now playing item의 rate를 1로 설정하여 시간이 흐르도록 합니다.
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
      return .success
    }
    
    // 제어 센터 pause 버튼 누르면 발생할 이벤트를 정의합니다.
    center.pauseCommand.addTarget {[weak self] (commandEvent) -> MPRemoteCommandHandlerStatus in
      guard let self = self else { return .commandFailed }
      _ = self.pause()
      //      self.avPlayer.pause()
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.avPlayer.currentTime)
      // 일시정지 할 땐 now playing item의 rate를 0으로 설정하여 시간이 흐르지 않도록 합니다.
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
      return .success
    }
    
    center.nextTrackCommand.addTarget {[weak self] event in
      guard let self = self else { return .commandFailed }
      guard self.nextMusic() else {
        return .noSuchContent
      }
      /* TODO: ~ 뭐 해줘야 하는게 있던가? ~ */
      
      return .success
    }
    
    center.previousTrackCommand.addTarget {[weak self] event in
      guard let self = self else { return .commandFailed }
      
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
    
    guard let currentMusic: MusicInfo = currentMusic else {
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
    guard !isFirst else { return false }
    if isFirst {
      return false
    }
    
    _ = previus()
    let url =  currentMusic?.url
    guard url != nil else {
      print("play url is nil")
      return false
    }
    
    return play(url: url!)
  }
  
  // musicData가 비었거나 마지막 인덱스라면 동작하지 않도록 isLast 검사
  // + normal 일때만 라스트 검사 하기
  @objc func nextMusic() -> Bool {
    if playMode == .normal {
      guard !isLast else { return false }
    }
    
    _ = next()
//    let url = currentMusic?.url
//    guard url != nil else {
//      print("play url is nil")
//      stopUpdateTimer()
//      return false
//    }
//    
//    return play(url: url!)
    return currentMusicPlay()
  }
  
  func currentMusicPlay() -> Bool {
    let url = currentMusic?.url
    guard url != nil else {
      print("play url is nil")
      stopUpdateTimer()
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
        url = currentMusic?.url
        guard url != nil else {
          print("play url is nil")
          stopUpdateTimer()
          return false
        }
      }
      return play(url: url)
    }
  }
  // 사용자 연결은 파라미터 안받는 play로, 내가 만들었는데도 헷갈리네
  // TODO: 나중에 생각있으면 함수명좀 분리하자
  // startUpdateTimer 포함
  private func play(url: URL?) -> Bool{
    defer {
      remoteCommandInfoCenterSetting()
      // 퍼블리쉬로 상태를 받는중이라 이제 쓸모가 없을지도? 나중에 뭘 변경할지도 모르니 일단 냅둠.
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    
    do {
      // 일시정지 상태에서의 재생
      if avPlayer.isPlaying == false, paused {
        avPlayer.play()
        
        paused = false
        isPlaying = true
        duration = avPlayer.duration
        startUpdateTimer()
        return true
      }
      
      // TODO: 차라리 throw를 하는게 나을지도?
      guard url != nil else {
        stopUpdateTimer()
        isPlaying = false
        return false
      }
      
      // TODO: avplayer를 재사용하려고했더니 딱히 방법이없다 AVQueuePlayer로 변경해야할거같다 그냥 처음부터 이거만 있지 왜 오디오플레이어가 따로 존재할까
      avPlayer = try AVAudioPlayer(contentsOf: url!)
      avPlayer.delegate = self
      avPlayer.prepareToPlay()
      avPlayer.play()
      
      startUpdateTimer()
      duration = avPlayer.duration
      paused = false
      isPlaying = true
      
    } catch  {
      NSLog(error.localizedDescription)
      print(error.localizedDescription)
      return false
    }
    
    return true
  }
  
  // 이걸 왜 private로 잡아놨는지 기억이 안난다 우선 변경
  func pause() -> Bool {
    defer {
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    avPlayer.pause()
    paused = true
    isPlaying = false
    stopUpdateTimer()
    
    return true
  }
  
  func stop() -> Bool {
    defer {
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    avPlayer.stop()
    paused = false
    isPlaying = false
    stopUpdateTimer()
    
    return true
  }
  
  private func startUpdateTimer() {
    stopUpdateTimer()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
      guard let self = self else{ return }
      self.currentTime = avPlayer.currentTime
    }
  }
  
  private func stopUpdateTimer() {
    updateTimer?.invalidate()
    updateTimer = nil
  }
  
  func seek(to time: TimeInterval) {
    avPlayer.currentTime = time
    currentTime = time
  }
  
}
extension MusicPlayer: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    switch playMode {
    case .normal, .loop:
      _ = nextMusic()
    case .one_loop:
      _ = currentMusicPlay()
      
    }
  }
  
  //  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
  //    let alert = UIAlertController()
  //    alert.title = "DECODE ERROR"
  //    alert.message = error?.localizedDescription ?? "audioPlayerDecodeErrorDidOccur"
  //    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
  //    self.present(alert, animated: false)
  //  }
}


