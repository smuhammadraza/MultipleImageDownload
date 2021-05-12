//
//  ConfigurationModel.swift
//  Tasks
//
//  Created by Muhammad Raza on 12/05/2021.
//

import Foundation

struct ConfigurationModel {
    
    let ipAddress: String
    let port: Int
    
    init(ip: String, port: String){
        self.ipAddress = ip
        self.port = Int(port) ?? 0
    }
}
