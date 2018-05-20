//
//  SwiftNotice.swift
//  SwiftNotice
//
//  Created by JohnLui on 15/4/15.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation
import UIKit

private let sn_topBar: Int = 1001

extension UIResponder {

    @discardableResult
    func pleaseWait() -> UIWindow{
        return SwiftNotice.wait()
    }

    @discardableResult
    func pleaseWaitWithImages(_ imageNames: Array<UIImage>, timeInterval: Int) -> UIWindow{
        return SwiftNotice.wait(imageNames, timeInterval: timeInterval)
    }

    @discardableResult
    func noticeTop(_ text: String, hideAfter: Int = 2) -> UIWindow{
        return SwiftNotice.noticeOnStatusBar(text, hideAfter: hideAfter)
    }
    
    @discardableResult
    func noticeOnlyText(_ text: String, hideAfter: Int = 3, closeOnTap: Bool = true) -> UIWindow{
        return SwiftNotice.showText(text, hideAfter: hideAfter, closeOnTap: closeOnTap)
    }

    @discardableResult
    func noticeSuccess(_ text: String, hideAfter: Int = 3, closeOnTap: Bool = true) -> UIWindow{
        return SwiftNotice.showNoticeWithText(NoticeType.success, text: text, hideAfter: hideAfter, closeOnTap: closeOnTap)
    }
    @discardableResult
    func noticeError(_ text: String, hideAfter: Int = 3, closeOnTap: Bool = true) -> UIWindow{
        return SwiftNotice.showNoticeWithText(NoticeType.error, text: text, hideAfter: hideAfter, closeOnTap: closeOnTap)
    }
    @discardableResult
    func noticeInfo(_ text: String, hideAfter: Int = 3, closeOnTap: Bool = true) -> UIWindow{
        return SwiftNotice.showNoticeWithText(NoticeType.info, text: text, hideAfter: hideAfter, closeOnTap: closeOnTap)
    }
    
    func clearAllNotice() {
        SwiftNotice.clear()
    }
}

enum NoticeType{
    case success
    case error
    case info
}

class SwiftNotice: NSObject {
    
    static var windows = Array<UIWindow?>()
    static let rv = UIApplication.shared.keyWindow?.subviews.first as UIView?
    static var timer: DispatchSource!
    static var timerTimes = 0
    
    // fix https://github.com/johnlui/SwiftNotice/issues/2
    // thanks broccolii(https://github.com/broccolii) and his PR https://github.com/johnlui/SwiftNotice/pull/5
    static func clear() {
        self.cancelPreviousPerformRequests(withTarget: self)
        if let _ = timer {
            timer.cancel()
            timer = nil
            timerTimes = 0
        }
        windows.removeAll(keepingCapacity: false)
    }
    
    @discardableResult
    static func noticeOnStatusBar(_ text: String, hideAfter: Int = 0) -> UIWindow{
        let frame = UIApplication.shared.statusBarFrame
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        let view = UIView()
        view.backgroundColor = UIColor(red: 0x6a/0x100, green: 0xb4/0x100, blue: 0x9f/0x100, alpha: 1)
        
        let label = UILabel(frame: frame.height > 20 ? CGRect(x: frame.origin.x, y: frame.origin.y + frame.height - 17, width: frame.width, height: 20) : frame)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.text = text
        view.addSubview(label)
        
        window.frame = frame
        view.frame = frame
        
        window.windowLevel = UIWindowLevelStatusBar
        window.isHidden = false
        window.addSubview(view)
        windows.append(window)
        
        var origPoint = view.frame.origin
        origPoint.y = -(view.frame.size.height)
        let destPoint = view.frame.origin
        view.tag = sn_topBar
        
        view.frame = CGRect(origin: origPoint, size: view.frame.size)
        UIView.animate(withDuration: 0.3, animations: {
            view.frame = CGRect(origin: destPoint, size: view.frame.size)
        }, completion: { b in
            if hideAfter > 0 {
                self.perform(.hideNotice, with: window, afterDelay: TimeInterval(hideAfter))
            }
        })
        return window
    }
    
    @discardableResult
    static func wait(_ imageNames: Array<UIImage> = Array<UIImage>(), timeInterval: Int = 0, userInteractionEnabled: Bool = false) -> UIWindow {
        let frame = CGRect(x: 0, y: 0, width: 78, height: 78)
        
        let window = configWindow(userInteractionEnabled: userInteractionEnabled, closeOnTap: false)
        
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)
        window.addSubview(mainView)
        
        if imageNames.count > 0 {
            if imageNames.count > timerTimes {
                let iv = UIImageView(frame: frame)
                iv.image = imageNames.first!
                iv.contentMode = UIViewContentMode.scaleAspectFit
                mainView.addSubview(iv)
                timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: DispatchQueue.main) as! DispatchSource
                timer.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.milliseconds(timeInterval))
                timer.setEventHandler(handler: { () -> Void in
                    let name = imageNames[timerTimes % imageNames.count]
                    iv.image = name
                    timerTimes += 1
                })
                timer.resume()
            }
        } else {
            let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            ai.frame = CGRect(x: 21, y: 21, width: 36, height: 36)
            ai.startAnimating()
            mainView.addSubview(ai)
        }
        
        mainView.frame = frame
        mainView.center = window.center
        
        windows.append(window)
        
        window.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            window.alpha = 1
        })
        
        return window
    }
    
    @discardableResult
    static func showText(_ text: String, hideAfter: Int = 2, userInteractionEnabled: Bool = false, closeOnTap: Bool = true) -> UIWindow {

        let window = configWindow(userInteractionEnabled: userInteractionEnabled, closeOnTap: closeOnTap)
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)
        window.addSubview(mainView)
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        let size = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width-82, height: CGFloat.greatestFiniteMagnitude))
        label.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        mainView.addSubview(label)
        
        let superFrame = CGRect(x: 0, y: 0, width: label.frame.width + 50 , height: label.frame.height + 30)
        mainView.frame = superFrame
        
        label.center = mainView.center
        mainView.center = window.center
        
        windows.append(window)
        
        window.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            window.alpha = 1
        })

        if hideAfter > 0 {
            self.perform(.hideNotice, with: window, afterDelay: TimeInterval(hideAfter))
        }
        return window
    }
    
    @discardableResult
    static func showNoticeWithText(_ type: NoticeType,text: String, hideAfter: Int = 0, userInteractionEnabled: Bool = false, closeOnTap: Bool = true) -> UIWindow {
        let frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        let window = configWindow(userInteractionEnabled: userInteractionEnabled, closeOnTap: closeOnTap)
        let mainView = UIView()
        mainView.layer.cornerRadius = 10
        mainView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.7)
        window.addSubview(mainView)
        
        var image = UIImage()
        switch type {
        case .success:
            image = SwiftNoticeSDK.imageOfCheckmark
        case .error:
            image = SwiftNoticeSDK.imageOfCross
        case .info:
            image = SwiftNoticeSDK.imageOfInfo
        }
        let checkmarkView = UIImageView(image: image)
        checkmarkView.frame = CGRect(x: 27, y: 15, width: 36, height: 36)
        mainView.addSubview(checkmarkView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 60, width: 90, height: 16))
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        label.text = text
        label.textAlignment = NSTextAlignment.center
        mainView.addSubview(label)
        mainView.frame = frame
        mainView.center = window.center
        
        windows.append(window)
        
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            mainView.alpha = 1
        })
        
        if hideAfter > 0 {
            self.perform(.hideNotice, with: window, afterDelay: TimeInterval(hideAfter))
        }
        return window
    }
    
    // config general window
    static func configWindow(userInteractionEnabled: Bool, closeOnTap: Bool) -> UIWindow{
        let window = UIWindow()
        window.backgroundColor = userInteractionEnabled
            ? UIColor.clear
            : UIColor(red:0, green:0, blue:0, alpha: 0.2)
        window.frame = (UIApplication.shared.keyWindow?.frame)!
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.center = SwiftNotice.rv!.center
        window.isUserInteractionEnabled = !userInteractionEnabled
        
        if closeOnTap && window.isUserInteractionEnabled {
            let tap = UITapGestureRecognizer(target: window, action: #selector(UIWindow.hide))
            window.addGestureRecognizer(tap)
        }
        
        return window
    }
}

class SwiftNoticeSDK {
    struct Cache {
        static var imageOfCheckmark: UIImage?
        static var imageOfCross: UIImage?
        static var imageOfInfo: UIImage?
    }
    class func draw(_ type: NoticeType) {
        let checkmarkShapePath = UIBezierPath()
        
        // draw circle
        checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
        checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        checkmarkShapePath.close()
        
        switch type {
        case .success: // draw checkmark
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.addLine(to: CGPoint(x: 16, y: 24))
            checkmarkShapePath.addLine(to: CGPoint(x: 27, y: 13))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.close()
        case .error: // draw X
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 26))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 26))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 10))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.close()
        case .info:
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.addLine(to: CGPoint(x: 18, y: 22))
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.close()
            
            UIColor.white.setStroke()
            checkmarkShapePath.stroke()
            
            let checkmarkShapePath = UIBezierPath()
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 27))
            checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 27), radius: 1, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
            checkmarkShapePath.close()
            
            UIColor.white.setFill()
            checkmarkShapePath.fill()
        }
        
        UIColor.white.setStroke()
        checkmarkShapePath.stroke()
    }
    class var imageOfCheckmark: UIImage {
        if (Cache.imageOfCheckmark != nil) {
            return Cache.imageOfCheckmark!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftNoticeSDK.draw(NoticeType.success)
        
        Cache.imageOfCheckmark = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCheckmark!
    }
    class var imageOfCross: UIImage {
        if (Cache.imageOfCross != nil) {
            return Cache.imageOfCross!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftNoticeSDK.draw(NoticeType.error)
        
        Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCross!
    }
    class var imageOfInfo: UIImage {
        if (Cache.imageOfInfo != nil) {
            return Cache.imageOfInfo!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftNoticeSDK.draw(NoticeType.info)
        
        Cache.imageOfInfo = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfInfo!
    }
}

extension UIWindow{
    @objc func hide(){
        SwiftNotice.hideNotice(self)
    }
}

fileprivate extension Selector {
    static let hideNotice = #selector(SwiftNotice.hideNotice(_:))
}

@objc extension SwiftNotice {
    // fix https://github.com/johnlui/SwiftNotice/issues/2
    static func hideNotice(_ sender: AnyObject) {
        if let window = sender as? UIWindow {
            if let v = window.subviews.first {
                UIView.animate(withDuration: 0.2, animations: {
                    if v.tag == sn_topBar {
                        v.frame = CGRect(x: 0, y: -v.frame.height, width: v.frame.width, height: v.frame.height)
                    }
                    window.alpha = 0
                }, completion: { b in
                    
                    if let index = windows.index(where: { (item) -> Bool in
                        return item == window
                    }) {
                        windows.remove(at: index)
                    }
                })
            }
        }
    }
}
