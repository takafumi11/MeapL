//
//  TabBarController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/13.
//

import UIKit
import ChameleonFramework

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        
        UITabBar.appearance().tintColor = UIColor.flatWatermelon()
    }
   

}
