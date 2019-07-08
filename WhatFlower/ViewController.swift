//
//  ViewController.swift
//  WhatFlower
//
//  Created by Frank Mortensen on 08/07/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        
        guard let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("Could not get image!")
        }
        
        imageView.image = userPickedImage
        
        guard let cgImage = userPickedImage.cgImage else {
            fatalError("Could not convert image to CGImage")
        }
        
        detect(image: cgImage)
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CGImage) {
        
        guard let model = try? VNCoreMLModel(for: Oxford102().model) else {
            fatalError("Could not load model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            if error != nil {
                fatalError("Could not process image \(error!)")
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            print(results)
            
            if let topResult = results.first {
                self.navigationItem.title = topResult.identifier.capitalized
            } else {
                self.navigationItem.title = "Unknown!"
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Could not perform request \(error)")
        }
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func photoLibraryButtonTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

