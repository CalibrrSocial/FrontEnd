//
//  IPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

public protocol IPage
{
    func getBackPage() -> IPage?
    func backAction(_ sender: UIButton?)
    func reloadData()
}
