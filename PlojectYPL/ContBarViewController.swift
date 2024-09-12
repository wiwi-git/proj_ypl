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
  
  var avPlayer: AVAudioPlayer?
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
    avPlayer?.numberOfLoops = 0
    
    
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
  
  func playTestMusic() {
    print("play test music")
    
    if avPlayer != nil {
      avPlayer?.play()
      return
    }
    
    let url = Bundle.main.url(forResource: "forest", withExtension: "mp3")
    if let url = url {
      do {
        avPlayer = try AVAudioPlayer(contentsOf: url)
        avPlayer?.prepareToPlay()
        avPlayer?.play()
      } catch {
        NSLog(error.localizedDescription)
      }
    }
  }
  
  
  @objc func playButtonAction() {
    defer {
      contBarView?.setPlayIcon(isPlay: avPlayer?.isPlaying)
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    
    if avPlayer?.isPlaying ?? false {
      guard avPlayer != nil else {
        return
      }
      
      avPlayer?.pause()
    } else {
      if avPlayer != nil {
        avPlayer?.play()
        return
      }
      
      let url = playList.currentUrl
      guard url != nil else {
        print("play url is nil")
        return
      }
      playUrl(url: url!)
    }
  }
  
  @objc func previousAction() {
    defer {
      contBarView?.setPlayIcon(isPlay: avPlayer?.isPlaying)
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    
    _ = playList.previus()
    let url = playList.currentUrl
    guard url != nil else {
      print("play url is nil")
      return
    }
    
    playUrl(url: url!)
  }
  
  @objc func nextAction() {
    defer {
      contBarView?.setPlayIcon(isPlay: avPlayer?.isPlaying)
      NotificationCenter.default.post(name: .changedContInfo, object: nil)
    }
    
    _ = playList.next()
    let url = playList.currentUrl
    guard url != nil else {
      print("play url is nil")
      return
    }
    playUrl(url: url!)
  }
  
  private func playUrl(url: URL) {
    do {
      avPlayer = try AVAudioPlayer(contentsOf: url)
      avPlayer?.prepareToPlay()
      avPlayer?.play()
    } catch  {
      NSLog(error.localizedDescription)
    }
  }
}
