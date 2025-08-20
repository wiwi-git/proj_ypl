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
  
  @State private var selectItemID: UUID?
  
  var body: some View {
    List(player.musicData, selection: $selectItemID) { item in
      Text(item.title)
    }
    .listStyle(.plain)
    .onAppear(perform: {
      player.loadList()
    })
    .modifier(ExcuteOnChangeModifier(selectedItemID: $selectItemID, executeAction: selectListAction))
  }
  
  func selectListAction(_ id: UUID?) {
    // 선택 하이라이트가 유지되지 않게 하고싶었는데 스타일이 딱히 뭐 안보이더라 그냥 nil 처리
    self.selectItemID = nil
    _ = player.stop()
    if let index = player.musicData.firstIndex(where: { music in
      music.id == id
    }) {
      player.setCurrentIndex(at: index)
    }
    _ = player.play()
    
  }
}

struct ExcuteOnChangeModifier: ViewModifier {
  @Binding var selectedItemID: UUID?
  let executeAction: (UUID?) -> Void
  
  func body(content: Content) -> some View {
    if #available(iOS 17.0, *) {
      // iOS 17.0 이상
      //onChange<V>(of value: V, initial:, _ action:)
      content.onChange(of: selectedItemID, initial: false) { oldID, newID in
        executeAction(newID)
      }
    } else if #available(iOS 14.0, *) {
      // iOS 14.0 ~ 16.x:
      // onChange<V>(of value: V, perform action: )
      content.onChange(of: selectedItemID) { newID in
        executeAction(newID)
      }
    } else {

    }
  }
}

#Preview {
  PlayListView()
    .environmentObject(MusicPlayer())
}
