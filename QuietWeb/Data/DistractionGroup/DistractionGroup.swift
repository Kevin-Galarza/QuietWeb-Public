//
//  WebsiteGroup.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/5/24.
//

import RealmSwift

enum DistractionGroup: Int, CaseIterable, Codable, PersistableEnum {
    case adult        // 0
    case blogs        // 1
    case dating       // 2
    case foodDelivery // 3
    case forums       // 4
    case gambling     // 5
    case gaming       // 6
    case messaging    // 7
    case music        // 8
    case news         // 9
    case politics     // 10
    case search       // 11
    case shopping     // 12
    case socialMedia  // 13
    case sports       // 14
    case video        // 15
    
    var name: String {
        switch self {
        case .adult: "Adult"
        case .blogs: "Blogs"
        case .dating: "Dating"
        case .foodDelivery: "Food Delivery"
        case .forums: "Forums"
        case .gambling: "Gambling"
        case .gaming: "Gaming"
        case .messaging: "Messaging"
        case .music: "Music"
        case .news: "News"
        case .politics: "Politics"
        case .search: "Search"
        case .shopping: "Shopping"
        case .socialMedia: "Social Media"
        case .sports: "Sports"
        case .video: "Video"
        }
    }
    
    var fileName: String {
        switch self {
        case .adult: "adult"
        case .blogs: "blogs"
        case .dating: "dating"
        case .foodDelivery: "food-delivery"
        case .forums: "forums"
        case .gambling: "gambling"
        case .gaming: "gaming"
        case .messaging: "messaging"
        case .music: "music"
        case .news: "news"
        case .politics: "politics"
        case .search: "search"
        case .shopping: "shopping"
        case .socialMedia: "social-media"
        case .sports: "sports"
        case .video: "video"
        }
    }
}
