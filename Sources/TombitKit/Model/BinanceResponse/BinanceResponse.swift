import Foundation

// Binance Asset Info
public typealias BinanceMarketAssetInfoResponse = MarketAssetInfoList
public typealias BinanceFutureAssetInfoResponse = FutureAccountInfo
public typealias BinanceMarketAssetInfoApiDataResponse = APIDataResponse<BinanceMarketAssetInfoResponse, APIError>
public typealias BinanceFutureAssetInfoApiDataResponse = APIDataResponse<BinanceFutureAssetInfoResponse, APIError>
public typealias BinanceAssetInfoTupleAPIDataResponse = (market: BinanceMarketAssetInfoApiDataResponse?, future: BinanceFutureAssetInfoApiDataResponse?)
// Binance Price Info
public typealias BinancePriceTickerInfoResponse = PriceTickerInfoList
public typealias BinancePriceTickerInfo = PriceTickerInfo
public typealias BinancePriceInfoTupleAPIDataResponse = (market: PriceTickerInfoList?, future: PriceTickerInfoList?)
public typealias BinanceMarketPriceInfoApiDataResponse = APIDataResponse<BinancePriceTickerInfoResponse, APIError>
public typealias BinanceFuturePriceInfoApiDataResponse = APIDataResponse<BinancePriceTickerInfoResponse, APIError>

public struct BinancePriceInfoWrapper: Equatable {
  public var marketInfo: BinancePriceTickerInfoResponse?
  public var futureInfo: BinancePriceTickerInfoResponse?
  
  public init(marketInfo: BinancePriceTickerInfoResponse?, futureInfo: BinancePriceTickerInfoResponse?) {
    self.marketInfo = marketInfo
    self.futureInfo = futureInfo
  }
}

public struct BinanceAssetInfoWrapper: Equatable {
  public var marketInfo: BinanceMarketAssetInfoResponse?
  public var futureInfo: BinanceFutureAssetInfoResponse?
  
  public init(marketInfo: BinanceMarketAssetInfoResponse?, futureInfo: BinanceFutureAssetInfoResponse?) {
    self.marketInfo = marketInfo
    self.futureInfo = futureInfo
  }
  
  public init() {}
}

public struct PriceTickerInfo: Codable, Equatable {
  public let symbol: String // ex) "BTCUSDT"
  public let price: String // ex) "6000.01"
  // future price ticker info에서만 time 필드 값이 존재
  public let time: Int?
}

public struct MarketAssetInfo: Codable, Equatable {
  public let coin: String
  public let depositAllEnable: Bool
  public let free, freeze, ipoable, ipoing: String
  public let isLegalMoney: Bool
  public let locked, name, storage: String
  public let trading, withdrawAllEnable: Bool
  public let withdrawing: String
}

public struct FutureAccountInfo: Codable, Equatable {
  public let feeTier: Int
  public let canTrade: Bool
  public let canDeposit: Bool
  public let canWithdraw: Bool
  public let updateTime: Int
  public let totalInitialMargin: String
  public let totalMaintMargin: String
  public let totalWalletBalance: String
  public let totalUnrealizedProfit: String
  public let totalPositionInitialMargin: String
  public let totalOpenOrderInitialMargin: String
  public let totalCrossWalletBalance: String
  public let totalCrossUnPnl: String
  public let availableBalance: String
  public let maxWithdrawAmount: String
  public let assets: [FutureAssetInfo]
}

public struct FutureAssetInfo: Codable, Equatable {
  public let asset: String
  public let walletBalance: String
  public let unrealizedProfit: String
  public let marginBalance: String
  public let maintMargin: String
  public let initialMargin: String
  public let positionInitialMargin: String
  public let openOrderInitialMargin: String
  public let crossWalletBalance: String
  public let crossUnPnl: String
  public let availableBalance: String
  public let maxWithdrawAmount: String
  public let marginAvailable: Bool
  public let updateTime: Int
}

public enum BinanceResponse {
  enum APIError: Error {
    case decodingError
  }
  
  public struct SymbolPriceTicker: Codable {
    public let symbol: String
    public let price: Double
    
    enum CodingKeys: String, CodingKey {
      case symbol
      case price
    }
    
    init?(json: [String: Any]) {
      guard let symbol = json["symbol"] as? String else { return nil }
      guard let priceAsString = json["price"] as? String else { return nil }
      guard let price = Double(priceAsString) else { return nil }
      
      self.symbol = symbol
      self.price = price
    }
    
    public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      let priceAsString = try values.decode(String.self, forKey: .price)
      
      guard let price = Double(priceAsString) else {
        throw APIError.decodingError
      }
      
      self.symbol = try values.decode(String.self, forKey: .symbol)
      self.price = price
    }
  }
}
