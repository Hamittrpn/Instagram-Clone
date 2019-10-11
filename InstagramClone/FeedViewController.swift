//
//  FeedViewController.swift
//  InstagramClone
//
//  Created by Hamit  Tırpan on 7.10.2019.
//  Copyright © 2019 Hamit  Tırpan. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var likeArray = [Int]()
    var userImageArray = [String]()
    var DocumentIdArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFromFirestore()
        
    }
    
    func getDataFromFirestore(){
        
        let fireStoreDatabase = Firestore.firestore()
        
        // .ORDER ile tarihe göre postları sondan başa doğru sıraladım.
        fireStoreDatabase.collection("Posts").order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil{
                self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
            } else{
                if snapshot?.isEmpty != true && snapshot != nil{
                    
                    // Anasayfa'da aynı postlar birden fazla kez gelmemesi için temizliyorum.
                    self.userImageArray.removeAll(keepingCapacity: false)
                    self.userEmailArray.removeAll(keepingCapacity: false)
                    self.userCommentArray.removeAll(keepingCapacity: false)
                    self.likeArray.removeAll(keepingCapacity: false)
                    self.DocumentIdArray.removeAll(keepingCapacity: false)
                    
                    // DocumentId ile ben tıklananan postun like'ına falan ulaşabileceğim.
                    for document in snapshot!.documents{
                        let documentID = document.documentID
                            self.DocumentIdArray.append(documentID)
                        if let postedBy = document.get("postedBy") as? String{
                            self.userEmailArray.append(postedBy)
                            
                            if let postComment = document.get("postComment") as? String{
                                self.userCommentArray.append(postComment)
                                
                                if let likes = document.get("likes") as? Int{
                                    self.likeArray.append(likes)
                                    
                                    if let imageUrl = document.get("imageUrl") as? String{
                                        self.userImageArray.append(imageUrl)
                                    }
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func makeAlert(titleInput:String, messageInput:String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        
        cell.userEmailLabel.text = userEmailArray[indexPath.row]
        cell.commentLabel.text = userCommentArray[indexPath.row]
        cell.likeLabel.text = String(likeArray[indexPath.row])
        cell.userImageView.sd_setImage(with: URL(string: self.userImageArray[indexPath.row]))
        cell.documentIdLabel.text = DocumentIdArray[indexPath.row]
        
        return cell
    }

}
