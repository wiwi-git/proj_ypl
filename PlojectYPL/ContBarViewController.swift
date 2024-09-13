//
//  viewController.swift
//  PlojectYPL
//
//  Created by 위대연 on 8/10/24.
//

import UIKit
import AVFoundation
extension NSNotification.Name {
  static let changedContInfo = NSNotification.Name(rawValue: "changed_cont_info")
}

class ContBarViewController: UIViewController {
  let buttonSize: CGSize
  let buttonPadding: CGFloat
  let buttonSpace: CGFloat
  
  var contBarView: ContBarView?
  var paused: Bool = false
  
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
  
  override func viewDidLoad() {
    contBarView = .init(frame: .zero, buttonSize: buttonSize, buttonPadding: buttonPadding, buttonSpace: buttonSpace)
    
    self.view.addSubview(contBarView!)
    contBarView?.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contBarView!.topAnchor.constraint(equalTo: self.view.topAnchor),
      contBarView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      contBarView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      contBarView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
    ])
    
    contBarView?.preButton.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
    contBarView?.playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
    contBarView?.nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
  }
  
//  func playTestMusic() {
//    print("play test music")
//    
//    if avPlayer != nil {
//      avPlayer?.play()
//      return
//    }
//    
//    let url = Bundle.main.url(forResource: "forest", withExtension: "mp3")
//    if let url = url {
//      do {
//        avPlayer = try AVAudioPlayer(contentsOf: url)
//        avPlayer?.prepareToPlay()
//        avPlayer?.play()
//      } catch {
//        NSLog(error.localizedDescription)
//      }
//    }
//  }
  
  
  @objc func playButtonAction() {
//    // 첫 재생
//    if avPlayer == nil {
//      let url = playList.currentUrl
//      guard url != nil else {
//        print("play url is nil")
//        return
//      }
//      play(url: url!)
//      return
//    }
    
    if avPlayer.isPlaying {
      // 재생 중에
      pause()
    } else {
      var url: URL?
      if !paused {
        url = playList.currentUrl
        guard url != nil else {
          print("play url is nil")
          return
        }
      }
      play(url: url)
    }
    
    return
  }
  
  @objc func previousAction() {
    _ = playList.previus()
    let url = playList.currentUrl
    guard url != nil else {
      print("play url is nil")
      return
    }
    
    play(url: url!)
  }
  
  @objc func nextAction() {
    print("called nextAction")
    _ = playList.next()
    let url = playList.currentUrl
    guard url != nil else {
      print("play url is nil")
      return
    }
    play(url: url!)
  }
  
  private func play(url: URL?) {
    defer {
      contBarView?.setPlayIcon(isPlay: avPlayer.isPlaying)
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    
    do {
      try AVAudioSession.sharedInstance().setActive(true)
      paused = false
      
      if avPlayer.isPlaying == false, paused {
        avPlayer.play()
        return
      }
      
      guard url != nil else {
        return
      }
      // TODO: avplayer를 재사용하려고했더니 딱히 방법이없다 AVQueuePlayer로 변경해야할거같다 그냥 처음부터 이거만 있지 왜 오디오플레이어가 따로 존재할까
      avPlayer = try AVAudioPlayer(contentsOf: url!)
      avPlayer.delegate = self
      avPlayer.prepareToPlay()
      avPlayer.play()
      
    } catch  {
      NSLog(error.localizedDescription)
    }
  }
  
  private func pause() {
    do {
      avPlayer.pause()
      try AVAudioSession.sharedInstance().setActive(false)
      paused = true
    } catch {
      NSLog("error: \(error)")
    }
  }
}
extension ContBarViewController: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    print("audioPlayerDidFinishPlaying > successfully :\(flag)")
    nextAction()
  }
  
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
    let alert = UIAlertController()
    alert.title = "DECODE ERROR"
    alert.message = error?.localizedDescription ?? "audioPlayerDecodeErrorDidOccur"
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    self.present(alert, animated: false)
  }
}
