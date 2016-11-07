//
//  ChartsAxisFormatter.swift
//  Scrolling
//
//  Created by David Hendershot on 11/6/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import Charts


@objc(BarChartFormatter)
public class BarChartFormatter: NSObject, IAxisValueFormatter
{
	
	var names = [String]()
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String
	{
		return names[Int(value)]
	}
	
	public func setValues(values: [String])
	{
		self.names = values
	}
}
