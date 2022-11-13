//
//  UpbitAPIPayload.swift
//  
//
//  Created by MinKyeongTae on 2022/11/09.
//

import Foundation
import SwiftJWT

/// payload for API with apiKey
struct UpbitAPIPayload: Claims {
  let access_key: String
  let nonce: String
  let query_hash: String
  let query_hash_alg: String
}
