//
//  UrlInfoRealm.swift
//  fullScreen
//
//  Created by 박휘목 on 7/21/24.
//

import Foundation
import RealmSwift

class UrlInfoRealm: Object {
    @Persisted (primaryKey: true) var urlSrl: String?
    @Persisted var urlDomain: String?
    
    convenience init(urlSrl: String?) {
        self.init()
        self.urlSrl = urlSrl
    }
}
