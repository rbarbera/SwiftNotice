//
//  SwiftNotice.swift
//  SwiftNotice
//
//  Created by Rafa Barberá on 21/05/2018
//  Based on work by JohnLui on 15/4/15.
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
    func noticeInfo(_ text: String, hideAfter: Int = 2, closeOnTap: Bool = true) -> UIWindow{
        return SwiftNotice.noticeOnStatusBar(text, color: UIColor(red: 0x6a/0x100, green: 0xb4/0x100, blue: 0x9f/0x100, alpha: 1), hideAfter: hideAfter, closeOnTap: closeOnTap)
    }

    @discardableResult
    func noticeError(_ text: String, hideAfter: Int = 2, closeOnTap: Bool = true) -> UIWindow{
        return SwiftNotice.noticeOnStatusBar(text, color: UIColor(red: 0x9f/0x100, green: 0x04/0x100, blue: 0x04/0x100, alpha: 1), hideAfter: hideAfter, closeOnTap: closeOnTap)
    }

    @discardableResult
    func noticeOnlyText(_ text: String, hideAfter: Int = 3, closeOnTap: Bool = true) -> UIWindow{
        return SwiftNotice.showText(text, hideAfter: hideAfter, closeOnTap: closeOnTap)
    }
    
    func clearAllNotice() {
        SwiftNotice.clear()
    }
}

class SwiftNotice: NSObject {
    
    static var windows = Array<UIWindow?>()
    static var timer: DispatchSource!
    static var timerTimes = 0

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
    static func noticeOnStatusBar(_ text: String, color: UIColor, hideAfter: Int = 0, closeOnTap: Bool = true) -> UIWindow {
        let frame = UIApplication.shared.statusBarFrame
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        let view = UIView()
        view.backgroundColor = color
        
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
        
        if closeOnTap {
            let tap = UITapGestureRecognizer(target: window, action: #selector(UIWindow.hide))
            window.addGestureRecognizer(tap)
        }

        return window
    }
    
    @discardableResult
    static func wait(userInteractionEnabled: Bool = false) -> UIWindow {
        let frame = CGRect(x: 0, y: 0, width: 78, height: 78)
        
        let window = notificationWindow(userInteractionEnabled: userInteractionEnabled, closeOnTap: false)
        
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)
        window.addSubview(mainView)
        
        let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        ai.frame = CGRect(x: 21, y: 21, width: 36, height: 36)
        ai.startAnimating()
        mainView.addSubview(ai)

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

        let window = notificationWindow(userInteractionEnabled: userInteractionEnabled, closeOnTap: closeOnTap)
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
   
    static func notificationWindow(userInteractionEnabled: Bool, closeOnTap: Bool) -> UIWindow{
        let rv = UIApplication.shared.keyWindow?.subviews.first

        let window = UIWindow()
        window.backgroundColor = userInteractionEnabled
            ? UIColor.clear
            : UIColor(red:0, green:0, blue:0, alpha: 0.2)
        window.frame = (UIApplication.shared.keyWindow?.frame)!
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.center = rv!.center
        window.isUserInteractionEnabled = !userInteractionEnabled
        
        if closeOnTap && window.isUserInteractionEnabled {
            let tap = UITapGestureRecognizer(target: window, action: #selector(UIWindow.hide))
            window.addGestureRecognizer(tap)
        }
        
        return window
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
