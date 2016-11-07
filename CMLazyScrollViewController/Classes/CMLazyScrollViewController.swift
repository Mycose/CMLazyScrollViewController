//
//  CMCarouselViewController.swift
//  CMCarousel
//
//  Created by Clément Morissard on 17/10/16.
//  Copyright © 2016 Clément Morissard. All rights reserved.
//

import UIKit
import CMPageControl

struct Constants {
    // value of the velocity over which we change page
    static let velocityMaxSensibility : CGFloat = 0.50
    static let pageControlHeightConstraintValue : CGFloat = 40.0
}

public enum CMPageControlPosition {
    case Top
    case Bottom
    case Left
    case Right
}

public enum CMLazyScrollViewDirection {
    case Vertical
    case Horizontal
}

public protocol CMLazyScrollViewControllerDelegate : class {
    func numberOfViewControllersIn(scrollViewController : CMLazyScrollViewController) -> Int
    func viewControllerIn(scrollViewController : CMLazyScrollViewController, atIndex: Int) -> UIViewController
}

public class CMLazyScrollViewController : UIViewController, UIScrollViewDelegate {

    // MARK: - PageControl Constraints
    fileprivate var currentPageControlConstraints : [NSLayoutConstraint] = []
    @IBOutlet fileprivate var pageControlBottomConstraint : NSLayoutConstraint!

    // MARK: - PRIVATE IBOUTLET
    @IBOutlet fileprivate var scrollView : UIScrollView!

    // MARK: - PRIVATE PROPERTIES

    // current index of the scrollview
    fileprivate var currentIndex : Int = 0 {
        didSet {
            if (oldValue != currentIndex) {
                updateCarousel()
            }
        }
    }

    // used to store view controllers
    fileprivate var viewControllers : [UIViewController?] = []
    // used to store views
    fileprivate var views : [UIView?] = []

    fileprivate var targetContentOffset : CGPoint?

    // to store the old offset from the scrollview to determine the direction of the scroll
    fileprivate var lastScrollViewOffset : CGPoint?
    // size of a page of the scrollview, set during the view did load with the frame
    fileprivate var pageSize = CGSize(width: 0, height: 0)
    // number of views in the scrollview, ask by delegate after setting the delegate
    fileprivate var numberOfViews : Int = 0

    // PROPERTIES AND GETTER/SETTER
    // used to set the current page with animation or not
    public func setCurrentPage(newValue : Int, animated : Bool) {
        let x = (scrollDirection == .Horizontal) ? CGFloat(newValue)*pageSize.width : 0
        let y = (scrollDirection == .Horizontal) ? 0 : CGFloat(newValue)*pageSize.height
        scrollView.scrollRectToVisible(CGRect(x: x, y: y, width: pageSize.width, height: pageSize.height), animated: animated)
        currentIndex = newValue
    }

    // get current index
    public func currentPage() -> Int {
        return fixIndex(index: currentIndex)
    }

    // get view controller at index, can return nil if view controller never created are not in stored anymore
    public func viewController(atIndex : Int) -> UIViewController? {
        if atIndex > 0 && atIndex < numberOfViews {
            return viewControllers[atIndex]
        }
        return nil
    }

    // true if it should rotate and detect rotation
    public var canRotate : Bool = false {
        didSet {
            if canRotate == true {
                NotificationCenter.default.addObserver(self, selector: #selector(screenDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }

    public var pageControlPaddingValue : CGFloat = 0.0 {
        didSet {
            refreshPageControlConstraint()
        }
    }

    // if false it will be vertical
    public var scrollDirection : CMLazyScrollViewDirection = .Horizontal

    public var pageControlPosition : CMPageControlPosition = .Bottom {
        didSet {
            refreshPageControlConstraint()
        }
    }

    // view controllers will be instantiated only once if true
    // if it's false, there will only be 3 per 3 view controllers in the memory (current, previous and next)
    public var isLazy = true

    // if the scrollview is infite or not, basically if it's yes, i consider there is 2 mores views in the scrollview like: 1 2 3 becomes 3 1 2 3 1.
    // if you arrive on the first or last element, i scroll to the n-1 or index 1 element
    public var infinite = false {
        didSet {
            reload()
        }
    }

    public var isPagerHidden = false {
        didSet {
            pageControl.isHidden = isPagerHidden
        }
    }

    // MARK: - PUBLIC PROPERTIES
    @IBOutlet public var pageControl : CMPageControl!

    // MARK: - PUBLIC SCROLL VIEW PROPERTIES
    public var isPagingEnable = true {
        didSet {
            scrollView.isPagingEnabled = isPagingEnable
        }
    }

    public var isHorizontalScrollIndicatorHidden = false {
        didSet {
            scrollView.showsHorizontalScrollIndicator = isHorizontalScrollIndicatorHidden
        }
    }

    public var isVerticalScrollIndicatorHidden = false {
        didSet {
            scrollView.showsVerticalScrollIndicator = isVerticalScrollIndicatorHidden
        }
    }

    // scroll view delegate which will be call after every delegate function
    public var scrollDelegate : UIScrollViewDelegate?

    // carousel view controller delegate
    public var delegate : CMLazyScrollViewControllerDelegate? {
        didSet {
            reload()
        }
    }

    // MARK: - PUBLIC FUNCTIONS
    // remove all views and rebuild the carousel
    public func reload() {
        if let delegate = delegate {

            pageSize = view.frame.size
            cleanArray()

            numberOfViews = delegate.numberOfViewControllersIn(scrollViewController: self)
            pageControl.numberOfElements = numberOfViews
            if infinite == true {
                numberOfViews += 2
            }

            let width = (scrollDirection == .Horizontal) ? CGFloat(numberOfViews)*pageSize.width : pageSize.width
            let height = (scrollDirection == .Horizontal) ? pageSize.height : CGFloat(numberOfViews)*pageSize.height
            scrollView.contentSize = CGSize(width: width, height: height)
            viewControllers = Array(repeating: nil, count: numberOfViews)
            views = Array(repeating: nil, count: numberOfViews)


            let x = (infinite == true && scrollDirection == .Horizontal) ? pageSize.width : 0
            let y = (infinite == true && scrollDirection == .Vertical) ? pageSize.height : 0

            scrollView.contentOffset = CGPoint(x: x, y: y)
            currentIndex = (infinite == true) ? 1 : 0
            updateCarousel()
        }
    }

    // MARK: - PRIVATE FUNCTIONS
    fileprivate func requestAndAddViewControllerAt(index : Int) {
        let fixedIndex = fixIndex(index: index)
        var vc : UIViewController!

        if viewControllers[index] != nil {
            vc = viewControllers[index]!
        } else {
            vc = delegate?.viewControllerIn(scrollViewController: self, atIndex: fixedIndex) ?? UIViewController()
        }

        // force frame to the size of a page
        vc.view.frame = CGRect(x: 0.0, y: 0.0, width: pageSize.width, height: pageSize.height)
        addChildViewController(vc)

        let x : CGFloat = (scrollDirection == .Horizontal) ? CGFloat(index)*pageSize.width : 0.0
        let y : CGFloat = (scrollDirection == .Horizontal) ? 0.0 : CGFloat(index)*pageSize.height
        // TODO: if i dont use a view here the constraint from the vc.view will break because of the scrollView, i tried to do some autolayout with the views i added but no success :(
        let view = UIView(frame: CGRect(x: x, y: y, width: pageSize.width, height: pageSize.height))
        view.tag = index
        view.addSubview(vc.view)

        scrollView.addSubview(view)
        views[index] = view
        viewControllers[index] = vc
        vc.didMove(toParentViewController: self)
    }

    fileprivate func fixIndex(index : Int) -> Int {
        var fixedIndex = index

        // if it's infinite, i fix the index to not ask views which does not exist
        if infinite == true {
            if index == 0 {
                fixedIndex = numberOfViews-3
            } else if (index == numberOfViews-1) {
                fixedIndex = 0
            } else {
                fixedIndex -= 1
            }
        }
        return fixedIndex
    }

    fileprivate func updateCarousel() {
        let i = currentIndex

        if i < 0 { return }

        if i != 0 {
            requestAndAddViewControllerAt(index: i-1)
        }
        if i < numberOfViews-1 {
            requestAndAddViewControllerAt(index: i)
            requestAndAddViewControllerAt(index: i+1)
        }
    }

    // clean all the array
    fileprivate func cleanArray() {
        for i in 0..<viewControllers.count {
            if let vc = viewControllers[i], let view = views[i] {
                view.removeFromSuperview()
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
                viewControllers[i] = nil
                views[i] = nil
            }
        }
    }

    // clean specific slot in array
    fileprivate func clearSlot(index : Int) {
        if let vc = viewControllers[index], let _ = views[index] {
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            if isLazy == true {
                viewControllers[index] = nil
                views[index] = nil
            }
        }
    }

    // check if index is at the end or begin and decide if it should scroll or not
    fileprivate func checkDidScrollInfiniteModeWithX(scrollView: UIScrollView) {
        let rest = scrollView.contentOffset.x.truncatingRemainder(dividingBy: pageSize.width)
        if (currentIndex == numberOfViews-1) {
            scrollView.scrollRectToVisible(CGRect(x: rest, y: 0, width: pageSize.width, height: pageSize.height), animated: false)
            if let _ = targetContentOffset {
                scrollView.scrollRectToVisible(CGRect(x: pageSize.width, y: 0, width: pageSize.width, height: pageSize.height), animated: true)
            }
            targetContentOffset = nil
        } else if (currentIndex == 0 && (lastScrollViewOffset != nil) && (lastScrollViewOffset!.x > scrollView.contentOffset.x)) {
            scrollView.scrollRectToVisible(CGRect(x: scrollView.contentSize.width-(pageSize.width*2)+rest, y: 0, width: pageSize.width, height: pageSize.height), animated: false)
            // targetcontentoffset is set at the end draging event and allow to finish the movement after the scrollrecttovisible
            if let _ = targetContentOffset {
               scrollView.scrollRectToVisible(CGRect(x: scrollView.contentSize.width-(pageSize.width*2), y: 0, width: pageSize.width, height: pageSize.height), animated: true)
            }
            targetContentOffset = nil
        }
    }

    // check if index is at the end or begin and decide if it should scroll or not
    fileprivate func checkDidScrollInfiniteModeWithY(scrollView: UIScrollView) {
        let rest = scrollView.contentOffset.y.truncatingRemainder(dividingBy: pageSize.height)
        if (currentIndex == numberOfViews-1) {
            scrollView.scrollRectToVisible(CGRect(x: 0, y: rest, width: pageSize.width, height: pageSize.height), animated: false)
            if let _ = targetContentOffset {
                scrollView.scrollRectToVisible(CGRect(x: 0, y: pageSize.height, width: pageSize.width, height: pageSize.height), animated: true)
            }
            targetContentOffset = nil
        } else if (currentIndex == 0 && (lastScrollViewOffset != nil) && (lastScrollViewOffset!.y > scrollView.contentOffset.y)) {
            scrollView.scrollRectToVisible(CGRect(x: 0, y: scrollView.contentSize.height-(pageSize.height*2)+rest, width: pageSize.width, height: pageSize.height), animated: false)

            if let _ = targetContentOffset {
                scrollView.scrollRectToVisible(CGRect(x: 0, y: scrollView.contentSize.height-(pageSize.height*2), width: pageSize.width, height: pageSize.height), animated: true)
            }
            targetContentOffset = nil
        }
    }

    // add constraint for the page control to put it on the left/top/bottom/right
    fileprivate func refreshPageControlConstraint() {
        self.view.removeConstraints(currentPageControlConstraints)
        switch pageControlPosition {
        case .Top:
            let topConstraint = NSLayoutConstraint(item: pageControl, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: pageControlPaddingValue)
            let leadingConstraint = NSLayoutConstraint(item: pageControl, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0)
            let trailingConstraint = NSLayoutConstraint(item: pageControl, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            let heightConstraint = NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 40.0)
            currentPageControlConstraints = [topConstraint, leadingConstraint, trailingConstraint, heightConstraint]
            self.view.addConstraints(currentPageControlConstraints)
            pageControl.orientation = .Horizontal
            break
        case .Bottom:
            let botConstraint = NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -pageControlPaddingValue)
            let leadingConstraint = NSLayoutConstraint(item: pageControl, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0)
            let trailingConstraint = NSLayoutConstraint(item: pageControl, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            let heightConstraint = NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 40.0)
            currentPageControlConstraints = [botConstraint, leadingConstraint, trailingConstraint, heightConstraint]
            self.view.addConstraints(currentPageControlConstraints)
            pageControl.orientation = .Horizontal
            break
        case .Left:
            let topConstraint = NSLayoutConstraint(item: pageControl, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
            let leadingConstraint = NSLayoutConstraint(item: pageControl, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: pageControlPaddingValue)
            let botConstraint = NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let widthConstraint = NSLayoutConstraint(item: pageControl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 40.0)
            currentPageControlConstraints = [topConstraint, leadingConstraint, botConstraint, widthConstraint]
            self.view.addConstraints(currentPageControlConstraints)
            pageControl.orientation = .Vertical
            break
        case .Right:
            let topConstraint = NSLayoutConstraint(item: pageControl, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
            let botConstraint = NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let trailingConstraint = NSLayoutConstraint(item: pageControl, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -pageControlPaddingValue)
            let widthConstraint = NSLayoutConstraint(item: pageControl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 40.0)
            currentPageControlConstraints = [topConstraint, botConstraint, trailingConstraint, widthConstraint]
            self.view.addConstraints(currentPageControlConstraints)
            pageControl.orientation = .Vertical
            break
        }
    }


    // MARK: - UIVIEWCONTROLLER OVERRIDE
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let bundle = Bundle(for: type(of: self))
        let nib = "CMLazyScrollViewController"
        super.init(nibName: nib, bundle: bundle)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        viewControllers.removeAll()
        views.removeAll()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - SCROLLVIEWDELEGATE
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (currentIndex-2 >= 0) {
            clearSlot(index: currentIndex-2)
        }
        if (currentIndex+2 < numberOfViews-1) {
            clearSlot(index: currentIndex+2)
        }
        scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = (scrollDirection == .Horizontal) ? (scrollView.contentOffset.x + (0.5 * pageSize.width)) / pageSize.width : (scrollView.contentOffset.y + (0.5 * pageSize.height)) / pageSize.height

        currentIndex = Int(page)
        pageControl.currentIndex = fixIndex(index: currentIndex)

        // last element, only for infinite mode
        if (infinite == true && scrollView.isTracking == false) {
            (scrollDirection == .Horizontal) ? checkDidScrollInfiniteModeWithX(scrollView: scrollView) : checkDidScrollInfiniteModeWithY(scrollView: scrollView)
        }

        lastScrollViewOffset = scrollView.contentOffset
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidZoom?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (isPagingEnable == true) {
            var index : CGFloat = CGFloat(currentIndex)
            // get the relative offset in the current page, x for horizontal and y for vertical mode
            let relativeOffset : CGFloat = (scrollDirection == .Horizontal) ? scrollView.contentOffset.x.truncatingRemainder(dividingBy: self.view.frame.width) : scrollView.contentOffset.y.truncatingRemainder(dividingBy: self.view.frame.height)
            // get the value we went compare the offset to width/2 or height/2
            let offsetValueToCompare : CGFloat = (scrollDirection == .Horizontal) ? (self.view.frame.width/2) : (self.view.frame.height/2)

            // we check if the velocity value is high enought to change page and if we didn't already change of page (with the relative offset)
            if ((velocity.x > Constants.velocityMaxSensibility || velocity.y > Constants.velocityMaxSensibility) && (relativeOffset < offsetValueToCompare)) {
                index += 1
            } else if (velocity.x < -Constants.velocityMaxSensibility || velocity.y < -Constants.velocityMaxSensibility && (relativeOffset > offsetValueToCompare)) {
                index -= 1
            }
            // set the target offset we want to go to
            targetContentOffset.pointee.x = (scrollDirection == .Horizontal) ? (index*pageSize.width) : 0
            targetContentOffset.pointee.y = (scrollDirection == .Horizontal) ? 0.0 : (pageSize.height*index)
            self.targetContentOffset = targetContentOffset.pointee
        }
        scrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollDelegate?.viewForZooming?(in: scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let bool = scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) {
            return bool
        }
        return true
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
    }

    public func screenDidRotate() {
        pageSize = view.frame.size
        let width = (scrollDirection == .Horizontal) ? CGFloat(numberOfViews)*pageSize.width : pageSize.width
        let height = (scrollDirection == .Horizontal) ? pageSize.height : CGFloat(numberOfViews)*pageSize.height
        scrollView.contentSize = CGSize(width: width, height: height)

        for view in views {
            if let view = view {
                let index : Int = view.tag
                let x : CGFloat = (scrollDirection == .Horizontal) ? CGFloat(index)*pageSize.width : 0.0
                let y : CGFloat = (scrollDirection == .Horizontal) ? 0.0 : CGFloat(index)*pageSize.height
                view.frame = CGRect(x: x, y: y, width: pageSize.width, height: pageSize.height)
            }
        }
        setCurrentPage(newValue: currentIndex, animated: false)
    }
}

