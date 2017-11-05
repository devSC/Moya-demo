//
//  ViewController.swift
//  Moya-demo
//
//  Created by Wilson-Yuan on 2017/11/5.
//  Copyright © 2017年 Wilson-Yuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        testApiManager()
    }
    
    func testApiManager() {
        GameAPIManager.request(.get, success: { (response) in
            print("response: \(response)")
        }) { (error) in
            print("error: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

