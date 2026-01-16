//
//  ImagePickerDelegate.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 03/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
//

import UIKit

typealias ImagePickerCallback = ((UIImage) -> ())

class ImagePickerDelegate : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var pickedImageCallback : ImagePickerCallback? = nil
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        var chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        if chosenImage.imageOrientation == .down || chosenImage.imageOrientation == .downMirrored {
            chosenImage = getFlippedImage(chosenImage)
        }
        
        pickedImageCallback!(chosenImage)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func getFlippedImage(_ image: UIImage) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
