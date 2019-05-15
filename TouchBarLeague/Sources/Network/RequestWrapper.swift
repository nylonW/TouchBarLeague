//
//  RequestWrapper.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 15/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestWrapper: NSObject {
    
    private static var session: Alamofire.Session = {
        let url = "127.0.0.1"
        let manager = ServerTrustManager(evaluators: [url : DisabledEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
    class func requestGETURL(_ url: String, headers: HTTPHeaders, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        session.request(URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url)?.absoluteString ?? url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseString(encoding: String.Encoding.utf8) { responseObject in
            switch responseObject.result {
            case .success:
                let resJson = responseObject.value
                success(resJson!)
            case .failure:
                let error : Error = responseObject.error!
                failure(error)
            }
        }
    }
    
    class func requestGETURL(_ url: String, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        session.request(URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url)?.absoluteString ?? url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseString(encoding: String.Encoding.utf8) { responseObject in
            switch responseObject.result {
            case .success:
                let resJson = responseObject.value
                success(resJson!)
            case .failure:
                let error : Error = responseObject.error!
                failure(error)
            }
        }
    }
}
