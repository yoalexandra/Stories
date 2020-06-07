//
//  SceneDelegate.swift
//  Stories
//
//  Created by Alexandra Beznosova on 07.06.2020.
//  Copyright © 2020 Alexandra Beznosova. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var coreDataStack = CoreDataStack.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let vc = (window?.rootViewController as? UINavigationController)?.topViewController as? StoriesViewController
        vc?.dataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, network: NetworkApi.shared)
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

