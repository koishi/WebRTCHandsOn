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
    var peerConnection: RTCPeerConnection! = nil
    var audioSource: RTCAudioSource?
    var videoSource: RTCAVFoundationVideoSource?

    @IBOutlet weak var videoView: RTCEAGLVideoView!
    @IBOutlet weak var cameraPreviewView: RTCCameraPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // RTCPeerConnectionFactoryの初期化
        peerConnectionFactory = RTCPeerConnectionFactory()

        startVideo()
        
        websocket = WebSocket(url: URL(string: "wss://conf.space/WebRTCHandsOnSig/koishi")!)
        websocket.delegate = self
        websocket.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tappedCloseButton(_ sender: Any) {
        // Closeボタンを押した時
        hangUp()
        websocket.disconnect()
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tappedConnectButton(_ sender: Any) {
        // Connectボタンを押した時
        if peerConnection == nil {
            peerConnection = prepareNewConnection()
        }
    }
    
    @IBAction func tappedHangUpButton(_ sender: Any) {
        //HangUpボタンを押した時
        hangUp()
    }

    func startVideo() {
        // 音声ソースの設定
        let audioSourceConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        // 音声ソースの生成
        audioSource = peerConnectionFactory.audioSource(with: audioSourceConstraints)
        
        // 映像ソースの設定
        let videoSourceConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        videoSource = peerConnectionFactory.avFoundationVideoSource(with: videoSourceConstraints)

        // 映像ソースをプレビューに設定
        cameraPreviewView.captureSession = videoSource?.captureSession
    }

    func LOG(_ body: String = "",
             function: String = #function,
             line: Int = #line) {
        print("[\(function) : \(line)] \(body)")
    }

    func prepareNewConnection() -> RTCPeerConnection {
        // STUN/TURNサーバーの指定
        let configuration = RTCConfiguration()
        configuration.iceServers = [
            RTCIceServer.init(urlStrings:
                ["stun:stun.l.google.com:19302"])]
        // PeerConecctionの設定(今回はなし)
        let peerConnectionConstraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil)
        // PeerConnectionの初期化
        peerConnection = peerConnectionFactory.peerConnection(
            with: configuration, constraints: peerConnectionConstraints, delegate: self)

        // 音声トラックの作成
        let localAudioTrack = peerConnectionFactory.audioTrack(with: audioSource!, trackId: "ARDAMSa0")
        // PeerConnectionからAudioのSenderを作成
        let audioSender = peerConnection.sender(
            withKind: kRTCMediaStreamTrackKindAudio,
            streamId: "ARDAMS")
        // Senderにトラックを設定
        audioSender.track = localAudioTrack
        
        // 映像ソースの設定
        let videoSourceConstraints = RTCMediaConstraints(
            mandatoryConstraints: nil, optionalConstraints: nil)
        videoSource = peerConnectionFactory
            .avFoundationVideoSource(with: videoSourceConstraints)
        
        // 映像ソースをプレビューに設定
        cameraPreviewView.captureSession = videoSource?.captureSession
        
        return peerConnection
    }

    func hangUp() {
        if peerConnection != nil {
            if peerConnection.iceConnectionState != RTCIceConnectionState.closed {
                peerConnection.close()
            }
            peerConnection = nil
            LOG("peerConnection is closed.")
        }
    }
    
    deinit {
        if peerConnection != nil {
            hangUp()
        }
        audioSource = nil
        videoSource = nil
        peerConnectionFactory = nil
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

extension ChatViewController: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange stateChanged: RTCSignalingState) {
        // 接続情報交換の状況が変化した際に呼ばれます
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didAdd stream: RTCMediaStream) {
        // 映像/音声が追加された際に呼ばれます
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove stream: RTCMediaStream) {
        // 映像/音声削除された際に呼ばれます
    }
    
    func peerConnectionShouldNegotiate(_
        peerConnection: RTCPeerConnection) {
        // 接続情報の交換が必要になった際に呼ばれます
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceConnectionState) {
        // PeerConnectionの接続状況が変化した際に呼ばれます
        var state = ""
        switch (newState) {
        case RTCIceConnectionState.checking:
            state = "checking"
        case RTCIceConnectionState.completed:
            state = "completed"
        case RTCIceConnectionState.connected:
            state = "connected"
        case RTCIceConnectionState.closed:
            state = "closed"
            hangUp()
        case RTCIceConnectionState.failed:
            state = "failed"
            hangUp()
        case RTCIceConnectionState.disconnected:
            state = "disconnected"
        default:
            break
        }
        LOG("ICE connection Status has changed to \(state)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceGatheringState) {
        // 接続先候補の探索状況が変化した際に呼ばれます
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didGenerate candidate: RTCIceCandidate) {
        // Candidate(自分への接続先候補情報)が生成された際に呼ばれます
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didOpen dataChannel: RTCDataChannel) {
        // DataChannelが作られた際に呼ばれます
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove candidates: [RTCIceCandidate]) {
        // Candidateが削除された際に呼ばれます
    }

}
