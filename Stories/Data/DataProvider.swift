//
//  DataProvider.swift
//  Stories
//
//  Created by Alexandra Beznosova on 07.06.2020.
//  Copyright © 2020 Alexandra Beznosova. All rights reserved.
//

import CoreData

let dataErrorDomain = "dataErrorDomain"

enum DataErrorCode: NSInteger {
    case networkUnavailable = 101
    case wrongDataFormat = 102
}

class DataProvider {
    
    private let persistentContainer: NSPersistentContainer
    private let network: NetworkApi
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(persistentContainer: NSPersistentContainer, network: NetworkApi) {
        self.persistentContainer = persistentContainer
        self.network = network
    }
    
    func fetchStories(_ completion: @escaping (Error?) -> Void) {
        
        network.getStories { result in
            do {
                guard let jsonDictionary = try result.get() else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
                    return }
                
                let taskContext = self.persistentContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil
                
                _ = self.syncStories(dictionary: jsonDictionary, taskContext: taskContext)
                
                completion(nil)
                    
            } catch {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
            }
        }
    }
    
    private func syncStories(dictionary: [[String: Any]], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            let matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Story")
            let titles = dictionary.map { $0["title"] as? String }.compactMap { $0 }
            matchingEpisodeRequest.predicate = NSPredicate(format: "title in %@", argumentArray: [titles])
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\n Could not delete existing records.")
                return
            }
            
            // Create new records.
            for storyDictionary in dictionary {
                
                guard let story = NSEntityDescription.insertNewObject(forEntityName: "Story", into: taskContext) as? Story else {
                    print("Error: Failed to create a new Story object!")
                    return
                }
                
                do {
                    try story.update(with: storyDictionary)
                } catch {
                    print("Error: \(error)\n object will be deleted.")
                    taskContext.delete(story)
                }
            }
            
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
}
