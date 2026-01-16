//
//  UIViewExtensions.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

extension UIView
{
    @discardableResult
    func roundCorners(_ radius: CGFloat = 5, top: Bool = false) -> UIView
    {
        if top {
            layer.cornerRadius = radius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }else{
            layer.cornerRadius = radius
        }
        
        return self
    }
    
    @discardableResult
    @objc func roundFull() -> UIView
    {
        clipsToBounds = true
        roundCorners(min(bounds.width, bounds.height) / 2.0)
        layer.masksToBounds = true
        layer.borderWidth = 0
        
        return self
    }
    
    @discardableResult
    func shadow(_ radius: CGFloat = 5, opacity: Float = 0.1, offset: CGFloat = 5, colour: UIColor = UIColor.black) -> UIView
    {
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: offset)
        layer.shadowColor = colour.cgColor
        layer.shadowOpacity = opacity
        
        return self
    }
    
    func findFirstResponder() -> UIView?
    {
        if isFirstResponder {
            return self
        }
        for subView in self.subviews {
            if let responder = subView.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
    
    @discardableResult
    func makeAccessible(_ id: String) -> Self
    {
        accessibilityActivate()
        accessibilityIdentifier = id
        return self
    }
    
    static func CreateAccessoryView(target: Any, action: Selector, next: Bool = false) -> UIView
    {
        let accessory = UIView(frame: CGRect(x: 0, y: 0, width: UIApplication.shared.keyWindow!.frame.width, height: 45))
        
        accessory.backgroundColor = UIColor.white
        accessory.alpha = 0.8
        accessory.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle(next ? "Next" : "Done", for: .normal)
        doneButton.titleLabel?.font = doneButton.titleLabel?.font.withSize(18)
        doneButton.addTarget(target, action: action, for: .touchUpInside)
        doneButton.showsTouchWhenHighlighted = true
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        accessory.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.bottom.top.right.equalTo(0)
        }
        doneButton.makeAccessible("DoneButton")
        
        return accessory
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}


#if canImport(UIKit)
import UIKit

// MARK: Protocol Definition
/// Make your UIView subclasses conform to this protocol when:
///  * they *are* NIB-based, and
///  * this class is used as the XIB's File's Owner
///
/// to be able to instantiate them from the NIB in a type-safe manner
public protocol NibOwnerLoadable: AnyObject {
  /// The nib file to use to load a new instance of the View designed in a XIB
  static var nib: UINib { get }
}

// MARK: Default implementation
public extension NibOwnerLoadable {
  /// By default, use the nib which have the same name as the name of the class,
  /// and located in the bundle of that class
  static var nib: UINib {
    return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
  }
}

// MARK: Support for instantiation from NIB
public extension NibOwnerLoadable where Self: UIView {
  /**
   Adds content loaded from the nib to the end of the receiver's list of subviews and adds constraints automatically.
   */
  func loadNibContent() {
    let layoutAttributes: [NSLayoutConstraint.Attribute] = [.top, .leading, .bottom, .trailing]
    for case let view as UIView in type(of: self).nib.instantiate(withOwner: self, options: nil) {
      view.translatesAutoresizingMaskIntoConstraints = false
      self.addSubview(view)
      NSLayoutConstraint.activate(layoutAttributes.map { attribute in
        NSLayoutConstraint(
          item: view, attribute: attribute,
          relatedBy: .equal,
          toItem: self, attribute: attribute,
          multiplier: 1, constant: 0.0
        )
      })
    }
  }
}
#endif
