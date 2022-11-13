//
//  UpbitSymbolInfo.swift
//
//
//  Created by MinKyeongTae on 2022/11/13.
//

import Foundation

public struct UpbitSymbolInfo: Codable {
  public let market, koreanName, englishName: String
  
  enum CodingKeys: String, CodingKey {
    case market
    case koreanName = "korean_name"
    case englishName = "english_name"
  }
}
