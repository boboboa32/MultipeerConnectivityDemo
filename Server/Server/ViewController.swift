//
//  ViewController.swift
//  Server
//
//  Created by scnfex on 10/29/14.
//  Copyright (c) 2014 Bobo Shone. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate{
  
  // MARK: Property
  @IBOutlet weak var status: UILabel!
  
  let serviceType: String = "bs-mc"
  var peerID: MCPeerID!
  var session: MCSession!
  var advertiser: MCNearbyServiceAdvertiser!
  
  // MARK: Lift cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let displayName = UIDevice.currentDevice().name
    self.peerID = MCPeerID(displayName: displayName)
    self.session = MCSession(peer: self.peerID)
    self.session.delegate = self
    
    self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil,
      serviceType: self.serviceType)
    self.advertiser.delegate = self
    self.advertiser.startAdvertisingPeer()
    
    self.status.text = "not connected"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  deinit {
    self.advertiser.stopAdvertisingPeer()
    self.session.disconnect()
  }
  // MARK: Action
  
  @IBAction func sendImage(sender: AnyObject) {
    if UIImagePickerController.isCameraDeviceAvailable(.Rear) {
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .Camera
      imagePicker.delegate = self
      self.presentViewController(imagePicker, animated: true, completion: nil)
    }
  }
  
  // MARK: UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    picker.dismissViewControllerAnimated(true, completion: nil)
    
    if let data = UIImagePNGRepresentation(image) {
      var error: NSError?
      self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: .Unreliable,
        error: &error)
    }
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
    /***/
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
  
  // MARK: MCNearbyServiceAdvertiserDelegate
  
  func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!,
    withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
      println("advertiser receive invitation from peer \(peerID.displayName)")
      
    let alertController = UIAlertController(title: "Permission", message: "\(peerID.displayName) wants to know your position",
      preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
      invitationHandler(true, self.session)
      }
    let noAction = UIAlertAction(title: "NO", style: .Cancel) { (action) -> Void in
      invitationHandler(false, nil)
      }
      alertController.addAction(okAction)
      alertController.addAction(noAction)
      self.presentViewController(alertController, animated: true, completion: nil)
  }
  
}

