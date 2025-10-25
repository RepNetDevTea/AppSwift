//
//  UIImageExtension.swift
//  RepNet
//
//  Created by Angel Bosquez on 16/10/25.
//

import UIKit


extension UIImage {
    
    // MARK: - Funcion de redimensionar

    // redimensiona la imagen para que su lado mas largo no exceda 'maxresolution'
    // mantiene la proporcion original de la imagen (no la deforma)
    func resized(to maxResolution: CGFloat) -> UIImage? {
        // obtenemos la imagen base, si falla, regresamos nil
        guard let cgImage = self.cgImage else { return nil }

        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)
        
        // si la imagen ya es mas pequena que el maximo, no hacemos nada y la regresamos
        if originalWidth <= maxResolution && originalHeight <= maxResolution {
            return self
        }
        
        // calculamos la relacion de aspecto
        let aspectRatio = originalWidth / originalHeight
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if aspectRatio > 1 {
            // si es una imagen horizontal (mas ancha que alta)
            newWidth = maxResolution
            newHeight = maxResolution / aspectRatio
        } else {
            // si es una imagen vertical o cuadrada
            newHeight = maxResolution
            newWidth = maxResolution * aspectRatio
        }
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // dibuja la imagen original en un nuevo contexto (un "lienzo")
        // con el tamano nuevo
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
