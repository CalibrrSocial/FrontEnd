//
//  CBRRepeatInputView.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

class CBRRepeatInputView : CBRTextInputView
{
    @IBOutlet var baseInput : CBRTextInputView? = nil
    
    override func getValidationError() -> String?
    {
        if inputField.text != baseInput?.inputField.text {
            return requiredMessage
        }
        return nil
    }
}
