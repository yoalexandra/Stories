//
//  StoriesViewController.swift
//  Stories
//
//  Created by Alexandra Beznosova on 07.06.2020.
//  Copyright © 2020 Alexandra Beznosova. All rights reserved.
//

import UIKit
import CoreData

class StoriesViewController: UITableViewController {
    var dataProvider: DataProvider!
    lazy var fetchedResultsController: NSFetchedResultsController<Story> = {
        let fetchRequest = NSFetchRequest<Story>(entityName: "Story")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending:true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: dataProvider.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider.fetchStories { error in
           // if error update ui
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let story = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = story.title
        cell.detailTextLabel?.text = story.abstract
        return cell
    }
    
}

extension StoriesViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
}
