//
//  ViewController.swift
//  MealTrkr
//
//  Created by Usman Qazi on 12/6/22.
//

import UIKit
import Photos
import PhotosUI
import CoreData

class SelectedMealInfo: UIViewController, PHPickerViewControllerDelegate {

    @IBOutlet var caloriesLabel : UILabel!
    @IBOutlet var saturatedFatLabel : UILabel!
    @IBOutlet var carbsLabel : UILabel!
    @IBOutlet var proteinLabel : UILabel!
    @IBOutlet var cholesterolLabel : UILabel!
    @IBOutlet var sodiumLabel : UILabel!
    @IBOutlet var mealImageView : UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var MealInfo : Meal?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Do any additional setup after loading the view.
        MealInfo = appDelegate.CurrentMealInfo
        if (MealInfo != nil) {
            let meal = MealInfo!
            print("Sodium recieved: \(meal.sodium)")
            caloriesLabel.text = "\(meal.calories)"
            saturatedFatLabel.text = "\(meal.saturated_fat)g"
            carbsLabel.text = "\(meal.carbs)g"
            proteinLabel.text = "\(meal.protein)g"
            cholesterolLabel.text = "\(meal.cholesterol)g"
            sodiumLabel.text = "\(meal.sodium)g"
            
            if(meal.meal_photo != nil) {
                let image = UIImage(data: meal.meal_photo!)
                mealImageView.image = image
            }
        }
        
        
    }

    @IBAction func AddPhoto(_ sender: UIButton) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        results.forEach{ result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    print("Image not recieved: \(error!)")
                    return
                }
                OperationQueue.main.addOperation{
                    self.mealImageView.image = image
                    self.uploadToImgur(image: image)
                }
            }
        }
        
    }
    
    func uploadToImgur(image: UIImage) {
        let imageData = image.jpegData(compressionQuality: 0.25)
        let base64Image = imageData!.base64EncodedString(options: .lineLength64Characters)


            let url = URL(string: "https://api.imgur.com/3/image")!
            let request = NSMutableURLRequest.init(url: url)
            request.httpMethod = "POST"
            request.addValue("Client-ID " + ImgurAPI.ClientID, forHTTPHeaderField: "Authorization")


            let boundary = NSUUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let body = NSMutableData()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"\r\n\r\n".data(using: .utf8)!)
            body.append(base64Image.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                return
            }
            guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                    return
                }
                if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("imgur upload results: \(dataString)")

                    let parsedResult: [String: AnyObject]
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                        if let dataJson = parsedResult["data"] as? [String: Any] {
                            print("Link is : \(dataJson["link"] as? String ?? "Link not found")")
                        }
                    } catch {
                        print("Error getting link")
                    }
                }
        }
        
        task.resume()
        
        
        let Meals = appDelegate.Meals
        
        let context = Meals.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Meal> = Meal.fetchRequest()
        var fetchedMeals : [Meal]?
        context.performAndWait {
            fetchedMeals = try? fetchRequest.execute()
        }
        fetchedMeals![appDelegate.CurrentMealIndex!].setValue(imageData, forKeyPath: "meal_photo")
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save meal photo: \(error)")
        }
    }

}


struct ImgurAPI{
    public static let ClientID = "a70633a770a22d3"
}

