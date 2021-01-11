//
//  Item.swift
//  Online Store
//
//  Created by Mohamed Jaber on 31/12/2020.
//

import Foundation
import UIKit
import InstantSearchClient

class Item {
    var id: String!
    var name: String!
    var categoryId: String!
    var price: String!
    var description: String!
    var imageLinks: [String]!
    init() {
    }
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as? String
        categoryId = _dictionary[kCATOGARYID] as? String
        name = _dictionary[kNAME] as? String
        description = _dictionary[kDESCRIPTION] as? String
        price = _dictionary[kPRICE] as? String
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
}
}

//MARK: Save items Function

func saveItemToFirestore(_ item: Item){
    FirebaseReference(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String: Any])
}

//MARK: Helper functions

func itemDictionaryFrom(_ item: Item)-> NSDictionary {
    return NSDictionary(objects: [item.id, item.categoryId, item.name, item.description, item.price, item.imageLinks], forKeys: [kOBJECTID as NSCopying, kCATOGARYID as NSCopying, kNAME as NSCopying, kDESCRIPTION as NSCopying, kPRICE as NSCopying, kIMAGELINKS as NSCopying])
}

//MARK: Download Func

func downloadItemsFromFirebase(withCategoryId: String, completion: @escaping (_ itemArray: [Item])->Void){
    var itemArray: [Item] = []
    FirebaseReference(.Items).whereField(kCATOGARYID, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        if !snapshot.isEmpty {
            for itemDict in snapshot.documents{
                itemArray.append(Item(_dictionary: itemDict.data() as NSDictionary))
            }
        }
        completion(itemArray)
    }
}
//MARK: - Download items from Firebase by itemID
func downloadItemsFromFirebaseByItemID(withIDs: [String], completion: @escaping (_ itemArray : [Item]) -> Void){
    
    //EXPLANATION: - every item found will be downloaded and added
    //EXPLANATION: - into the itemArray and once the counter reaches
    //EXPLANATION: - the amount of sent IDs, the callback will be called
    var count = 0
    var itemArray: [Item] = []
    
    if withIDs.count > 0 {
        for itemID in withIDs {
            FirebaseReference(.Items).document(itemID).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                if snapshot.exists {
                    //EXPLANATION: - if there is data inside the snapshot received from Firebase
                    //EXPLANATION: - the itemArray will append a new Item, created by usind the
                    //EXPLANATION: - data inside the snapshot, as a NSDictionary
                    itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    count += 1
                } else {
                    completion(itemArray)
                    return
                }
                
                //EXPLANATION: - if the counter incremented in this function
                //EXPLANATION: - has the same value as the size of the ID Array
                //EXPLANATION: - received by the function, the completion callback
                //EXPLANATION: - can be called, as all items were appended
                if count == withIDs.count {
                    completion(itemArray)
                }
            }
        }
    } else {
        completion(itemArray)
    }
}
 
//MARK: - Algolia functions
func saveItemToAlgolia(item: Item){
    
    let index = AlgoliaService.shared.index
    
    let itemToSave = itemDictionaryFrom(item) as! [String : Any]
    
    index.addObject(itemToSave, withID: item.id ,requestOptions: nil) { (content, error) in
        if error != nil {
            print("Error saving item to Algolia!: \(error!.localizedDescription)")
        } else {
            print("Added to Algolia!")
        }
    }
}

func searchAlgolia(searchString: String, completion: @escaping (_ itemArray: [String]) -> Void){
    
    let index = AlgoliaService.shared.index
    var resultIDs: [String] = []
    
    let query = Query.init(query: searchString)
    query.attributesToRetrieve = ["name", "description"]
    index.search(query) { (content, error) in
        
        if error == nil {
            let content = content!["hits"] as! [[String : Any]]
            resultIDs = []
            
            for result in content {
                resultIDs.append(result["objectID"] as! String)
            }
            completion(resultIDs)
        } else {
            print("Error algolia search!: \(error!.localizedDescription)")
        }
    }
}
