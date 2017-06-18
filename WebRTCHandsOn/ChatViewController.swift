//
//  ChatViewController.swift
//  WebRTCHandsOn
//
//  Created by 大石弘一郎 on 2017/06/18.
//  Copyright © 2017年 Koichiro Oishi. All rights reserved.
//

import UIKit
import WebRTC
import Starscream

class ChatViewController: UIViewController {

    var websocket: WebSocket! = nil
    var peerConnectionFactory: RTCPeerConnectionFactory! = nil
    var audioSource: RTCAudioSource?
    var videoSource: RTCAVFoundationVideoSource?

    @IBOutlet weak var videoView: RTCEAGLVideoView!
    @IBOutlet weak var cameraPreviewView: RTCCameraPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // RTCPeerConnectionFactoryの初期化
        peerConnectionFactory = RTCPeerConnectionFactory()

        websocket = WebSocket(url: URL(string: "wss://conf.space/WebRTCHandsOnSig/koishi")!)
        websocket.delegate = self
        websocket.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tappedCloseButton(_ sender: Any) {
        websocket.disconnect()
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tappedConnectButton(_ sender: Any) {
    }
    
    @IBAction func tappedHangUpButton(_ sender: Any) {
    }

    func startVideo() {

    }
    
    func LOG(_ body: String = "",
             function: String = #function,
             line: Int = #line) {
        print("[\(function) : \(line)] \(body)")
    }

}

extension ChatViewController: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocket) {
        LOG()
    }
    func websocketDidDisconnect(socket: WebSocket,
                                error: NSError?) {
        LOG("error: \(String(describing: error?.localizedDescription))")
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        LOG("message: \(text)")
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        LOG("data.count: \(data.count)")
    }
}
