//
//  ViewController.swift
//  SwiftNoticeExample
//
//  Created by JohnLui on 15/4/15.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func userInteractionSwitch(_ sender: UISwitch) {
        //
    }
    
    @IBAction func topNotice(_ sender: AnyObject) {
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
        self.noticeInfo("OK!, tap to hide", hideAfter: 10)
    }
    @IBAction func wait(_ sender: AnyObject) {
    }

    @IBAction func noticeSuccess(_ sender: AnyObject) {
    }
    
    @IBAction func noticeError(_ sender: AnyObject) {
        self.noticeError("This is an error")
    }
    
    @IBAction func noticeInfo(_ sender: AnyObject) {
    }
    
    @IBAction func text(_ sender: AnyObject) {
        self.noticeOnlyText("Only Text Only Text Only Text Only \nText Only Text Only Text Only\n Text Only Text Only Text ", hideAfter: 5, closeOnTap: true)
    }
    
    @IBAction func clear(_ sender: AnyObject) {
        self.clearAllNotice()
    }
    
    @IBAction func request(_ sender: UIButton) {
        let hud = self.pleaseWait()
        DispatchQueue.global().async {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                hud.hide()
                self.anotherRequest()
            })
        }
    }

    func anotherRequest(){
        let hud = self.pleaseWait()
        DispatchQueue.global().async {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                hud.hide()
            })
        }
    }
}

