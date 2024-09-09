//
//  ControllViewController.swift
//  PlojectYPL
//
//  Created by 위대연 on 8/10/24.
//

import UIKit

class cntBarViewController: UIViewController {
  let buttonSize: CGSize
  let buttonPadding: CGFloat
  let buttonSpace: CGFloat
  
  var playButton: UIButton?
  var preButton: UIButton?
  var nextButton: UIButton?
  
  init(buttonSize: CGSize, buttonPadding: CGFloat = 8, buttonSpace: CGFloat = 20) {
    self.buttonSize = buttonSize
    self.buttonPadding = buttonPadding
    self.buttonSpace = buttonSpace
    
    super.init()
  }
  
  // 스토리보드 생성은 패스
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    setup(view: self.view)
  }
  
  // view
  func setup(view: UIView) {
    let controllView: UIView = .init()
    view.addSubview(controllView)
    
    preButton = createCntBtn(title: "❮")
    controllView.addSubview(preButton!)
    
    playButton = createCntBtn(title: "▶︎")
    controllView.addSubview(playButton!)
    
    nextButton = createCntBtn(title: "❯")
    controllView.addSubview(nextButton!)
    
    
    playButton?.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      playButton!.centerXAnchor.constraint(equalTo: controllView.centerXAnchor),
      playButton!.centerYAnchor.constraint(equalTo: controllView.centerYAnchor),
      playButton!.heightAnchor.constraint(equalToConstant: buttonSize.height),
      playButton!.widthAnchor.constraint(equalToConstant: buttonSize.width),
      playButton!.topAnchor.constraint(greaterThanOrEqualTo: controllView.topAnchor, constant: buttonPadding),
      playButton!.bottomAnchor.constraint(greaterThanOrEqualTo: controllView.bottomAnchor, constant: buttonPadding),
    ])
    
    preButton?.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      preButton!.trailingAnchor.constraint(equalTo: playButton!.leadingAnchor, constant: buttonSpace),
      preButton!.centerYAnchor.constraint(equalTo: playButton!.centerYAnchor),
      preButton!.heightAnchor.constraint(equalToConstant: buttonSize.height),
      preButton!.widthAnchor.constraint(equalToConstant: buttonSize.width),
      preButton!.leadingAnchor.constraint(greaterThanOrEqualTo: controllView.leadingAnchor, constant: buttonPadding),
    ])
    
    nextButton?.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      nextButton!.leadingAnchor.constraint(equalTo: playButton!.trailingAnchor, constant: buttonSpace),
      nextButton!.centerYAnchor.constraint(equalTo: playButton!.centerYAnchor),
      nextButton!.heightAnchor.constraint(equalToConstant: buttonSize.height),
      nextButton!.widthAnchor.constraint(equalToConstant: buttonSize.width),
      nextButton!.trailingAnchor.constraint(greaterThanOrEqualTo: controllView.trailingAnchor, constant: buttonPadding),
    ])
  }
  
  private func createCntBtn(title: String) -> UIButton {
    let button: UIButton = .init(frame: .init(origin: .zero, size: buttonSize))
    button.setTitle(title, for: .normal)
    button.setTitleColor(.black, for: .normal)
    return button
  }
  
}
