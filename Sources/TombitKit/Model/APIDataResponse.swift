//
//  APIDataResponse.swift
//  
//
//  Created by MinKyeongTae on 2022/11/09.
//

import Foundation

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
