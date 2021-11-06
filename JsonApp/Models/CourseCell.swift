//
//  CourseCell.swift
//  JsonApp
//
//  Created by  Pavel on 06.02.2021.
//

import UIKit

class CourseCell: UITableViewCell {
    
    @IBOutlet var courseImage: ImageView!
    @IBOutlet var courseNameLabel: UILabel!
    @IBOutlet var numberOfLessons: UILabel!
    @IBOutlet var numberOfTests: UILabel!
    
    func configure(with course: Course) {
        courseNameLabel.text = course.name
        numberOfLessons.text = "Number of lessons: \(course.numberOfLessons ?? 0)"
        numberOfTests.text = "Number of tests: \(course.numberOfTests ?? 0)"
        courseImage.fetchImage(with: course.imageUrl)
    }
}
