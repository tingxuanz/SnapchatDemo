//
//  photoReviewViewController.swift
//  NewCookieChat
//
//  Created by Chao Liang on 11/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation
import Firebase
import CoreData

@available(iOS 10.0, *)
class photoReviewViewController: UIViewController {

    var filterN = 1
    var oriImage:UIImage!
    @IBOutlet weak var photoReviewImageView: UIImageView?
    var image = UIImage()
    var picture:PictureInput!
    var filter:SaturationAdjustment!
    var imageArray: Array<UIImageView> = []
    var textArray: Array<UILabel> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoReviewImageView!.image = self.image
        self.oriImage = self.image
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func filterTest(_ sender: AnyObject) {
//        picture = PictureInput(image: self.image)
//        filter = SaturationAdjustment()
//        picture --> filter --> displayView
//        picture.processImage()
//        let testImage = image
//        let toonFilter = SmoothToonFilter()
//        let filteredImage = testImage.filterWithOperation(toonFilter)
//        display.image = testImage
        
    }
    @IBAction func addIcon(_ sender: AnyObject) {
        let icon = UIImage(named: "G1")
        let iconImageView = UIImageView(image: icon!)
        iconImageView.frame = CGRect(x: 100, y: 100, width: (icon?.size.width)!, height: (icon?.size.height)!)
        imageArray.append(iconImageView)
        view.addSubview(iconImageView)
        iconImageView.isUserInteractionEnabled = true
        let drag = UIPanGestureRecognizer(target: self, action: #selector(photoReviewViewController.dragged(_:)))
        iconImageView.addGestureRecognizer(drag)
        
    }
    
    func addText(text: String) -> Void {
        let label = UILabel(frame: CGRect(x:100,y:100,width:300,height:50))
        label.textAlignment = .natural
        label.font = UIFont(name: "AvenirNext-Heavy", size: 24.0)
        label.textColor = .white
        label.text = text
        textArray.append(label)
        view.addSubview(label)
        label.isUserInteractionEnabled = true
        let drag = UIPanGestureRecognizer(target: self, action: #selector(photoReviewViewController.dragged(_:)))
        label.addGestureRecognizer(drag)
    }
    
    func dragged(_ dragGesture: UIPanGestureRecognizer) {
        if dragGesture.state == .began || dragGesture.state == .changed {
            var newPosition = dragGesture.translation(in: dragGesture.view!)
            newPosition.x += dragGesture.view!.center.x
            newPosition.y += dragGesture.view!.center.y
            dragGesture.view!.center = newPosition
            dragGesture.setTranslation(CGPoint.zero,in: dragGesture.view)
        }
    }
    
    func mergeImage() -> UIImage {
        let size = CGSize(width: (photoReviewImageView?.frame.width)!, height: (photoReviewImageView?.frame.height)!)
        UIGraphicsBeginImageContext(size)
        
        let aspectSize = CGSizeAspectFill(aspectRatio: self.image.size, minimumSize: size)
        var x:CGFloat
        var y:CGFloat
        if(aspectSize.width>size.width){
            x = -(aspectSize.width - size.width)/2
            y = 0
        }else{
            x = 0
            y = -(aspectSize.height - size.height)/2
        }
        let areaSize = CGRect(x:x,y:y,width: aspectSize.width, height:aspectSize.height)
        print(areaSize)
        self.image.draw(in: areaSize)
        for sub in imageArray{
            sub.image?.draw(in: sub.frame)
        }
        for text in textArray{
            let plainText:NSString = NSString(string: text.text!)
            plainText.draw(in: text.frame, withAttributes: [NSFontAttributeName:text.font, NSForegroundColorAttributeName: text.textColor])
        }
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
//        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
        return newImage
    }
    
    func CGSizeAspectFill(aspectRatio:CGSize, minimumSize:CGSize) -> CGSize {
        var aspectFillSize:CGSize = CGSize(width: minimumSize.width, height: minimumSize.height)
        let mW = minimumSize.width / aspectRatio.width
        let mH = minimumSize.height / aspectRatio.height
        if( mH > mW ) {
            aspectFillSize.width = mH * aspectRatio.width
        }else if( mW > mH ){
            aspectFillSize.height = mW * aspectRatio.height
        }
        return aspectFillSize;
    }
    @IBAction func addTextButton(_ sender: AnyObject) {
        let alertMessage = UIAlertController(title: "Input", message:"Make some input for adding to the image.",preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (action: UIAlertAction) in
            let inputField = alertMessage.textFields?[0]
            let input = inputField?.text
            self.addText(text: input!)
        }))
        alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (action: UIAlertAction) in
            // do
        }))
        alertMessage.addTextField(configurationHandler: { (text: UITextField) in
            text.placeholder = "Input here..."
        })
        self.present(alertMessage, animated: true, completion: nil)
    }
    @IBAction func freeHand(_ sender: AnyObject) {
    }
    @IBAction func dismissView(_ sender: AnyObject) {
//        dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "previewToMain", sender: self)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }  
    @IBAction func savePreview(_ sender: AnyObject) {
        let newImage = mergeImage()
        saveMemory(newImage: newImage)
    }

    func saveMemory(newImage:UIImage){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectorPath:String = paths[0]
        var imagesDirectoryPath = documentDirectorPath.appending("/ImagePicker")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }

        imagesDirectoryPath = imagesDirectoryPath.appending("/\(Date().timeIntervalSince1970).png")
        print(imagesDirectoryPath)
        let data = UIImagePNGRepresentation(newImage)
        print(data)
        let success = FileManager.default.createFile(atPath: imagesDirectoryPath, contents: data, attributes: nil)

    }

    @IBAction func changeFilter(_ sender: AnyObject) {
        image = applyFilter(image: oriImage)
        self.photoReviewImageView?.image = self.image
    }
    func applyFilter(image:UIImage) -> UIImage {
        let oriImage = image
        let filter1 = ToonFilter()
        let filter2 = SketchFilter()
        let filter3 = Luminance()
        let filter4 = GlassSphereRefraction()
        var filteredImage:UIImage = UIImage()
        if(filterN == 0){
            filteredImage = oriImage
            filterN = filterN+1
        }else if(filterN == 1){
            filteredImage = image.filterWithOperation(filter1)
            filterN = filterN+1
        }else if(filterN == 2){
            filteredImage = image.filterWithOperation(filter2)
            filterN = filterN+1
        }else if(filterN == 3){
            filteredImage = image.filterWithOperation(filter3)
            filterN = filterN+1
        }else if(filterN == 4){
            filteredImage = image.filterWithOperation(filter4)
            filterN = 0
        }
        return filteredImage
    }
    @IBAction func send(_ sender: AnyObject) {
        performSegue(withIdentifier: "previewToFriend", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "previewToFriend"){
            let des = segue.destination as! friendList
            des.enableEdit = true
            let new = mergeImage()
            des.sentImage = new
        }
    }
}
