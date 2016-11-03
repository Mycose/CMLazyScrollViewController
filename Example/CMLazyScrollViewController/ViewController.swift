//
//  ViewController.swift
//  CMCarousel
//
//  Created by Clément Morissard on 17/10/16.
//  Copyright © 2016 Clément Morissard. All rights reserved.
//

import UIKit
import CMLazyScrollViewController

class ViewController: UIViewController, CMLazyScrollViewControllerDelegate, UIScrollViewDelegate, SwitchViewControllerDelegate {

    var imageBasename : String = "deadpool"

    let switchVC = SwitchViewController()
    let carousel = CMLazyScrollViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        switchVC.delegate = self
        // Do any additional setup after loading the view, typically from a nib.

        carousel.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        carousel.pageControlPaddingValue = 20.0
        carousel.canRotate = true
        carousel.pageControlPosition = .Left
        carousel.scrollDirection = .Horizontal
        carousel.infinite = true
        carousel.isPagingEnable = true
        carousel.delegate = self
        self.addChildViewController(carousel)
        self.view.addSubview(carousel.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: CMLazyScrollViewControllerDelegate
    func numberOfViewControllersIn(scrollViewController: CMLazyScrollViewController) -> Int {
        return 5
    }

    func viewControllerIn(scrollViewController: CMLazyScrollViewController, atIndex: Int) -> UIViewController {
        var vc : UIViewController = UIViewController()
         if (atIndex == 0) {
            vc = switchVC
         } else {
            vc = ImageViewController()
            (vc as? ImageViewController)!.imageName = "\(self.imageBasename)\(atIndex).jpg"
        }
        return vc
    }

    func newImageBasename(imagebasename: String) {
        self.imageBasename = imagebasename
        self.carousel.reload()
    }
}

