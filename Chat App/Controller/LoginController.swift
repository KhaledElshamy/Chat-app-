//
//  LoginController.swift
//  Chat App
//
//  Created by Khaled Elshamy on 11/4/19.
//  Copyright © 2019 Khaled Elshamy. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    var stackView = UIStackView()
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = .photoLibrary
        showImagePickerVC(vc: pickerController)
    }
    
    
    let inputsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.rgb(red: 61, green: 91, blue: 151).cgColor
        return view
    }()
    
    let loginRegisterButton:UIButton = {
       let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.rgb(red: 80, green: 101, blue: 151)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    @objc func handleLoginRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }else {
            handleRegister()
        }
    }
    
    @objc func handleLogin(){
        guard let email = emailTextField.text, let pass = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: pass) { (res, error) in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            guard let uid = res?.user.uid else {
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let SC = UISegmentedControl(items: ["Login" , "Register"])
        SC.translatesAutoresizingMaskIntoConstraints = false
        SC.layer.borderWidth = 0.5
        SC.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        SC.tintColor = UIColor.init(white: 0.0, alpha: 0.5)
        SC.selectedSegmentIndex = 1
        SC.addTarget(self, action: #selector(LoginRegisterChange), for: .valueChanged)
        return SC
    }()
    
    @objc func LoginRegisterChange(){
        let title  = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        containerViewHeight?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 1 ? 150 : 100
        
        let index = loginRegisterSegmentedControl.selectedSegmentIndex
        if index == 0 {
            stackView.removeArrangedSubview(nameTextField)
            nameTextField.removeFromSuperview()
            
            stackView.distribution = .fillEqually
            stackView.axis = .vertical
            self.plusPhotoButton.isHidden = true
        }else if index == 1 {
        
            stackView.addArrangedSubview(nameTextField)
            stackView.addArrangedSubview(emailTextField)
            stackView.addArrangedSubview(passwordTextField)
            stackView.distribution = .fillEqually
            stackView.axis = .vertical
             self.plusPhotoButton.isHidden = false
        }
    }
    
    
    let nameTextField: UITextField = {
        let TF = UITextField()
        TF.translatesAutoresizingMaskIntoConstraints = false
        TF.placeholder = "Name"
        TF.textAlignment = .left
        return TF
    }()
    
    let emailTextField: UITextField = {
        let TF = UITextField()
        TF.translatesAutoresizingMaskIntoConstraints = false
        TF.placeholder = "Email"
        TF.textAlignment = .left
        return TF
    }()
    
    
    let passwordTextField: UITextField = {
        let TF = UITextField()
        TF.translatesAutoresizingMaskIntoConstraints = false
        TF.placeholder = "Password"
        TF.textAlignment = .left
        TF.isSecureTextEntry = true
        return TF
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 61, green: 91, blue: 151)
        //view.backgroundColor = .white
        setupConstraints()
    }
    
    var containerViewHeight:NSLayoutConstraint?
    
    // MARK -- setup constraints for views
    func setupConstraints(){
        
        // MARK -- constraints for inputContainter constraints
        view.addSubview(inputsContainer)
        inputsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor,constant: -24).isActive = true
        containerViewHeight =  inputsContainer.heightAnchor.constraint(equalToConstant: 150)
        containerViewHeight?.isActive = true
        
        
        // MARK -- Login register button
        view.addSubview(loginRegisterButton)
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainer.bottomAnchor,constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stackView = UIStackView(arrangedSubviews: [nameTextField,emailTextField,passwordTextField])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        inputsContainer.addSubview(stackView)
        stackView.anchor(top: inputsContainer.topAnchor, left: inputsContainer.leadingAnchor, bottom: inputsContainer.bottomAnchor, right: inputsContainer.trailingAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: -10, width: 0, height: 0)

        
        
        // MARK -- constraints for loginRegisterSegmentControl
        view.addSubview(loginRegisterSegmentedControl)
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainer.topAnchor , constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // MARK -- constraints for plus photo
        view.addSubview(plusPhotoButton)

        plusPhotoButton.anchor(top: nil, left: nil, bottom: loginRegisterSegmentedControl.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -80, paddingRight: 0, width: 140, height: 140)

        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
