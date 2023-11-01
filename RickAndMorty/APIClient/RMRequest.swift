//
//  RMRequest.swift
//  RickAndMortyRA
//
//  Created by MacOS on 3.10.2023.
//

import Foundation

final class RMRequest {
    
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
    
    let endpoint: RMEndpoint
    private let pathComponents: [String]
    private let queryParameters: [URLQueryItem]
    let httpMethod = "GET"
    
    init(endpoint: RMEndpoint,pathComponents: [String] = [], queryParameters: [URLQueryItem] = []) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
//    location?page=2&name=Earth
    
    convenience init?(url: URL) {
        let string = url.absoluteString
        if !string.contains(Constants.baseUrl) {
//            print(Constants.baseUrl)
            return nil
        }
//        /character/?name=Rick
        let trimmed = string.replacingOccurrences(of: Constants.baseUrl + "/", with: "")
        if trimmed.contains("/") {
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty {
                let endpointString = components[0]
                if let rmEndpoint = RMEndpoint(rawValue: endpointString) {
                    self.init(endpoint: rmEndpoint,pathComponents: [components[1]])
//                    print(self.url?.absoluteString)
                    return
                }
                
            }
            //    location page=2&name=Earth
        }else if trimmed.contains("?") {
            let components = trimmed.components(separatedBy: "?")
            if !components.isEmpty, components.count >= 2 {
                let endpointString = components[0]
                let queryItemsString = components[1]
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                    guard $0.contains("=") else {return nil}
                    let parts = $0.components(separatedBy: "=")
                    
                    return URLQueryItem(name: parts[0], value: parts[1])
                })
                if let rmEndpoint = RMEndpoint(rawValue: endpointString) {
                    self.init(endpoint: rmEndpoint,queryParameters: queryItems)
                    return
                }
            }
        }
        return nil
     }
    
    private var urlString: String {
        var url = Constants.baseUrl
        url += "/\(endpoint.rawValue)"
        
        if !pathComponents.isEmpty {
            pathComponents.forEach { str in
                url += "/" + str
            }
        }
        
        if !queryParameters.isEmpty {
            
            let string = queryParameters.compactMap({
                guard let value = $0.value else {return nil}
                return "\($0.name)=\(value)"
            }).joined(separator: "&")
            url += "?" + string
        }
        
        return url
    }
    
    var url: URL? {
        return URL(string: urlString)
    }
}
