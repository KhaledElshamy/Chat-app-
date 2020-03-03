//
//  IconImoji.swift
//  Chat App
//
//  Created by Apple on 3/3/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit


extension ChatMessagesController {
     func setupLongPressGesture() {
          view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
      }
      
      @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
          if gesture.state == .began {
              handleGestureBegan(gesture: gesture)
          } else if gesture.state == .ended {
              
              // clean up the animation
              UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                  let stackView = self.iconsContainerView.subviews.first
                  stackView?.subviews.forEach({ (imageView) in
                      imageView.transform = .identity
                  })
                  
                  self.iconsContainerView.transform = self.iconsContainerView.transform.translatedBy(x: 0, y: 50)
                  self.iconsContainerView.alpha = 0
                  
              }, completion: { (_) in
                  self.iconsContainerView.removeFromSuperview()
              })
              
              
          } else if gesture.state == .changed {
              handleGestureChanged(gesture: gesture)
          }
      }
      
      fileprivate func handleGestureChanged(gesture: UILongPressGestureRecognizer) {
          let pressedLocation = gesture.location(in: self.iconsContainerView)
          print(pressedLocation)
          
          let fixedYLocation = CGPoint(x: pressedLocation.x, y: self.iconsContainerView.frame.height / 2)
          
          let hitTestView = iconsContainerView.hitTest(fixedYLocation, with: nil)
          
          if hitTestView is UIImageView {
              
              UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                  
                  let stackView = self.iconsContainerView.subviews.first
                  stackView?.subviews.forEach({ (imageView) in
                      imageView.transform = .identity
                  })
                  
                  hitTestView?.transform = CGAffineTransform(translationX: 0, y: -50)
                  
              })
          }
      }
      
      fileprivate func handleGestureBegan(gesture: UILongPressGestureRecognizer) {
          view.addSubview(iconsContainerView)
          
          let pressedLocation = gesture.location(in: self.view)
          print(pressedLocation)
          
          // transformation of the red box
          let centeredX = (view.frame.width - iconsContainerView.frame.width) / 2
          
          iconsContainerView.alpha = 0
          self.iconsContainerView.transform = CGAffineTransform(translationX: centeredX, y: pressedLocation.y)
          
          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
              
              self.iconsContainerView.alpha = 1
              self.iconsContainerView.transform = CGAffineTransform(translationX: centeredX, y: pressedLocation.y - self.iconsContainerView.frame.height)
          })
      }
      
      override var prefersStatusBarHidden: Bool { return true }
}
