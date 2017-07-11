//
//  ViewController.swift
//  FaceDetection
//
//  Created by pooja on 24/06/2017.
//  Copyright © 2017 pooja. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    @IBOutlet weak var imgView:UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.detectAndDraw()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDashedLine(center: CGPoint, r: CGFloat) {
        let circlePath = UIBezierPath(arcCenter: center, radius: CGFloat(r), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.red.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 2.0
        let castAsNSNumber : NSNumber = 2

        shapeLayer.lineDashPattern = [castAsNSNumber]

        self.imgView!.layer.addSublayer(shapeLayer)
    }

    func detectAndDraw() {
        
        guard let personciImage = CIImage(image: (self.imgView?.image)!) else {
            return
        }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)

        var exifOrientation : Int
        switch ((self.imgView?.image)!.imageOrientation)
        {
        case UIImageOrientation.up:
            exifOrientation = 1;
        case UIImageOrientation.down:
            exifOrientation = 3;
        case UIImageOrientation.left:
            exifOrientation = 8;
        case UIImageOrientation.right:
            exifOrientation = 6;
        case UIImageOrientation.upMirrored:
            exifOrientation = 2;
        case UIImageOrientation.downMirrored:
            exifOrientation = 4;
        case UIImageOrientation.leftMirrored:
            exifOrientation = 5;
        case UIImageOrientation.rightMirrored:
            exifOrientation = 7;
        }
        
        let faces = faceDetector?.features(in: personciImage, options:["CIDetectorImageOrientation":exifOrientation])
        
        // For converting the Core Image Coordinates to UIView Coordinates
        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        for face in faces as! [CIFaceFeature] {
            
            print("Found bounds are \(face.bounds)")
            
            // Apply the transform to convert the coordinates
            var faceViewBounds = face.bounds.applying(transform)
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = self.imgView?.bounds.size
            let scale = min((viewSize?.width)! / ciImageSize.width,
                            (viewSize?.height)! / ciImageSize.height)
            let offsetX = ((viewSize?.width)! - ciImageSize.width * scale) / 2
            let offsetY = ((viewSize?.height)! - ciImageSize.height * scale) / 2
            
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
//            let faceBox = UIView(frame: faceViewBounds)
//            
//            faceBox.layer.borderWidth = 1
//            faceBox.layer.borderColor = UIColor.red.cgColor
//            faceBox.layer.cornerRadius = faceBox.frame.size.height/2
//            faceBox.backgroundColor = UIColor.clear
//            self.imgView?.addSubview(faceBox)
            
            let midX = faceViewBounds.midX
            let midY = faceViewBounds.midY

            self.addDashedLine(center:  CGPoint (x : midX, y : midY), r: faceViewBounds.size.height/2)
            if face.hasLeftEyePosition {
                print("Left eye bounds are \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
                print("Right eye bounds are \(face.rightEyePosition)")
            }
        }
    }

}



