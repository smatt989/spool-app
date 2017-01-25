//
//  MaxLengthUITextField.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/24/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class MaxLengthUITextField: UITextField, UITextFieldDelegate {
    private var characterLimit: Int?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    @IBInspectable var maxLength: Int {
        get {
            guard let length = characterLimit else {
                return Int.max
            }
            return length
        }
        set {
            characterLimit = newValue
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard string.characters.count > 0 else {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return allowedIntoTextField(text: prospectiveText)
    }
    
    func allowedIntoTextField(text: String) -> Bool {
        return text.characters.count <= maxLength
    }
}
