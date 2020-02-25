//
//  LoginController+imagePicker.swift
//  Chat App
//
//  Created by Apple on 2/24/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // MARK - handle register button
    @objc func handleRegister(){
        guard let email = emailTextField.text, let pass = passwordTextField.text , let name = nameTextField.text else {return }
        Auth.auth().createUser(withEmail: email, password: pass) { (res, error) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            guard let uid = res?.user.uid else {
                return
            }
            
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            
            if let uploadImage = self.plusPhotoButton.imageView?.image?.pngData() {
                storageRef.putData(uploadImage, metadata: nil) { (_, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        
                        guard let url = url else { return }
                        let values = ["name": name, "email": email, "profileImageUrl": url.absoluteString]
                        
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                    })
                    
                }
            self.dismiss(animated: true, completion: nil)
        }
        }}
    
    
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
            self.messagesController?.FetchUserAndSetupNavBarTitle() 
            self.messagesController?.navigationItem.title = ""
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        var selectedImageFromPicker: UIImage?
        
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.rgb(red: 61, green: 91, blue: 151).cgColor
        plusPhotoButton.layer.borderWidth = 1
        
        self.plusPhotoButton.setImage(selectedImageFromPicker?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismissImagePisker()
    }
    
    func showImagePickerVC(vc: UIImagePickerController) {
        self.present(vc, animated: true, completion: nil)
    }
    
    func dismissImagePisker(){
         self.dismiss(animated: true, completion: nil)
    }
}

