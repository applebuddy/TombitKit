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
}

extension TombitAPIManager {
  // MARK: - Upbit
  
  public func requestMarketAllInfo() async -> Result<[UpbitSymbolInfo], APIError> {
    return await UpbitAPIManager.shared.requestMarketAllInfo()
  }
  
  public func requestUpbitTickerPriceInfo(marketsSubPath: String) async -> Result<UpbitMarketTickerListResponse, APIError> {
    return await UpbitAPIManager.shared.requestUpbitTickerPriceInfo(marketsQuery: marketsSubPath)
  }

  public func requestUpbitAccountsInfo(apiAccessKey: String, apiSecretKey: String) async -> Result<UpbitAccountsListResponse, APIError> {
    return await UpbitAPIManager.shared.requestUpbitAccountsInfo(
      apiAccessKey: apiAccessKey,
      apiSecretKey: apiSecretKey
    )
  }
}

extension TombitAPIManager {
  // MARK: - Binance
  
  public func requestExchangeInfo(apiType: BinanceAPIManager.APIType) async -> Result<BinanceExchangeInfo, APIError> {
    let connection = BinanceAPIManager()
    switch apiType {
    case .market:
      return await connection.getMarketExchangeInfo()
    case .future:
      return await connection.getFutureExchangeInfo()
    }
  }
  
  public func requestBinanceAssetList(apiAccessKey: String, apiSecretKey: String) async -> Result<BinanceAssetTupleInfoResponse, APIError> {
    binanceApiAccessKey = apiAccessKey
    binanceApiSecretKey = apiSecretKey
    debugPrint("\(apiAccessKey), \(apiSecretKey)")
    
    let connection = BinanceAPIManager(apiKey: apiAccessKey, secretKey: apiSecretKey)
    
    async let marketInfoResult = connection.getMarketAssetInfoList()
    async let futureInfoResult = connection.getFutureAccountInfo()
    var assetTupleInfoResponse: BinanceAssetTupleInfoResponse = (nil, nil)
    
    switch await marketInfoResult {
    case .success(let marketInfo):
      assetTupleInfoResponse.market = marketInfo
    case .failure(let apiError):
      return .failure(apiError)
    }
    
    switch await futureInfoResult {
    case .success(let futureInfo):
      assetTupleInfoResponse.future = futureInfo
    case .failure(let apiError):
      return .failure(apiError)
    }

    return .success(assetTupleInfoResponse)
  }
  
  public func requestBinanceMarketPriceList() async -> Result<PriceTickerInfoList, APIError> {
    let connection = BinanceAPIManager(
      apiKey: binanceApiAccessKey ?? "",
      secretKey: binanceApiSecretKey ?? ""
    )
    return await connection.getMarketPriceInfoList()
  }
  
  public func requestBinanceFuturePriceList() async -> Result<PriceTickerInfoList, APIError> {
    let connection = BinanceAPIManager(
      apiKey: binanceApiAccessKey ?? "",
      secretKey: binanceApiSecretKey ?? ""
    )
    return await connection.getFuturePriceInfoList()
  }
  
  public func requestBinancePriceList() async -> Result<BinancePriceInfoTupleAPIDataResponse, APIError> {
    let connection = BinanceAPIManager(
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
      return .failure(error)
    }
    
    switch await futureResult {
    case .success(let futureInfo):
      tupleResponse.future = futureInfo
    case .failure(let error):
      return .failure(error)
    }
    return .success(tupleResponse)
  }
}
