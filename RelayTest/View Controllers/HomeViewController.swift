//
//  Home.swift
//  RelayTest
//
//  Created by Andy Sherwood on 9/5/17.
//  Copyright © 2017 Clean Water Services. All rights reserved.
//

import UIKit
import Starscream

class HomeViewController: UIViewController, WebSocketDelegate {

    @IBOutlet weak var response: UITextView!
    @IBOutlet weak var textToSend: UITextField!
    
    private var socket:WebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let environment: [String:String] = ProcessInfo.processInfo.environment
        
        let relay = ServiceBusRelay(relayNamespace: environment["AZURE_RELAY_NAMESPACE"] ?? "",
                                    sasKeyName: environment["AZURE_SAS_KEYNAME"] ?? "",
                                    sasPrimaryKey: environment["AZURE_SAS_PRIMARYKEY"] ?? "",
                                    entityPath: environment["AZURE_RELAY_ENTITYPATH"] ?? "")
        
        do {
            let relayUrl:URL = try relay.makeSecureHybridConnectionSenderUrl()
            self.socket = WebSocket(url: relayUrl)
            self.socket?.delegate = self
        } catch {
            NSLog("Relay Error: \(error.localizedDescription)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.socket?.connect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.socket?.disconnect()
    }

    @IBAction func touchedSend(_ sender: Any) {
        
        if let text = self.textToSend.text {
            NSLog("SENDING --> \"\(text)\"")
            self.socket?.write(string: "\(text)\n")
        }
    }
    
    func websocketDidConnect(socket: WebSocket) {
        NSLog("Connected.")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if let error = error {
            NSLog("Disconnected, with error: \(error.localizedDescription)")
        } else {
            NSLog("Disconnected.")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        NSLog("\(data.count) bytes received.")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        NSLog("\"\(text)\" received.")
        self.response.text = text
    }
}
