//
//  MealStore.swift
//  MealTrkr
//
//  Created by Cope, Aaron on 12/7/22.
//

import Foundation
import CoreData

class MealStore {
    let persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StoredMeals")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error).")
            }
        }
        return container
    }()
}
