//
//  ScrollViewDelegate.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 17. 08. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

public class ScrollViewDelegate {
    public var didScroll: ((_ scrollView: UIScrollView) -> Void)?
    public var didScrollToTop: ((_ scrollView: UIScrollView) -> Void)?
    public var shouldScrollToTop: ((_ scrollView: UIScrollView) -> Bool)?
    public var didEndDecelerating: ((_ scrollView: UIScrollView) -> Void)?
    public var willBeginDecelerating: ((_ scrollView: UIScrollView) -> Void)?
    public var didEndScrollingAnimation: ((_ scrollView: UIScrollView) -> Void)?
    public var didChangeAdjustedContentInset: ((_ scrollView: UIScrollView) -> Void)?
    public var willBeginDragging: ((_ scrollView: UIScrollView) -> Void)?
    public var didEndDragging: ((_ scrollView: UIScrollView, _ willDecelerate: Bool) -> Void)?
    public var willEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)?
    public var willBeginZooming: ((_ scrollView: UIScrollView, _ view: UIView?) -> Void)?
    public var didEndZooming: ((_ scrollView: UIScrollView, _ view: UIView?, _ scale: CGFloat) -> Void)?
    public var didZoom: ((_ scrollView: UIScrollView) -> Void)?
    public var zooming: ((_ scrollView: UIScrollView) -> UIView?)?
}
