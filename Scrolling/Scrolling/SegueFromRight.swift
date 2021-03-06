//
//  SegueFromRight.swift
//  Scrolling
//
//  Created by David Hendershot on 11/1/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import QuartzCore

class SegueFromRight: UIStoryboardSegue {

	override func perform() {
		let src: UIViewController = self.source
		let dst: UIViewController = self.destination
		let transition: CATransition = CATransition()
		let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		transition.duration = 0.25
		transition.timingFunction = timeFunc
		transition.type = kCATransitionPush
		transition.subtype = kCATransitionFromRight
		src.navigationController!.view.layer.add(transition, forKey: kCATransition)
		src.navigationController!.pushViewController(dst, animated: false)
	}
	
}
