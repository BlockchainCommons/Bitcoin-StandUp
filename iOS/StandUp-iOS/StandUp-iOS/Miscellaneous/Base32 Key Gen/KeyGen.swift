//
//  KeyGen.swift
//  BitSense
//
//  Created by Peter on 24/10/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import CryptoKit
import Foundation

class KeyGen {
    
    var privKey = ""
    var pubKey = ""
    
    func generate() {
        
        if #available(iOS 13.0, *) {
            
            let privKeyRaw = Curve25519.KeyAgreement.PrivateKey.init()
            let pubKeyRaw = privKeyRaw.publicKey
            
            let privKeyData = privKeyRaw.rawRepresentation
            let pubkeyData = pubKeyRaw.rawRepresentation
            
            let privkeyBase32 = privKeyData.base32EncodedString
            let pubkeyBase32 = pubkeyData.base32EncodedString
            
            privKey = privkeyBase32.replacingOccurrences(of: "====", with: "")
            pubKey = pubkeyBase32.replacingOccurrences(of: "====", with: "")
        
        }
        
    }
    
}


