//
//  ControllBarView.swift
//  PlojectYPL
//
//  Created by 위대연 on 3/24/25.
//

import SwiftUI

struct ControllButton: View {
  let text: String
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Text(text)
        .font(.title)
        .frame(width: 50)
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
    }
  }
}

struct ControllBarView: View {
  @EnvironmentObject var player: MusicPlayer
  
  private func minuteString(to timeInterval: TimeInterval) -> String {
    let minutes = Int(timeInterval) / 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
  
  var body: some View {
    VStack(
      alignment: .leading,
      spacing: 4,
      content: {
        Button(action: {
          player.loadList()
        }, label: {
          Text("내부파일 재로드")
        })
        .padding(.horizontal)
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
        .font(Font.title3)
        
        HStack(content: {
          Text("\(minuteString(to: player.currentTime))")
          Slider(value: $player.currentTime, in: 0...player.duration) { isEditing in
            if !isEditing {
              player.seek(to: player.currentTime)
            }
          }
          Text("\(minuteString(to: player.duration))")
        })
        .padding(.horizontal, 8)
        
        HStack(content: {
          Spacer()
          
          ControllButton(text: "❮") {
            _ = player.previousMusic()
          }
          ControllButton(text: player.isPlaying ? "❚❚" : "▶︎") {
            _ = player.play()
          }
//          .disabled(true)
          ControllButton(text: "❯") {
            _ = player.nextMusic()
          }
          
          Spacer()
        })// HStack
        
        Color.clear
          .frame(height: 8)
      })
  }
   
}


#Preview {
  ControllBarView()
}


