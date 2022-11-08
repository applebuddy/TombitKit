//
//  GlobalApiManager.swift
//  Tombit
//
//  Created by MinKyeongTae on 2022/09/09.
//

import UIKit
import SwiftJWT

typealias BinanceMarketAssetInfoResponse = MarketAssetInfoList
typealias BinanceFutureAssetInfoResponse = FutureAccountInfo
typealias BinancePriceTickerInfoResponse = PriceTickerInfoList
typealias BinancePriceTickerInfo = PriceTickerInfo

public struct APIDataResponse<Decodable, Failure: Error> : Equatable {
  public static func == (lhs: APIDataResponse<Decodable, Failure>, rhs: APIDataResponse<Decodable, Failure>) -> Bool {
    lhs.id == rhs.id
  }
  
  let id = UUID()
  
  public var result: Result<Decodable, Failure>?
  
  init(_ result: Result<Decodable, Failure>) {
    self.result = result
  }
}

// Binance Asset Info
typealias BinanceAssetInfoTupleAPIDataResponse = (market: BinanceMarketAssetInfoApiDataResponse?, future: BinanceFutureAssetInfoApiDataResponse?)
typealias BinanceMarketAssetInfoApiDataResponse = APIDataResponse<BinanceMarketAssetInfoResponse, APIError>
typealias BinanceFutureAssetInfoApiDataResponse = APIDataResponse<BinanceFutureAssetInfoResponse, APIError>
// Binance Price Info
typealias BinancePriceInfoTupleAPIDataResponse = (market: PriceTickerInfoList?, future: PriceTickerInfoList?)
typealias BinanceMarketPriceInfoApiDataResponse = APIDataResponse<BinancePriceTickerInfoResponse, APIError>
typealias BinanceFuturePriceInfoApiDataResponse = APIDataResponse<BinancePriceTickerInfoResponse, APIError>

struct BinancePriceInfoWrapper: Equatable {
  var marketInfo: BinancePriceTickerInfoResponse?
  var futureInfo: BinancePriceTickerInfoResponse?
}

struct BinanceAssetInfoWrapper: Equatable {
  var marketInfo: BinanceMarketAssetInfoResponse?
  var futureInfo: BinanceFutureAssetInfoResponse?
}

typealias UpbitAccountsListResponse = [UpbitAccountsResponse]

struct UpbitAccountsResponse: Codable, Equatable, Identifiable {
  var id = UUID()
  var currency: String
  var balance: String
  var locked: String
  var avgBuyPrice: String
  var avgBuyPriceModified: Bool
  var unitCurrency: String
  
  enum CodingKeys: String, CodingKey {
    case currency, balance, locked
    case avgBuyPrice = "avg_buy_price"
    case avgBuyPriceModified = "avg_buy_price_modified"
    case unitCurrency = "unit_currency"
  }
}

final class TombitAPIManager {
  static let shared = TombitAPIManager()
  
  var binanceApiAccessKey: String?
  var binanceApiSecretKey: String?

  // MARK: - Binance

  func requestBinanceAssetList(apiAccessKey: String, apiSecretKey: String) async -> BinanceAssetInfoTupleAPIDataResponse {
    binanceApiAccessKey = apiAccessKey
    binanceApiSecretKey = apiSecretKey
    debugPrint("\(apiAccessKey), \(apiSecretKey)")

    let connection = BinanceConnection(apiKey: apiAccessKey, secretKey: apiSecretKey)
    var tupleResponse: BinanceAssetInfoTupleAPIDataResponse = (market: nil, future: nil)
    
    async let marketInfoResult = await connection.getMarketAssetListInfo()
    async let futureInfoResult = await connection.getFutureAccountInfo()
    
    tupleResponse.market = APIDataResponse(await marketInfoResult)
    tupleResponse.future = APIDataResponse(await futureInfoResult)
    return tupleResponse
  }
  
  func requestBinancePriceList() async throws -> Result<BinancePriceInfoTupleAPIDataResponse?, APIError> {
    let connection = BinanceConnection(
      apiKey: binanceApiAccessKey ?? "",
      secretKey: binanceApiSecretKey ?? ""
    )

    var tupleResponse: BinancePriceInfoTupleAPIDataResponse = (market: nil, future: nil)
    
    // 현물 가격 조회
    async let marketResult = connection.getMarketPriceListInfo()
    // 선물 가격 조회
    async let futureResult = connection.getFuturePriceListInfo()
    
    switch await marketResult {
    case .success(let marketInfo):
      tupleResponse.market = marketInfo
    case .failure(let error):
      throw error
    }
    
    switch await futureResult {
    case .success(let futureInfo):
      tupleResponse.future = futureInfo
    case .failure(let error):
      throw error
    }
    return .success(tupleResponse)
  }
  
  // MARK: Upbit
  
  func requestUpbitAccountsInfo(apiAccessKey: String, apiSecretKey: String) async -> UpbitAccountsListResponse? {
    let baseURL = "https://api.upbit.com/v1/accounts"
    
    var jwt = JWT(
      claims: UpbitAPIPayload(
        access_key: apiAccessKey,
        nonce: UUID().uuidString,
        query_hash: "",
        query_hash_alg: "SHA512"
      )
    )

    guard
      let secretKeyData = apiSecretKey.data(using: .utf8),
      let signedJWT = try? jwt.sign(using: .hs256(key: secretKeyData)),
      let url = URL(string: baseURL) else {
      debugPrint("signedJWT parsing Failed.")
      return nil
    }
    
    let authenticationToken = "Bearer " + signedJWT
    do {
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.addValue(authenticationToken, forHTTPHeaderField: "Authorization")
      let (data, _) = try await URLSession.shared.data(for: request)
      let parsedData = try JSONDecoder().decode(UpbitAccountsListResponse.self, from: data)
      return parsedData
    } catch {
      debugPrint(error.localizedDescription)
      return nil
    }
  }
}
