//
//  ViewController.swift
//  Program Builder
//
//  Created by Adam Grow on 8/11/22.
//

import UIKit

class InitialViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(named: "temple")
        imageView.alpha = 0.35
        imageView.contentMode = .scaleAspectFill
        
        startButton.sizeToFit()
    }
}

