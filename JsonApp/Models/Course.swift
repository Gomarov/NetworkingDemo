//
//  Course.swift
//  JsonApp
//
//  Created by  Pavel on 06.02.2021.
//

struct Course: Decodable {
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: Int?
    let numberOfTests: Int?
    
    init(dictCourse: [String: Any]) {
        name = dictCourse["name"] as? String
        link = dictCourse["link"] as? String
        imageUrl = dictCourse["imageUrl"] as? String
        numberOfLessons = dictCourse["number_of_lessons"] as? Int
        numberOfTests = dictCourse["number_of_tests"] as? Int
    }
    
    static func getCourses(from jsonData: Any) -> [Course] {
        guard let jsonData = jsonData as? [[String: Any]] else { return [] }
        return jsonData.compactMap { Course(dictCourse: $0) }
    }
}

struct WebsiteDescription: Decodable {
    let courses: [Course]?
    let websiteDescription: String?
    let websiteName: String?
}
