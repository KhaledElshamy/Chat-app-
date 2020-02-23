//
//  Extensions.swift
//  Chat App
//
//  Created by Khaled Elshamy on 11/4/19.
//  Copyright © 2019 Khaled Elshamy. All rights reserved.
//


import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        let color = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
        return color
    }
}

extension UIImageView {
    func downloadImage(imageURL : String){
        
        let http = imageURL
        
        let request = NSMutableURLRequest(url: NSURL(string: http)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        _ = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            else{
                let data = NSData(data: data!)
                DispatchQueue.main.sync {
                    let image = UIImage(data: data as Data)
                    self.image = image
                }
            }
            }.resume()
    }
}


extension UIView {
    
    func applyGradient(colors:[UIColor])->Void {
        self.applyGradient(colors: colors, locations: nil)
    }
    
    func applyGradient(colors:[UIColor],locations:[NSNumber]?)->Void{
        let gradients : CAGradientLayer = CAGradientLayer()
        gradients.frame = self.bounds
        gradients.colors = colors.map{$0.cgColor}
        gradients.locations = locations
        self.layer.insertSublayer(gradients, at: 0)
    }
}


extension UIFont {
    static func popinsMedium(size:CGFloat) -> UIFont{
        return UIFont(name: "Poppins-Medium", size: size)!
    }
    
    static func popinsRegular(size:CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Regular", size: size)!
    }
    
    static func poppinsSemiBold(size:CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size)!
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat ,paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leadingAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            self.trailingAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}


