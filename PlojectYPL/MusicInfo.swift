//
//  MusicInfo.swift
//  PlojectYPL
//
//  Created by 위대연 on 10/24/24.
//

import UIKit

struct MusicInfo: Identifiable {
  let id = UUID()
  var title: String
  var artist: String
  var artworkImage: UIImage?
  var url: URL?
}
