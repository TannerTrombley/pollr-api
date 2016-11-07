//
//  MyPollsTableViewController.swift
//  Scrolling
//
//  Created by David Hendershot on 11/6/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import Firebase

class MyPollsTableViewController: UITableViewController {

	@IBOutlet var myPollsTable: UITableView!
	
	var polls = [Poll]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		myPollsTable.delegate = self
		myPollsTable.dataSource = self
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//		self.navigationItem.leftBarButtonItem?.isEnabled = false
//		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Polls", style: UIBarButtonItemStyle.plain, target: self, action: "segueBackToMain")
		
		
		func done(polls: [Poll]) {
			self.polls = polls.reversed()
			
			DispatchQueue.main.async {
				self.myPollsTable.reloadData()
			}
		}
		
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			if let error = error {
				// Handle error
				return;
			}
			
			let client = clientAPI(token: idToken!)
			client.getDemoPolls(done: done)
		}
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
//		print("The segue is \(segue.identifier)")
//		print("Going to view controller \(segue.destination)")
		
		if segue.identifier == "ShowResults",
			let destination = segue.destination as? PollResultsViewController
		{
			let row = (myPollsTable.indexPathForSelectedRow?.row)!
			print("The selected row is: \(row)")
			
			let pollId = polls[(myPollsTable.indexPathForSelectedRow?.row)!].getId()
			print("Making the poll id -> \(pollId)")
			
			destination.pollId = pollId
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return polls.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pollTableViewCell", for: indexPath) as! MyPollsTableViewCell
		let row = indexPath.row

		cell.pollTitle.text = polls[row].getQuestion()
		
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
