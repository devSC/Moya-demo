//
//  PKCS12Import.swift
//  TestNetwork
//
//  Created by Wilson Yuan on 2017/10/25.
//  Copyright © 2017年 Being Inc. All rights reserved.
//

import Foundation

class PKCS12Importer {
    var urlCredential: URLCredential = URLCredential()
    
    init?(data p12Data: NSData?, password: String) {
        
        guard let inpkcs12Data = CFBridgingRetain(p12Data) else {
            return nil
        }
        
        let (result, secIdentify) = extractOSStatus(from: inpkcs12Data as! CFData, password: password)
        
        guard result == errSecSuccess, let identify = secIdentify else {
            return nil
        }
        
        var secCertificate: SecCertificate? = nil
        SecIdentityCopyCertificate(identify, &secCertificate)
        
        guard let cer = secCertificate else {
            return nil
        }
        
        urlCredential = URLCredential(identity: identify, certificates: [cer], persistence: .permanent)
    }
    
    convenience init?(mainBundleResource: String, resourceType: String, password: String) {
        guard let pathToCert = Bundle.main.path(forResource: mainBundleResource, ofType: resourceType) else {
            return nil
        }
        let localCertificate = NSData(contentsOfFile: pathToCert)
        
        self.init(data: localCertificate, password: password)
    }
    
    private func extractOSStatus(from p12Data: CFData, password: String) -> (OSStatus, SecIdentity?) {
        
        var securityError = errSecSuccess
        var secIdentify: SecIdentity? = nil
        
        let certOptions : Dictionary = [kSecImportExportPassphrase as String : password]
        var secItems: CFArray?
        
        securityError = SecPKCS12Import(p12Data, certOptions as CFDictionary, &secItems)
        guard securityError == errSecSuccess else {
            return (securityError, secIdentify)
        }
        
        let secItemsArray = secItems! as Array
        let identDic = secItemsArray.first! as! Dictionary<String, AnyObject>
        secIdentify = identDic[kSecImportItemIdentity as String] as! SecIdentity?
        return (securityError, secIdentify)
    }
}
