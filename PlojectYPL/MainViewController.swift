//
//  ViewController.swift
//  PlojectYPL
//
//  Created by 위대연 on 8/10/24.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  var contVC: ContBarViewController?
  var playList: PlayList = .shared
  
  lazy var reloadButton: UIButton = {
    let button: UIButton = .init()
    button.setTitle("내부파일 재로드", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 20)
    button.addTarget(self, action: #selector(reloadButtonAction), for: .touchUpInside)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    NotificationCenter.default.addObserver(forName: .changedContInfo, object: nil, queue: nil) {  _  in
      self.playListView?.reloadData()
    }
    
    playList.loadList()
    setLayout()
  }
  
  var playListView: UITableView?
  func setLayout() {
    // 컨트롤바
    contVC = ContBarViewController(buttonSize: .init(width: 50, height: 50), buttonPadding: 8, buttonSpace: 8)
    self.addChild(contVC!)
    view.addSubview(contVC!.view)
    
    contVC!.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contVC!.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
      contVC!.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      contVC!.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
    ])
    // 새로 추가하는 툴버튼
    self.view.addSubview(reloadButton)
    reloadButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      reloadButton.bottomAnchor.constraint(equalTo: self.contVC!.view.topAnchor, constant: 8),
      reloadButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8)
    ])
    
    // 테이블뷰로 재생목록 만들건데 이게 파일로 따로 커스텀해서 쓸거였는데 기억이 잘안나서 그냥우선 여기다가 바로해봄
    playListView = .init(frame: .zero, style: .plain)
    playListView?.backgroundColor = .white
    
    playListView?.delegate = self
    playListView?.dataSource = self
    playListView?.register(PlayListCell.self, forCellReuseIdentifier: PlayListCell.reuseId)
    
    view.addSubview(playListView!)
    playListView!.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      playListView!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
      playListView!.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      playListView!.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
//      playListView!.bottomAnchor.constraint(equalTo: self.contVC!.view.topAnchor, constant: 8)
      playListView!.bottomAnchor.constraint(equalTo: self.reloadButton.topAnchor, constant: 8)
    ])
  }
  
  @objc func reloadButtonAction() {
    playList.loadList()
    playListView?.reloadData()
  }
    
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.playList.urls.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PlayListCell.reuseId, for: indexPath) as! PlayListCell
    // 우선 재생목록은 오로지 현 플레이인덱스만 알려주는 용도로
    cell.selectionStyle = .none
    cell.nameLabel.text = self.playList.urls[indexPath.row].lastPathComponent
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

class PlayListCell: UITableViewCell {
  static let reuseId: String = "play_list_cell"
  
  lazy var nameLabel: UILabel = {
    let label: UILabel = .init()
    label.font = .systemFont(ofSize: 15)
    label.textColor = .black
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(nameLabel)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
    ])
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func prepareForReuse() {
      self.nameLabel.text = ""
  }
}
