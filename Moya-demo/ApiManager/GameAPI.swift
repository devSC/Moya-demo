//
//  GameAPI.swift
//  Game
//
//  Created by Wilson Yuan on 2017/10/23.
//  Copyright © 2017年 Game.com Inc. All rights reserved.
//

import Foundation
import Moya
import Alamofire

let HttpScheme = "https";
let HttpHost = "httpbin.org";

public enum Game {
    case login(String, String)
    case get
}

extension Game: TargetType {
    public var baseURL: URL {
        return URL(string: "\(HttpScheme)://\(HttpHost)")!
    }
    
    public var path: String {
        switch self {
        case .get:
            return "/get"
        default:
            return "/"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login:
            return .post
        default:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case .login(let username, let password):
            let defaultEncoding = URLEncoding(destination: .queryString);
            return .requestParameters(parameters: ["username" : username, "password" : password], encoding: defaultEncoding)
        default:
            return .requestPlain
        }
    }
    
    public var validate: Bool {
        return false
    }
    
    public var sampleData: Data {
        return "Hello world".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String : String]? {
        return nil
    }
}

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
