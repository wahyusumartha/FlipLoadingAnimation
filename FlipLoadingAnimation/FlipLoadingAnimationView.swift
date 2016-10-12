//
//  FlipLoadingAnimationView.swift
//  FlipLoadingAnimation
//
//  Created by Wahyu Sumartha on 06/10/2016.
//  Copyright © 2016 Wahyu Sumartha. All rights reserved.
//

import UIKit

enum FlipDirectionState {
    case flipStop
    case flipFromTopToBottom
    case flipFromBottomToTop
    case flipFromLeftToRight
    case flipFromRightToLeft
    case flipStopAnimating
}

protocol FlipLoadingAnimationViewProtocol: class {
    func startAnimating()
    func stopAnimating()
    
}

class FlipLoadingAnimationView: UIView, FlipLoadingAnimationViewProtocol {
    
    static let icarPrimaryColor = UIColor(red: 218/255,
                                   green: 0/255,
                                   blue: 0/255,
                                   alpha: 1.0)
    
    var colors = [FlipLoadingAnimationView.icarPrimaryColor,
                  UIColor.blueColor(),
                  UIColor.blackColor(),
                  UIColor.greenColor()]
    
//    var colors = [FlipLoadingAnimationView.icarPrimaryColor,
//                  FlipLoadingAnimationView.icarPrimaryColor,
//                  FlipLoadingAnimationView.icarPrimaryColor,
//                  FlipLoadingAnimationView.icarPrimaryColor]
    
    
    var imageNames = ["icoChat",
                      "icoCar",
                      "icoSaveCar",
                      "icoSearch"]
    
    var frontView: UIView?
    var backView: UIView?
    var firstHalfFrontView: UIView?
    var secondHalfFrontView: UIView?
    var firstHalfBackView: UIView?
    var secondHalfBackView: UIView?
    
    var frontImageView: UIImageView?
    var backImageView: UIImageView?
    
    var previousFlipState: FlipDirectionState = .flipStop
    var currentFlipState: FlipDirectionState = .flipFromLeftToRight
    
    var animationCount = 0
    
    var isBottomFirstAnimation: Bool {
        get {
            if currentFlipState == .flipFromTopToBottom || currentFlipState == .flipFromBottomToTop {
                return false
            } else {
                return true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.yellowColor()
        
        // initialization
        let circleDiameter = min(frame.size.width, frame.size.height)
        
        frontView = UIView()
        frontView?.backgroundColor = UIColor.clearColor()
        frontView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        frontView?.layer.cornerRadius = circleDiameter/2
        
        let frontColor = colors[0]
        moveColorObjectsInArray()
        frontView?.layer.backgroundColor = frontColor.CGColor
        frontView?.center = self.center
        
        backView = UIView()
        backView?.backgroundColor = UIColor.clearColor()
        backView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        backView?.layer.cornerRadius = circleDiameter/2
        
        let backColor = colors[0]
        moveColorObjectsInArray()
        backView?.layer.backgroundColor = backColor.CGColor
        backView?.center = self.center
        
        previousFlipState = .flipStop
        currentFlipState = .flipFromRightToLeft
        animationCount = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        if !NSThread.isMainThread() {
            performSelectorOnMainThread(#selector(FlipLoadingAnimationView.startAnimating), withObject: nil, waitUntilDone: false)
        }
        
        if animationCount < 1 {
            animationCount = 1
            currentFlipState = .flipFromRightToLeft
            getFlipDirectionState()
        } else {
            animationCount = animationCount + 1
        }
    }
    
    func stopAnimating() {
        if !NSThread.isMainThread() {
            performSelectorOnMainThread(#selector(FlipLoadingAnimationView.stopAnimating), withObject: nil, waitUntilDone: false)
        }
        
        if animationCount == 1 {
            animationCount = 0
            currentFlipState = .flipStopAnimating
            NSObject.cancelPreviousPerformRequestsWithTarget(self,
                                                             selector: #selector(FlipLoadingAnimationView.getFlipDirectionState),
                                                             object: nil)
            getFlipDirectionState()
        } else {
            animationCount = animationCount - 1
        }
    }
    
    
    func convertViewToImages(fromView view: UIView,
                                      flipState: FlipDirectionState) -> [UIImageView] {
        
        // convert view to image
        UIGraphicsBeginImageContextWithOptions(view.layer.bounds.size,
                                               view.layer.opaque,
                                               0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var size = CGSizeZero
        
        if flipState == .flipFromBottomToTop || flipState == .flipFromTopToBottom {
            size = CGSizeMake(renderedImage.size.width, renderedImage.size.height/2)
        } else {
            size = CGSizeMake(renderedImage.size.width/2, renderedImage.size.height)
        }
        
        
        var topImage: UIImage?
        var bottomImage: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(size,
                                               view.layer.opaque,
                                               0)
        
        renderedImage.drawAtPoint(CGPointZero)
        topImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(size,
                                               view.layer.opaque,
                                               0)
        if flipState == .flipFromBottomToTop || flipState == .flipFromTopToBottom {
            renderedImage.drawAtPoint(CGPointMake(CGPointZero.x, -renderedImage.size.height/2))
        } else {
            renderedImage.drawAtPoint(CGPointMake(-renderedImage.size.width/2, CGPointZero.y))
        }
        
        bottomImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        let topHalfImageView = UIImageView(image: topImage)
        let bottomHalfImageView = UIImageView(image: bottomImage)
        
        return [topHalfImageView, bottomHalfImageView]
    }
    
    func detectCenterPoint(fromOldCenterPoint currentCenterPoint: CGPoint,
                            movedFromAnchorPoint oldAnchorPoint: CGPoint,
                            toAnchorPoint newAnchorPoint: CGPoint,
                            inFrame frame: CGRect) -> CGPoint {
        let anchorPointDiff = CGPoint(x: newAnchorPoint.x - oldAnchorPoint.x,
                                      y: newAnchorPoint.y - oldAnchorPoint.y)
        let newCenterPoint = CGPoint(x: currentCenterPoint.x + (anchorPointDiff.x * frame.size.width),
                                     y: currentCenterPoint.y + (anchorPointDiff.y * frame.size.height))
        return newCenterPoint
    }
    
    func animateView() {
        var frontImages: [UIImageView]? = nil
        if isBottomFirstAnimation {
            frontImages = convertViewToImages(fromView: backView!, flipState: currentFlipState)
        } else {
            frontImages = convertViewToImages(fromView: frontView!, flipState: currentFlipState)
        }
        
        firstHalfFrontView = frontImages![0]
        secondHalfFrontView = frontImages![1]
        
        firstHalfFrontView?.frame = (firstHalfFrontView?.bounds)!
        addSubview(firstHalfFrontView!)
      
        if currentFlipState == .flipFromBottomToTop || currentFlipState == .flipFromTopToBottom {
            secondHalfFrontView?.frame = CGRectOffset(firstHalfFrontView!.frame, 0, firstHalfFrontView!.frame.size.height)
        } else {
            secondHalfFrontView?.frame = CGRectOffset(firstHalfFrontView!.frame, firstHalfFrontView!.frame.size.width, 0)
        }
        addSubview(secondHalfFrontView!)
        
        
        var backImages: [UIImageView]? = nil
        if isBottomFirstAnimation {
            backImages = convertViewToImages(fromView: frontView!, flipState: currentFlipState)
        } else {
            backImages = convertViewToImages(fromView: backView!, flipState: currentFlipState)
        }
        
        firstHalfBackView = backImages![0]
        secondHalfBackView = backImages![1]
        
        firstHalfBackView?.frame = (firstHalfFrontView?.frame)!
        insertSubview(firstHalfBackView!, belowSubview: firstHalfFrontView!)
        
        secondHalfBackView?.frame = (secondHalfFrontView?.frame)!
        insertSubview(secondHalfBackView!, belowSubview: secondHalfFrontView!)
     
        var newTopViewAnchorPoint = CGPointZero
        var newAnchorPointBottomHalf = CGPointZero
        
        if currentFlipState == .flipFromBottomToTop || currentFlipState == .flipFromTopToBottom {
            newTopViewAnchorPoint = CGPointMake(0.5, 1.0);
            newAnchorPointBottomHalf = CGPointMake(0.5, 0.0);
        } else {
            newTopViewAnchorPoint = CGPointMake(1.0, 0.5);
            newAnchorPointBottomHalf = CGPointMake(0.0,0.5);
        }
        
        firstHalfFrontView?.layer.anchorPoint = newTopViewAnchorPoint
        firstHalfFrontView?.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        firstHalfFrontView?.layer.opacity = 1
        firstHalfFrontView?.layer.opaque = true
        
        secondHalfBackView?.layer.anchorPoint = newAnchorPointBottomHalf
        secondHalfBackView?.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        secondHalfBackView?.layer.opacity = 1
        secondHalfBackView?.layer.opaque = true
        
        if isBottomFirstAnimation {
            bottomFirstAnimation()
        } else {
            topFirstAnimation()
        }
    }
    
    
    func bottomFirstAnimation() {
        var skewedIdentityTransform = CATransform3DIdentity
        let zDistance: CGFloat = 1000.000
        skewedIdentityTransform.m34 = 1.0 / -zDistance
        
        var x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0
        if currentFlipState == .flipFromBottomToTop || currentFlipState == .flipFromTopToBottom {
            x = 1.0
            y = 0.0
            z = 0.0
        } else {
            x = 0.0
            y = 1.0
            z = 0.0
        }

        let bottomAnimation = CABasicAnimation(keyPath: "transform")
        bottomAnimation.beginTime = CACurrentMediaTime()
        bottomAnimation.duration = 0.5
        bottomAnimation.fromValue = NSValue(CATransform3D: skewedIdentityTransform)
        
        switch currentFlipState {
        case .flipFromBottomToTop:
            bottomAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromTopToBottom:
            bottomAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromLeftToRight:
            bottomAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                -CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromRightToLeft:
            bottomAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                -CGFloat(M_PI_2),
                x,
                y,
                z))
        default:
            break
        }
     
        bottomAnimation.delegate = nil
        bottomAnimation.removedOnCompletion = false
        bottomAnimation.fillMode = kCAFillModeForwards
        bottomAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.7, 0.0, 1.0, 1.0)
        
        secondHalfBackView?.layer.opacity = 1
        secondHalfBackView?.layer.opaque = true
        
        secondHalfBackView?.layer.addAnimation(bottomAnimation, forKey: "bottomDownFlip")
        bringSubviewToFront(secondHalfBackView!)
        
        
        let topAnimation = CABasicAnimation(keyPath: "transform")
        topAnimation.beginTime = bottomAnimation.beginTime + bottomAnimation.duration
        topAnimation.duration = bottomAnimation.duration
        topAnimation.toValue = NSValue(CATransform3D: skewedIdentityTransform)
        
        switch currentFlipState {
        case .flipFromBottomToTop:
            topAnimation.fromValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                -CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromTopToBottom:
            topAnimation.fromValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                -CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromLeftToRight:
            topAnimation.fromValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromRightToLeft:
            topAnimation.fromValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                CGFloat(M_PI_2),
                x,
                y,
                z))
        default:
            break
        }
        
        topAnimation.delegate = self
        topAnimation.removedOnCompletion = false
        topAnimation.fillMode = kCAFillModeBoth
        topAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.3, 1.0, 1.0, 1.0)
        
        firstHalfFrontView?.layer.opacity = 1
        firstHalfFrontView?.layer.opaque = true
        firstHalfFrontView?.layer.addAnimation(topAnimation, forKey: "topDownFlip")

        bringSubviewToFront(firstHalfFrontView!)
    
    }
    
    func topFirstAnimation() {
        var skewedIdentityTransform = CATransform3DIdentity
        let zDistance: CGFloat = 1000.000
        skewedIdentityTransform.m34 = 1.0 / -zDistance
        
        var x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0
        if currentFlipState == .flipFromBottomToTop || currentFlipState == .flipFromTopToBottom {
            x = 1.0
            y = 0.0
            z = 0.0
        } else {
            x = 0.0
            y = 1.0
            z = 0.0
        }

        let topAnimation = CABasicAnimation(keyPath: "transform")
        topAnimation.beginTime = CACurrentMediaTime()
        topAnimation.duration = 0.5
        topAnimation.fromValue = NSValue(CATransform3D: skewedIdentityTransform)
        
        switch currentFlipState {
        case .flipFromBottomToTop:
            topAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                -CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromTopToBottom:
            topAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                -CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromLeftToRight:
            topAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromRightToLeft:
            topAnimation.toValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                CGFloat(M_PI_2),
                x,
                y,
                z))
        default:
            break
        }
        
        topAnimation.delegate = nil
        topAnimation.removedOnCompletion = false
        topAnimation.fillMode = kCAFillModeBoth
        topAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.7, 1.0, 1.0, 1.0)
        
        firstHalfFrontView?.layer.opacity = 1
        firstHalfFrontView?.layer.opaque = true
        firstHalfFrontView?.layer.addAnimation(topAnimation, forKey: "topDownFlip")
        
        bringSubviewToFront(firstHalfFrontView!)

        let bottomAnimation = CABasicAnimation(keyPath: "transform")
        bottomAnimation.beginTime = topAnimation.beginTime + topAnimation.duration
        bottomAnimation.duration = topAnimation.duration
        
        switch currentFlipState {
        case .flipFromBottomToTop:
            bottomAnimation.fromValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromTopToBottom:
            bottomAnimation.fromValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromLeftToRight:
            bottomAnimation.fromValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                -CGFloat(M_PI_2),
                x,
                y,
                z))
        case .flipFromRightToLeft:
            bottomAnimation.fromValue = NSValue(CATransform3D: CATransform3DRotate(skewedIdentityTransform,
                -CGFloat(M_PI_2),
                x,
                y,
                z))
        default:
            break
        }
        
        bottomAnimation.toValue = NSValue(CATransform3D: skewedIdentityTransform)
        bottomAnimation.delegate = self
        bottomAnimation.removedOnCompletion = false
        bottomAnimation.fillMode = kCAFillModeBoth
        bottomAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.3, 0.0, 1.0, 1.0)
        
        secondHalfBackView?.layer.opacity = 1
        secondHalfBackView?.layer.opaque = true
        
        secondHalfBackView?.layer.addAnimation(bottomAnimation, forKey: "bottomDownFlip")
        bringSubviewToFront(secondHalfBackView!)
    }
    
    
    func getFlipDirectionState() {
        switch currentFlipState {
        case .flipFromBottomToTop:
            animateView()
            previousFlipState = .flipFromBottomToTop
            currentFlipState = .flipStop
        case .flipFromTopToBottom:
            animateView()
            previousFlipState = .flipFromTopToBottom
            currentFlipState = .flipStop
        case .flipFromLeftToRight:
            animateView()
            previousFlipState = .flipFromLeftToRight
            currentFlipState = .flipStop
        case .flipFromRightToLeft:
            animateView()
            previousFlipState = .flipFromRightToLeft
            currentFlipState = .flipStop
        case .flipStop:
            // remove all of the half view from its super view
            firstHalfFrontView?.removeFromSuperview()
            secondHalfFrontView?.removeFromSuperview()
            firstHalfBackView?.removeFromSuperview()
            secondHalfBackView?.removeFromSuperview()
            
            firstHalfFrontView = nil
            secondHalfFrontView = nil
            firstHalfBackView = nil
            secondHalfBackView = nil
            
            let colorRef = frontView?.layer.backgroundColor
            frontView?.layer.backgroundColor = backView?.layer.backgroundColor
            backView?.layer.backgroundColor = colorRef
            
//            switch (previousFlipState) {
//            case .flipFromBottomToTop:
//                currentFlipState = .flipFromRightToLeft;
//            case .flipFromTopToBottom:
//                currentFlipState = .flipFromLeftToRight;
//            case .flipFromLeftToRight:
//                currentFlipState = .flipFromBottomToTop;
//            case .flipFromRightToLeft:
//                currentFlipState = .flipFromTopToBottom;
//            default:
//                break
//            }

            switch (previousFlipState) {
            case .flipFromRightToLeft:
                currentFlipState = .flipFromRightToLeft;
            default:
                break
            }

            
            let backColor = colors[0]
            moveColorObjectsInArray()
            backView?.layer.backgroundColor = backColor.CGColor
            
            getFlipDirectionState()
        default:
            firstHalfFrontView?.removeFromSuperview()
            secondHalfFrontView?.removeFromSuperview()
            firstHalfBackView?.removeFromSuperview()
            secondHalfBackView?.removeFromSuperview()
            
            firstHalfFrontView = nil
            secondHalfFrontView = nil
            firstHalfBackView = nil
            secondHalfBackView = nil
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        performSelectorOnMainThread(#selector(FlipLoadingAnimationView.getFlipDirectionState),
                                    withObject: nil,
                                    waitUntilDone: false)
    }
    
    var isAnimating: Bool {
        get {
            return animationCount > 0
        }
    }
    
    func moveColorObjectsInArray() {
        let color = colors[0]
        colors.removeAtIndex(0)
        colors.append(color)
    }
    
    func moveImageObjectsInArray() {
        let image = imageNames[0]
        imageNames.removeAtIndex(0)
        imageNames.append(image)
    }
}