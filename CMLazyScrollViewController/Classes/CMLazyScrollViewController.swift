//
//  CMCarouselViewController.swift
//  CMCarousel
//
//  Created by Clément Morissard on 17/10/16.
//  Copyright © 2016 Clément Morissard. All rights reserved.
//

import UIKit

public protocol CMLazyScrollViewControllerDelegate : class {
    func numberOfViewControllersIn(scrollViewController : CMLazyScrollViewController) -> Int
    func viewControllerIn(scrollViewController : CMLazyScrollViewController, atIndex: Int) -> UIViewController
}

public class CMLazyScrollViewController : UIViewController, UIScrollViewDelegate {

    // MARK: - PRIVATE IBOUTLET
    @IBOutlet fileprivate var pageControl : UIPageControl!
    @IBOutlet fileprivate var scrollView : UIScrollView!

    // MARK: - PRIVATE PROPERTIES
    // current index of the scrollview
    fileprivate var currentIndex : Int = 0 {
        didSet {
            if (oldValue != currentIndex) {
                self.updateCarousel()
            }
        }
    }

    // used to store views
    fileprivate var viewsInCache : [UIViewController?] = []

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
        self.scrollView.scrollRectToVisible(CGRect(x: CGFloat(newValue)*self.pageSize.width, y: 0, width: self.pageSize.width, height: self.pageSize.height), animated: animated)
        self.currentIndex = newValue
    }

    // get current index
    public func currentPage() -> Int {
        return self.fixIndex(index: self.currentIndex)
    }

    // get view controller at index, can return nil if view controller never created are not in stored anymore
    public func viewController(atIndex : Int) -> UIViewController? {
        if atIndex > 0 && atIndex < self.numberOfViews {
            return self.viewsInCache[atIndex]
        }
        return nil
    }

    // view controllers will be instantiated only once if true
    // if it's false, there will only be 3 per 3 view controllers in the memory (current, previous and next)
    public var isLazy = true

    // if the scrollview is infite or not, basically if it's yes, i consider there is 2 mores views in the scrollview like: 1 2 3 becomes 3 1 2 3 1.
    // if you arrive on the first or last element, i scroll to the n-1 or index 1 element
    public var infinite = false {
        didSet {
            self.reload()
        }
    }

    public var isPagerHidden = false {
        didSet {
            self.pageControl.isHidden = self.isPagerHidden
        }
    }

    // MARK: - PUBLIC SCROLL VIEW PROPERTIES

    public var isPagingEnable = true {
        didSet {
            self.scrollView.isPagingEnabled = self.isPagingEnable
        }
    }

    public var isHorizontalScrollIndicatorHidden = false {
        didSet {
            self.scrollView.showsHorizontalScrollIndicator = self.isHorizontalScrollIndicatorHidden
        }
    }

    public var isVerticalScrollIndicatorHidden = false {
        didSet {
            self.scrollView.showsVerticalScrollIndicator = self.isVerticalScrollIndicatorHidden
        }
    }

    // scroll view delegate which will be call after every delegate function
    public var scrollDelegate : UIScrollViewDelegate?

    // carousel view controller delegate
    public var delegate : CMLazyScrollViewControllerDelegate? {
        didSet {
            self.reload()
        }
    }

    // MARK: - PUBLIC FUNCTIONS
    // remove all views and rebuild the carousel
    public func reload() {
        if let delegate = self.delegate {

            self.pageSize = self.view.frame.size
            self.cleanArray()

            self.numberOfViews = delegate.numberOfViewControllersIn(scrollViewController: self)
            self.pageControl.numberOfPages = self.numberOfViews
            if self.infinite == true {
                self.numberOfViews += 2
            }

            self.scrollView.contentSize = CGSize(width: CGFloat(self.numberOfViews)*self.pageSize.width, height: self.pageSize.height)
            self.viewsInCache = Array(repeating: nil, count: self.numberOfViews)

            self.scrollView.contentOffset = CGPoint(x: (self.infinite == true) ? self.pageSize.width : 0, y: 0)
            self.currentIndex = (self.infinite == true) ? 1 : 0
            self.updateCarousel()
        }
    }

    // MARK: - PRIVATE FUNCTIONS
    fileprivate func requestAndAddViewControllerAt(index : Int) {
        let fixedIndex = self.fixIndex(index: index)
        var vc : UIViewController!

        if self.viewsInCache[index] != nil {
            vc = self.viewsInCache[index]!
        } else {
            vc = self.delegate?.viewControllerIn(scrollViewController: self, atIndex: fixedIndex) ?? UIViewController()
        }


        // force frame to the size of a page
        vc.view.frame = CGRect(x: 0.0, y: 0.0, width: self.pageSize.width, height: self.pageSize.height)
        self.addChildViewController(vc)


        // TODO: fix the fact that i need a view to not loose bg color ?
        let view = UIView(frame: CGRect(x: CGFloat(index)*self.pageSize.width, y: 0.0, width: self.pageSize.width, height: self.pageSize.height))
        view.addSubview(vc.view)

        self.scrollView.addSubview(view)
        self.viewsInCache[index] = vc
        vc.didMove(toParentViewController: self)
    }

    fileprivate func fixIndex(index : Int) -> Int {
        var fixedIndex = index

        // if it's infinite, i fix the index to not ask views which does not exist
        if self.infinite == true {
            if index == 0 {
                fixedIndex = self.numberOfViews-3
            } else if (index == self.numberOfViews-1) {
                fixedIndex = 0
            } else {
                fixedIndex -= 1
            }
        }
        return fixedIndex
    }

    fileprivate func updateCarousel() {
        let i = self.currentIndex

        if i < 0 {
            return
        }

        if i != 0 {
            self.requestAndAddViewControllerAt(index: i-1)
        }
        if i < self.numberOfViews-1 {
            self.requestAndAddViewControllerAt(index: i)
        }
        if i < self.numberOfViews-1 {
            self.requestAndAddViewControllerAt(index: i+1)
        }
    }

    fileprivate func cleanArray() {
        for i in 0..<self.viewsInCache.count {
            if let vc = self.viewsInCache[i] {
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
                self.viewsInCache[i] = nil
            }
        }
    }

    fileprivate func clearSlot(index : Int) {
        if let vc = self.viewsInCache[index] {
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            if self.isLazy == true {
                self.viewsInCache[index] = nil
            }
        }
    }


    // MARK: - UIVIEWCONTROLLER OVERRIDE
    override public func viewDidLoad() {
        super.viewDidLoad()
        //self.reloadCarousel()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

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
        self.viewsInCache.removeAll()
    }

    // MARK: - SCROLLVIEWDELEGATE

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (self.currentIndex-2 >= 0) {
            self.clearSlot(index: self.currentIndex-2)
        }
        if (self.currentIndex+2 < self.numberOfViews-1) {
            self.clearSlot(index: self.currentIndex+2)
        }
        self.scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }


    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = (scrollView.contentOffset.x + (0.5 * self.pageSize.width)) / self.pageSize.width

        self.currentIndex = Int(page)
        self.pageControl.currentPage = self.fixIndex(index: self.currentIndex)

        // last element, only for infinite mode
        if (self.infinite == true && self.currentIndex == self.numberOfViews-1) {
            let rest = scrollView.contentOffset.x.truncatingRemainder(dividingBy: self.pageSize.width)
            self.scrollView.scrollRectToVisible(CGRect(x: rest, y: 0, width: self.pageSize.width, height: self.pageSize.height), animated: false)
            if let _ = self.targetContentOffset {
                self.scrollView.scrollRectToVisible(CGRect(x: self.pageSize.width, y: 0, width: self.pageSize.width, height: self.pageSize.height), animated: true)
            }
            targetContentOffset = nil
        } else if (self.infinite == true && self.currentIndex == 0 && (self.lastScrollViewOffset != nil) && (self.lastScrollViewOffset!.x > scrollView.contentOffset.x)) {

            let rest = scrollView.contentOffset.x.truncatingRemainder(dividingBy: self.pageSize.width)

            self.scrollView.scrollRectToVisible(CGRect(x: self.scrollView.contentSize.width-(self.pageSize.width*2)+rest, y: 0, width: self.pageSize.width, height: self.pageSize.height), animated: false)

            // targetcontentoffset is set at the end draging event and allow to finish the movement after the scrollrecttovisible
            if let _ = self.targetContentOffset {
                self.scrollView.scrollRectToVisible(CGRect(x: self.scrollView.contentSize.width-(self.pageSize.width*2), y: 0, width: self.pageSize.width, height: self.pageSize.height), animated: true)
            }
            self.targetContentOffset = nil
        }
        self.lastScrollViewOffset = self.scrollView.contentOffset
        self.scrollDelegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidZoom?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.targetContentOffset = targetContentOffset.pointee
        self.scrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollDelegate?.viewForZooming?(in: scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.scrollDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scrollDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let bool = self.scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) {
            return bool
        }
        return true
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
}
