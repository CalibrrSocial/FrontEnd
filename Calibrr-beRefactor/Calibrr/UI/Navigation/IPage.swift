//
//  IPage.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

public protocol IPage
{
    func getBackPage() -> IPage?
    func backAction(_ sender: UIButton?)
    func reloadData()
}
