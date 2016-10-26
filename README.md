# CMLazyScrollViewController

[![CI Status](http://img.shields.io/travis/Mycose/CMLazyScrollViewController.svg?style=flat)](https://travis-ci.org/Mycose/CMLazyScrollViewController)
[![Version](https://img.shields.io/cocoapods/v/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)
[![License](https://img.shields.io/cocoapods/l/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)
[![Platform](https://img.shields.io/cocoapods/p/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)

## Changes

Future
- Custom UIPageControl
- UIPageControl left/right/top or bot
- Any ideas or request ?

v0.0.2 (WIP)
- Vertical Scroll Support (almost done, just a little bug to fix)
- Rotation Support (Done, will be in 0.0.2)

v0.0.1
- Draft version

## CMLazyScrollViewController
CMLazyScrollViewController is a UIViewController which has a UIScrollView and UIPageControl.
The delegation of the CMLazyScrollViewController ask for UIViewController to put in the scroll view on a page system
There is a lazy option (only 3 per 3 view controllers in the memory) and infinite mode.

## CMLazyScrollViewController Properties:
```swift
// properties for the scrollview
public var isPagingEnable = true
public var isHorizontalScrollIndicatorHidden = false
public var isVerticalScrollIndicatorHidden = false
// scroll view delegate which will be call after every delegate function
public var scrollDelegate : UIScrollViewDelegate?
```

## CMLazyScrollViewController Usage Example:
```swift
let carousel = CMLazyScrollViewController()
carousel.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
carousel.infinite = true
carousel.isPagingEnable = true
carousel.delegate = self
self.addChildViewController(carousel)
self.view.addSubview(carousel.view)
```

## CMLazyScrollViewController Delegation : CMLazyScrollViewControllerDelegate
```swift
// ask for the number of view in the controller
func numberOfViewControllersIn(scrollViewController : CMLazyScrollViewController) -> Int
// request a view controller to show at the index
func viewControllerIn(scrollViewController : CMLazyScrollViewController, atIndex: Int) -> UIViewController    
```

## Installation
CMLazyScrollViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CMLazyScrollViewController'
```

## Author
Mycose, morissard@gmail.com

## License
CMLazyScrollViewController is available under the MIT license. See the LICENSE file for more info.
