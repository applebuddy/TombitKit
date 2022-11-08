//
//  UpbitAccountsResponse.swift
//  
//
//  Created by MinKyeongTae on 2022/11/09.
//

import Foundation

public typealias UpbitAccountsListResponse = [UpbitAccountsResponse]

public struct UpbitAccountsResponse: Codable, Equatable, Identifiable {
  public var id = UUID()
  public var currency: String
  public var balance: String
  public var locked: String
  public var avgBuyPrice: String
  public var avgBuyPriceModified: Bool
  public var unitCurrency: String
  
  enum CodingKeys: String, CodingKey {
    case currency, balance, locked
    case avgBuyPrice = "avg_buy_price"
    case avgBuyPriceModified = "avg_buy_price_modified"
    case unitCurrency = "unit_currency"
  }
}
