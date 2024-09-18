import UIKit
import Foundation

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        let origin = CGPoint(x: self.origin.x * size.width, y: (1 - self.origin.y - self.size.height) * size.height)
        let scaledSize = CGSize(width: self.size.width * size.width, height: self.size.height * size.height)
        return CGRect(origin: origin, size: scaledSize)
    }
}
