//
//  NewMainVC.swift
//  PlojectYPL
//
//  Created by 위대연 on 11/11/24.
//

import UIKit
import AVFoundation
import MediaPlayer

class NewMainVC: UIViewController {
  let buttonSize: CGSize = .init(width: 50, height: 50)
  let buttonPadding: CGFloat = 8
  let buttonSpace: CGFloat = 8
  let playList: PlayList = .shared
  
  var avPlayer: AVAudioPlayer = .init()
  
  lazy var preButton: UIButton = createContBtn(title: "❮")
  lazy var playButton: UIButton = {
    let button = createContBtn(title: "▶︎")
    button.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
    return button
  }()
  
  var paused: Bool = false
  
  lazy var nextButton: UIButton = createContBtn(title: "❯")
  
  lazy var playListView: UITableView = {
    let tableview: UITableView = .init(frame: .zero, style: .plain)
    tableview.backgroundColor = .white
    
    tableview.delegate = self
    tableview.dataSource = self
    tableview.register(PlayListCell.self, forCellReuseIdentifier: PlayListCell.reuseId)
    return tableview
  }()
  
  lazy var reloadButton: UIButton = {
    let button: UIButton = .init()
    button.setTitle("내부파일 재로드", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 20)
    button.addTarget(self, action: #selector(reloadButtonAction), for: .touchUpInside)
    return button
  }()
  let contBarView: UIView = .init()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setLayout()
    initPlayer()
  }
  
  func initPlayer() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      /// 이유를 모르겠다 옵션즈에 값을 넣으면 락스크린에 컨트롤바가 안생김....
//      try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try audioSession.setCategory(.playback, mode: .default, options: [])
    } catch let error as NSError {
      print("audioSession 설정 오류 : \(error.localizedDescription)")
    }
    reloadButtonAction()
//    guard let url = Bundle.main.url(forResource: "forest", withExtension: "mp3") else {
//      return
//    }
//    do {
//        try self.avPlayer = AVAudioPlayer(contentsOf: url)
//        self.avPlayer.delegate = self
//        self.avPlayer.play()
//    } catch let error as NSError {
//        print("플레이어 초기화 오류 발생 : \(error.localizedDescription)")
//    }
    
    self.remoteCommandCenterSetting()
//    self.remoteCommandInfoCenterSetting()
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
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.avPlayer.currentTime)
      // 일시정지 할 땐 now playing item의 rate를 0으로 설정하여 시간이 흐르지 않도록 합니다.
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
      return .success
    }
    
    center.nextTrackCommand.addTarget { event in
      let nextResult = self.nextAction()
      if !nextResult {
        return .noSuchContent
      }
      
//      MPNowPlayingInfoCenter.default()
//        .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.avPlayer.currentTime)
//      // 재생 할 땐 now playing item의 rate를 1로 설정하여 시간이 흐르도록 합니다.
//      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
      return .success
    }
    center.previousTrackCommand.addTarget { event in
      _ = self.previousAction()
      
      return .success
    }
    
    center.playCommand.isEnabled = true
    center.pauseCommand.isEnabled = true
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
  
  private func createContBtn(title: String) -> UIButton {
    let button: UIButton = .init(frame: .init(origin: .zero, size: buttonSize))
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 30)
    button.backgroundColor = .white
    
    button.setTitleColor(.black, for: .normal)
    button.setTitleColor(.lightGray, for: .highlighted)
    return button
  }
  
  func cntViewSetupLayout(cntView: UIView) {
    cntView.addSubview(preButton)
    cntView.addSubview(playButton)
    cntView.addSubview(nextButton)
    
    playButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      playButton.centerXAnchor.constraint(equalTo: cntView.centerXAnchor),
      playButton.centerYAnchor.constraint(equalTo: cntView.centerYAnchor),
      playButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
      playButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
      playButton.topAnchor.constraint(equalTo: cntView.topAnchor, constant: buttonPadding),
      playButton.bottomAnchor.constraint(equalTo: cntView.bottomAnchor, constant: -buttonPadding)
    ])
    
    preButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      preButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -buttonSpace),
      preButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
      preButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
      preButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
    ])
    
    
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      nextButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: buttonSpace),
      nextButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
      nextButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
      nextButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
    ])
  }
  
  
  func setLayout() {
    // 컨트롤바 겉
    self.view.addSubview(contBarView)
    contBarView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contBarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
      contBarView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      contBarView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
    ])
    
    // 컨트롤바 내부
    cntViewSetupLayout(cntView: contBarView)
    
    // 새로 추가하는 툴버튼
    self.view.addSubview(reloadButton)
    reloadButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      reloadButton.bottomAnchor.constraint(equalTo: contBarView.topAnchor, constant: 8),
      reloadButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8)
    ])
    
    view.addSubview(playListView)
    playListView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      playListView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
      playListView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      playListView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
      playListView.bottomAnchor.constraint(equalTo: self.reloadButton.topAnchor, constant: 8)
    ])
  }
  
  @objc func reloadButtonAction() {
    playList.loadList()
    playListView.reloadData()
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
  
  @objc func nextAction() -> Bool {
    if playList.isLast {
      return false
    }
    
    _ = playList.next()
    let url = playList.currentMusic?.url
    guard url != nil else {
      print("play url is nil")
      return false
    }
    return play(url: url!)
  }
  
  func setPlayIcon(isPlay: Bool?) {
    playButton.setTitle(isPlay ?? false ? "❚❚" : "▶", for: .normal)
  }
  
  private func play(url: URL?) -> Bool{
    defer {
      setPlayIcon(isPlay: avPlayer.isPlaying)
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
      setPlayIcon(isPlay: avPlayer.isPlaying)
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    avPlayer.pause()
    paused = true
    return true
  }
}
extension NewMainVC : UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.playList.data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PlayListCell.reuseId, for: indexPath) as! PlayListCell
    cell.selectionStyle = .none
    // 우선 재생목록은 오로지 현 플레이인덱스만 알려주는 용도로
    let music = self.playList.currentMusic
    cell.nameLabel.text = music?.title ?? ""
    
    if indexPath.row == self.playList.currentIndex {
      cell.backgroundColor = .lightGray
      cell.nameLabel.textColor = .white
    } else {
      cell.backgroundColor = .clear
      cell.nameLabel.textColor = .black
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // TODO: 리스트에서 선택으로 인덱스 변경시켜서 재생시키는건 나중에
  }
}
extension NewMainVC : AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
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

