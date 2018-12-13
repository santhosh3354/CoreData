//
//  AddPlayerController.swift
//  Task2
//
//  Created by Ideabytes on 2018-12-12.
//  Copyright © 2018 Ideabytes. All rights reserved.
//

import UIKit
import CoreData

class AddPlayerController: UIViewController,UITextFieldDelegate {
    //cuntry name
    var countryName : String = ""
    //player name
    var playerName : String = ""
    
    //Textfield to input the name
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTextField.text = playerName //if user is updating the playername
    }
    //resign the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //MARK: - Save the PlayerName
    @IBAction func saveButtonAction(_ sender: UIButton) {
        //Pass the player name to method as param
        //if playername is empty just parsing as noplayer
        updatePlayerName(playerName: playerName)
    }
    //MARK: - Method to Save/Update in coredata
    //If you want u can use two methods, one is to store the data, one is to update. But I am using only once method to save and update
    func updatePlayerName(playerName: String){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // Create a Fetch request
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")//Check the entity
        fetchRequest.predicate = NSPredicate(format: "name == %@", playerName) //Check with the name
        let result = try? managedContext.fetch(fetchRequest)
        if result!.count > 0 { //if there is a player
        for player in result! {
            if let name = (player as! NSManagedObject).value(forKey: "name") {
            if name as! String == playerName { //if user wanst to update the same player
                (player as! NSManagedObject).setValue("\(nameTextField.text!)", forKey: "name") //save the value
            }
            }
        }
        } else { //if there is no player exists, create a new one
            let entity =
                NSEntityDescription.entity(forEntityName: "Player",
                                           in: managedContext)!
            
            let player = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            // save the values of the player
            player.setValue(nameTextField.text!, forKeyPath: "name")
            player.setValue(countryName, forKeyPath: "countryname")

        }
        do {
            try managedContext.save() //save the data
            self.navigationController?.popViewController(animated: true) //navigate to previous vc
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
