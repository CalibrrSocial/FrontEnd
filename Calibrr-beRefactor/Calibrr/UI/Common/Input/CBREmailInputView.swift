//
//  CBREmailInputView.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation

class CBREmailInputView : CBRTextInputView
{
    
    override func getValidationError() -> String?
    {
        if let text = inputField.text {
            if text.range(of: "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$", options: .regularExpression, range: nil, locale: nil) == nil {
                return "Enter a valid e-mail address!"
            }
        }
        return nil
    }
}
