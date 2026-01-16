//
//  DataStore.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

class DataStore<T> where T : Any
{
    private var objects = [String : T]()
    private let getId : ((T) -> String)
    
    init(_ getId: @escaping((T) -> String))
    {
        self.getId = getId
    }
    
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
    
    func store(_ object: T)
    {
        let id = getId(object)
        objects[id] = object
    }
    
    func store(_ objects: [T])
    {
        for o in objects{
            store(o)
        }
    }
    
    func delete(_ object: T)
    {
        let id = getId(object)
        delete(id: id)
    }
    
    func delete(_ objects: [T])
    {
        for o in objects{
            delete(o)
        }
    }
    
    func delete(id: String)
    {
        objects.removeValue(forKey: id)
    }
    
    func deleteAll()
    {
        objects.removeAll()
    }
}
