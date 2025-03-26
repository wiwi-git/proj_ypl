//
//  PlayListView.swift
//  PlojectYPL
//
//  Created by 위대연 on 3/24/25.
//

import SwiftUI

struct PlayListView: View {
  @EnvironmentObject var player: MusicPlayer
  
  var testData: [MusicInfo] = [
    .init(title: "test-data-1", artist: "yeon"),
    .init(title: "test-data-2- blank -", artist: "wi"),
    .init(title: "test-data-3", artist: "yeon"),
    .init(title: "test-data-4- blank -", artist: "wi"),
    .init(title: "test-data-5", artist: "yeon"),
    .init(title: "test-data-6- blank -", artist: "wi"),
    .init(title: "test-data-7", artist: "yeon"),
    .init(title: "test-data-8- blank -", artist: "wi"),
    .init(title: "test-data-9", artist: "yeon"),
    .init(title: "test-data-10- blank -", artist: "wi"),
  ]
  
  var body: some View {
    List(player.musicData) { item in
      Text(item.title)
    }
    .listStyle(.automatic)
    .onAppear(perform: {
      player.loadList()
    })
  }
}

#Preview {
  PlayListView()
    .environmentObject(MusicPlayer())
}
