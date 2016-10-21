//
//  BoutonViewController.swift
//  CMCarousel
//
//  Created by Clément Morissard on 20/10/16.
//  Copyright © 2016 Clément Morissard. All rights reserved.
//

import UIKit

protocol SwitchViewControllerDelegate {
    func newImageBasename(imagebasename: String)
}

class SwitchViewController: UIViewController {

    @IBOutlet var buttons : [UIButton]!

    @IBOutlet var deadpoolButton : UIButton!
    @IBOutlet var carsButton : UIButton!
    @IBOutlet var animalsButton : UIButton!
    @IBOutlet var pokemonsButton : UIButton!

    var delegate : SwitchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.deadpoolButton.layer.borderColor = UIColor(red: 58.0/255.0, green: 95.0/255.0, blue: 205.0/255.0, alpha: 1.0).cgColor
        self.deadpoolButton.layer.borderWidth = 1.0

        self.carsButton.layer.borderColor = UIColor(red: 58.0/255.0, green: 95.0/255.0, blue: 205.0/255.0, alpha: 1.0).cgColor
        self.carsButton.layer.borderWidth = 1.0

        self.animalsButton.layer.borderColor = UIColor(red: 58.0/255.0, green: 95.0/255.0, blue: 205.0/255.0, alpha: 1.0).cgColor
        self.animalsButton.layer.borderWidth = 1.0

        self.pokemonsButton.layer.borderColor = UIColor(red: 58.0/255.0, green: 95.0/255.0, blue: 205.0/255.0, alpha: 1.0).cgColor
        self.pokemonsButton.layer.borderWidth = 1.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func resetAllButtons() {
        for button in self.buttons {
            button.isSelected = false
            button.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func deadpoolButtonClicked() {
        self.resetAllButtons()
        self.deadpoolButton.isSelected = true
        self.deadpoolButton.backgroundColor = UIColor.black
        self.delegate?.newImageBasename(imagebasename: "deadpool")
    }

    @IBAction func carsButtonClicked() {
        self.resetAllButtons()
        self.carsButton.isSelected = true
        self.carsButton.backgroundColor = UIColor.black
        self.delegate?.newImageBasename(imagebasename: "cars")
    }

    @IBAction func animalButtonClicked() {
        self.resetAllButtons()
        self.animalsButton.isSelected = true
        self.animalsButton.backgroundColor = UIColor.black
        self.delegate?.newImageBasename(imagebasename: "animal")
    }

    @IBAction func pokemonsButtonClicked() {
        self.resetAllButtons()
        self.pokemonsButton.isSelected = true
        self.pokemonsButton.backgroundColor = UIColor.black
        self.delegate?.newImageBasename(imagebasename: "pokemon")
    }
}
