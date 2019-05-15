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
    
    class func requestGETURL(_ url: String, headers: HTTPHeaders, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        AF.request(URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url)?.absoluteString ?? url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseString(encoding: String.Encoding.utf8) { responseObject in
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
