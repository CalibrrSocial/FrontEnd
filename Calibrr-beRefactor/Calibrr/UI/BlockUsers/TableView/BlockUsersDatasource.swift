//
//  BlockUsersDatasource.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation
import OpenAPIClient

class BlockUsersDatasource : AStandardItemsDatasource<SearchUserCell, User>
{
    override var noContentMessage: String { get { return "No Results" }
        set {
            self.noContentMessage = newValue
        }
    }
    
    override func reload()
    {
    }
}
