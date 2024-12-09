//
//  Profile.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/9/24.
//

import Foundation
import RealmSwift

enum WebShieldGroup: Int, PersistableEnum {
    
    case ads = 0
    case privacy = 1
    case security = 2
    
    var associatedBlocklists: [WebShieldBlocklist] {
        switch self {
        case .ads: return [.adsBase, .adsMobile]
        case .privacy: return [.privacyBase, .easyPrivacy, .peterLowe]
        case .security: return [.securityPhishing, .securityScams, .securityMalware]
        }
    }
    
    var contentBlockerIdentifier: ContentBlockerIdentifier {
        switch self {
        case .ads: return .adsBlockerIdentifier
        case .privacy: return .privacyBlockerIdentifier
        case .security: return .securityBlockerIdentifier
        }
    }
    
    var contentBlockerMasterFileName: ContentBlockerMasterFileName {
        switch self {
        case .ads: return .adsBlockerFileName
        case .privacy: return .privacyBlockerFileName
        case .security: return .securityBlockerFileName
        }
    }
    
    var name: String {
        switch self {
        case .ads: return "Ad Blocking"
        case .privacy: return "Privacy"
        case .security: return "Security"
        }
    }
    
    var description: String {
        switch self {
        case .ads: return "Filters that remove ads"
        case .privacy: return "Filters that prevent tracking"
        case .security: return "Filters that block known online threats and malware"
        }
    }
}

enum WebShieldBlocklist: Int, PersistableEnum {
    case adsBase = 0
    case adsMobile = 1
    case privacyBase = 2
    case easyPrivacy = 3
    case peterLowe = 4
    case securityPhishing = 5
    case securityScams = 6
    case securityMalware = 7
    
    var fileNames: [String] {
        switch self {
        case .adsBase: return ["AdsBase"]
        case .adsMobile: return ["AdsMobile"]
        case .privacyBase: return ["PrivacyBase"]
        case .easyPrivacy: return ["EasyPrivacy"]
        case .peterLowe: return ["PeterLowe"]
        case .securityPhishing: return ["Phishing"]
        case .securityScams: return ["Scams"]
        case .securityMalware: return ["Malware"]
        }
    }
}

class WebShield: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var enabledWebShieldGroups: List<WebShieldGroup> = List<WebShieldGroup>()
    @Persisted var enabledWebShieldBlocklists: List<WebShieldBlocklist> = List<WebShieldBlocklist>()
    @Persisted var dateCreated: Date = Date()
    @Persisted var dateModified: Date = Date()
    
    override class func primaryKey() -> String? {
        return "_id"
    }
}
