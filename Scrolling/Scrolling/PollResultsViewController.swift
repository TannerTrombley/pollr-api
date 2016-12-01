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

class PollResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var barChartView: BarChartView!
	@IBOutlet weak var pollTitle: UILabel!
	@IBOutlet weak var commentsTable: UITableView!
	
	var pollId = Int()
	var comments = ["Hello", "World", "How", "are", "you", "doing"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		commentsTable.delegate = self
		commentsTable.dataSource = self
		
		
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			if let error = error {
				print(error)
				return;
			}
			
			let client = clientAPI(token: idToken!)
			client.getPoll(pollId: self.pollId, done: self.receivedPolls)
		}

    }

	
	func receivedPolls(poll: Poll, comments: [String]) {
		
		self.comments = comments

		let question = poll.getQuestion()
		
		let results = poll.getAnswers()
		
		var answers = [String]()
		var voteCounts = [Int]()
		
		for answer in results {
			answers.append(answer.0)
			voteCounts.append(answer.1)
		}
		
		self.pollTitle.text = question
		setChart(title: question, dataPoints: answers, values: voteCounts)
	}
	
	func receivedComments(comments: [String]) {
		self.comments = comments
	}
	
	// MARK: Setting up the Chart
	func setChart(title: String, dataPoints: [String], values: [Int]) {
		barChartView.noDataText = "Loading data..."
		
		let formatter = BarChartFormatter()
		formatter.setValues(values: dataPoints)
		let xaxis:XAxis = XAxis()
		
		var dataEntries: [BarChartDataEntry] = []
		
		for i in 0..<dataPoints.count {
			let dataEntry = BarChartDataEntry(x: Double(i), yValues: [Double(values[i])])
			dataEntries.append(dataEntry)
		}
		
		let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
		chartDataSet.colors = ChartColorTemplates.colorful()
		let chartData = BarChartData(dataSet: chartDataSet)
		
		xaxis.valueFormatter = formatter
		barChartView.xAxis.valueFormatter = xaxis.valueFormatter
		
		barChartView.data = chartData
		barChartView.xAxis.labelPosition = .bottom
		barChartView.xAxis.drawGridLinesEnabled = false
		barChartView.xAxis.granularityEnabled = true
		barChartView.xAxis.granularity = 1.0
		barChartView.xAxis.decimals = 0
		
		self.barChartView.legend.enabled = false
		
		barChartView.chartDescription?.enabled = false
		barChartView.rightAxis.enabled = false
//		barChartView.xAxis.labelRotationAngle = 270.0
		barChartView.animate(yAxisDuration: 2.0)
	}
	
	
	
	// MARK: Comments Table Functions
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return comments.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		if indexPath.row < comments.count {
			cell.textLabel?.text = comments[indexPath.row]
		}
		
		return cell
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
