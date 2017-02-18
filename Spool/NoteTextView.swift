//
//  NoteTextView.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/25/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {
    
//    func updateNote(note: String, outerFrame: CGRect) {
//        self.text = note
//        frame.size.height = contentSize.height
//        layoutIfNeeded()
//    }
    
    func setup(note: String, outerFrame: CGRect) {
        text = note
        let height = contentSize.height
        self.frame = CGRect(x: 38.0, y: outerFrame.maxY - height - 100, width: outerFrame.maxX - 76.0, height: height)
        
        self.backgroundColor      =   UIColor(red:0.23, green:0.24, blue:0.29, alpha:0.9) // #3B3C4A
        self.layer.cornerRadius   =   CGFloat(18.0)
        self.clipsToBounds        =   true
        self.font                 =   UIFont(name: "Nunito-SemiBold", size: 16)!
        self.textAlignment        =   NSTextAlignment.center
        self.textColor            =   UIColor.white
    }

}
