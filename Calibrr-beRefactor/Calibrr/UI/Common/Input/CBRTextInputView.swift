//
//  CBRTextInputView.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

protocol CBRTextInputViewDelegate {
    func textFieldDidChange(inputView: CBRTextInputView, text: String)
}

class CBRTextInputView : UIView, UITextFieldDelegate
{
    @IBOutlet var iconView : UIImageView?
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var titleLabelBotConstraint : NSLayoutConstraint?
    @IBOutlet var inputField : UITextField!
    @IBOutlet var divider : UIView!
    @IBOutlet var dividerHighlight : UIView!
    @IBOutlet var dividerHighlightWidthConstraint : NSLayoutConstraint!
    @IBOutlet var requiredLabel : UILabel?
    @IBOutlet var nextInput : CBRTextInputView?
    @IBOutlet var inputDelegate : UITextFieldDelegate?
    @IBOutlet weak var infoLabel: UILabel?
    
    @IBInspectable var isLight : Bool = false
    @IBInspectable var isRequired : Bool = false
    @IBInspectable var isNumeric : Bool = false
    @IBInspectable var regexValidation : String? = nil
    @IBInspectable var isEnableNextBar : Bool = true
    
    var requiredMessage : String? = nil
    
    private var titleLabelTransformBefore : CGAffineTransform? = nil
    private var titleLabelTransformAfter : CGAffineTransform? = nil
    private var titleLabelBotBefore : CGFloat = 0
    
    public var currentInputView: UIView?
    public var delegate: CBRTextInputViewDelegate?
    var autoValid: Bool = true
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        offSuggestion()
        
        if isLight {
            titleLabel.setupWhite(textSize: 17)
            inputField.setupWhite(textSize: 18)
            divider.backgroundColor = UIColor.white
            dividerHighlight.backgroundColor = UIColor.cbrGrayLight
            requiredLabel?.setupRed(textSize: 12, bold: true)
        }else{
            titleLabel.setupDark(textSize: 17)
            inputField.setupMainDark(textSize: 18)
            divider.backgroundColor = UIColor.cbrGrayLight
            dividerHighlight.backgroundColor = UIColor.cbrGray
            requiredLabel?.setupRed(textSize: 12, bold: true)
        }
        
//        self.inputField.attributedPlaceholder = NSAttributedString(string:self.inputField.placeholder != nil ? self.inputField.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        if isNumeric {
            inputField.keyboardType = .numberPad
        }
        inputField.delegate = self
        
        dividerHighlightWidthConstraint.constant = 0
        
        
        if self.isEnableNextBar {
            inputField.inputAccessoryView = UIView.CreateAccessoryView(target: self, action: #selector(inputFieldDone(_:)), next: nextInput != nil)
        } else {
            inputField.inputAccessoryView = UIView.CreateAccessoryView(target: self, action: #selector(inputFieldDone(_:)), next: false)
        }
        
        
        requiredMessage = requiredLabel?.text
        requiredLabel?.isHidden = true
        
        inputField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setup(_ title: String)
    {
        titleLabel.text = title
    }
    
    func setup(_ title: String, icon: UIImage)
    {
        iconView?.image = icon
        
        setup(title)
    }
    
    func getInput() -> String?
    {
        return inputField.text
    }
    
    func setupInput(_ input: String)
    {
        inputField.text = input
        
        if !input.isEmpty {
            showTextFieldEditing(instant: true)
            hideHighlight(instant: true)
        }
    }
    
    public func offSuggestion() {
        inputField.contentVerticalAlignment = .bottom
        
        inputField.spellCheckingType = .no
        inputField.autocorrectionType = .no
        inputField.smartInsertDeleteType = .no
        inputField.smartDashesType = .no
        inputField.smartQuotesType = .no
        let item = inputField.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        inputField.textContentType = .init(rawValue: "")
    }
    
    func getValidationError() -> String?
    {
        guard isRequired else { return nil }
        
        if let regex = regexValidation {
            if inputField.text?.range(of: regex, options: .regularExpression, range: nil, locale: nil) == nil
            {
                return requiredMessage
            }
        }
        return inputField.text != nil && !inputField.text!.isEmpty ? nil : requiredMessage
    }
    
    @discardableResult
    func validateAndShow() -> Bool
    {
        let validationError = getValidationError()
        let show = validationError != nil
        requiredLabel?.isHidden = !show
        requiredLabel?.text = validationError
        infoLabel?.isHidden = show
        return !show
    }
    
    @objc func inputFieldDone(_ sender: UIView)
    {
        inputField.resignFirstResponder()
        if isEnableNextBar {
            nextInput?.inputField.becomeFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        showTextFieldEditing()
        inputDelegate?.textFieldDidBeginEditing?(textField)
        
        if let picker = textField.inputView as? UIPickerView,
           let index = (picker.dataSource as? ChoicePickerDatasource)?.getIndex(textField.text) {
            picker.selectRow(index, inComponent: 0, animated: false)
            picker.delegate?.pickerView?(picker, didSelectRow: index, inComponent: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if autoValid {
            validateAndShow()
        }
        
        if textField.text == nil || textField.text?.isEmpty == true
        {
            hideTextFieldEditing()
        }
        hideHighlight()
        inputDelegate?.textFieldDidEndEditing?(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        inputField.resignFirstResponder()
        if self.isEnableNextBar {
            nextInput?.inputField.becomeFirstResponder()
        }
        return true
    }
    
    private func showTextFieldEditing(instant: Bool = false)
    {
        if let titleLabelBotConstraint = titleLabelBotConstraint {
            if titleLabelTransformBefore == nil {
                titleLabelTransformBefore = titleLabel.transform
                titleLabelBotBefore = titleLabelBotConstraint.constant
                let xOffset = titleLabel.frame.width * 0.5
                titleLabelTransformAfter = titleLabelTransformBefore!.translatedBy(x: -xOffset, y: 0).scaledBy(x: 0.8, y: 0.8).translatedBy(x: xOffset, y: 0)
            }
            
            titleLabelBotConstraint.constant = inputField.frame.height + 3
            
            if instant {
                titleLabel.transform = titleLabelTransformAfter!
            }else{
                UIView.animate(withDuration: 0.4, animations: {
                    self.titleLabel.transform = self.titleLabelTransformAfter!
                })
                
            }
        }
        
        requiredLabel?.isHidden = true
        infoLabel?.isHidden = false
        
        dividerHighlightWidthConstraint.constant = divider.frame.width
        
        if instant {
            layoutIfNeeded()
        }else{
            UIView.animate(withDuration: 0.4, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.delegate?.textFieldDidChange(inputView: self, text: textField.text ?? "")
    }
    
    private func hideHighlight(instant: Bool = false)
    {
        dividerHighlightWidthConstraint.constant = 0
        
        if instant {
            layoutIfNeeded()
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    private func hideTextFieldEditing(instant: Bool = false)
    {
        if titleLabelBotConstraint != nil {
            titleLabelBotConstraint!.constant = titleLabelBotBefore
            
            if instant {
                titleLabel.transform = titleLabelTransformBefore!
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.titleLabel.transform = self.titleLabelTransformBefore!
                })
            }
        }
        
        if instant {
            layoutIfNeeded()
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        }
    }
}
