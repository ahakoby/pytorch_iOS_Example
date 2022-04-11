//
//  ViewController.swift
//  test-pytorch-ios
//
//  Created by Armen Hakobyan on 18.10.21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    private var image : UIImage?
    private let testImages = ["test_1.jpg", "test_2.png", "test_3", "test_4"]
    private var imgIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        image = UIImage(named: testImages[imgIndex])!
        imageView.image = image
        detectFaceLandmarks()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
//        imgIndex = (imgIndex + 1) % testImages.count
//        image = UIImage(named: testImages[imgIndex])!
//        imageView.image = image
//        detectFaceLandmarks()
    }
    
    func detectFaceLandmarks() {
        guard let image = image else {return}
        Processor.detectFaceLandmarks(img: image, landmarkedImageCompletionHandler: {[weak self] _image in
            guard let strongSlef = self else {return}
            strongSlef.image = _image
            strongSlef.imageView.image = _image
        }, landmarksCompletionHandler: nil)
    }
}
