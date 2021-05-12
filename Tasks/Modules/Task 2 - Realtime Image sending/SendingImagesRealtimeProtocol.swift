//
//  SendingImagesRealtimeProtocol.swift
//  Tasks
//
//  Created by Muhammad Raza on 12/05/2021.
//

import Foundation

protocol SendingImagesRealtimeProtocol: class {
    func resetUIWithConnection(status: Bool)
    func update(imageMessage: Data)
}
