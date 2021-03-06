//
//  TableViewController.swift
//  On the Map
//
//  Created by Carmine Totera on 2021/8/11.
//  Copyright © 2021 Carmine Totera. All rights reserved.
//

import UIKit

// MARK: - TableViewController  : UIViewController

class StudentLocationTableViewController: UIViewController {

    // MARK: Properties
//    var students: [StudentInformation] = [StudentInformation]()
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var studentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(UdacityClient.sharedInstance.loadViews) {
            loadTableView()
            if(UdacityClient.sharedInstance.loadTableView && UdacityClient.sharedInstance.loadMapView) {
                UdacityClient.sharedInstance.loadViews = false
            }
        }
    }
    
    func loadTableView() {
        UdacityClient.sharedInstance.loadTableView = true
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        UdacityClient.sharedInstance.getStudentLocations() { (students, error) in
            if let students = students {
                Students.shared.students = students
                DispatchQueue.main.async {
                    self.studentsTableView.reloadData()

                    self.activityIndicator.stopAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if(error?.code == 1) {
                        UdacityClient.sharedInstance.displayAlert(self, title: "", message: error?.localizedDescription ?? "Unknown error")
                    } else {
                        UdacityClient.sharedInstance.displayAlert(self, title: "", message: "Error getting data!")
                    }
                
                }
            }
        }
    }
}

// MARK: - TableViewController: UITableViewDelegate, UITableViewDataSource

extension StudentLocationTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentLocationTableViewCell"
        let student = Students.shared.students[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! StudentLocationTableViewCell
        
        /* Set cell defaults */
        cell.studentName?.text = "\(student.firstName) \(student.lastName)"
        cell.studentMediaURL?.text = student.mediaURL
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Students.shared.students.count > 100 {
            return 100
        } else {
            return Students.shared.students.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = Students.shared.students[(indexPath as NSIndexPath).row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        let app = UIApplication.shared
        if UdacityClient.sharedInstance.checkURL(student.mediaURL){
            app.open(URL(string: student.mediaURL)!)
        } else {
            UdacityClient.sharedInstance.displayAlert(self, title: "", message: ErrorMessage.InvalidLinkTitle)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65.0
    }
}
