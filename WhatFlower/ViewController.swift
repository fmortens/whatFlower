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
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    let imagePicker = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
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
            
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Model failed to process image")
            }
            
            self.navigationItem.title = classification.identifier.capitalized
            
            self.lookupFlowerInformationFromWikipedia(flowerName: classification.identifier)
            
        }
        
        let handler = VNImageRequestHandler(cgImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Could not perform request \(error)")
        }
        
    }
    
    func lookupFlowerInformationFromWikipedia(flowerName: String) {
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
        ]
        
        Alamofire
            .request(wikipediaURl, method: .get, parameters: parameters)
            .responseJSON {
                response in
                if response.result.isSuccess {
                    
                    let wikiJSON : JSON = JSON(response.result.value!)
                    let pageId = wikiJSON["query"]["pageids"][0].stringValue
                    let extract = wikiJSON["query"]["pages"][pageId]["extract"].stringValue
                    
                    self.textView.text = extract
                    
                }
                else {
                    print("Error: \(response.result.error!)")
                }
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

