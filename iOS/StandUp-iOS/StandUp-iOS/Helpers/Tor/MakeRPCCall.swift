//
//  MakeRPCCall.swift
//  BitSense
//
//  Created by Peter on 31/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation

class MakeRPCCall {
    
    static let sharedInstance = MakeRPCCall()
    let aes = AESService()
    let cd = CoreDataService()
    var rpcusername = ""
    var rpcpassword = ""
    var onionAddress = ""
    var rpcport = ""
    var errorBool = Bool()
    var errorDescription = String()
    let torClient = TorClient.sharedInstance
    var objectToReturn:Any!
    var attempts = 0
    
    func executeRPCCommand(method: BTC_CLI_COMMAND, param: Any, completion: @escaping () -> Void) {
        print("executeTorRPCCommand")
        
        attempts += 1
        
        cd.retrieveEntity(entityName: .nodes) {
            
            if !self.cd.errorBool {
                
                let nodes = self.cd.entities
                let node = NodeStruct(dictionary: nodes[0])
                self.onionAddress = self.aes.decryptKey(keyToDecrypt: node.onionAddress)
                self.rpcusername = self.aes.decryptKey(keyToDecrypt: node.rpcuser)
                self.rpcpassword = self.aes.decryptKey(keyToDecrypt: node.rpcpassword)
                let walletUrl = "http://\(self.rpcusername):\(self.rpcpassword)@\(self.onionAddress)/wallet/StandUp"
                var formattedParam = (param as! String).replacingOccurrences(of: "''", with: "")
                formattedParam = formattedParam.replacingOccurrences(of: "'\"'\"'", with: "'")
                
                guard let url = URL(string: walletUrl) else {
                    self.errorBool = true
                    self.errorDescription = "url error"
                    completion()
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
                //print("request: \("{\"jsonrpc\":\"1.0\",\"id\":\"curltest\",\"method\":\"\(method)\",\"params\":[\(formattedParam)]}")")
                request.httpBody = "{\"jsonrpc\":\"1.0\",\"id\":\"curltest\",\"method\":\"\(method)\",\"params\":[\(formattedParam)]}".data(using: .utf8)
                //print("request = \(request)")
                
                let queue = DispatchQueue(label: "com.FullyNoded.torQueue")
                queue.async {
                    
                    let task = self.torClient.session.dataTask(with: request as URLRequest) { (data, response, error) in
                        
                        do {
                            
                            if error != nil {
                                
                                // attempt a node command 5 times to avoid user having to tap refresh button
                                if self.attempts < 5 {
                                    
                                    self.executeRPCCommand(method: method, param: param, completion: completion)
                                    
                                } else {
                                    
                                    self.errorBool = true
                                    self.errorDescription = error!.localizedDescription
                                    completion()
                                    
                                }
                                
                            } else {
                                
                                self.attempts = 0
                                
                                if let urlContent = data {
                                    
                                    do {
                                        
                                        let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                                        
                                        if let errorCheck = jsonAddressResult["error"] as? NSDictionary {
                                            
                                                if let errorMessage = errorCheck["message"] as? String {
                                                    
                                                    self.errorDescription = errorMessage
                                                    
                                                } else {
                                                    
                                                    self.errorDescription = "Uknown error"
                                                    
                                                }
                                                
                                                self.errorBool = true
                                                completion()
                                                
                                            
                                        } else {
                                            
                                            self.errorBool = false
                                            self.errorDescription = ""
                                            self.objectToReturn = jsonAddressResult["result"]
                                            completion()
                                            
                                        }
                                        
                                    } catch {
                                        
                                        self.errorBool = true
                                        self.errorDescription = "Uknown Error"
                                        completion()
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    
                    }
                    
                    task.resume()
                    
                }
                
            } else {
                
                self.errorBool = true
                self.errorDescription = "error getting nodes from core data"
                completion()
                
            }
            
        }
        
    }
    
    private init() {}
    
}
