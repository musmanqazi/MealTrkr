//
//  SearchController.swift
//  MealTrkr
//
//  Created by Cope, Aaron on 12/7/22.
//

import UIKit
import CoreData

class SearchController: UIViewController {
    @IBOutlet var SearchTextField : UITextField!
    @IBOutlet var SearchButton : UIButton!
    @IBOutlet var AddButton : UIButton!
    @IBOutlet var SaveButton : UIButton!
    @IBOutlet var FoodImage : UIImageView!
    @IBOutlet var ServingCount : UITextField!
    
    var current_food = Nutrients(serving_qty: 0.0,
                                 serving_unit: "Cups",
                                 nf_calories: 0.0,
                                 nf_saturated_fat: 0.0,
                                 nf_sodium: 0.0,
                                 nf_cholesterol: 0.0,
                                 nf_total_carbohydrate: 0.0,
                                 nf_protein: 0.0,
                                 photo : Photo(highres: ""))
    
    @IBOutlet var ServingSize : UILabel!
    @IBOutlet var Calories : UILabel!
    @IBOutlet var SaturatedFat : UILabel!
    @IBOutlet var Sodium : UILabel!
    @IBOutlet var Cholesterol : UILabel!
    @IBOutlet var Carbohydrates : UILabel!
    @IBOutlet var Protein : UILabel!
    
    var current_meal_totals = Nutrients(serving_qty: 0.0,
                                        serving_unit: "Cups",
                                        nf_calories: 0.0,
                                        nf_saturated_fat: 0.0,
                                        nf_sodium: 0.0,
                                        nf_cholesterol: 0.0,
                                        nf_total_carbohydrate: 0.0,
                                        nf_protein: 0.0,
                                        photo : Photo(highres: ""))
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func SearchButtonPressed(_ sender : UIButton) {
        if (SearchTextField.text!.isEmpty) {
            print("Search Bar empty")
            return
        }
        
        let url = URL(string: "https://trackapi.nutritionix.com/v2/natural/nutrients")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/json",
            "x-app-id" : NutritionixAPI.x_app_id,
            "x-app-key" : NutritionixAPI.x_app_key
        ]
        
        let body = ["query" : SearchTextField.text!]
        let bodyData = try? JSONSerialization.data(
            withJSONObject : body,
            options : []
        )
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with : request) { (data, response, error) in
            if let error = error {
                print("HTTP Request error: \(error)")
            } else if let data = data {
                let decoder = JSONDecoder()
                do{
                    let jsonFood = try decoder.decode(Response.self, from: data)
                    self.current_food = jsonFood.foods[0]
                    print(jsonFood.foods[0])
                    OperationQueue.main.addOperation {
                        self.updateNutritionLabels()
                        self.AddButton.isEnabled = true
                    }
                } catch {
                    print(error)
                }
            } else {
                print("Unexpected HTTP error")
            }
        }
        task.resume()
    }
    
    @IBAction func AddFood(_ sender : UIButton) {
        let servings = Float(ServingCount.text!)!
        current_meal_totals.nf_calories += current_food.nf_calories * servings
        current_meal_totals.nf_protein += current_food.nf_protein * servings
        current_meal_totals.nf_cholesterol += current_food.nf_cholesterol * servings
        current_meal_totals.nf_saturated_fat += current_food.nf_saturated_fat * servings
        current_meal_totals.nf_total_carbohydrate += current_food.nf_total_carbohydrate * servings
        current_meal_totals.nf_sodium += current_food.nf_sodium * servings
        print(current_meal_totals)
        
        AddButton.isEnabled = false
        SaveButton.isEnabled = true
    }
    
    @IBAction func SaveMeal(_ sender : UIButton) {
        let Meals = appDelegate.Meals
        let context = Meals.persistentContainer.viewContext
        var meal: Meal!
        context.performAndWait {
            meal = Meal(context: context)
            meal.calories = current_meal_totals.nf_calories
            meal.carbs = current_meal_totals.nf_total_carbohydrate
            meal.cholesterol = current_meal_totals.nf_cholesterol
            meal.protein = current_meal_totals.nf_protein
            meal.saturated_fat = current_meal_totals.nf_saturated_fat
            meal.sodium = current_meal_totals.nf_sodium
            meal.date = Date()
        }
        
        SaveButton.isEnabled = false
        current_meal_totals = Nutrients(serving_qty: 0.0, serving_unit: "Cups", nf_calories: 0.0, nf_saturated_fat: 0.0, nf_sodium: 0.0, nf_cholesterol: 0.0, nf_total_carbohydrate: 0.0, nf_protein: 0.0, photo : Photo(highres: ""))
        
        do{
            try context.save()
        } catch {
            print("Error saving meal: \(error)")
        }
    }

    func updateNutritionLabels(){
        let food = self.current_food
        ServingSize.text = "\(food.serving_qty) \(food.serving_unit)"
        Calories.text = "\(food.nf_calories)"
        SaturatedFat.text = "\(food.nf_saturated_fat)g"
        Sodium.text = "\(food.nf_sodium)g"
        Cholesterol.text = "\(food.nf_cholesterol)g"
        Carbohydrates.text = "\(food.nf_total_carbohydrate)g"
        Protein.text = "\(food.nf_protein)g"
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        SearchTextField.resignFirstResponder()
        ServingCount.resignFirstResponder()
    }
}

struct Photo : Codable {
    var highres : String
}

struct Nutrients : Codable {
    var serving_qty: Float
    var serving_unit: String
    var nf_calories: Float
    var nf_saturated_fat: Float
    var nf_sodium: Float
    var nf_cholesterol: Float
    var nf_total_carbohydrate: Float
    var nf_protein: Float
    var photo : Photo
}

struct Response : Codable {
    var foods : [Nutrients]
}


struct NutritionixAPI {
    public static let x_app_id : String = "3b08aa0f"
    public static let x_app_key : String = "70fc61621ceda0c4e2af2b3de2c86822"
}



