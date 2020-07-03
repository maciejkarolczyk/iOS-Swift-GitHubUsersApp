import Foundation
import UIKit
import Kingfisher
import RealmSwift

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var maskViewLabel: UILabel!
    
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

    override func viewDidLoad() {
        super .viewDidLoad()
        self.title = Strings.detailsViewTitle
        activityIndicator.hidesWhenStopped = true
    }
    
    func refreshUI(dataModel:UserDetails) {
        DispatchQueue.main.async {
            self.loadViewIfNeeded()
            let notProvided = Strings.notProvided
            if let avatarURL = dataModel.avatarUrl {
                self.avatarImageView.kf.setImage(with: URL(string: avatarURL))
            } else {
                self.avatarImageView.image = UIImage(named: "noimage")
            }
            self.userNameLabel.text = (dataModel.name != nil) ? dataModel.name : notProvided
            self.idLabel.text = String(dataModel.id)
            self.webPageLabel.text = (dataModel.htmlUrl != nil) ? dataModel.htmlUrl : notProvided
            self.companyLabel.text = (dataModel.company != nil) ? dataModel.company : notProvided
            self.locationLabel.text = (dataModel.location != nil) ? dataModel.location : notProvided
            self.emailLabel.text = (dataModel.email != nil) ? dataModel.email : notProvided
            self.repositoriesLabel.text = String(dataModel.publicReposCount)
            self.followersLabel.text = String(dataModel.followersCount)
            
            if let creationDate = dataModel.creationDate {
                let df = DateFormatter()
                df.dateFormat = Constants.apiDateFormat
                self.creationDateLabel.text = df.string(from: creationDate)
            } else {
                self.creationDateLabel.text = notProvided
            }
        }
    }
    
    private func getModel(_ userLogin:String) {
        setLoadingView(isLoading: true, isWelcome: false)
        ServiceManager.sharedInstance.requestUserDetails(userName: userLogin, { reference in
            DispatchQueue.main.async {
                let realm = try! Realm()
                guard let model = realm.resolve(reference) else {return}
                self.refreshUI(dataModel: model)
            }
            self.setLoadingView(isLoading: false, isWelcome: false)
        }, failure: { errorResponse in
            self.setLoadingView(isLoading: false, isWelcome: true)
            Utils.displayAlert(errorResponse, vc: self)
        })
    }
    
    func setLoadingView(isLoading:Bool, isWelcome:Bool) {
        guard let maskViewLabel = self.maskViewLabel else {return}
        DispatchQueue.main.async {
            let shouldMaskBeHidden = (!isLoading && !isWelcome)
            let shouldSpinnerBeHidden = (!isLoading && isWelcome)
            self.setMaskView(isHidden: shouldMaskBeHidden)
            self.setActivityIndicator(isHidden: shouldSpinnerBeHidden)
            maskViewLabel.text = isLoading ? Strings.loading : Strings.welcomeMessage
        }
    }
    
    func setMaskView(isHidden:Bool) {
        guard let welcomeView = self.maskView else {return}
        welcomeView.isHidden = isHidden
    }
    
    func setActivityIndicator(isHidden:Bool) {
        if let indicator = self.activityIndicator {
            if isHidden == true {
                indicator.stopAnimating()
            } else {
                indicator.startAnimating()
            }
        }
    }
}

extension DetailsViewController: UserListControllerDelegate {
    func userSelected(_ userLogin: String?) {
        guard let userLogin = userLogin else {return}
        getModel(userLogin)
    }
}
