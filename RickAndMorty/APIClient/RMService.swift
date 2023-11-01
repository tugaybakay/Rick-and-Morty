//
//  RMService.swift
//  RickAndMortyRA
//
//  Created by MacOS on 3.10.2023.
//

import Foundation

final class RMService {
    static let shared = RMService()
    
    private let cacheManager = RMAPICacheManager()
    
    private init() {}
    
    func execute<T:Codable>(_ request: RMRequest,expecting type: T.Type,completion: @escaping (Result<T,Error>)-> Void) {
        
        if let cacheData = cacheManager.cachedResponse(for: request.endpoint, url: request.url) {
            do{
                let result = try JSONDecoder().decode(type, from: cacheData)
                completion(.success(result))
                return
            }catch {
                completion(.failure(error))
            }
        }
        
        guard let urlRequest = self.request(from: request) else {
            completion(.failure(RMServiceError.failedToCreatedUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(RMServiceError.failedToGetData))
                return
            }
            
            do{
                let dataFromResult = try JSONDecoder().decode(type, from: data)
                self?.cacheManager.setCache(for: request.endpoint, url: request.url, data: data)
                completion(.success(dataFromResult))
            }catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func request(from rmRequest: RMRequest) -> URLRequest? {
        guard let url = rmRequest.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = rmRequest.httpMethod
        return request
    }
}

enum RMServiceError: Error {
    case failedToCreatedUrl
    case failedToGetData
}
