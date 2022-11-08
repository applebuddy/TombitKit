//
//  UpbitAPIPayload.swift
//  
//
//  Created by MinKyeongTae on 2022/11/09.
//

import Foundation
import SwiftJWT

struct UpbitAPIPayload: Claims {
  let access_key: String
  let nonce: String
  let query_hash: String
  let query_hash_alg: String
}

enum ApiType: CaseIterable {
  case upbit
  case binance
  
  func title() -> String {
    switch self {
    case .upbit:
      return "업비트 API 연동"
    case .binance:
      return "바이낸스 API 연동"
    }
  }
  
  func name() -> String {
    switch self {
    case .upbit:
      return "업비트 (Upbit)"
    case .binance:
      return "바이낸스 (Binance)"
    }
  }
  
  func unit() -> String {
    switch self {
    case .upbit:
      return "KRW"
    case .binance:
      return "USDT"
    }
  }
}
