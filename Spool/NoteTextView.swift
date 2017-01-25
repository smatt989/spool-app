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
        self.frame = CGRect(x: 0, y: outerFrame.maxY - height - 100, width: outerFrame.maxX, height: height)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.textColor = UIColor.white
    }

}
