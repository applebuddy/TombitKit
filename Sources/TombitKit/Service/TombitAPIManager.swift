//
//  TombitAPIManager.swift
//  Tombit
//
//  Created by MinKyeongTae on 2022/09/09.
//

import UIKit
import SwiftJWT

public final class TombitAPIManager {
  public static let shared = TombitAPIManager()
  public var binanceApiAccessKey: String?
  public var binanceApiSecretKey: String?
  private let upbitBaseURLString = "https://api.upbit.com/v1"
}

extension TombitAPIManager {
  // MARK: - Upbit
  
  public func requestMarketAllInfo() async -> Result<[UpbitSymbolInfo], APIError> {
    guard let url = URL(string: "\(upbitBaseURLString)/market/all") else {
      return .failure(APIError.normal(URLError(.badURL)))
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let jsonData = try JSONDecoder().decode([UpbitSymbolInfo].self, from: data)
      return .success(jsonData)
    } catch {
      return .failure(APIError.normal(error))
    }
  }
  
  public func requestUpbitTickerPriceInfo(marketsSubPath: String) async -> Result<UpbitMarketTickerListResponse, APIError> {
    guard let url = URL(string: "\(upbitBaseURLString)/ticker?markets=\(marketsSubPath)") else {
      return .failure(APIError.normal(URLError(.badURL)))
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let response = try JSONDecoder().decode(UpbitMarketTickerListResponse.self, from: data)
      return .success(response)
    } catch {
      return .failure(APIError.normal(error))
    }
  }

  public func requestUpbitAccountsInfo(apiAccessKey: String, apiSecretKey: String) async throws -> UpbitAccountsListResponse? {
    let baseURL = "\(upbitBaseURLString)/accounts"
    
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
      throw APIError.normal(URLError(.badURL))
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
      throw error
    }
  }
}

extension TombitAPIManager {
  // MARK: - Binance
  
  public func requestBinanceAssetList(apiAccessKey: String, apiSecretKey: String) async -> BinanceAssetInfoTupleAPIDataResponse {
    binanceApiAccessKey = apiAccessKey
    binanceApiSecretKey = apiSecretKey
    debugPrint("\(apiAccessKey), \(apiSecretKey)")
    
    let connection = BinanceConnection(apiKey: apiAccessKey, secretKey: apiSecretKey)
    var tupleResponse: BinanceAssetInfoTupleAPIDataResponse = (market: nil, future: nil)
    
    async let marketInfoResult = connection.getMarketAssetInfoList()
    async let futureInfoResult = connection.getFutureAccountInfo()
    
    tupleResponse.market = APIDataResponse(await marketInfoResult)
    tupleResponse.future = APIDataResponse(await futureInfoResult)
    return tupleResponse
  }
  
  public func requestBinanceMarketPriceList() async -> Result<PriceTickerInfoList, APIError> {
    let connection = BinanceConnection(
      apiKey: binanceApiAccessKey ?? "",
      secretKey: binanceApiSecretKey ?? ""
    )
    return await connection.getMarketPriceInfoList()
  }
  
  public func requestBinanceFuturePriceList() async -> Result<PriceTickerInfoList, APIError> {
    let connection = BinanceConnection(
      apiKey: binanceApiAccessKey ?? "",
      secretKey: binanceApiSecretKey ?? ""
    )
    return await connection.getFuturePriceInfoList()
  }
  
  public func requestBinancePriceList() async throws -> Result<BinancePriceInfoTupleAPIDataResponse?, APIError> {
    let connection = BinanceConnection(
      apiKey: binanceApiAccessKey ?? "",
      secretKey: binanceApiSecretKey ?? ""
    )
    
    var tupleResponse: BinancePriceInfoTupleAPIDataResponse = (market: nil, future: nil)
    
    async let marketResult = connection.getMarketPriceInfoList()
    async let futureResult = connection.getFuturePriceInfoList()
    
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
}
