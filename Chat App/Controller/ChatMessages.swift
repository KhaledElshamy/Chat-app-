//
//  ChatMessages.swift
//  Chat App
//
//  Created by Apple on 2/24/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit
import Firebase

class ChatMessagesController:UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    var containerViewBottomAnchor: NSLayoutConstraint?
        var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var userName = String()
    var sendToId = String()
    
    var messagesFromServer = [ChatMessage]()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let iconsContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white

        // configuration options
        let iconHeight: CGFloat = 38
        let padding: CGFloat = 6
        
        let images = [#imageLiteral(resourceName: "blue_like"), #imageLiteral(resourceName: "red_heart"), #imageLiteral(resourceName: "surprised"), #imageLiteral(resourceName: "cry_laugh"), #imageLiteral(resourceName: "cry"), #imageLiteral(resourceName: "angry")]
        
        let arrangedSubviews = images.map({ (image) -> UIView in
            let imageView = UIImageView(image: image)
            imageView.layer.cornerRadius = iconHeight / 2
            // required for hit testing
            imageView.isUserInteractionEnabled = true
            return imageView
        })
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fillEqually
        
        stackView.spacing = padding
        stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        containerView.addSubview(stackView)
        
        let numIcons = CGFloat(arrangedSubviews.count)
        let width =  numIcons * iconHeight + (numIcons + 1) * padding
        
        containerView.frame = CGRect(x: 0, y: 0, width: width, height: iconHeight + 2 * padding)
        containerView.layer.cornerRadius = containerView.frame.height / 2
        
        // shadow
        containerView.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        stackView.frame = containerView.frame
        
        return containerView
    }()
    
    fileprivate let cellId = "id123"
    
    var chatMessages = [[ChatMessage]]()
    
    var messages = [MyContactsMessages]()

    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user_messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = MyContactsMessages(dictionary: dictionary)
                    
                
                if message.toId == self.sendToId {
                    self.chatMessages.removeAll()
                    if let imageUrl = dictionary["imageUrl"] as? String {
                        print(imageUrl)
                        self.messagesFromServer.append(ChatMessage(text: "", isIncoming: false , date: Date.dateFromCustomString(customString: message.date ?? ""), imageUrl: imageUrl))
                    }
                    if let txt = dictionary["text"] as? String {
                        self.messagesFromServer.append(ChatMessage(text: txt, isIncoming: false , date: Date.dateFromCustomString(customString: message.date ?? ""), imageUrl: ""))
                    }
                    self.attemptToAssembleGroupedMessages()
                }else if message.toId == Auth.auth().currentUser?.uid && message.fromId == self.sendToId {
                    self.chatMessages.removeAll()
                   if let imageUrl = dictionary["imageUrl"] as? String {
                        self.messagesFromServer.append(ChatMessage(text: "", isIncoming: true , date: Date.dateFromCustomString(customString: message.date ?? ""), imageUrl: imageUrl))
                    }
                    if let txt = dictionary["text"] as? String {
                        self.messagesFromServer.append(ChatMessage(text: txt, isIncoming: true , date: Date.dateFromCustomString(customString: message.date ?? ""), imageUrl: ""))
                    }
                    self.attemptToAssembleGroupedMessages()
                }
                }, withCancel: nil)
            
            }, withCancel: nil)
    }

    
    fileprivate func attemptToAssembleGroupedMessages() {
           let groupedMessages = Dictionary(grouping: messagesFromServer) { (element) -> Date in
               return element.date.reduceToMonthDayYear()
        }
           // provide a sorting for your keys somehow
           let sortedKeys = groupedMessages.keys.sorted()
           sortedKeys.forEach { (key) in
               let values = groupedMessages[key]
               chatMessages.append(values ?? [])
        }
        self.tableView.reloadData()
//        print(chatMessages[1][0].text)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
     @objc func handleKeyboardWillShow(_ notification: Notification) {
           let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
           let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
           
           containerViewBottomAnchor?.constant = -keyboardFrame!.height
           UIView.animate(withDuration: keyboardDuration!, animations: {
               self.view.layoutIfNeeded()
           })
    }
       
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
           
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormatter.string(from: firstMessageInSection.date)
            let label = DateHeaderLabel()
            label.text = dateString
            
            let containerView = UIView()
            
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            
            return containerView
        }
        return nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return chatMessages[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        if let profileImageUrl = self.user?.profileImageUrl {
            if chatMessages[indexPath.section][indexPath.row].isIncoming == true  {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        }
        
        let chat = chatMessages[indexPath.section][indexPath.row]
                
        cell.chatMessage = chat
        cell.chatLogController = self 
        
        if chatMessages[indexPath.section][indexPath.row].imageUrl != "" {
            cell.messageImageView.loadImageUsingCacheWithUrlString(chatMessages[indexPath.section][indexPath.row].imageUrl ?? "")
            cell.messageImageView.isHidden = false
            cell.bubbleBackgroundView.backgroundColor = .clear
        }else {
            cell.messageImageView.isHidden = true
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if chatMessages[indexPath.section][indexPath.row].imageUrl != "" {
            
        }
    }
    
    
    @objc func handleSend() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let date = Date().DateString()
        let timestamp = Int(Date().timeIntervalSince1970)
        let fromId = uid
        
        //is it there best thing to include the name inside of the message node
        let values = ["text": inputTextField.text!, "name": user?.name ?? "","sendToId":sendToId,"fromId":fromId,"date":date,"timestamp":timestamp] as [String : Any]
        //childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            guard let messageId = childRef.key else {
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user_messages").child(fromId).child(messageId)
            userMessagesRef.setValue(1)
            
            let recipientUserMessagesRef = Database.database().reference().child("user_messages").child(self.sendToId).child(messageId)
            recipientUserMessagesRef.setValue(1)
            self.inputTextField.text = ""
        }
    }
       
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
        //my custom zooming logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
            
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
            
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
            
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
                
            keyWindow.addSubview(zoomingImageView)
                
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.blackBackgroundView?.alpha = 1
                    self.view.alpha = 0
                    
                    // math?
                    // h2 / w1 = h1 / w1
                    // h2 = h1 / w1 * w1
                    let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                    
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    
                    zoomingImageView.center = keyWindow.center
                    
                    }, completion: { (completed) in
    //                    do nothing
                })
                
            }
    }
        
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
                //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
                
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    zoomOutImageView.frame = self.startingFrame!
                    self.blackBackgroundView?.alpha = 0
                    self.view.alpha = 1
                    
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
                })
            }
        }
    
    func setupConstraints(){
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        
        //ios9 constraint anchors
        //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
               
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
               
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // constraints for table view
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leadingAnchor, bottom: separatorLineView.topAnchor, right: view.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = "Messages"
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        setupConstraints()
        setupKeyboardObservers()
        tableView.keyboardDismissMode = .interactive
        tableView.backgroundColor = .white
       // observeMessages()
    }
}
