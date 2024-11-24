//
//  ContView.swift
//  PlojectYPL
//
//  Created by 위대연 on 8/12/24.
//

import UIKit

class ContBarView: UIView {
  let buttonSize: CGSize
  let buttonPadding: CGFloat
  let buttonSpace: CGFloat

  lazy var preButton: UIButton = createContBtn(title: "❮")
  lazy var playButton: UIButton = createContBtn(title: "▶︎")
//  lazy var stopButton: UIButton = createContBtn(title: "■")
  lazy var nextButton: UIButton = createContBtn(title: "❯")
  
  
  init(frame: CGRect, buttonSize: CGSize, buttonPadding: CGFloat = 8, buttonSpace: CGFloat = 20) {
    self.buttonSize = buttonSize
    self.buttonPadding = buttonPadding
    self.buttonSpace = buttonSpace
    super.init(frame: frame)
    
    layoutSetup(view: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  // view
  private func layoutSetup(view: UIView) {
    view.addSubview(preButton)
    view.addSubview(playButton)
    view.addSubview(nextButton)
//    view.addSubview(stopButton)
    
    playButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      playButton.heightAnchor.constraint(equalToConstant: buttonSize.height),
      playButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
      playButton.topAnchor.constraint(equalTo: view.topAnchor, constant: buttonPadding),
      playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -buttonPadding)
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
  
  func setPlayIcon(isPlay: Bool?) {
    playButton.setTitle(isPlay ?? false ? "❚❚" : "▶", for: .normal)
    setNeedsDisplay()
  }
}
