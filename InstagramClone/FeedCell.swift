//
//  FeedCell.swift
//  InstagramClone
//
//  Created by Hamit  Tırpan on 7.10.2019.
//  Copyright © 2019 Hamit  Tırpan. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func likeButtonClicked(_ sender: Any) {
        
        let firestoreDataBase = Firestore.firestore()
        
        if let likeCount = Int(likeLabel.text!){
            let likeSore = ["likes" : likeCount + 1] as [String : Any]
            // Aşağıda data güncelleme işlemi yaptım.Dataset'te sadece like alanını güncelledim.Dataset'te sadece tek bir alan güncellemek istediğim için .setData'nın merge olan func'nı kullandım.
            firestoreDataBase.collection("Posts").document(documentIdLabel.text!).setData(likeSore, merge: true)
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
