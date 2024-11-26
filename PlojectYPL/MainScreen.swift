//
//  MainScreen.swift
//  PlojectYPL
//
//  Created by 위대연 on 11/28/24.
//

import SwiftUI
extension NSNotification.Name {
  static let changedContInfo = NSNotification.Name(rawValue: "changed_cont_info")
}

struct MainScreen: View {
  @StateObject var player: MusicPlayer = .init()
  
  var body: some View {
    VStack(spacing: 0) {
      PlayListView()
      ControllBarView()
    }
    .environmentObject(player)
  }
}

#Preview {
  MainScreen()
}

