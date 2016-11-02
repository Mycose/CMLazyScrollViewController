# CMPageControl

[![Version](https://img.shields.io/cocoapods/v/CMPageControl.svg?style=flat)](http://cocoapods.org/pods/CMPageControl)
[![License](https://img.shields.io/cocoapods/l/CMPageControl.svg?style=flat)](http://cocoapods.org/pods/CMPageControl)
[![Platform](https://img.shields.io/cocoapods/p/CMPageControl.svg?style=flat)](http://cocoapods.org/pods/CMPageControl)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Changes

Future
- Maybe remove the delegation since it's an UIControl
- Animation for changing selected element
- Any ideas or request ?

v0.0.1
- Draft version

## CMPageControl
CMPageControl is a UIControl working like a UIPageControl but support horizontal/vertical display and is customisable.
Currently you can customize the borderWidth, the backgroundColor, the borderColor and an image if you want images instead of basic views

## CMPageControl Properties:
```swift
// current index, will apply selected style if you set manually
public var currentIndex : Int = 0
 
// when set will "setup" the views
public var numberOfElements : Int = 0
  
// to selecte if round or square
public var isRounded : Bool = true

// unselected image
public var elementImage : UIImage?

// unselected background color
public var elementBackgroundColor : UIColor = UIColor.gray

// unselected border color
public var elementBorderColor : UIColor = UIColor.gray

// unselected border width
public var elementBorderWidth : CGFloat = 1.0

// selected image
public var elementSelectedImage : UIImage? {

// selected background color
public var elementSelectedBackgroundColor : UIColor = UIColor.white

// selected border color
public var elementSelectedBorderColor : UIColor = UIColor.white

// selected border width
public var elementSelectedBorderWidth : CGFloat = 2.0

// element width and height
public var elementWidth : CGFloat = 10.0

// if you want the view to be aligned vertically or horizontally
public var orientation : CMPageControlOrientation = .Horizontal

public var delegate : CMPageControlDelegate?
```

## CMPageControl Usage Example:
```swift
self.pageControl = CMPageControl(frame: CGRect(x: 0, y: 40, width: 40, height: 200))
self.pageControl?.numberOfElements = 5
self.pageControl?.elementImage = image
self.pageControl?.elementSelectedImage = selectedImage
self.pageControl?.elementBackgroundColor = UIColor.clear
self.pageControl?.elementWidth = 20.0
self.pageControl?.elementBorderWidth = 0.0
self.pageControl?.elementSelectedBorderWidth = 0.0
self.pageControl?.elementSelectedBackgroundColor = UIColor.clear
self.pageControl?.orientation = .Vertical
self.view.addSubview(self.pageControl!)
```

## CMPageControl Delegation : CMPageControlDelegate
```swift
/!\ might disappear because the UIControl should do the same
// called when a view is clicked
func elementClicked(pageControl : CMPageControl, atIndex: Int)
// decide if the index should change after the click
func shouldChangeIndex(from : Int, to : Int) -> Bool
```

## Installation

CMPageControl is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CMPageControl"
```

## Author

Clément Morissard, morissard@gmail.com

## License

CMPageControl is available under the MIT license. See the LICENSE file for more info.
