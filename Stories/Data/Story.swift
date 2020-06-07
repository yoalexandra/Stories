//
//  Story.swift
//  Stories
//
//  Created by Alexandra Beznosova on 07.06.2020.
//  Copyright © 2020 Alexandra Beznosova. All rights reserved.
//

import CoreData

class Story: NSManagedObject {
    
    @NSManaged var title: String
    @NSManaged var abstract: String
    
    func update(with json: [String: Any]) throws {
        guard let title = json["title"] as? String,
            let abstract = json["abstract"] as? String
            else {
                throw NSError(domain: "", code: 100, userInfo: nil)
        }
        self.title = title
        self.abstract = abstract
    }
}

