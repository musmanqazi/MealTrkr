//
//  SearchController.swift
//  MealTrkr
//
//  Created by Cope, Aaron on 12/7/22.
//

import UIKit

class SearchController: UIViewController {
    @IBOutlet var SearchTextField : UITextField!
    @IBOutlet var SearchButton : UIButton!
    @IBOutlet var AddButton : UIButton!
    
    var current_food : Nutrients!
    @IBOutlet var ServingSize : UILabel!
    @IBOutlet var Calories : UILabel!
    @IBOutlet var SaturatedFat : UILabel!
    @IBOutlet var Sodium : UILabel!
    @IBOutlet var Cholesterol : UILabel!
    @IBOutlet var Carbohydrates : UILabel!
    @IBOutlet var Protein : UILabel!
    
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

    func updateNutritionLabels(){
        let food = self.current_food!
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
