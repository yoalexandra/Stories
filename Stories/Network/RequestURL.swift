//
//  RequestURL.swift
//  Stories
//
//  Created by Alexandra Beznosova on 07.06.2020.
//  Copyright © 2020 Alexandra Beznosova. All rights reserved.
//

import Foundation

let apiKey = "uXvUwtprWyPIvJ5hWPvCR6KCDdATV5A3"

enum RequestURL {
    
    static let baseUrl = "https://api.nytimes.com"
    
    case stories
    
    var path: String {
        switch self {
        case .stories:
            return "/svc/topstories/v2/world.json"
        }
    }
    
    var parameters: String? {
        switch self {
        case .stories:
            return "?api-key=\(apiKey)"
        }
    }
    
    func buildUrl() -> URL {
        var absolutePath = "\(RequestURL.baseUrl)\(path)"
        if let parameters = parameters {
            absolutePath += parameters
        }
        return URL(string: absolutePath)!
    }
}
