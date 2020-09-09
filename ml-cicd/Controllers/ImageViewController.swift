//
//  ImageViewController.swift
//  ml-cicd
//
//  Created by Ascentspark on 09/09/20.
//  Copyright © 2020 Ascentspark. All rights reserved.
//

import UIKit
import NSFWDetector
import QuartzCore

class ImageViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var blurView: UIVisualEffectView!
    @IBOutlet private weak var nsfwLabel: UILabel!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blurView.layer.cornerRadius = 10
        blurView.clipsToBounds = true
        
        guard let image = self.image else {
            self.nsfwLabel.text = "No Image Selected"
            return
        }
        
        self.imageView.image = image
        
        NSFWDetector.shared.check(image: image) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .error:
                self.nsfwLabel.text = "Detection Failed"
            case let .success(nsfwConfidence: confidence):
                self.nsfwLabel.text = String(format: "%.1f %% porn", confidence * 100.0)
            }
        }
        
    }
    

    @IBAction func closeButtonTask(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
