//
//  SendingImagesRealtimeViewController.swift
//  Tasks
//
//  Created by Muhammad Raza on 12/05/2021.
//

import UIKit

class SendingImagesRealtimeViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var labelConnectionStatus: UILabel!
    @IBOutlet weak var textFieldIPAddress: UITextField!
    @IBOutlet weak var textFieldPort: UITextField!
    @IBOutlet weak var buttonConnect: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonSend: UIButton!
    
    // MARK: - VARIABLES
    var socketManager: SocketManager!
    lazy var imagePicker = UIImagePickerController()
    
    var dataArray = [DataModel]()
    
    // MARK: - VIEW LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // testing
        self.textFieldIPAddress.text = "localhost"
        self.textFieldPort.text = "49253"
        setup()
    }
    
    // MARK: - SETUP VIEW
    
    private func setup() {
        self.updateUIForConnection(status: false)
        socketManager = SocketManager(with: self)
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
    }
    
    
    // MARK: - BUTTON ACTIONS
    
    @IBAction func didTapConnectButton(_ sender: UIButton) {
        if self.validateInputFields() {
            let config = ConfigurationModel.init(ip: self.textFieldIPAddress.text ?? "",
                                                 port: self.textFieldPort.text ?? "")
            self.socketManager.connectWith(object: config)
        }
    }
    
    @IBAction func didTapSendImageButton(_ sender: UIButton) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - HELPER METHODS
    
    private func validateInputFields() -> Bool {
        guard let textFieldIPAddress = self.textFieldIPAddress,
              let ipAddress = textFieldIPAddress.text, !ipAddress.isEmpty else {
            self.showAlert(message: "Address field is required")
            return false
        }
        guard let textFieldPort = self.textFieldPort,
              let port = textFieldPort.text, !port.isEmpty else {
            self.showAlert(message: "Port field is required")
            return false
        }
        return true
    }
    
    private func updateUIForConnection(status: Bool) {
        self.textFieldIPAddress.isEnabled = !status
        self.textFieldPort.isEnabled = !status
        self.buttonConnect.isEnabled = !status
        self.buttonSend.isEnabled = status
        self.updateConnectionStatusMessage(status: status)
    }
    
    private func updateConnectionStatusMessage(status: Bool) {
        self.labelConnectionStatus.text = status ? "Connected" : "Disconnected"
    }
    
    
    private func showAlert(title: String = "Error", message: String) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}


extension SendingImagesRealtimeViewController: SendingImagesRealtimeProtocol {
    
    func resetUIWithConnection(status: Bool) {
        self.updateUIForConnection(status: status)
    }
    
    func update(imageMessage: Data) {
        self.dataArray.append(DataModel(title: "Remote", image: imageMessage))
        self.tableView.reloadData()
    }
}


extension SendingImagesRealtimeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(object: self.dataArray[indexPath.row])
        return cell
    }
}

extension SendingImagesRealtimeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if let imageData = image.jpegData(compressionQuality: 0.3) {
            self.socketManager.sendImage(data: imageData)
            self.dataArray.append(DataModel(title: "Local", image: imageData))
            self.tableView.reloadData()
        } else {
            self.showAlert(message: "Unable to send image")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
