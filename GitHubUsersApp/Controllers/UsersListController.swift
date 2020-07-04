import Foundation
import UIKit
import Alamofire
import RealmSwift

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
    let cellIdentifier = "GitHubUserCell"
    var notificationToken: NotificationToken?
    
    var dataSource: UsersModel? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                guard let source = self.dataSource else {return}
                self.tableMaskView.isHidden = source.count() > 0
                self.tableMaskViewLabel.text = Strings.noUsers
                self.setActivityIndicator(false)
            }
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        activityIndicator.hidesWhenStopped = true
        configureSplitView()
        self.hideKeyboardWhenTappedAround()
        self.title = Strings.mainViewTitle
        let realm = try! Realm()
        notificationToken = realm.observe { [unowned self] note, realm in
            if self.currentQuery != nil {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.setActivityIndicator(false)
                }
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationToken?.invalidate()
    }
    
    func configureSplitView() {
        splitViewController?.preferredPrimaryColumnWidthFraction = CGFloat(Constants.preferredPrimaryColumnWidthFraction);
        let maxSize = splitViewController?.view.bounds.size.width
        guard let size = maxSize else {return}
        splitViewController?.maximumPrimaryColumnWidth = size;
    }
    
    @IBAction func onSearchButtonPressed(_ sender: Any) {
        if let query = searchTextField.text, query.isAlphanumeric() {
            self.setActivityIndicator(true)
            currentQuery = query
            currentPage = 1
            ServiceManager.sharedInstance.requestUsersAfterSearch(query: query, { reference in
                DispatchQueue.main.async {
                    guard let model = DBManager.sharedInstance.resolveThreadSafeReference(reference:reference) else {return}
                    self.dataSource = model
                    self.delegate?.userSelected(self.dataSource?.users.first?.name)
                }
                self.setActivityIndicator(false)
            }, failure: { errorResponse in
                self.setActivityIndicator(false)
                Utils.displayAlert(errorResponse.description, vc:self)
            })
        } else {
            Utils.displayAlert(Strings.noAlphanumeric, vc:self)
        }
    }
    
    func loadMore() {
        guard let currentQuery = self.currentQuery else {return}
        if InternetConnectionManager.isConnectedToNetwork() {
            currentPage = currentPage + 1
            ServiceManager.sharedInstance.downloadMoreUsers(query: currentQuery, page: currentPage,
                                                            failure: { errorResponse in
                                                                Utils.displayAlert(errorResponse.description, vc:self)
                                                                self.setActivityIndicator(false)
            })
        }
    }
    
    func setActivityIndicator(_ shouldAnimate:Bool) {
        DispatchQueue.main.async {
            if shouldAnimate {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

extension UsersListController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! GitHubUserCell
        if let dataSourceForCell = dataSource?.users[indexPath.row] {
            cell.setupCell(dataModel:dataSourceForCell)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        return dataSource.count();
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let dataSource = self.dataSource else {return}
        let lastElement = dataSource.users.count - 1
        if indexPath.row == lastElement {
            self.setActivityIndicator(true)
            loadMore()
        }
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



