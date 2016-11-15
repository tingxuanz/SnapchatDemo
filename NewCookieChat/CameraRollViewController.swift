//
//  CameraRollViewController.swift
//  NewCookieChat
//
//  Created by Chao Liang on 16/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit
import Photos
import Firebase

class CameraRollViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    
    var imageMemory = [UIImage]()
    var imagesArray = [UIImage]()
    let fullScreen = UIScreen.main.bounds

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.frame = fullScreen
        self.collectionView.frame.origin.x = collectionView.frame.width
        self.collectionView2.frame = fullScreen
        
        scrollView.frame = fullScreen
        scrollView.frame.origin.y = 64
        scrollView.contentSize = CGSize(width: fullScreen.width*2, height: fullScreen.height)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        layout.itemSize = CGSize(width: CGFloat(self.collectionView.frame.width)/3 - 10.0,height: CGFloat(self.collectionView.frame.width)/3 - 10.0)
        self.collectionView?.collectionViewLayout = layout
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        layout2.itemSize = CGSize(width: CGFloat(self.collectionView.frame.width)/2 - 10.0,height: CGFloat(self.collectionView.frame.width)/2 - 10.0)
        self.collectionView2.collectionViewLayout = layout2
        
        
        
        
        
        
        grabImage()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView2.delegate = self
        collectionView2.dataSource = self
        print(self.collectionView)
        print(self.collectionView2)
        
        self.readMemory()
        self.collectionView.reloadData()
        
    }

//    func downloadImageFromDb(){
//        let currentUserId = FIRAuth.auth()?.currentUser?.uid
//        FIRDatabase.database().reference().child("imageUrls").child(currentUserId!).observe(.childAdded, with: {(snapshot) -> Void in
//            let downloadURL  = snapshot.value as! String
//            let storageRef = FIRStorage.storage().reference(forURL: downloadURL)
//            storageRef.downloadURL(completion: { (url, error) in
//                if error != nil {
//                    print(error?.localizedDescription)
//                } else {
//                    if let downloadURL = url?.absoluteString{
//                        self.imageUrlFromDb.append(downloadURL)
//                    }
//                }
//            })
//        })
//    }
    
    func showImageFromUrl(imageUrl : String) -> UIImage{
        var image = UIImage()
        let url = NSURL.fileURL(withPath: imageUrl)
        if let data = NSData.init(contentsOf: url){
            image = UIImage(data:data as Data)!
        }
        return image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.collectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MemoryCollectionViewCell
            cell.imageshow.image = imagesArray[indexPath.item]
            cell.isUserInteractionEnabled = true
            cell.imageshow.frame = CGRect(x:0,y:0,width: self.collectionView.frame.width/3-10, height: self.collectionView.frame.width/3-10)
            return cell
        }
        if(collectionView == self.collectionView2){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MemoryCollectionViewCell
//            let url = imageMemory[indexPath.item]
//            cell.imageshow.image = showImageFromUrl(imageUrl: url)
            cell.imageshow.image = imageMemory[indexPath.item]
            cell.isUserInteractionEnabled = true
            cell.imageshow.frame = CGRect(x:0,y:0,width: self.collectionView.frame.width/2-10, height: self.collectionView.frame.width/2-10)
            cell.backgroundColor = .black
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.collectionView){
            return self.imagesArray.count
        }
        if(collectionView == self.collectionView2){
            return self.imageMemory.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func grabImage() {
        let imgManager = PHImageManager.default()
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .opportunistic
        
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult:PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOption) {
            if(fetchResult.count > 0){
                for i in 0..<fetchResult.count{
                    imgManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOption, resultHandler: {
                        image, error in
                        self.imagesArray.append(image!)
                    })
                }
            }else{
                print("NO photo")
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if(collectionView == self.collectionView){
//            switch kind {
//            case UICollectionElementKindSectionHeader:
//                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! headerReusableView
//                headerView.label.text = "Memory"
//                return headerView
//            default: assert(false, "Unexpected element kind")
//            }
//        }
//        if(collectionView == self.collectionView2){
//            switch kind {
//            case UICollectionElementKindSectionHeader:
//                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! headerReusableView
//                headerView.label.text = "Album"
//                return headerView
//            default: assert(false, "Unexpected element kind")
//            }
//        }
//        return UICollectionReusableView()
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backToMain(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "memToMain", sender: self)
    }
    @IBAction func cam(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "memToMain", sender: self)
    }
    func readMemory() {
        do{
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentDirectorPath:String = paths[0]
            let imagesDirectoryPath = documentDirectorPath.appending("/ImagePicker")
            let titles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath)
            print(imagesDirectoryPath)
            print(titles)
            for image in titles{
                let data = FileManager.default.contents(atPath: imagesDirectoryPath.appending("/\(image)"))
                let image = UIImage(data: data!)
                self.imageMemory.append(image!)
            }
        }catch{
            print("Error")
        }
    }

}
