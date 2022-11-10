//
//  UpbitMarketTickerResponse.swift
//  
//
//  Created by MinKyeongTae on 2022/11/13.
//

import Foundation

public typealias UpbitMarketTickerListResponse = [UpbitMarketTickerResponse]

public struct UpbitMarketTickerResponse: Codable, Equatable {
  public let market, tradeDate, tradeTime, tradeDateKst: String
  public let tradeTimeKst: String
  public let tradeTimestamp: Int
  public let openingPrice, highPrice, lowPrice: Double
  public let tradePrice, prevClosingPrice: Double
  public let change: String
  public let changePrice: Double
  public let changeRate: Double
  public let signedChangePrice: Double
  public let signedChangeRate, tradeVolume, accTradePrice, accTradePrice24H: Double
  public let accTradeVolume, accTradeVolume24H: Double
  public let highest52_WeekPrice: Double
  public let highest52_WeekDate: String
  public let lowest52_WeekPrice: Double
  public let lowest52_WeekDate: String
  public let timestamp: Int
  
  enum CodingKeys: String, CodingKey {
    case market
    case tradeDate = "trade_date"
    case tradeTime = "trade_time"
    case tradeDateKst = "trade_date_kst"
    case tradeTimeKst = "trade_time_kst"
    case tradeTimestamp = "trade_timestamp"
    case openingPrice = "opening_price"
    case highPrice = "high_price"
    case lowPrice = "low_price"
    case tradePrice = "trade_price"
    case prevClosingPrice = "prev_closing_price"
    case change
    case changePrice = "change_price"
    case changeRate = "change_rate"
    case signedChangePrice = "signed_change_price"
    case signedChangeRate = "signed_change_rate"
    case tradeVolume = "trade_volume"
    case accTradePrice = "acc_trade_price"
    case accTradePrice24H = "acc_trade_price_24h"
    case accTradeVolume = "acc_trade_volume"
    case accTradeVolume24H = "acc_trade_volume_24h"
    case highest52_WeekPrice = "highest_52_week_price"
    case highest52_WeekDate = "highest_52_week_date"
    case lowest52_WeekPrice = "lowest_52_week_price"
    case lowest52_WeekDate = "lowest_52_week_date"
    case timestamp
  }
}
