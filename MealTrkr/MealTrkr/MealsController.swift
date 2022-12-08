//
//  MealsController.swift
//  MealTrkr
//
//  Created by Cope, Aaron on 12/7/22.
//

import UIKit
import CoreData


class MealsController: UIViewController{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var saved_meals : [Meal] = []
    
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        saved_meals = fetchedMeals!
        print("Meals View loaded. CoreData founds \(saved_meals.count) meals stored.")
        tableView.reloadData()
    }
    
}

extension MealsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Hello")
    }
}

extension MealsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saved_meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mma"
        
        let meal = saved_meals[indexPath.row]
        cell.textLabel?.text = dateFormatter.string(from: meal.date!)
        cell.detailTextLabel?.text = "Calories: \(meal.calories)\nCarbs: \(meal.carbs)\nProtein: \(meal.protein)\nSaturated Fat: \(meal.saturated_fat)\nSodium: \(meal.sodium)\nCholesterol: \(meal.cholesterol)"
        
        return cell
    }
}
