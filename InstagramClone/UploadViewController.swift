//
//  UploadViewController.swift
//  InstagramClone
//
//  Created by Hamit  Tırpan on 7.10.2019.
//  Copyright © 2019 Hamit  Tırpan. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var uploadButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
    }
    // Resim Upload İşlemi
    @objc func chooseImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    // Kullanıcı resmi seçtikten sonra ne olacak ? Daha sonra info.plist'e gidip izin ekle (Privacy-PhotoLibrary)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil )
    }
    
    func makeAlert(titleInput:String, messageInput:String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK ", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        
        //Bu referans'ı kullanarak hangi klasörle çalışacağımızı , nereye kaydedeceğimizi belirtiyoruz.
        let storageReference = storage.reference()
        
        // child ile klasör içine giriyorum.
        let mediaFolder = storageReference.child("Media") // Firebase'deki klasörümün referansı
        
        // Resmi kaydedebilmem için imageView'ımdaki görseli alıp veriye(data) çevirmem gerekiyor.
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            
            // Kullanıcının firebase'e yüklediği resimlerin isimleri benzersiz olması için uuid üretiyorum.
            let uuid = UUID().uuidString
            
            let imageReference  = mediaFolder.child("\(uuid).jpg") // Oluşturacağım görselin referansı
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if error != nil{
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                }else{
                    // Metadata'yı kullanarak kullanıcının kaydettiği şeyin hangi url'ye, hangi web adresine kayıt edildiğini alıyorum.
                    imageReference.downloadURL(completion: { (url, error) in
                        
                        if error == nil{
                            let imageUrl = url?.absoluteString
                            
                            // Database işlemleri
                            let firestoreDatabase = Firestore.firestore()
                            // Db'ye okuma,yazma ve değiştirme yapabilmem için oluşturduğum obje
                            var firestoreReference : DocumentReference? = nil
                            
                            let firestorePost = ["imageUrl": imageUrl!, "postedBy": Auth.auth().currentUser!.email!, "postComment": self.commentText.text!, "date": FieldValue.serverTimestamp(), "likes" : 0] as [String : Any]
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil{
                                    
                                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error!")
                                } else{
                                    
                                    self.imageView.image = UIImage(named: "select.png")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
                        }
                    })
                }
            }
        }
    }
}
