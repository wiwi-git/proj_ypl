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
  var currentIndex: Int {
    get {
      return index
    }
  }
  var currentUrl: URL? {
    get {
      guard currentIndex < urls.count else { return nil }
      return urls[currentIndex]
    }
  }
  
//  var currentIndex: Int = 0
  private var index: Int = 0
  
  var urls: [URL] = []

  func loadList() {
    let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil)
    
    guard urls != nil else {
      print("error: urls is nil")
      return
    }
    
    self.urls = urls!
    
    print("loaded urls.... count:\(self.urls.count)")
  }
  
  /// 플레이 인덱스를 다음으로 설정 후 현재 인덱스 반환, 인덱스가 넘어갈시 0
  func next() -> Int {
    let temp: Int = index + 1
    index = temp < urls.count ? temp : 0
    return index
  }
  
  /// 플레이 인덱스를 이전으로 설정 후 현재 인덱스 반환, 인덱스가 0 보다 작을시 count -1으로
  func previus() -> Int {
    let temp: Int = index - 1
    index = temp < 0 ? urls.count - 1 : temp
    return index
  }
}
