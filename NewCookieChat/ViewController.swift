//
//  ViewController.swift
//  NewCookieChat
//
//  Created by Chao Liang on 10/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import ImageIO

class ViewController: UIViewController {
    @IBOutlet weak var changeCamButton: UIButton!
    @IBOutlet weak var activeFlashButton: UIButton!
    @IBOutlet var outView: UIView!
    @IBOutlet weak var cameraView: UIImageView!
    
    var session: AVCaptureSession?
    let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    let frontCamera = AVCaptureDevice.devices().filter({ ($0 as AnyObject).position == .front }).first as? AVCaptureDevice
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentCam:Int!
    var input: AVCaptureDeviceInput!
    var flashModel:Int!
    var image:UIImage?
    
    let username:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (Platform.isSimulator){
            self.image = UIImage(named: "cup")!
            print("It's an iOS Simulator")
        }
        session?.stopRunning()
        session?.startRunning()
        
        let swipeGestureRecognizerUP: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.toDown))
        let swipeGestureRecognizerDOWN: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.toUp))
        let swipeGestureRecognizerLEFT: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.toRight))
        let swipeGestureRecognizerRIGHT: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.toLeft))
        swipeGestureRecognizerUP.direction = UISwipeGestureRecognizerDirection.up
        swipeGestureRecognizerDOWN.direction = UISwipeGestureRecognizerDirection.down
        swipeGestureRecognizerLEFT.direction = UISwipeGestureRecognizerDirection.left
        swipeGestureRecognizerRIGHT.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeGestureRecognizerUP)
        self.view.addGestureRecognizer(swipeGestureRecognizerDOWN)
        self.view.addGestureRecognizer(swipeGestureRecognizerRIGHT)
        self.view.addGestureRecognizer(swipeGestureRecognizerLEFT)
    }
    
    
    
    @IBAction func changeCam(_ sender: AnyObject) {
        session!.stopRunning()
        session!.beginConfiguration()
        session!.removeInput(input)
        var error: NSError?
        if (currentCam==0){
            do {
                input = try AVCaptureDeviceInput(device: frontCamera)
                currentCam = 1
                flashLabel.text = "OFF"
                flashModel = 0
            } catch let error1 as NSError {
                error = error1
                input = nil
                print(error!.localizedDescription)
            }
        }else{
            do {
                input = try AVCaptureDeviceInput(device: backCamera)
                currentCam = 0
                flashLabel.text = "OFF"
                flashModel = 0
                try backCamera?.lockForConfiguration()
                backCamera?.flashMode = AVCaptureFlashMode.off
                backCamera?.unlockForConfiguration()
            } catch let error1 as NSError {
                error = error1
                input = nil
                print(error!.localizedDescription)
            }
        }
        session!.addInput(input)
        session!.commitConfiguration()
        session!.startRunning()
    }
    
    
    
    // Taking photo
    @IBAction func capturePhoto(_ sender: AnyObject) {
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection) { (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
//                let dataProvider = CGDataProvider(data: imageData as! CFData)
//                let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
//                self.image = UIImage(cgImage: cgImageRef!)
                self.image = UIImage(data: imageData!, scale: 1.0)!
//                self.image = image
//                UIImageWriteToSavedPhotosAlbum(self.image!, nil, nil, nil)
//                print(self.image)
                self.performSegue(withIdentifier: "toPreview", sender: self)
            }
        }
        if (Platform.isSimulator){
            self.image = UIImage(named: "cup")!
            self.performSegue(withIdentifier: "toPreview", sender: self)
            print("It's an iOS Simulator")
        }
    }
    
    
    
    
    // Flash
    @IBOutlet weak var flashLabel: UILabel!
    @IBAction func activeFlash(_ sender: AnyObject) {
        if (flashModel == 0){
            if (currentCam == 0 && (backCamera?.isFlashAvailable)!){
                do{
                    try backCamera?.lockForConfiguration()
                    backCamera?.flashMode = AVCaptureFlashMode.on
                    backCamera?.unlockForConfiguration()
                    flashLabel.text = "ON"
                    flashModel = 1
                } catch let error as NSError {
                    print(error)
                }
            }
        }else{
            if (currentCam == 0 && (backCamera?.isFlashAvailable)!){
                do{
                    try backCamera?.lockForConfiguration()
                    backCamera?.flashMode = AVCaptureFlashMode.off
                    backCamera?.unlockForConfiguration()
                    flashLabel.text = "OFF"
                    flashModel = 0
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    // segue to the photo review
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPreview" {
            if #available(iOS 10.0, *) {
                let previewView = segue.destination as! photoReviewViewController
                previewView.image = self.image!
            } else {
                // Fallback on earlier versions
            }
            
        }
        if segue.identifier == "toUp" {
            let profileView = segue.destination as! ContactDetailViewController
            if(AppState.sharedInstance.displayName == nil){
                profileView.contact = User(id: 111, name: "test", email: "test@test.com", profileImageUrl: "")
            }else{
                profileView.contact = User(id: AppState.sharedInstance.userId , name:AppState.sharedInstance.displayName, email: AppState.sharedInstance.email, profileImageUrl: "")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if (Platform.isSimulator){
            changeCamButton.isEnabled = false
            activeFlashButton.isEnabled = false
            print("It's an iOS Simulator")
        }else{
            session = AVCaptureSession()
            session!.sessionPreset = AVCaptureSessionPresetPhoto
            var error: NSError?
            do {
                input = try AVCaptureDeviceInput(device: backCamera)
                currentCam = 0
            } catch let error1 as NSError {
                error = error1
                input = nil
                print(error!.localizedDescription)
            }
            if error == nil && session!.canAddInput(input) {
                session!.addInput(input)
                // ...
                // The remainder of the session setup will go here...
            }
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if session!.canAddOutput(stillImageOutput) {
                session!.addOutput(stillImageOutput)
                // ...
                // Configure the Live Preview here...
            }
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            videoPreviewLayer!.frame = outView.bounds
            outView.layer.insertSublayer(videoPreviewLayer!, at: 0)
            session!.startRunning()
            flashLabel.text = "OFF"
            flashModel = 0
        }
    }

    @IBAction func profile(_ sender: AnyObject) {
        performSegue(withIdentifier: "toUp", sender: self)
    }
    @IBAction func chat(_ sender: AnyObject) {
        performSegue(withIdentifier: "toLeft", sender: self)
    }
    
    
    func toLeft() {
        self.performSegue(withIdentifier: "toLeft", sender: self)
    }
    func toRight() {
        self.performSegue(withIdentifier: "toRight", sender: self)
    }
    func toUp() {
        self.performSegue(withIdentifier: "toUp", sender: self)
    }
    func toDown() {
        self.performSegue(withIdentifier: "toDown", sender: self)
    }
    @IBAction func toStory(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toRight", sender: self)
    }
    @IBAction func toMemory(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toDown", sender: self)
    }
}

