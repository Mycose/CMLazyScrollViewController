# CMLazyScrollViewController

[![Version](https://img.shields.io/cocoapods/v/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)
[![License](https://img.shields.io/cocoapods/l/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)
[![Platform](https://img.shields.io/cocoapods/p/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
or 
https://appetize.io/app/qcb2rwc82uu53thuy2efvez6hr?device=iphone5s&scale=75&orientation=portrait&osVersion=9.3

## Future
- Smoothen the animation when you end dragging on infinite mode without pagging
- Any ideas or request ?

## Algorithm

For the infinite carousel/scroll etc... I see only two possibilities:
1- Use a UICollectionView or UITableView, setting the number of elements to a really high value, and scroll at the middle at the beginning, and then play with / and % to have the right index everytime
2- Imagine you have a UIScrollView with pages like this 1 2 3 4 5. Basically you just want to have 5 1 2 3 4 5 1, and when the user scroll and arrive on the first 1 or the second 5, you want to scroll back at the beginning or the end without animation and seemlessly, it create the feeling of infinity since you will basically scroll over and over on the same elements

In this projet I used the second way

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
