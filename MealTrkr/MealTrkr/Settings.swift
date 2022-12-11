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
    @IBOutlet var outletswitch: UISwitch!
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    @IBAction func darkaction(_ sender: Any){
        
        if outletswitch.isOn == true{
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        }
    
}
    //func saveallpreferences(){
        //let default = UserDefaults.standard
        
        //default.set{
            //elf.outletswitch.
        
        //}//default set
    //}//saveallpreferences
    //@IBOutlet var mySwitch: UISwitch!
    //@IBOutlet var switchOffButton: UIButton!
    //@IBOutlet var switchOnButton: UIButton!
    
    //@IBAction func switchToggled(_ sw: UISwitch){
        //if (sw.isOn){
            //turn off night mode
        //}//if
        //else{
            //switch on night mode
        //}//else
        
        
   // }//Switchhtoggled
    
    //@IBAction func switchOff(_ b: UIButton){
       // self.mySwitch.isOn = false
       // self.switchToggled(self.mySwitch)
    //}//switchoff
    
    //@IBAction func switchOn(_ b: UIButton){
      //  self.mySwitch.isOn = true
       // self.switchToggled(self.mySwitch)
    //}//switchon
    
}
