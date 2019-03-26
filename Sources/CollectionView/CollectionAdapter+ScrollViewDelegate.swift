//
//  CollectionAdapter+ScrollViewDelegate.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

// As mentioned in [Swift: UIScrollViewDelegate extension](https://stackoverflow.com/questions/31271849/swift-uiscrollviewdelegate-extension)
// this implementation couldn't be shared with `TableAdapter`.

public extension CollectionAdapter {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate.didScroll?(scrollView)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollDelegate.didScrollToTop?(scrollView)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return scrollDelegate.shouldScrollToTop?(scrollView) ?? true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate.didEndDecelerating?(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate.willBeginDecelerating?(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDelegate.didEndScrollingAnimation?(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollDelegate.didChangeAdjustedContentInset?(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate.willBeginDragging?(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate.didEndDragging?(scrollView, decelerate)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollDelegate.willEndDragging?(scrollView, velocity, targetContentOffset)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollDelegate.willBeginZooming?(scrollView, view)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollDelegate.didEndZooming?(scrollView, view, scale)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollDelegate.didZoom?(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollDelegate.zooming?(scrollView) ?? nil
    }
}
