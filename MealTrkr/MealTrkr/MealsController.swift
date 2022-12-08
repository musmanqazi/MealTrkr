//
//  MealsController.swift
//  MealTrkr
//
//  Created by Cope, Aaron on 12/7/22.
//

import UIKit
import CoreData


class MealsController: UITableViewController{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        let Meals = appDelegate.Meals
        
        let context = Meals.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Meal> = Meal.fetchRequest()
        var fetchedMeals : [Meal]?
        context.performAndWait {
            fetchedMeals = try? fetchRequest.execute()
        }
        print("Meals View loaded. CoreData founds \(fetchedMeals!.count) meals stored.")
    }

    
    
    
}

