//
//  SocketManager.swift
//  Tasks
//
//  Created by Muhammad Raza on 12/05/2021.
//

import Foundation

class SocketManager: NSObject {
    
    // MARK: - VARIABLES
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    weak var bindingProtocol: SendingImagesRealtimeProtocol!
    
    // MARK: - INITIALIZER
    init(with delegate: SendingImagesRealtimeProtocol){
        self.bindingProtocol = delegate
    }
    
    func connectWith(object: ConfigurationModel) {
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (object.ipAddress as CFString), UInt32(object.port), &readStream, &writeStream)
        open()
    }
    
    func disconnect(){
        close()
    }
    
    // MARK: - HELPER METHODS
    
    func open() {
        print("Opening streams.")
        outputStream = writeStream?.takeRetainedValue()
        inputStream = readStream?.takeRetainedValue()
        outputStream?.delegate = self
        inputStream?.delegate = self
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.open()
        inputStream?.open()
    }
    
    func close() {
        print("Closing streams.")
        bindingProtocol?.resetUIWithConnection(status: false)
        inputStream?.close()
        outputStream?.close()
        inputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.delegate = nil
        outputStream?.delegate = nil
        inputStream = nil
        outputStream = nil
    }

    
//    func messageReceived(message: String){
//        bindingProtocol?.update(message: "server said: \(message)")
//        print(message)
//    }
//    
//    func send(message: String){
//        let response = "msg:\(message)"
//        let buff = [UInt8](message.utf8)
//        if let _ = response.data(using: .ascii) {
//            outputStream?.write(buff, maxLength: buff.count)
//        }
//    }
    
    func messageReceived(image: Data){
        bindingProtocol?.update(imageMessage: image)
        print("New image received from server")
    }
    
    func sendImage(data: Data) {
        outputStream?.write(data.bytes, maxLength: data.count)
    }

}

extension SocketManager: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print("stream event \(eventCode)")
        switch eventCode {
        case .openCompleted:
            bindingProtocol?.resetUIWithConnection(status: true)
            print("Stream opened")
        case .hasBytesAvailable:
            if aStream == inputStream {
                // reading image
                var count = 0
                let dataOfTheImage = NSMutableData()
                var buffer = Array<UInt8>(repeating: 0, count: 1024)
                inputStream?.open()

                //MARK: Loop through thumbnail stream
                while (inputStream?.hasBytesAvailable)! {
                    count = count + 1
                    print("Counter: \(count)")
                    //MARK: Read from the stream and append bytes to NSMutableData variable
                    let len  = inputStream?.read(&buffer, maxLength: buffer.count) ?? 0
                    dataOfTheImage.append(buffer, length: len)

                    //MARK: Size of the image in MB
                    let size = Float(dataOfTheImage.length) / 1024.0 / 1024.0
                    print("Data length = \(size)")
                }

                //MARK: Check if there are no bytes left and show the image
                if (inputStream?.hasBytesAvailable == false){
                    inputStream?.close()
                    self.messageReceived(image: dataOfTheImage as Data)
                }
                
                // reading text
//                var dataBuffer = Array<UInt8>(repeating: 0, count: 1024)
//                var len: Int
//                while (inputStream?.hasBytesAvailable)! {
//                    len = (inputStream?.read(&dataBuffer, maxLength: 1024))!
//                    if len > 0 {
//                        let output = String(bytes: dataBuffer, encoding: .ascii)
//                        if nil != output {
//                            print("server said: \(output ?? "")")
//                            messageReceived(message: output!)
//                        }
//                    }
//                }
            }
        case .hasSpaceAvailable:
            print("Stream has space available now")
        case .errorOccurred:
            print("\(aStream.streamError?.localizedDescription ?? "")")
        case .endEncountered:
            aStream.close()
            aStream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            print("close stream")
            bindingProtocol?.resetUIWithConnection(status: false)
        default:
            print("Unknown event")
        }
    }
    
}
