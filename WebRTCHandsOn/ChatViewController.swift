//
//  ChatViewController.swift
//  WebRTCHandsOn
//
//  Created by 大石弘一郎 on 2017/06/18.
//  Copyright © 2017年 Koichiro Oishi. All rights reserved.
//

import UIKit
import WebRTC

class ChatViewController: UIViewController {

    @IBOutlet weak var videoView: RTCEAGLVideoView!
    @IBOutlet weak var cameraPreviewView: RTCCameraPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tappedCloseButton(_ sender: Any) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tappedConnectButton(_ sender: Any) {
    }
    
    @IBAction func tappedHangUpButton(_ sender: Any) {
    }

    func LOG(_ body: String = "",
             function: String = #function,
             line: Int = #line) {
        print("[\(function) : \(line)] \(body)")
    }

}
