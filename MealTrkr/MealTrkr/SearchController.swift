//
//  SearchController.swift
//  MealTrkr
//
//  Created by Cope, Aaron on 12/7/22.
//

import UIKit
import CoreData
import CryptoKit
import Foundation

class MyNetStuff
{
    static func loadData(
        from url: URL,
        completion: @escaping (Data?, URLResponse?, Error?) -> ()
    )
    {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request)
        {
            (data, response, error) in
            
            OperationQueue.main.addOperation {
                completion(data, response, error)
            }
        }
        task.resume()
    }
}

class MyPersistence
{
    static func stringToHashString(_ s: String) -> String
    {
        let data = s.data(using: String.Encoding.utf8)!
        let hash = SHA512.hash(data: data)
        let hashString = hash.map {
            String(format: "%02hhc", $0)
        }.joined()
        
        return hashString
    }
        
    func makeFileCacheURL(_ fileKey: String) -> URL
    {
        let cacheDirs = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        
        let cacheDir = cacheDirs.first!
        let fileNameHash = MyPersistence.stringToHashString(fileKey)
        let cachePath = cacheDir.appendingPathComponent(fileNameHash)
        
        return cachePath
    }
    
    func isFileCache(fileKey: String) -> Bool
    {
        let cacheURL = self.makeFileCacheURL(fileKey)
        let exists = FileManager.default.fileExists(atPath: cacheURL.path)
        return exists
    }
    
    func saveFileToCache(fileKey: String, fileData: Data?, overwrite: Bool = false)
    {
        if let fileDataSafe = fileData
        {
            let cacheURL = self.makeFileCacheURL(fileKey)
            
            if ( overwrite == false && self.isFileCache(fileKey: fileKey) )
            {
                return
            }
            
            do
            {
                try fileDataSafe.write(to: cacheURL, options: NSData.WritingOptions.atomic)
                print("File was saved to cache: \(cacheURL)")
            }
            catch
            {
                print("Error: \(error)")
            }
        }
    }
    
    func loadFileFromCache(fileKey: String) -> Data?
    {
        let cacheURL = self.makeFileCacheURL(fileKey)
        
        do
        {
            let fileData = try Data(contentsOf: cacheURL)
            print("Loading file data directly from cacheURL: \(cacheURL)")
            return fileData
        }
        catch
        {
            return nil
        }
    }
    
    func loadFileToCache(urlAsString: String, completion: @escaping (Data) -> () )
    {
        let fileURL = URL(string: urlAsString)!
        
        MyNetStuff.loadData(from: fileURL)
        {
            (data, repsonse, error) in
            
            if let theError = error {
                print("error loading file: \(theError)")
            }
            else if (data != nil) {
                self.saveFileToCache(fileKey: urlAsString, fileData: data)
                print("Loaded from URL \(urlAsString) and saved to cache.")
                OperationQueue.main.addOperation {
                    completion(data!)
                }
            }
        }
    }

}
class SearchController: UIViewController {
    @IBOutlet var SearchTextField : UITextField!
    @IBOutlet var SearchButton : UIButton!
    @IBOutlet var AddButton : UIButton!
    @IBOutlet var SaveButton : UIButton!
    @IBOutlet var FoodImage : UIImageView!
    @IBOutlet var ServingCount : UITextField!
    
    var myPersistence = MyPersistence()
    
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
    
    var food_list : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ServingsFieldChanged(_ textField: UITextField) {
        if (textField.text != nil) {
            var text = textField.text!
            if (Float(text) != nil) {
                if Float(text)! > 30 {
                    textField.text = "30"
                }
            } else if (text == "") {
                textField.text = "0"
            }
            if ((text.components(separatedBy: ".").count - 1) > 1) {
                while ((text.components(separatedBy: ".").count - 1) > 2) {
                    text = String(text.dropLast())
                    textField.text = String(text.dropLast())
                }
            } else if ((text.components(separatedBy: ",").count - 1) > 1) {
                while ((text.components(separatedBy: ",").count - 1) > 2) {
                    text = String(text.dropLast())
                    textField.text = String(text.dropLast())
                }
            }
        } else {
            textField.text = "0"
        }
    }
    
    @IBAction func SearchButtonPressed(_ sender : UIButton) {
        if (SearchTextField.text!.isEmpty) {
            print("Search Bar empty")
            return
        }
        
        getNutritionalInfo()
    }
    
    func getNutritionalInfo() {
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
                    self.getFoodImage()
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
    
    func getFoodImage() {
        let urlString = current_food.photo.highres
        if (urlString.isEmpty) {
            return
        }
        let url = URL(string: urlString)!
        
        if let data = try? Data(contentsOf: url) {
            OperationQueue.main.addOperation {
                self.FoodImage.image = UIImage(data: data)
            }
        }

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
        
        if(SearchTextField != nil) {
            food_list.append(SearchTextField.text!)
        }

        
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
            meal.photo_url = current_food.photo.highres
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mma"
        
        let desktopPath = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first
        
        let joined = food_list.joined(separator: "\n")
        do {
            try joined.write(toFile: desktopPath!, atomically: true, encoding: .utf8)
            print("Saved food list as txt to \(desktopPath!)")
        } catch {
            print("Could not save foods to txt: \(error)")
        }
        
        food_list = []
        
        SaveButton.isEnabled = false
        current_meal_totals = Nutrients(serving_qty: 0.0, serving_unit: "Cups", nf_calories: 0.0, nf_saturated_fat: 0.0, nf_sodium: 0.0, nf_cholesterol: 0.0, nf_total_carbohydrate: 0.0, nf_protein: 0.0, photo : Photo(highres: ""))
        
        do {
            try context.save()
        } catch {
            print("Error saving meal: \(error)")
        }
        
        let urlAsString = current_food.photo.highres
        if (urlAsString.isEmpty) {
            return
        }
//        let url = URL(string: urlAsString)
        
//        if let fileName = url?.lastPathComponent {
//            if (self.myPersistence.isFileCache(fileKey: urlAsString)) {
//                if let data = self.myPersistence.loadFileFromCache(fileKey: urlAsString) {
//                    self.myPersistence.saveFileToCache(fileKey: fileName, fileData: data)
//                }
//            }
//        }
        if let urlAsString = meal.photo_url {
            if (self.myPersistence.isFileCache(fileKey: urlAsString) == false) {
                self.myPersistence.loadFileToCache(urlAsString: urlAsString) {
                    (fileData) in
                    self.FoodImage.image = UIImage(data: fileData)
                    print("Success! Loaded file from URL and saved to cache.")
                }
            }
            else {
                if let data = self.myPersistence.loadFileFromCache(fileKey: urlAsString) {
                    self.FoodImage.image = UIImage(data: data)
                    print("Success! Loaded file directly from cache.")
                }
                else {
                    print("Error! Failed to load file from cache.")
                }
            }
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

