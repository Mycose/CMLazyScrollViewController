//
//  CMPageControl.swift
//  CMPageControl
//
//  Created by Clément Morissard on 26/10/16.
//  Copyright © 2016 Clément Morissard. All rights reserved.
//

import UIKit

@objc public enum CMPageControlOrientation : Int {
    case Horizontal = 0
    case Vertical = 1
}

public protocol CMPageControlDelegate {
    func elementClicked(pageControl : CMPageControl, atIndex: Int)
    func shouldChangeIndex(from : Int, to : Int) -> Bool
}

@IBDesignable
public class CMPageControl: UIControl {

    // MARK: - PRIVATE PROPERTIES
    fileprivate var currentView : UIView?

    fileprivate var views : [UIView?] = []
    fileprivate var imageViews : [UIImageView?] = []
    fileprivate var buttons : [UIButton?] = []

    fileprivate var buttonWidth : CGFloat = 10.0

    fileprivate func cleanViews() {
        for view in views {
            if let view = view {
                view.removeFromSuperview()
                views[view.tag] = nil
            }
        }
        for button in buttons {
            if let btn = button {
                btn.removeFromSuperview()
                buttons[btn.tag] = nil
            }
        }
    }

    // MARK: - PUBLIC PROPERTIES
    public var currentIndex : Int = 0 {
        didSet {
            if currentIndex < 0 || currentIndex > numberOfElements-1 { return }

            for view in views {
                if let view = view {
                    if view.tag == currentIndex {
                        currentView = view
                        setSelectedStyleForView(view: view, animated: true)
                    } else {
                        setUnselectedStyleForView(view: view, animated: true)
                    }
                }
            }
        }
    }

    @IBInspectable public var numberOfElements : Int = 0 {
        didSet {
            setup()
        }
    }

    @IBInspectable public var elementSpacing : CGFloat = 10.0

    @IBInspectable public var elementWidth : CGFloat = 7.0 {
        didSet {
            buttonWidth = elementWidth * 1.5
        }
    }

    @IBInspectable public var elementCornerRadius : CGFloat = 5.0 {
        didSet {
            if (isRounded == true) {
                for view in views {
                    if let view = view {
                        view.layer.masksToBounds = true
                        view.layer.cornerRadius = elementCornerRadius
                    }
                }
            }
        }
    }

    @IBInspectable public var isRounded : Bool = true {
        didSet {
            for view in views {
                if let view = view {
                    if (isRounded == true) {
                        view.layer.masksToBounds = true
                        view.layer.cornerRadius = elementCornerRadius
                    } else {
                        view.layer.masksToBounds = false
                        view.layer.cornerRadius = 0
                    }
                }
            }
        }
    }

    @IBInspectable public var elementImage : UIImage? {
        didSet {
            setup()
        }
    }

    @IBInspectable public var elementBackgroundColor : UIColor = UIColor.white.withAlphaComponent(0.2) {
        didSet {
            for view in views {
                if let view = view, view != currentView {
                    view.backgroundColor = elementBackgroundColor
                }
            }
        }
    }

    @IBInspectable public var elementBorderColor : UIColor = UIColor.clear {
        didSet {
            for view in views {
                if let view = view, view != currentView {
                    view.layer.borderColor = elementBorderColor.cgColor
                }
            }
        }
    }

    @IBInspectable public var elementBorderWidth : CGFloat = 0.0 {
        didSet {
            for view in views {
                if let view = view, view != currentView {
                    view.layer.borderWidth = elementBorderWidth
                }
            }
        }
    }

    @IBInspectable public var elementSelectedImage : UIImage? {
        didSet {
            if let view = currentView as? UIImageView {
                view.image = elementSelectedImage
            }
        }
    }

    @IBInspectable public var elementSelectedBackgroundColor : UIColor = UIColor.white {
        didSet {
            if let view = currentView {
                view.backgroundColor = elementSelectedBackgroundColor
            }
        }
    }

    @IBInspectable public var elementSelectedBorderColor : UIColor = UIColor.clear {
        didSet {
            if let view = currentView {
                view.layer.borderColor = elementSelectedBorderColor.cgColor
            }
        }
    }

    @IBInspectable public var elementSelectedBorderWidth : CGFloat = 0.0 {
        didSet {
            if let view = currentView {
                view.layer.borderWidth = elementSelectedBorderWidth
            }
        }
    }

    @IBInspectable public var orientation : CMPageControlOrientation = .Horizontal {
        didSet {
            setup()
        }
    }

    public var delegate : CMPageControlDelegate?

    fileprivate func setup() {
        cleanViews()

        let nbSpace : Int = numberOfElements + 1
        var spaceWidth : CGFloat = 0.0
        var xPos : CGFloat = 0.0
        var yPos : CGFloat = 0.0

        views = Array(repeating: nil, count: numberOfElements)
        buttons = Array(repeating: nil, count: numberOfElements)
        for i in 0..<numberOfElements {

            // calculate x and y depending on if vertical or horizontal and depending on index
            if (orientation == .Horizontal) {
                spaceWidth = (frame.width - (CGFloat(numberOfElements) * elementWidth)) / CGFloat(nbSpace)
                xPos = (CGFloat(i) * elementWidth) + (CGFloat(i+1) * spaceWidth)
                yPos = (frame.height - elementWidth) / 2
            } else {
                spaceWidth = (frame.height - (CGFloat(numberOfElements) * elementWidth)) / CGFloat(nbSpace)
                yPos = (CGFloat(i) * elementWidth) + (CGFloat(i+1) * spaceWidth)
                xPos = (frame.width - elementWidth) / 2
            }

            var view : UIView = UIView()

            // if there is an image set, create UIImageView instead of UIView
            if let image = elementImage {
                let imageView = UIImageView(frame: CGRect(x: xPos, y: yPos, width: elementWidth, height: elementWidth))
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                view = imageView
            } else {
                view = UIView(frame: CGRect(x: xPos, y: yPos, width: elementWidth, height: elementWidth))
                view.backgroundColor = elementBackgroundColor
                view.layer.borderColor = elementBorderColor.cgColor
                view.layer.borderWidth = elementBorderWidth
                if (isRounded == true) {
                    view.layer.masksToBounds = true
                    view.layer.cornerRadius = elementCornerRadius
                }
            }

            addSubview(view)
            view.tag = i
            views[i] = view

            // button put over the indicator view if width != 0.0 (cant happen normally)
            // i prefer to use a button over the indicator view because else there is no way to control the clickable area. Here you can just set a bigger value for buttonWidth for a bigger clickable area
            if buttonWidth != 0.0 {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
                button.center = view.center
                button.tag = i
                button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
                addSubview(button)
                buttons[i] = button
            }
        }
        currentIndex = 0
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    override public func layoutSubviews() {
        let nbSpace : Int = numberOfElements - 1
        let elementsWidth : CGFloat = CGFloat(numberOfElements) * elementWidth
        let elementsSpacing : CGFloat = CGFloat(nbSpace) * elementSpacing
        let frameWidth : CGFloat = (orientation == .Horizontal) ? self.frame.width : self.frame.height
        let posStart : CGFloat = (frameWidth - (elementsWidth + elementsSpacing)) / 2.0

        var xPos : CGFloat = 0.0
        var yPos : CGFloat = 0.0
        for view in views {
            if let view = view {
                let index : CGFloat = CGFloat(view.tag)
                if (orientation == .Horizontal) {
                    xPos = posStart + (index * elementWidth) + (index * elementSpacing)
                    yPos = (frame.height - elementWidth) / 2
                } else {
                    yPos = posStart + (index * elementWidth) + (index * elementSpacing)
                    xPos = (frame.width - elementWidth) / 2
                }
                view.frame = CGRect(x: xPos, y: yPos, width: elementWidth, height: elementWidth)
                if let btn = buttons[view.tag] {
                    btn.center = view.center
                }
            }
        }
    }

    @objc fileprivate func buttonClicked(sender : UIButton) {
        let shouldChange = delegate?.shouldChangeIndex(from: currentIndex, to: sender.tag) ?? true
        delegate?.elementClicked(pageControl: self, atIndex: sender.tag)
        if shouldChange == true {
            currentIndex = sender.tag
        }
    }

    fileprivate func setSelectedStyleForView(view : UIView, animated : Bool) {
        if let view = view as? UIImageView {
            if let image = elementSelectedImage {
                view.image = image
            }
        }
        view.backgroundColor = elementSelectedBackgroundColor
        view.layer.borderWidth = elementSelectedBorderWidth
        view.layer.borderColor = elementSelectedBorderColor.cgColor
    }

    fileprivate func setUnselectedStyleForView(view : UIView, animated : Bool) {
        if let view = view as? UIImageView {
            if let image = elementImage {
                view.image = image
            }
        }
        view.backgroundColor = elementBackgroundColor
        view.layer.borderWidth = elementBorderWidth
        view.layer.borderColor = elementBorderColor.cgColor
    }
}
