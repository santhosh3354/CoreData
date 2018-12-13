//
//  PlayerViewController.swift
//  Task2
//
//  Created by Ideabytes on 2018-12-12.
//  Copyright © 2018 Ideabytes. All rights reserved.
//

import UIKit
import CoreData

class PlayerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    //string to get countryname from previous class
    var countryName : String = ""
    //store players in an array
    var playersArray = NSMutableArray()
    //tableview to display the players list
    @IBOutlet weak var playerTableView: UITableView!
    
    //TableView cell
    let tablecellId = "myCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = countryName //add title
        
        //Add button on navigation to add players
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addPlayer))
        self.navigationItem.rightBarButtonItem = addButton

    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayPlayers()
    }
    //MARK: -Add button method to add a player
    @objc func addPlayer()  {
        //Navigate to next vc to add a new player
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPlayerController") as! AddPlayerController
        vc.countryName = countryName
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    //MARK: - Display all the players on Tavbleview
    func displayPlayers() {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // Create the ManagedObjectContext
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // Check the entity
        let entity =
            NSEntityDescription.entity(forEntityName: "Player",
                                       in: managedContext)!
        let player = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
        
        // Configure Fetch Request
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "countryname == %@",countryName) //check the players country to get selected country players only
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            playersArray.removeAllObjects()
            for player in result {
                if let name = (player as! NSManagedObject).value(forKey: "name") {
                    playersArray.add(name) //add players name to array
                }
                
            }
            playerTableView.reloadData() //reload the table once data is fetched
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
    }

    //MARK: - Tableview Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        //reusable cell id
        let cell:UITableViewCell = self.playerTableView.dequeueReusableCell(withIdentifier: tablecellId) as UITableViewCell!
        //display the player name
        cell.textLabel?.text = playersArray.object(at: indexPath.row) as! String
        
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Navigate to next vc to update/edit the player name
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPlayerController") as! AddPlayerController
        vc.playerName = playersArray[indexPath.row] as! String //pass player name to next vc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //user swipe to delete the player
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            //pass player name to delete from core data
            deletePlayer(playerName: playersArray.object(at: indexPath.row) as! String)
            playersArray.removeObject(at: indexPath.row) //delete from local array
            playerTableView.reloadData() //reload the data once deleted

        }

    }

    //MARK: - Delete the record from CoreData
    func deletePlayer(playerName:String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // Initialise the fetch request
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
        fetchRequest.predicate = NSPredicate(format: "name == %@ && countryname == %@", playerName,countryName) //check the player name
        let result = try? managedContext.fetch(fetchRequest)
            for player in result! {
                managedContext.delete(player as! NSManagedObject) //delete from core data
        }
        
        do {
            try managedContext.save() //save once deleted
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
