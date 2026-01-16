//
//  CBRDateInputView.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class CBRDateInputView : CBRTextInputView
{
    private var datePicker: UIDatePicker? = nil
    private var dateSelected: Date?
    var isLimitAge: Bool = false
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        let formatter = DateFormatter()
        
        datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker!.timeZone = formatter.timeZone
        datePicker!.locale = formatter.locale
        datePicker!.calendar = formatter.calendar
        datePicker!.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        inputField.inputView = datePicker
        inputField.tintColor = UIColor.clear
    }
    
    func setupDate(startDate: Date, datePickerMode: UIDatePicker.Mode, minDate: Date? = nil, maxDate: Date? = nil, minuteInterval: Int = 1, show: Bool = false)
    {
        dateSelected = startDate
        datePicker!.setDate(startDate, animated: false)
        datePicker!.datePickerMode = datePickerMode
        datePicker!.minimumDate = minDate
        datePicker!.maximumDate = maxDate
        datePicker!.minuteInterval = minuteInterval
        
        if show {
            textFieldDidBeginEditing(inputField)
        }
    }
    
    func setDate(_ date: Date) {
        datePicker?.date = date
    }
    
    func getDate() -> Date?
    {
        return dateSelected
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if inputField.text?.isEmpty == true {
            datePickerValueChanged(datePicker!)
            setupInput(inputField.text!)
        }else{
            super.textFieldDidBeginEditing(textField)
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker)
    {
        dateSelected = sender.date
        inputField.text = sender.datePickerMode == .time ? dateSelected!.getTimeString() : dateSelected!.getDateString(false)
    }
    
    override func getValidationError() -> String? {
        if isLimitAge {
            if self.dateSelected?.age() ?? 0 < 13 {
                return self.requiredMessage
            }
            return nil
        }
        return super.getValidationError()
    }
}
