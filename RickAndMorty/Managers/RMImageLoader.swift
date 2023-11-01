//
//  ImageLoader.swift
//  RickAndMortyRA
//
//  Created by MacOS on 9.10.2023.
//

import Foundation

final class RMImageLoader {
    static let shared = RMImageLoader()
    
    
    private var imageDataCache = NSCache<NSString,NSData>()
    
    private init() {}
    
    func downloadImage(with url: URL, completion: @escaping(Result<Data,Error>) -> Void) {
//        print(url.absoluteString)
        let key = url.absoluteString as NSString
        if let data = imageDataCache.object(forKey: key) {
            completion(.success(data as Data))
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            let value = data as NSData
            self.imageDataCache.setObject(value, forKey: key)
            completion(.success(data))
        }
        task.resume()
    }
}
