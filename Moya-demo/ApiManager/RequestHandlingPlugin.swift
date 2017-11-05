//
//  RequestHandlingPlugin.swift
//  Game
//
//  Created by Wilson Yuan on 2017/10/30.
//  Copyright © 2017年 Game.com Inc. All rights reserved.
//

import Foundation
import Moya
import enum Result.Result

class RequestHandlingPlugin: PluginType {
    
    /// Called to modify a request before sending
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutateableRequest = request
        return mutateableRequest.appendCommonParams();
    }
    
}

extension URLRequest {
    
    /// global common params
    private var commonParams: [String: Any] {
        return [
            "device" : "ios",
            "appstore_id" : "123288392"
        ]
    }
    
    /// global common header fields
    private var commonHeaderFields: [String : String] {
        return ["access_token" : "******"]
    }
    
    mutating func appendCommonParams() -> URLRequest {
        let newHeaderFields = (allHTTPHeaderFields ?? [:]).merging(commonHeaderFields) { (current, _) in current }
        allHTTPHeaderFields = newHeaderFields
        let request = try? encoded(parameters: commonParams, parameterEncoding: URLEncoding(destination: .queryString))
        assert(request != nil, "append common params failed, please check common params value")
        return request!
    }
    
    func encoded(parameters: [String: Any], parameterEncoding: ParameterEncoding) throws -> URLRequest {
        do {
            return try parameterEncoding.encode(self, with: parameters)
        } catch {
            throw MoyaError.parameterEncoding(error)
        }
    }
}

