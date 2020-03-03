//
//  uploadImage.swift
//  Chat App
//
//  Created by Apple on 3/2/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit
import Firebase


extension ChatMessagesController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
            
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage)
        }
            
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                ref.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    
                    self.sendMessageWithImageUrl(url?.absoluteString ?? "",image: image)
                })
            })
        }
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String,image:UIImage) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let values = ["imageUrl": imageUrl, "sendToId": toId, "fromId": fromId, "timestamp": timestamp,"imageWidth":image.size.width ,"imageHeight":image.size.height] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            
            guard let messageId = childRef.key else { return }
            
           let userMessagesRef = Database.database().reference().child("user_messages").child(fromId).child(messageId)
            userMessagesRef.setValue(1)
            
            let recipientUserMessagesRef = Database.database().reference().child("user_messages").child(self.sendToId).child(messageId)
            recipientUserMessagesRef.setValue(1)
        }
    }
}
