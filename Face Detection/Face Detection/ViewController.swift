import UIKit
import Vision

final class ViewController: UIViewController {
    let faceDetection = VNDetectFaceRectanglesRequest()
    let faceLandmarks = VNDetectFaceLandmarksRequest()
    
    var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRequests()
        
        let titleLabel = UILabel()
        titleLabel.text = "FACE DETECTION"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        titleLabel.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 30)
        view.addSubview(titleLabel)
        
        guard let image = UIImage(named: "dad2") else {
            print("Image not found or failed to convert UIImage to CGImage")
            return
        }
        
        let framedSize = CGSize(width: 750, height: 750)
        let resizedImage = image.resized(to: framedSize)

        print("Image size: \(resizedImage.size).\n")
        
        guard let cgImage = resizedImage.cgImage else {
            print("Failed to convert UIImage to CGImage")
            return
        }
        
        let ciImage = CIImage(cgImage: cgImage).oriented(forExifOrientation: Int32(UIImage.Orientation.up.rawValue))
        
        imageView = UIImageView(image: resizedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 150, width: view.bounds.width, height: view.bounds.width)
        view.addSubview(imageView)
        
        DispatchQueue.main.async {
            self.detectFace(on: ciImage)
        }
    }

    func configureRequests() {
        #if targetEnvironment(simulator)
            if #available(iOS 17.0, *) {
                let allDevices = MLComputeDevice.allComputeDevices
                for device in allDevices {
                    if(device.description.contains("MLCPUComputeDevice")){
                        faceDetection.setComputeDevice(.some(device), for: .main)
                        faceLandmarks.setComputeDevice(.some(device), for: .main)
                        break
                    }
                }
            } else {
                faceDetection.usesCPUOnly = true
                faceLandmarks.usesCPUOnly = true
            }
        #endif
    }

    func detectFace(on image: CIImage) {
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([faceDetection])
            print("Face detection request performed.\n")
        } catch {
            print("Face detection failed: \(error)")
            return
        }
        
        guard let results = faceDetection.results, !results.isEmpty else {
            print("No face detected.")
            return
        }
        
        print("Face detected: \(results.count)\n")
        drawBoundingBox(on: results)
    }

    func drawBoundingBox(on faceObservations: [VNFaceObservation]) {
        for faceObservation in faceObservations {
            let boundingBox = faceObservation.boundingBox
            let convertedBoundingBox = convertBoundingBox(boundingBox)
            print("BoundingBox: \(convertedBoundingBox)\n")
            drawBoundingBox(convertedBoundingBox)
        }
    }

    func convertBoundingBox(_ boundingBox: CGRect) -> CGRect {
        let imageViewSize = imageView.bounds.size
        let origin = CGPoint(x: boundingBox.origin.x * imageViewSize.width, y: (1 - boundingBox.origin.y - boundingBox.size.height) * imageViewSize.height)
        let size = CGSize(width: boundingBox.size.width * imageViewSize.width, height: boundingBox.size.height * imageViewSize.height)
        return CGRect(origin: origin, size: size)
    }
    
    func drawBoundingBox(_ boundingBox: CGRect) {
        let boundingBoxPath = UIBezierPath(rect: boundingBox)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = boundingBoxPath.cgPath
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        imageView.layer.addSublayer(shapeLayer)
    }
}
