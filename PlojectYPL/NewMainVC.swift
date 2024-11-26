//
//  NewMainVC.swift
//  PlojectYPL
//
//  Created by 위대연 on 11/11/24.
//

import UIKit

extension NSNotification.Name {
  static let changedContInfo = NSNotification.Name(rawValue: "changed_cont_info")
}

class NewMainVC: UIViewController {
  let buttonSize: CGSize = .init(width: 50, height: 50)
  let buttonPadding: CGFloat = 8
  let buttonSpace: CGFloat = 8
  let player: MusicPlayer = .shared
  
  lazy var preButton: UIButton = createContBtn(title: "❮", 
                                               action: #selector(preButtonAction))
  lazy var playButton: UIButton = createContBtn(title: "▶︎",
                                                action: #selector(playButtonAction))
  lazy var nextButton: UIButton = createContBtn(title: "❯",
                                                action: #selector(nextButtonAction))
  
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
    NotificationCenter.default.addObserver(forName: .changedContInfo, object: nil, queue: nil) {  _  in
      // 플레이 상태가 변했을때 리스트를 다시 그려줘라
      self.playListView.reloadData()
    }
    reloadButtonAction()
  }
  
  
  private func createContBtn(title: String, action: Selector? = nil) -> UIButton {
    let button: UIButton = .init(frame: .init(origin: .zero, size: buttonSize))
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 30)
    button.backgroundColor = .white
    
    button.setTitleColor(.black, for: .normal)
    button.setTitleColor(.lightGray, for: .highlighted)
    if let action = action {
      button.addTarget(self, action: action, for: .touchUpInside)
    }
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
  
  func setPlayIcon(isPlay: Bool?) {
    playButton.setTitle(isPlay ?? false ? "❚❚" : "▶", for: .normal)
  }
  
  @objc func reloadButtonAction() {
    PlayList.shared.loadList()
    self.playListView.reloadData()
  }
  
  @objc func playButtonAction(){
//    defer {
//      setPlayIcon(isPlay: player.isPlaying)
//    }
    _ = player.play()
    setPlayIcon(isPlay: player.isPlaying)
  }
  
  @objc func preButtonAction() {
    _ = player.previousMusic()
    setPlayIcon(isPlay: player.isPlaying)
  }
  
  @objc func nextButtonAction() {
    _ = player.nextMusic()
    setPlayIcon(isPlay: player.isPlaying)
  }
  
}
// 따로 뺄까말까 고민하다 cell ui설정하는 부분이 있어 그냥 냅둠
extension NewMainVC : UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return PlayList.shared.data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PlayListCell.reuseId, for: indexPath) as! PlayListCell
    cell.selectionStyle = .none
    // 우선 재생목록은 오로지 현 플레이인덱스만 알려주는 용도로
    let playList: PlayList = .shared
    let music = playList.currentMusic
    cell.nameLabel.text = music?.title ?? ""
    
    if indexPath.row == playList.currentIndex {
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
