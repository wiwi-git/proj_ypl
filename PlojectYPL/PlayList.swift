//
//  PlayList.swift
//  PlojectYPL
//
//  Created by 위대연 on 9/6/24.
//

import Foundation

class PlayList {
  
  private init() {}
  static var shared = PlayList()
  
  // 데이터가 비었을땐 false를 반환
  var isFirst: Bool {
    get {
      if data.isEmpty { return false }
      return currentIndex == 0
    }
  }
  
  // 데이터가 비었을땐 false를 반환
  var isLast: Bool {
    get {
      if data.isEmpty { return false }
      return currentIndex == data.count - 1
    }
  }
  
  var currentIndex: Int {
    get {
      return index
    }
  }
  
  var currentMusic: MusicInfo? {
    get {
      guard currentIndex < data.count else { return nil }
      return data[currentIndex]
    }
  }
  
//  var currentIndex: Int = 0
  private var index: Int = 0
  
//  var urls: [URL] = []
  var data: [MusicInfo] = []

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
        data = []
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
      
      self.data = infos
    } catch  {
      NSLog(error.localizedDescription)
      print(error.localizedDescription)
    }
    
    print("loaded urls.... count:\(self.data.count)")
  }
  
  /// 플레이 인덱스를 다음으로 설정 후 현재 인덱스 반환, 인덱스가 넘어갈시 0
  func next() -> Int {
    let temp: Int = index + 1
    index = temp < data.count ? temp : 0
    return index
  }
  
  /// 플레이 인덱스를 이전으로 설정 후 현재 인덱스 반환, 인덱스가 0 보다 작을시 count -1으로
  func previus() -> Int {
    let temp: Int = index - 1
    index = temp < 0 ? data.count - 1 : temp
    return index
  }
}
