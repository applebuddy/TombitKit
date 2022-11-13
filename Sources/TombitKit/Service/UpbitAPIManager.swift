//
//  UpbitAPIManager.swift
//  
//
//  Created by MinKyeongTae on 2022/11/13.
//

import Foundation
import SwiftJWT

public final class UpbitAPIManager {
  static let shared = UpbitAPIManager()
  private let baseURLString = "https://api.upbit.com/v1"
  
  private struct PayloadBuilder {
    enum SecurityType {
      case none
      case trade(accessKey: String, secretKey: String)
    }
  }
  
  private func requestAPI<T: Decodable>(
    withPath path: String,
    queryString: String? = nil,
    securityType: PayloadBuilder.SecurityType
  ) async -> Result<T, APIError> {
    
    var urlString = self.baseURLString + "/\(path)"
    if let queryString = queryString {
      urlString += "?\(queryString)"
    }
    
    guard let url = URL(string: urlString) else {
      return .failure(APIError.normal(URLError(.badURL)))
    }
    
    switch securityType {
    case .trade(let accessKey, let secretKey):
      var jwt = JWT(
        claims: UpbitAPIPayload(
          access_key: accessKey,
          nonce: UUID().uuidString,
          query_hash: "",
          query_hash_alg: "SHA512"
        )
      )
      
      guard
        let secretKeyData = secretKey.data(using: .utf8),
        let signedJWT = try? jwt.sign(using: .hs256(key: secretKeyData)) else {
        return .failure(APIError.normal(URLError(.badURL)))
      }
      
      let authenticationToken = "Bearer " + signedJWT
      do {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(authenticationToken, forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let parsedData = try JSONDecoder().decode(T.self, from: data)
        return .success(parsedData)
      } catch {
        debugPrint(error.localizedDescription)
        return .failure(APIError.normal(error))
      }

    case .none:
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      do {
        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonData = try JSONDecoder().decode(T.self, from: data)
        return .success(jsonData)
      } catch {
        return .failure(APIError.normal(error))
      }
    }
  }
  
  public func requestMarketAllInfo() async -> Result<[UpbitSymbolInfo], APIError> {
    await requestAPI(
      withPath: "/market/all",
      securityType: .none
    )
  }
  
  public func requestUpbitTickerPriceInfo(marketsQuery: String) async -> Result<UpbitMarketTickerListResponse, APIError> {
    await requestAPI(
      withPath: "/ticker",
      queryString: marketsQuery,
      securityType: .none
    )
  }
  
  public func requestUpbitAccountsInfo(apiAccessKey: String, apiSecretKey: String) async -> Result<UpbitAccountsListResponse, APIError> {
    await requestAPI(
      withPath: "/accounts",
      securityType: .trade(
        accessKey: apiAccessKey,
        secretKey: apiSecretKey)
    )
  }
}
