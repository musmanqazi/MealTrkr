//
//  Settings.swift
//  MealTrkr
//
//  Created by Jung, Andrew on 12/8/22.
//

import Foundation
import UIKit



class SettingsControler : UIViewController {
    
    
    @IBOutlet var label: UILabel!
    @IBOutlet var darkModeSwitch: UISwitch!
    
    static let darkModeSwitchState = "darkModeSwitchState"
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        darkModeSwitch.isOn = defaults.bool(forKey: SettingsControler.darkModeSwitchState)
    }
    
    @IBAction func darkaction(_ sender: UISwitch){
        let defaults = UserDefaults.standard
        if (darkModeSwitch.isOn) {
            //dark mode
            defaults.set(true, forKey: SettingsControler.darkModeSwitchState)
            UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?.overrideUserInterfaceStyle = .dark
        } else {
            //light mode
            defaults.set(false, forKey: SettingsControler.darkModeSwitchState)
            UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?.overrideUserInterfaceStyle = .light
        }
    }
}
