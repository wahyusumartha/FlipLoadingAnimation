//
//  ViewController.swift
//  FlipLoadingAnimation
//
//  Created by Wahyu Sumartha on 06/10/2016.
//  Copyright © 2016 Wahyu Sumartha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    static let flipViewWidthAndHeight: CGFloat = 50
    let flipView = FlipLoadingAnimationView(frame: CGRect(x: ((UIScreen.mainScreen().bounds.size.width - ViewController.flipViewWidthAndHeight) / 2),
        y: ((UIScreen.mainScreen().bounds.size.height - ViewController.flipViewWidthAndHeight)/2),
        width: ViewController.flipViewWidthAndHeight,
        height: ViewController.flipViewWidthAndHeight))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(flipView)
        flipView.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

