//
//  ConnectBusiness.swift
//  FileView
//
//  Created by Kevin Scardina on 3/22/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

enum ErrorConnectLogic: Error {
    case emptyIP
}

class ConnectLogicFactory {
    static private var instance:ConnectLogic?
    static var connectLogic:ConnectLogic {
        get {
            if let i = ConnectLogicFactory.instance {
                return i
            } else {
                instance = ConnectLogic()
                return ConnectLogicFactory.instance!
            }
        }
        set(value){
            instance = value
        }
    }
}

class ConnectLogic: Logic {
    static let HOST_HISTORY_KEY = "com.popmedic.hosthistory"
    static let HOST_KEY = "com.popmedic.host"
    
    private lazy var model = DefaultModel()
    private var _host:String? = nil
    
    var host:String {
        get {
            if let h = self._host {
                return h
            }
            self._host = model.get(ConnectLogic.HOST_KEY) as? String ?? ""
            return self._host!
        }
        set(value) {
            self._host = value
            model.set(ConnectLogic.HOST_KEY, value: value)
        }
    }
    
    var key:String {
        get {
            if let key = getKeyFromHistory(self.host) {
                if key.count > 0 {
                    return key
                }
            }
            self.setKeyInHistory(self.host, key: String.random())
            return self.getKeyFromHistory(self.host) ?? ""
        }
        set(value) {
            self.setKeyInHistory(self.host, key: value)
        }
    }
    
    private var _hostHistory: NSDictionary? = nil
    var hostHistory:NSDictionary {
        get {
            if let hh = self._hostHistory {
                return hh
            }
            if let hh = model.get(ConnectLogic.HOST_HISTORY_KEY) as? NSDictionary {
                self._hostHistory = hh
                return hh
            }
            let hh = NSDictionary()
            model.set(ConnectLogic.HOST_HISTORY_KEY, value:hh)
            return hh
        }
        set(value) {
            self._hostHistory = value
            model.set(ConnectLogic.HOST_HISTORY_KEY, value: value)
        }
    }
    
    func getHostFromHistory(_ idx:Int) -> String? {
        if idx < hostHistory.allKeys.count {
            return hostHistory.allKeys[idx] as? String
        }
        return nil
    }
    
    func addHostToHistory(_ host:String?) -> Int {
        if let h = host {
            if let hh = model.get(ConnectLogic.HOST_HISTORY_KEY) as? NSDictionary {
                let n = NSMutableDictionary(dictionary: hh)
                if n[h] == nil {
                    n[h] = ""
                }
                hostHistory = n
            }
        }
        return hostHistory.count
    }
    
    func setKeyInHistory(_ host:String?, key:String) {
        if let h = host {
            if let hh = model.get(ConnectLogic.HOST_HISTORY_KEY) as? NSDictionary {
                let n = NSMutableDictionary(dictionary: hh)
                n[h] = key
                hostHistory = n
            }
        }
    }
    
    func getKeyFromHistory(_ host:String?) -> String? {
        if let h = host {
            return hostHistory[h] as? String
        }
        return nil
    }
    
    func removeFromHistory(_ idx:Int) -> Bool {
        if let h = getHostFromHistory(idx) {
            if let hh = model.get(ConnectLogic.HOST_HISTORY_KEY) as? NSDictionary {
                let n = NSMutableDictionary(dictionary: hh)
                n.removeObject(forKey: h)
                hostHistory = n
                return true
            }
        }
        return false
    }
    
    func connect(_ host:String?, completion: @escaping ((_ data:Response<Data>?, _ error: Error?) -> Void)) {
        self.host = host ?? ""
        if self.host.count > 0 {
            CustomRequestBuilderTrustedHost.setTrustedHost(self.host)
            SwaggerClientAPI.basePath = "https://\(self.host):8443"
            PathAPI.pthGet(pth: "", completion: completion)
            return
        }
        completion(nil, ErrorConnectLogic.emptyIP)
    }
    
    func isAdmin(completion: @escaping (_ yes:Bool) -> Void) {
        AuthAPI.authGet() { (data, error) in
            if error == nil {
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func isConnectError(_ err: Error?) -> (code:Int, title: String, msg: String, yes: Bool) {
        if let err = err {
            switch(err) {
            case let err as ErrorConnectLogic:
                switch(err){
                case .emptyIP:
                    return (code: 0, title: "ERROR", msg: "Must set ip address", yes: true)
                }
            case let err as ErrorResponse:
                switch(err) {
                case .error(let c, let d, let e):
                    switch(c) {
                    case 401, 403:
                        return (code: c, title: "ERROR: Auth", msg: "unauthorized/unauthenticated", yes: true)
                    default:
                        return (code: c, title:"Error \(c)", msg:self.getErrorResponseMessage(e, data: d), yes: true)
                    }
                }
            default:
                return (code: 0, title: "ERROR", msg: err.localizedDescription, yes: true)
            }
        }
        return (code: 200, title: "", msg: "", yes: false)
    }
    
    func getErrorResponseMessage(_ err:Error, data:Data?) -> String {
        var msg:String
        do {
            let msgObj = try JSONDecoder().decode(Error500.self, from: data ?? Data())
            msg = msgObj.error ?? err.localizedDescription
        } catch {
            msg = err.localizedDescription
        }
        return msg
    }
}
