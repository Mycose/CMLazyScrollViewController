//
//  ImageViewController.swift
//  CMCarousel
//
//  Created by Clément Morissard on 20/10/16.
//  Copyright © 2016 Clément Morissard. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet var imageView : UIImageView!

    var imageName : String = ""

    override func awakeFromNib() {
        self.imageView.image = UIImage(named: imageName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(named: imageName)
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
