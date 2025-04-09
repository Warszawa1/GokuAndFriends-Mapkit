//
//  SplashController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 3/4/25.
//

import UIKit

class SplashController: UIViewController {
    
    private var secureData = SecureDataProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if secureData.getToken() != nil {
            let heroesVC = HeroesController()
            navigationController?.pushViewController(heroesVC, animated: false)
        } else {
            let loginController = LoginController()
            navigationController?.pushViewController(loginController, animated: true)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
