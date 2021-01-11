//
//  Basket.swift
//  Online Store
//
//  Created by Mohamed Jaber on 02/01/2021.
//

import Foundation
class Basket {
    
    var id: String!
    var ownerId: String!
    var itemIds: [String]!
    
    init() {
    }
    
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as? String
        ownerId = _dictionary[kOWNERID] as? String
        itemIds = _dictionary[kITEMIDS] as? [String]
    }
    
}
//MARK: - download Basket

func downloadBasketFromFirestore(_ ownerId: String, completion: @escaping (_ basket: Basket?)-> Void){
    
    FirebaseReference(.Basket).whereField(kOWNERID, isEqualTo: ownerId).getDocuments { (snapshot, err) in
        
        guard let snapshot = snapshot else {
            completion(nil)
            return
        }
        
        if !snapshot.isEmpty && snapshot.documents.count > 0 {
            
            // - we used document.first because every user has only one basket !!
            let basket = Basket(_dictionary: snapshot.documents.first!.data() as NSDictionary)
            completion(basket)
        }else{
            completion(nil)
        }
        
    }
    
}
    
//MARK: - save to Firestore Basket
func saveBasketToFirestore(_ basket:Basket){
    FirebaseReference(.Basket).document(basket.id).setData(basketDictionaryFrom(basket) as! [String:Any])
}
//MARK: - Helper func
func basketDictionaryFrom(_ basket: Basket) -> NSDictionary{
    return NSDictionary(objects: [basket.id, basket.itemIds, basket.ownerId], forKeys: [kOBJECTID as NSCopying, kITEMIDS as NSCopying, kOWNERID as NSCopying])
}
//MARK: - Update Basket

func updateBasketInFirestore(_ basket: Basket, withValues: [String: Any], completion: @escaping (_ error: Error?)->Void){

    FirebaseReference(.Basket).document(basket.id).updateData(withValues) { (err) in
        
        if err != nil {
            completion(err)
        }
        
        completion(nil)
        
    }
}
//MARK: - Download Items in Basket
func donwloadItemInBasket(_ withIds: [String], comletion: @escaping (_ itemArray: [Item])->Void){
    
    var count = 0
    var itemArray: [Item] = []
    
    if withIds.count > 0 {
        
        for itemId in withIds {
            
            FirebaseReference(.Items).document(itemId).getDocument { (snapshot, err) in
                
                guard let snapshot = snapshot else {
                    comletion(itemArray)
                    return
                }
                
                if snapshot.exists {
                    
                    itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    count += 1
                }else {
                    comletion(itemArray)
                }
                
                if count == withIds.count {
                    comletion(itemArray )
                }
            }
        }
        comletion(itemArray)
    }
}
