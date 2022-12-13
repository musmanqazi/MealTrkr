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
    
    @IBAction func onClickDeleteButton(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point)
        else { return }
        
        let Meals = appDelegate.Meals
        let context = Meals.persistentContainer.viewContext
        let meal = saved_meals[indexPath.row]
        context.delete(meal)
        saved_meals.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .fade)
        tableView.endUpdates()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mma"
        
        do {
            print("Successfully deleted meal: \(dateFormatter.string(from: meal.date!))")
            try context.save()
        } catch {
            print("Error deleting meal: \(error)")
        }
    }
    
    @IBAction func onInfoButtonClick(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point)
        else { return }

        let meal = saved_meals[indexPath.row]
        
        appDelegate.CurrentMealInfo = meal
    }
    

}

extension MealsController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Hello")
//    }
}

extension MealsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saved_meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mma"

        let meal = saved_meals[indexPath.row]
        cell.label.text = dateFormatter.string(from: meal.date!)
//        cell.detailTextLabel?.text = "Calories: \(meal.calories)\nCarbs: \(meal.carbs)\nProtein: \(meal.protein)\nSaturated Fat: \(meal.saturated_fat)\nSodium: \(meal.sodium)\nCholesterol: \(meal.cholesterol)"
        
        if (meal.photo_url != nil) {
            let url = URL(string: meal.photo_url!)
            if let data = try? Data(contentsOf: url!) {
                OperationQueue.main.addOperation {
                    cell.thumbnailImageView.image = UIImage(data: data)
                }
            }
        }
    
        return cell
    }
}
