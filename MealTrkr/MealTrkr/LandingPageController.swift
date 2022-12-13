

import UIKit


class LandingPageController : UIViewController {
    
    
    static let darkModeSwitchState = "darkModeSwitchState"
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated : Bool) {
        super.viewDidAppear(true)
        
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: LandingPageController.darkModeSwitchState) != nil) {
            if defaults.bool(forKey: LandingPageController.darkModeSwitchState) {
                print(defaults.bool(forKey: LandingPageController.darkModeSwitchState))
                UIApplication
                    .shared
                    .connectedScenes
                    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                    .first?.overrideUserInterfaceStyle = .dark
            } else {
                UIApplication
                    .shared
                    .connectedScenes
                    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                    .first?.overrideUserInterfaceStyle = .light
            }
        }
    }
    
}
    
    
