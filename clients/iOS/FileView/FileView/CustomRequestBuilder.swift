//
//  CustomRequestBuilder.swift
//  FileView
//
//  Created by Kevin Scardina on 3/22/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit
import Alamofire

class CustomRequestBuilderTrustedHost {
    private static var trustedHost = ""
    private static let lock = DispatchSemaphore(value: 1)
    class func setTrustedHost(_ host:String) {
        lock.wait()
        CustomRequestBuilderTrustedHost.trustedHost = host
        lock.signal()
    }
    class func getTrustedHost() -> String {
        lock.wait()
        let trustedHost = CustomRequestBuilderTrustedHost.trustedHost
        lock.signal()
        return trustedHost
    }
}

class CustomRequestBuilderFactory: RequestBuilderFactory {
    class func SetCustomRequestBuilderFactory() -> Void {
        SwaggerClientAPI.requestBuilderFactory = CustomRequestBuilderFactory()
    }
    
    func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
        return CustomRequestBuilder<T>.self
    }
    
    func getBuilder<T>() -> RequestBuilder<T>.Type where T : Decodable {
        return CustomRequestBuilder<T>.self
    }
}

class CustomRequestBuilder<T>: AlamofireRequestBuilder<T> {
    override func createSessionManager() -> Alamofire.SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = buildHeaders()
        
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            CustomRequestBuilderTrustedHost.getTrustedHost(): .disableEvaluation
        ]
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }
    override func buildHeaders() -> [String : String] {
        var headers = super.buildHeaders()
        headers["Authorization"] = "Bearer " + ConnectLogicFactory.connectLogic.key
        return headers
    }
}
