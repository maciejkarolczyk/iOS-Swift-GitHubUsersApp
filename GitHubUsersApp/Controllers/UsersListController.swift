import Foundation
import UIKit
import Alamofire

protocol UserListControllerDelegate: class {
  func userSelected(_ userLogin: String?)
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
                guard let source = self.dataSource else {return}
                self.tableMaskView.isHidden = source.count() > 0
                self.tableMaskViewLabel.text = "No users found for criteria"
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
        self.hideKeyboardWhenTappedAround()
    }
    
    func configureSplitView() {
        splitViewController?.preferredPrimaryColumnWidthFraction = 0.5;
        let maxSize = splitViewController?.view.bounds.size.width
        guard let size = maxSize else {return}
        splitViewController?.maximumPrimaryColumnWidth = size;
    }
    
    @IBAction func onSearchButtonPressed(_ sender: Any) {
        if let query = searchTextField.text {
            if query.isAlphanumeric() {
                currentQuery = query
                currentPage = 1
                activityIndicator.startAnimating()
                ServiceManager.sharedInstance.requestUsers(query: query, { response in
                    self.dataSource = response
                    self.delegate?.userSelected(self.dataSource?.users.first?.name)
                    self.stopActivityIndicator()
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
        ServiceManager.sharedInstance.requestUsers(query: currentQuery, page:currentPage + 1, { response in
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
        let usersCount = self.dataSource?.users.count ?? 0
        if indexPath.row == usersCount - 1 && usersCount > 29 {
            self.loadMore()
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
            self.delegate?.userSelected(selectedUser?.name)
            DispatchQueue.main.async {
                self.splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
            }
        }
    }
}



