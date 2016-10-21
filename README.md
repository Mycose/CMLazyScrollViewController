# CMLazyScrollViewController

[![CI Status](http://img.shields.io/travis/Mycose/CMLazyScrollViewController.svg?style=flat)](https://travis-ci.org/Mycose/CMLazyScrollViewController)
[![Version](https://img.shields.io/cocoapods/v/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)
[![License](https://img.shields.io/cocoapods/l/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)
[![Platform](https://img.shields.io/cocoapods/p/CMLazyScrollViewController.svg?style=flat)](http://cocoapods.org/pods/CMLazyScrollViewController)

## CMLazyScrollViewController
CMLazyScrollViewController is a UIViewController which has a UIScrollView and UIPageControl.
The delegation of the CMLazyScrollViewController ask for UIViewController to put in the scroll view on a page system
There is a lazy option (only 3 per 3 view controllers in the memory) and infinite mode.

## CMLazyScrollViewController Properties:
```swift
```

## CMLazyScrollViewController Usage Example:
```swift
func numberOfViewsInCarousel(scrollViewController : CMLazyScrollViewController) -> Int
func viewInCarousel(scrollViewController : CMLazyScrollViewController, index: Int) -> UIViewController
```

## CMSteppedProgressBar Delegation : CMSteppedProgressBarDelegate
Called when the user click on an activated step dot, send you the sender and the step clicked
```swift
- (void)steppedBar:(CMSteppedProgressBar *)steppedBar didSelectIndex:(NSUInteger)index;
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
