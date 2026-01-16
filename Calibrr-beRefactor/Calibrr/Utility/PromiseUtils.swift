//
//  PromiseUtils.swift
//  Calibrr
//
//

import PromiseKit

class PromiseUtils
{
    static let DEFAULT_TIMEOUT : Double = 10
    
    static let TRUE_PROMISE = Promise<Bool>{ data in
        data.fulfill(true)
    }
    static let VOID_PROMISE = Promise<Void>{ data in
        data.fulfill(())
    }
    
    static func CreateFail<T>(_ message: String) -> Promise<T>
    {
        return Promise<T>{ data in
            data.reject(CBRError.GeneralError(message: message))
        }
    }
    
    static func CreateFailResults(_ message: String) -> Promise<[Result<Bool>]>
    {
        return Promise<[Result<Bool>]>{ data in
            data.reject(CBRError.GeneralError(message: message))
        }
    }
    
//    static func CreateSuccess<T>(_ result: T) -> Promise<T>
//    {
//        return Promise<T>(result)
//    }
    
    static func CreateTimeout<T>(_ seconds: Double) -> Promise<T>
    {
        return Promise<T> { data in
            let timeoutTime = DispatchTime.now() + seconds
            DispatchQueue.global().asyncAfter(deadline: timeoutTime) { data.reject(CBRError.NetworkError(code: 500, json: [:], error: NSError(domain: URLError.errorDomain, code: URLError.timedOut.rawValue, userInfo: nil), request: "local", parameters: nil))}
        }
    }
    
    static func CreateInActionPromise<T,U>(input: T, _ body: @escaping(T) throws -> U) -> Promise<U>
    {
        return Promise<U>{ data in
            do{
                let returnValue = try body(input)
                data.fulfill(returnValue)
            } catch {
                data.reject(error)
            }
        }
    }
    
    static func CreateInActionVoidPromise<T>(input: T, _ body: @escaping(T) throws -> Void) -> Promise<Void>
    {
        return Promise<Void>{ data in
            do{
                try body(input)
                data.fulfill(())
            } catch {
                data.reject(error)
            }
        }
    }
    
    static func CreateActionPromise<T>(_ body: @escaping() throws -> T) -> Promise<T>
    {
        return Promise<T>{ data in
            do{
                let returnValue = try body()
                data.fulfill(returnValue)
            } catch {
                data.reject(error)
            }
        }
    }
    
    static func CreateActionVoidPromise(_ body: @escaping() throws -> Void) -> Promise<Void>
    {
        return Promise<Void>{ data in
            do{
                try body()
                data.fulfill(())
            } catch {
                data.reject(error)
            }
        }
    }
}

extension Promise where T : Any
{
    func catchCBRError(show: Bool = false, from: UIViewController? = nil)
    {
        self.catch{ e in
            let error = e.createCBR()
            
            if show {
                error.logAndPresent(from)
            }else{
                error.log()
            }
        }
    }
    
    @discardableResult
    func thenInAction<U>(_ body: @escaping(T) throws -> U) -> Promise<U>
    {
        return self.then{ out in
            return PromiseUtils.CreateInActionPromise(input: out, body)
        }
    }
    
    @discardableResult
    func thenInActionVoid(_ body: @escaping(T) throws -> Void) -> Promise<Void>
    {
        return self.then{ out in
            return PromiseUtils.CreateInActionVoidPromise(input: out, body)
        }
    }
    
    @discardableResult
    func thenAction<U>(_ body: @escaping() throws -> U) -> Promise<U>
    {
        return self.then{ _ in
            return PromiseUtils.CreateActionPromise(body)
        }
    }
    
    @discardableResult
    func thenActionVoid(_ body: @escaping() throws -> Void) -> Promise<Void>
    {
        return self.then{ _ in
            return PromiseUtils.CreateActionVoidPromise(body)
        }
    }
    
    func thenTrue() -> Promise<Bool>
    {
        return self.map{ _ in
            return PromiseUtils.TRUE_PROMISE.value ?? false
        }
    }
    
    func thenVoid() -> Promise<Void>
    {
        return self.map{ _ in
            return PromiseUtils.VOID_PROMISE.value ?? ()
        }
    }
    
    @discardableResult
    func withTimeout(_ timeoutSeconds: Double = PromiseUtils.DEFAULT_TIMEOUT) -> Promise<T>
    {
        return race(self, PromiseUtils.CreateTimeout(timeoutSeconds))
    }
}
