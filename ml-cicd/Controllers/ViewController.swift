//
//  ViewController.swift
//  ml-cicd
//
//  Created by Ascentspark on 09/09/20.
//  Copyright © 2020 Ascentspark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoButton.layer.cornerRadius = 12
        self.cameraButton.layer.cornerRadius = 12
        
        photoButton.addTarget(self, action: #selector(showImagePickerTask), for: .touchUpInside)
    }

    @objc func showImagePickerTask() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true, completion: nil)
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage ?? info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        self.selectedImage = image
        picker.dismiss(animated: true) {
            self.performSegue(withIdentifier: "ImageViewer", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ImageViewer", let imageViewController = segue.destination.children.first as? ImageViewController else {
            return
        }
        
        imageViewController.image = self.selectedImage
        self.selectedImage = nil
    }
}

