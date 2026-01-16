//
//  SearchUsersDatasource.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation
import OpenAPIClient

class SearchUsersDatasource : AStandardItemsDatasource<SearchUserCell, User>
{
    public var _noContentMessage: String = ""
    override var noContentMessage: String {
        get { return _noContentMessage }
    }
    
    override func reload()
    {
    }
}

class SearchUsersDistanceDatasource : AStandardItemsDatasource<SearchUserCell, User>
{
    override var noContentMessage: String {
        get { return "Not seeing anyone nearby?\n\nTry increasing your distance setting\nand inviting your friends to join Calibrr Social" }
        set {
            self.noContentMessage = newValue
        }
    }
}
