import Foundation
import UIKit
import Kingfisher
import RealmSwift

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var welcomeView: UIView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var webPageLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var repositoriesLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userLogin:String? {
        didSet {
            self.getModel()
        }
    }
    var dataModel:UserDetails?
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        self.title = "gitHub User Details"
        activityIndicator.hidesWhenStopped = true
    }

    func refreshUI(dataModel:UserDetails) {
        DispatchQueue.main.async {
            self.loadViewIfNeeded()
            if let avatarURL = dataModel.avatarUrl {
                self.avatarImageView.kf.setImage(with: URL(string: avatarURL))
            } else {
                self.avatarImageView.image = UIImage(named: "noimage")
            }
            self.userNameLabel.text = (dataModel.name != nil) ? dataModel.name : "<Not Provided>"
            self.idLabel.text = String(dataModel.id)
            self.webPageLabel.text = (dataModel.htmlUrl != nil) ? dataModel.htmlUrl : "<Not Provided>"
            self.companyLabel.text = (dataModel.company != nil) ? dataModel.company : "<Not Provided>"
            self.locationLabel.text = (dataModel.location != nil) ? dataModel.location : "<Not Provided>"
            self.emailLabel.text = (dataModel.email != nil) ? dataModel.email : "<Not Provided>"
            self.repositoriesLabel.text = String(dataModel.publicReposCount)
            self.followersLabel.text = String(dataModel.followersCount)
            
            if let creationDate = dataModel.creationDate {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd hh:mm:ss"
                self.creationDateLabel.text = df.string(from: creationDate)
            } else {
                self.creationDateLabel.text = "<Not Provided>"
            }
        }
    }
    
    private func getModel() {
        changeActivityIndicator(isHidden: false)
        if let userLogin = self.userLogin {
            ServiceManager.sharedInstance.requestUserDetails(userName: userLogin, { reference in
                self.welcomeView(isHidden: true)
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    if let model = realm.resolve(reference) {
                        self.refreshUI(dataModel: model)
                    }
                }
                self.changeActivityIndicator(isHidden: true)
            }, failure: { errorResponse in
                self.changeActivityIndicator(isHidden: true)
                self.welcomeView(isHidden: false)
                Utils.displayAlert(errorResponse, vc: self)
            })
        } else {
            welcomeView(isHidden: false)
        }
    }
    
    func welcomeView(isHidden:Bool) {
        DispatchQueue.main.async {
            self.welcomeView.isHidden = isHidden
        }
    }
    
    func changeActivityIndicator(isHidden:Bool) {
        DispatchQueue.main.async {
            if isHidden == true {
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.startAnimating()
            }
        }
    }
}

extension DetailsViewController: UserListControllerDelegate {
    func userSelected(_ userLogin: String?) {
        self.userLogin = userLogin
    }
}
