//
//  BinanceExchangeInfo.swift
//  
//
//  Created by MinKyeongTae on 2022/11/13.
//

import Foundation

// MARK: - Binance Exchange Info

/// spot, future 공통 모델
public struct BinanceSymbolInfo: Codable, Equatable {
  public var symbol: String
  //  var permissions: [String]?
}

public struct BinanceExchangeInfo: Codable, Equatable {
  public var symbols: [BinanceSymbolInfo]
  
  enum CodingKeys: String, CodingKey {
    case symbols
  }
}
