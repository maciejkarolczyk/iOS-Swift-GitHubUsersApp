import Foundation
import UIKit
import Kingfisher

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
    
    var dataModel:UserDetails? {
        didSet {
            DispatchQueue.main.async {
                self.refreshUI()
            }
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        self.title = "gitHub User Details"
    }

    private func refreshUI() {
        self.loadViewIfNeeded()
        if let dataModel = dataModel {
            welcomeView.isHidden = true
            if let avatarURL = dataModel.avatarUrl {
                avatarImageView.kf.setImage(with: URL(string: avatarURL))
            } else {
                avatarImageView.image = UIImage(named: "noimage")
            }
            userNameLabel.text = (dataModel.name != nil) ? dataModel.name : "<Not Provided>"
            idLabel.text = String(dataModel.id)
            webPageLabel.text = (dataModel.htmlUrl != nil) ? dataModel.htmlUrl : "<Not Provided>"
            companyLabel.text = (dataModel.company != nil) ? dataModel.company : "<Not Provided>"
            locationLabel.text = (dataModel.location != nil) ? dataModel.location : "<Not Provided>"
            emailLabel.text = (dataModel.email != nil) ? dataModel.email : "<Not Provided>"
            if let publicReposCount = dataModel.publicReposCount {
                repositoriesLabel.text = String(publicReposCount)
            } else {
                repositoriesLabel.text = "<Not Provided>"
            }
            
            if let followersCount = dataModel.followersCount {
                followersLabel.text = String(followersCount)
            } else {
                followersLabel.text = "<Not Provided>"
            }
        
            
            if let creationDate = dataModel.creationDate {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd hh:mm:ss"
                creationDateLabel.text = df.string(from: creationDate)
            }
            
        } else {
            welcomeView.isHidden = false
        }
    }

}

extension DetailsViewController: UserListControllerDelegate {
    func userSelected(_ userSelected: UserDetails?) {
        dataModel = userSelected
    }
}
