//
//  ViewController.swift
//  Task2
//
//  Created by Ideabytes on 2018-12-12.
//  Copyright © 2018 Ideabytes. All rights reserved.
//

//Servie URL
let COUNTRIES_URL = "https://demo6869072.mockable.io/cricket/countries"

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //Array to store countries
    var countriesNames = NSMutableArray()
    //Tableview to display countries
    @IBOutlet weak var countriesTableView: UITableView!
    
    //TableView cell
    let tablecellId = "myCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //get countries list from service
        self.getCountriesList(url: COUNTRIES_URL, completionHandler: {(json) in
            //copy them to an array
            let listOfCountries = json as! NSArray
            //enumerate through the list to store locally
            for country in listOfCountries {
                guard let countryName = (country as? NSDictionary)?.value(forKey: "name") as? String
                    else {
                        return
                }
                //need main thread to store in Coredata
                DispatchQueue.main.async {
                    //save method to store the country in Coredata,pass the country name as param
                    self.save(name:countryName)
                }
            }
            
        })
        
        //display on tableview
        self.displayCountries()

    }
    
    //MARK: -Get Countries from Service
    func getCountriesList(url : String, completionHandler : @escaping (_ data : Any) -> Void) {
        
        //convert into URL format
        let url = URL.init(string: url)
        //create a request
        var request = URLRequest.init(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpMethod = "GET" //method type
        
        let session = URLSession.shared
        //session creation
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) //serialize the json result
                    completionHandler(json) //pass the data using closure
                }
                catch {
                    print("Error")
                }
                
            }
        }).resume()
        
        
        
    }
    
    //MARK: - Save in CoreData
    func save(name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // Getting the context from AppDelegate
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country") //create a fetchrequest with entity name
        fetchRequest.predicate = NSPredicate(format: "name == %@", name) //use predicate to filter the data
        let result = try? managedContext.fetch(fetchRequest) //check the result
        if result!.count == 0 {
            // if 0 records found with the name
            //create a record and insert into Coredata
            let entity =
                NSEntityDescription.entity(forEntityName: "Country",
                                           in: managedContext)!
            
            let country = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
            
            // set the value you want to store
            country.setValue(name, forKeyPath: "name")
        }
        do {
            //save the context
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - To display on TableView
    func displayCountries() {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // create an entity with name
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Country",
                                       in: managedContext)!
        
        let country = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
        
        // Configure Fetch Request
        fetchRequest.entity = entity
        
        do {
            let result = try managedContext.fetch(fetchRequest) //hit the request
            countriesNames.removeAllObjects() //empty an array before going to add reslut
            for country in result { //enumerate through result
                if let name = (country as! NSManagedObject).value(forKey: "name") {
                    countriesNames.add(name) //add country names to array
                }
                
            }
            //reload the Tableview once data is fetched
            countriesTableView.reloadData()
        } catch {
            let fetchError = error as NSError
            print(fetchError) //some error while fetching
        }

    }
    
    //MARK: - TableView DataSource and Delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countriesNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //reusable cell id
        let cell:UITableViewCell = self.countriesTableView.dequeueReusableCell(withIdentifier: tablecellId) as UITableViewCell!

        //display country name
        cell.textLabel?.text = countriesNames[indexPath.row] as! String
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //by selecting the country navigate to next vc
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        vc.countryName = countriesNames[indexPath.row] as! String //pass the country name to next vc
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

