//
//  RMAPICacheManager.swift
//  RickAndMortyRA
//
//  Created by MacOS on 15.10.2023.
//

import Foundation

final class RMAPICacheManager {
    
    private var cacheDictionary: [RMEndpoint: NSCache<NSString,NSData>] = [:]
    private let cache = NSCache<NSString,NSData>()
    
    init() {
        setUpCache()
    }
    
    func cachedResponse(for endpoint: RMEndpoint, url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[endpoint], let url = url else { return nil }
        let data = targetCache.object(forKey: url.absoluteString as NSString)
        return data as? Data
    }
    
    func setCache(for endpoint: RMEndpoint, url: URL?, data: Data) {
        guard let targetCache = cacheDictionary[endpoint], let url = url else { return }
        let key = url.absoluteString as NSString
        targetCache.setObject(data as NSData, forKey: key)
    }
    
    private func setUpCache() {
        RMEndpoint.allCases.forEach { endpoint in
            cacheDictionary[endpoint] = NSCache<NSString,NSData>()
        }
    }
}
