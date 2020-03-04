//
//  ChatMessagesCell.swift
//  Chat App
//
//  Created by Apple on 2/24/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
        
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    var chatLogController: ChatMessagesController?
    
    static let blueColor = UIColor.rgb(red: 0, green: 137, blue: 249)
    let whiteColor = UIColor(white: 0.95, alpha: 1)
    var chatMessage: ChatMessage! {
        didSet {
            if chatMessage.imageUrl != "" {
                messageImageView.loadImageUsingCacheWithUrlString(chatMessage.imageUrl ?? "")
                messageImageView.isHidden = false
                bubbleBackgroundView.backgroundColor = .clear
                messageLabel.isHidden = true
                bubbleBackgroundView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            }else {
                bubbleBackgroundView.backgroundColor = chatMessage.isIncoming ? whiteColor : #colorLiteral(red: 0, green: 0.537254902, blue: 0.9764705882, alpha: 1)
                messageLabel.textColor = chatMessage.isIncoming ? .black : .white
                    
                messageLabel.text = chatMessage.text
                messageImageView.isHidden = true
                messageLabel.isHidden = false
            }
            
            if chatMessage.isIncoming {
                leadingConstraint.isActive = true
                trailingConstraint.isActive = false
            }else {
                leadingConstraint.isActive = false
                trailingConstraint.isActive = true
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var  messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap(_ :))))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
           if let imageView = tapGesture.view as? UIImageView {
               //PRO Tip: don't perform a lot of custom logic inside of a view class
               self.chatLogController?.performZoomInForStartingImageView(imageView)
        }
    }
    
    
    @objc func showImojis(){
        self.chatLogController?.setupLongPressGesture()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            backgroundColor = .clear
            
        bubbleBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showImojis)))
            bubbleBackgroundView.layer.cornerRadius = 12
            bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bubbleBackgroundView)
            
        
            addSubview(messageLabel)
            messageLabel.numberOfLines = 0
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
            addSubview(profileImageView)
        
            bubbleBackgroundView.addSubview(messageImageView)
        var constraints = [NSLayoutConstraint]()
            
            // lets set up some constraints for our label
             constraints = [
                messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
                messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
                messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                
                bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
                bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
                bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
                bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
                
                //x,y,w,h
                profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -16),
                profileImageView.widthAnchor.constraint(equalToConstant: 32),
                profileImageView.heightAnchor.constraint(equalToConstant: 32),
                
                messageImageView.leftAnchor.constraint(equalTo: bubbleBackgroundView.leftAnchor),
                messageImageView.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor),
                messageImageView.widthAnchor.constraint(equalTo: bubbleBackgroundView.widthAnchor),
                messageImageView.heightAnchor.constraint(equalTo: bubbleBackgroundView.heightAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
            
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 32)
            leadingConstraint.isActive = false
            
            trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
            trailingConstraint.isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}


