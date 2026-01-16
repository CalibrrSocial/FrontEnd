//
//  CBRPasswordInputView.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation

class CBRPasswordInputView : CBRTextInputView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        inputField.isSecureTextEntry = true
    }
    
    override func getValidationError() -> String?
    {
        if let text = inputField.text {
            if text.count < 8 {
                return "Must have at least 8 characters!"
            }
            if text.count > 100 {
                return "Must have at most a 100 characters!"
            }
            if text.range(of: "[a-z]", options: .regularExpression, range: nil, locale: nil) == nil {
                return "Must have at least one lowercase letter!"
            }
            if text.range(of: "[A-Z]", options: .regularExpression, range: nil, locale: nil) == nil {
                return "Must have at least one uppercase letter!"
            }
            if text.range(of: "[0-9]", options: .regularExpression, range: nil, locale: nil) == nil {
                return "Must have at least one number!"
            }
        }
        return nil
    }
}
