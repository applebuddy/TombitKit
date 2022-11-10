//
//  URLSession+Extension.swift
//  TombitKit
//
//  Created by MinKyeongTae on 2022/11/09.
//

import Foundation

@available(iOS 13.0.0, *)
extension URLSession {
  /// dataTask method with async await for iOS 13.0+ version
  func data(from url: URL) async throws -> (Data, URLResponse) {
    do {
      return try await withCheckedThrowingContinuation { continuation in
        dataTask(with: url) { data, response, error in
          if let error = error {
            continuation.resume(throwing: error)
            return
          }

          guard let data = data, let response = response else {
            continuation.resume(throwing: URLError(.badServerResponse))
            return
          }
          continuation.resume(returning: (data, response))
        }
        .resume()
      }
    } catch { throw error }
  }

  /// dataTask method with async await for iOS 13.0+ version
  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    do {
      return try await withCheckedThrowingContinuation { continuation in
        dataTask(with: request) { data, response, error in
          if let error = error {
            continuation.resume(throwing: error)
            return
          }
          
          guard let data = data, let response = response else {
            continuation.resume(throwing: URLError(.badServerResponse))
            return
          }
          continuation.resume(returning: (data, response))
        }
        .resume()
      }
    } catch { throw error }
  }
}
