//
//  CBRRepeatInputView.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
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
