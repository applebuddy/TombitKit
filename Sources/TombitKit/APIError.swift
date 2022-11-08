//
//  APIError.swift
//  
//
//  Created by MinKyeongTae on 2022/11/09.
//

import Foundation

public enum APIError: Error, Equatable {
  public static func == (lhs: APIError, rhs: APIError) -> Bool {
    lhs.errorDescription() == rhs.errorDescription()
  }

  case normal(Error?)
  case failedToParseJson
  case noError
  case noData
  
  func errorDescription() -> String? {
    switch self {
    case .failedToParseJson:
      return "데이터 처리에 실패했습니다."
    case .noError:
      return "에러가 존재하지 않습니다."
    case .normal(let error):
      return error?.localizedDescription
    case .noData:
      return "데이터가 존재하지 않아요."
    }
  }
}
