//
//  GitHubUserCell.swift
//  GitHubUsersApp
//
//  Created by Karolczyk, Maciej on 27/06/2020.
//  Copyright © 2020 Karolczyk, Maciej. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class GitHubUserCell:UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(dataModel:UserTableModel) {
        let url = URL(string: dataModel.avatarUrl)
        avatarImageView.kf.setImage(with: url)
        nameLabel.text = dataModel.name
        scoreValueLabel.text = String(dataModel.score)
        
    }
    
}
