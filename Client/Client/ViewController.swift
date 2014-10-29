//
//  ViewController.swift
//  Client
//
//  Created by scnfex on 10/29/14.
//  Copyright (c) 2014 Bobo Shone. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate {

  // MARK: Property
  
  let serviceType: String = "bs-mc"
  var peerID: MCPeerID!
  var session: MCSession!
  var browser: MCNearbyServiceBrowser!
  
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let displayName = UIDevice.currentDevice().name
    self.peerID = MCPeerID(displayName: displayName)
    self.session = MCSession(peer: self.peerID)
    self.session.delegate = self
    
    self.browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
    self.browser.delegate = self
    self.browser.startBrowsingForPeers()
    
    self.status.text = "not connected"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  deinit {
    self.browser.stopBrowsingForPeers()
    self.session.disconnect()
  }
  
  // MARK: MCSessionDelegate
  
  func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    switch state {
    case .Connected:
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.status.text = "connected"
      })
    case .Connecting:
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.status.text = "connecting..."
      })
    case .NotConnected:
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.status.text = "connect fail"
      })
    default:
      println("error")
    }
  }
  
  func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    if let image = UIImage(data: data) {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView.image = image
      })
    }
  }
  
  func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    /***/
  }
  
  func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    /***/
  }
  
  func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
    /***/
  }

  // MARK: MCNearbyServiceBrowserDelegate
  
  func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
    println("browser found peear \(peerID.displayName)")
    
    browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 0)
  }
  
  func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
    println("browser lost peer \(peerID.displayName)")
  }
}

