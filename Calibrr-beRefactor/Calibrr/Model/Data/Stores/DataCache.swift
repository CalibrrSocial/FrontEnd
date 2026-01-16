//
//  DataCache.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation

class DataCache<T> where T : Any
{
    private var objects = [String : T]()
    
    func get(id: String) -> T?
    {
        return objects[id]
    }
    
    func getAll() -> [T]
    {
        var out = [T]()
        for o in objects.values {
            out.append(o)
        }
        return out
    }
    
    func store(_ object: T, id: String)
    {
        objects[id] = object
    }
    
    func store(_ objects: [T], ids: [String])
    {
        for i in 0..<objects.count {
            store(objects[i], id: ids[i])
        }
    }
    
    func delete(_ ids: [String])
    {
        for id in ids{
            delete(id)
        }
    }
    
    func delete(_ id: String)
    {
        objects.removeValue(forKey: id)
    }
    
    func deleteAll()
    {
        objects.removeAll()
    }
}
