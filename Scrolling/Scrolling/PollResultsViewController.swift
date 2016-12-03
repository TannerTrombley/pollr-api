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

class PollResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	@IBOutlet weak var barChartView: BarChartView!
	@IBOutlet weak var pollTitle: UILabel!
	@IBOutlet weak var commentsTable: UITableView!
	
	var pollId = Int()
	var comments = [String]()
//		= ["Hello", "World", "How are you doing? Is this resizing?", "What about down here? Dynamically resized cells are new in iOS8"]
	let sections = ["Comments", "Submit A Comment"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		commentsTable.delegate = self
		commentsTable.dataSource = self
		commentsTable.estimatedRowHeight = 44.0
		commentsTable.rowHeight = UITableViewAutomaticDimension
		
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
		self.commentsTable.reloadData()
		
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
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 0:
				return 1
			case 1:
				return comments.count
			default:
				return 0
		}
		return comments.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.section {
			case 0:
				return configureInputCell(indexPath: indexPath)
			case 1:
				return configureCommentCell(indexPath: indexPath)
			default:
				return UITableViewCell()
		}
	}
	
	func configureCommentCell(indexPath: IndexPath) -> UITableViewCell {
		let cell = commentsTable.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
		if indexPath.row < comments.count {
			cell.comment.text = comments[indexPath.row]
		}
		return cell
	}
	
	func configureInputCell(indexPath: IndexPath) -> UITableViewCell {
		let cell = commentsTable.dequeueReusableCell(withIdentifier: "submitCommentCell", for: indexPath) as! SubmitCommentTableViewCell
		cell.userComment.delegate = self
		return cell
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if string == "\n" {
			textField.resignFirstResponder()
			
			if textField.text != "" {
				let currentUser = FIRAuth.auth()?.currentUser
				currentUser?.getTokenForcingRefresh(true) {idToken, error in
					if let error = error {
						print(error)
						return;
					}
					
					let client = clientAPI(token: idToken!)
					client.submitComment(pollId: self.pollId, commentTextField: textField, done: self.done)
				}
			}
		}
		return true
	}
	
	func done(textField: UITextField) {
		comments.append(textField.text!)
		textField.text = "Add another comment..."
		commentsTable.reloadData()
	}
	
	// Clears the default text
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.text = ""
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
