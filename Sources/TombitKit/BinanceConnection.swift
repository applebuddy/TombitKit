import CryptoKit
import Foundation

public typealias MarketAssetInfoList = [MarketAssetInfo]
public typealias PriceTickerInfoList = [PriceTickerInfo]

public final class BinanceConnection {
  enum APIType {
    case market
    case future
    
    var baseURLString: String {
      switch self {
      case .market:
        return BinanceConnection.MarketEndPoint
      case .future:
        return BinanceConnection.FutureEndPoint
      }
    }
  }
  
  private struct PayloadBuilder {
    enum SecurityType {
      case none
      case trade(secret: String), margin(secret: String), userData(secret: String)
      case userStream, marketData
      
      var secret: String? {
        switch self {
        case .trade(secret: let secret), .margin(secret: let secret), .userData(secret: let secret):
          return secret
        default:
          return nil
        }
      }
    }
    
    let payload: String
    let timestamp: Bool
    let security: SecurityType
    
    func build() -> String {
      var built = payload
      
      if case .none = security {
        return payload
      }
      
      if timestamp {
        // TODO: API 성격에 따라 recvWindow 값 조절 필요 (default 값 설정 시 future 자산 조회 에러가 발생하는 경우가 있어 10000으로 임시 조정
        built = "\(built)timestamp=\(Int64(Date().timeIntervalSince1970 * 1000))&recvWindow=10000"
      }
      
      guard let secret = security.secret else { return built }
      
      guard let secretKeyData = secret.data(using: .utf8),
            let builtData = built.data(using: .utf8) else {
        return payload
      }
      
      let key = SymmetricKey(data: secretKeyData)
      let signature = HMAC<SHA256>.authenticationCode(for: builtData, using: key)
      return "\(built)&signature=\(Data(signature).map { String(format: "%02hhx", $0) }.joined())"
    }
  }
  
  public enum BinanceError: Error {
    
    case invalidResponse
  }
  
  static private let MarketEndPoint = "https://api.binance.com"
  static private let FutureEndPoint = "https://fapi.binance.com"
  
  let apiKey: String
  let secretKey: String
  
  public init(apiKey: String, secretKey: String) {
    self.apiKey = apiKey
    self.secretKey = secretKey
  }
  
  private func performCall<T: Decodable>(
    withPath path: String,
    queryString: String,
    timestamp: Bool,
    apiType: APIType = .market,
    securityType: PayloadBuilder.SecurityType
  ) async -> Result<T, APIError> {
    let payload = PayloadBuilder(payload: queryString, timestamp: timestamp, security: securityType).build()
    let url = URL(string: "\(apiType.baseURLString)\(path)?\(payload)")!
    var urlRequest = URLRequest(url: url)
    urlRequest.addValue(apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let parsedData = try JSONDecoder().decode(T.self, from: data)
      return .success(parsedData)
    } catch {
      print(error.localizedDescription)
      return .failure(APIError.normal(error))
    }
  }
  
  // MARK: - Market

  /// 현물 자산 리스트 정보
  public func getMarketAssetListInfo() async -> Result<MarketAssetInfoList, APIError> {
    return await performCall(
      withPath: "/sapi/v1/capital/config/getall",
      queryString: "",
      timestamp: true,
      apiType: .market,
      securityType: .userData(secret: secretKey)
    )
  }

  /// 현물 가격 리스트 정보
  public func getMarketPriceListInfo() async -> Result<PriceTickerInfoList, APIError> {
    return await performCall(
      withPath: "/api/v3/ticker/price",
      queryString: "",
      timestamp: false,
      apiType: .market,
      securityType: .marketData
    )
  }

  /// 선물 가격 리스트 정보
  public func getFuturePriceListInfo() async -> Result<PriceTickerInfoList, APIError> {
    return await performCall(
      withPath: "/fapi/v1/ticker/price",
      queryString: "",
      timestamp: false,
      apiType: .future,
      securityType: .marketData
    )
  }
  
  // MARK: - Future

  /// 선물 계정 정보
  public func getFutureAccountInfo() async -> Result<FutureAccountInfo, APIError> {
    return await performCall(
      withPath: "/fapi/v2/account",
      queryString: "",
      timestamp: true,
      apiType: .future,
      securityType: .userData(secret: secretKey)
    )
  }
}
