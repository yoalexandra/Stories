//
//  NetworkApi.swift
//  Stories
//
//  Created by Alexandra Beznosova on 07.06.2020.
//  Copyright © 2020 Alexandra Beznosova. All rights reserved.
//

import Foundation

class NetworkApi {
    
    private init() {}
    static let shared = NetworkApi()
    
    private let urlSession = URLSession.shared
    private let url = RequestURL.stories.buildUrl()
    
    func getStories(_ completion: @escaping (Result<[[String: Any]]?, Error>) -> ()) {
        urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.networkUnavailable.rawValue, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let result = jsonDictionary["results"] as? [[String: Any]] else {
                    throw NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                }
               
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
