//
//  CoursesViewController.swift
//  JsonApp
//
//  Created by  Pavel on 06.02.2021.
//

import UIKit
import Alamofire

class CoursesViewController: UITableViewController {
    
    private let jsonUrlOne = "https://swiftbook.ru//wp-content/uploads/api/api_course"
    private let jsonUrlTwo = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
    private let jsonUrlThree = "https://swiftbook.ru//wp-content/uploads/api/api_website_description"
    private let jsonUrlFour = "https://swiftbook.ru//wp-content/uploads/api/api_missing_or_wrong_fields"
    
    private var courses: [Course] = []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CourseCell
        
        let course = courses[indexPath.row]
        cell.configure(with: course)
        
        return cell
    }
    
    // MARK: - TableViewDeligate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func fetchDataV1() {
        guard let url = URL(string: jsonUrlOne) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let course = try JSONDecoder().decode(Course.self, from: data)
                print(course.name ?? "nil")
                print(course.imageUrl ?? "nil")
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    func fetchDataV2() {
        guard let url = URL(string: jsonUrlTwo) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let courses = try JSONDecoder().decode([Course].self, from: data)
                print(courses)
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    func fetchDataV3() {
        guard let url = URL(string: jsonUrlThree) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let websiteDescription = try JSONDecoder().decode(WebsiteDescription.self, from: data)
                print(websiteDescription.courses ?? [])
                print(websiteDescription.websiteDescription ?? "nil")
                print(websiteDescription.websiteName ?? "nil")
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    func fetchDataV4() {
        guard let url = URL(string: jsonUrlFour) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let websiteDescription = try JSONDecoder().decode(WebsiteDescription.self, from: data)
                print(websiteDescription.courses ?? [])
                print(websiteDescription.websiteDescription ?? "nil")
                print(websiteDescription.websiteName ?? "nil")
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    func fetchData() {
        guard let url = URL(string: jsonUrlTwo) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                self.courses = try decoder.decode([Course].self, from: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    func fetchDataWithAlamofire() {
        guard let url = URL(string: jsonUrlTwo) else { return }
        AF.request(url).validate().responseJSON { dataResponse in
            switch dataResponse.result {
            case .success(let value):
                print("value: ", value)
                self.courses = Course.getCourses(from: value)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func  postWithAlamofire() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        let userData: [String: Any] = [
            "name": "Network Requests!",
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/2018/03/2-courselogo.jpg",
            "number_of_lessons": "18",
            "number_of_tests": "10"
        ]
        
        AF.request(url, method: .post, parameters: userData).validate().responseJSON { responseData in
            
            guard let statusCode = responseData.response?.statusCode else { return }
            print("Status Code: ", statusCode)
            
            switch responseData.result {
            case .success(let value):
                print(value)
                guard let jsonData = value as? [String: Any] else { return }
                print("jsonData: ", jsonData)
                let course = Course(dictCourse: jsonData)
                print("course: ", course)
                self.courses.append(course)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
