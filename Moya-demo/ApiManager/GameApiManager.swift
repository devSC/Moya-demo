//
//  GameApiManager.swift
//  Game
//
//  Created by Wilson Yuan on 2017/10/25.
//  Copyright © 2017年 Game.com Inc. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import enum Result.Result


private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJson = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJson, options: .prettyPrinted)
        return prettyData
    } catch  {
        return data
    }
}

struct GameResponse {
    let response: HTTPURLResponse
}

class GameAPIManager {
    struct ResponseError: Error, CustomStringConvertible {
        enum Code: Int {
            case serviceError = 0, httpError = 1
            case timeout = 2, cancelled = 3, unknow = 4
            case invalidToken = 401, expiredToken = 402
        }
        let message: String
        let code: Code
        
        var description: String {
            return "errorCode: \(code), message: \(message)"
        }
    }

    private static let `default` = GameAPIManager()
    private let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
        certificates: ServerTrustPolicy.certificates(),
        validateCertificateChain: true,
        validateHost: false
    )
    private let manager: SessionManager
    private let gameApiProvider: MoyaProvider<Game>
    private let pkcs12Import = PKCS12Importer(
        mainBundleResource: "client",
        resourceType: "p12",
        password: "******"
    )
    
    init() {
        //config the params if you need.
//        let serverTrustPolicies = ["\(HttpHost)" : serverTrustPolicy]
//        let serverTrustPolicyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        
        manager = SessionManager(
            configuration: URLSessionConfiguration.default
//            delegate: SessionDelegate(),
//            serverTrustPolicyManager: serverTrustPolicyManager
        )
        
        gameApiProvider = MoyaProvider<Game>(
            manager: manager,
            plugins: [
                NetworkLoggerPlugin(
                    verbose: true, responseDataFormatter: JSONResponseDataFormatter
                ),
                RequestHandlingPlugin()
            ]
        )
        
//        customSessionDidReceiveChallengeDelegateMethod()
    }
    
    @discardableResult
    static func request(
        _ target: Game,
        callbackQueue: DispatchQueue? = nil,
        progress: Moya.ProgressBlock? = nil,
        success: @escaping (Moya.Response) -> Void,
        failure: @escaping (MoyaError) -> Void) -> Cancellable {
        
        return GameAPIManager.default.gameApiProvider.request(
            target,
            callbackQueue: callbackQueue,
            progress: progress,
            completion: { (result) in
                switch result {
                case .success(let response):
                    success(response)
                case .failure(let error):
                    failure(error)
                }
                
        })
    }
}

private extension GameAPIManager {
    func customSessionDidReceiveChallengeDelegateMethod() {
        manager.delegate.sessionDidReceiveChallengeWithCompletion = { [weak self] (session, challenge, completion) in
            guard let `self` = self else {
                completion(.performDefaultHandling, nil)
                return
            }

            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                guard
                    let serverTrust = challenge.protectionSpace.serverTrust,
                    self.serverTrustPolicy.evaluate(serverTrust, forHost: challenge.protectionSpace.host) else {
                        completion(.performDefaultHandling, nil)
                        return
                }
                completion(.useCredential, URLCredential(trust: serverTrust))
            }
            else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                guard let pkcs12Import = self.pkcs12Import else {
                    completion(.performDefaultHandling, nil)
                    return

                }
                completion(.useCredential, pkcs12Import.urlCredential)
            }
            else {
                completion(.performDefaultHandling, nil)
            }
        }
    }
}
