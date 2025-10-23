//
//  UIImageExtension.swift
//  RepNet
//
//  Created by Angel Bosquez on 16/10/25.
//

import UIKit

extension UIImage {
    /// Redimensiona la imagen para que su lado más largo no exceda un tamaño máximo, manteniendo la proporción.
    func resized(to maxResolution: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)
        
        // Si la imagen ya es más pequeña que la resolución máxima, no hacemos nada.
        if originalWidth <= maxResolution && originalHeight <= maxResolution {
            return self
        }
        
        let aspectRatio = originalWidth / originalHeight
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if aspectRatio > 1 { // Imagen horizontal
            newWidth = maxResolution
            newHeight = maxResolution / aspectRatio
        } else { // Imagen vertical o cuadrada
            newHeight = maxResolution
            newWidth = maxResolution * aspectRatio
        }
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // Dibuja la imagen en el nuevo tamaño.
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

