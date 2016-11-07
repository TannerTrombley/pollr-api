//
//  PollResultsViewController.swift
//  Scrolling
//
//  Created by David Hendershot on 11/6/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import Firebase
import Charts

class PollResultsViewController: UIViewController {
	
	@IBOutlet weak var barChartView: BarChartView!
	
	var pollId = Int()
	var answers = [String]()
	var voteCounts = [Int]()
	
//	override func viewWillAppear(_ animated: Bool) {
//		print("The pollID is \(pollId)")
//	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			if let error = error {
				print(error)
				return;
			}
			
			let client = clientAPI(token: idToken!)
			client.getPoll(pollId: self.pollId, done: self.done)
		}
		
		answers = ["First", "Second", "Third"]
		voteCounts = [10, 12, 14]
		
		setChart(dataPoints: answers, values: voteCounts)
    }

	
	func done(poll: Poll) {
		let results = poll.getAnswers()
		
		for answer in results {
			answers.append(answer.0)
			voteCounts.append(answer.1)
		}
		
//		print("The answers are: \(answers)")
//		print("With vote counts: \(voteCounts)")
	}
	
	
	// MARK: Setting up the Chart
	func setChart(dataPoints: [String], values: [Int]) {
		barChartView.noDataText = "Loading data..."
		
		var dataEntries: [BarChartDataEntry] = []
		
		for i in 0..<dataPoints.count {
			let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
			dataEntries.append(dataEntry)
		}
		
		let chartDataSet = BarChartDataSet(values: dataEntries, label: "Who da best?")
		let chartData = BarChartData(dataSet: chartDataSet)
		barChartView.data = chartData
		barChartView.xAxis.labelPosition = .bottom
	}
	
	
	
	

	
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
