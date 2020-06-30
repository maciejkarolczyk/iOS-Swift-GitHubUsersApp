import Foundation
import UIKit
import Alamofire

protocol UserListControllerDelegate: class {
  func userSelected(_ userSelected: UserDetails?)
}

class UsersListController:UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableMaskView: UIView!
    @IBOutlet weak var tableMaskViewLabel: UILabel!
    
    weak var delegate: UserListControllerDelegate?
    var currentPage: Int = 1
    var currentQuery: String?
    
    
    var dataSource: UsersModel? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.dataSource?.count() ?? 0 > 0 {
                    self.tableMaskView.isHidden = true
                } else {
                    self.tableMaskView.isHidden = false
                    self.tableMaskViewLabel.text = "No users found for criteria"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        activityIndicator.hidesWhenStopped = true
        configureSplitView()
    }
    
    func configureSplitView() {
        splitViewController?.preferredPrimaryColumnWidthFraction = 0.5;
        let maxSize = splitViewController?.view.bounds.size.width
        if let maxSize = maxSize {
            splitViewController?.maximumPrimaryColumnWidth = maxSize;
        }
    }
    
    @IBAction func onSearchButtonPressed(_ sender: Any) {
        if let query = searchTextField.text {
            if query.isAlphanumeric() {
                currentQuery = query
                currentPage = 1
                activityIndicator.startAnimating()
                ServiceManager.requestUsers(query: query, { response in
                    self.dataSource = response
                    if let firstUser = self.dataSource?.users.first {
                        //download details for first user
                        ServiceManager.requestUserDetails(userName: firstUser.name, { response in
                            self.delegate?.userSelected(response)
                            self.stopActivityIndicator()
                        }, failure: { errorResponse in
                            Utils.displayAlert(errorResponse, vc: self)
                        })
                    } else {
                        self.delegate?.userSelected(nil)
                        self.stopActivityIndicator()
                    }
                }, failure: { errorResponse in
                    self.stopActivityIndicator()
                    Utils.displayAlert(errorResponse.description, vc:self)
                })
            } else {
                Utils.displayAlert("please insert valid userName or part of it", vc:self)
            }
        }
    }
    
    func loadMore() {
        ServiceManager.requestUsers(query: currentQuery, page:currentPage + 1, { response in
            self.dataSource?.users.append(contentsOf: response.users)
        }, failure: { errorResponse in
            Utils.displayAlert(errorResponse.description, vc:self)
        })
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }

}

extension UsersListController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GitHubUserCell") as! GitHubUserCell
        if let dataSourceForCell = dataSource?.users[indexPath.row] {
            cell.setupCell(dataModel:dataSourceForCell)
        }
        if let usersCount = self.dataSource?.users.count {
            if indexPath.row == usersCount - 1 {
                self.loadMore()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        return dataSource.count();
    }
}

extension UsersListController:UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = dataSource?.users[indexPath.row]
        if let detailsViewController = delegate as? DetailsViewController, let detailNavigationController = detailsViewController.navigationController {
            ServiceManager.requestUserDetails(userName: selectedUser?.name, { response in
                self.delegate?.userSelected(response)
                DispatchQueue.main.async {
                    self.splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
                }
            }, failure: { errorResponse in
                Utils.displayAlert(errorResponse, vc: self)
            })
        }
    }
}



