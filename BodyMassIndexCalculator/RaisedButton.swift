//
//  RaisedButton.swift
//  gTodo
//
//  Created by Jeremy Broutin on 8/29/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import UIKit

class RaisedButton: UIButton {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.layer.cornerRadius = 2.0
		self.layer.masksToBounds = false
		self.layer.shadowColor = UIColor.darkGray.cgColor
		self.layer.shadowRadius = 1.5
		self.layer.shadowOpacity = 0.5
		self.layer.shadowOffset = CGSize(width: 0, height: 1)
		self.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightSemibold)
	}
	
	override var isEnabled: Bool {
		didSet{
			if isEnabled {
				self.alpha = 1
			} else {
				self.alpha = 0.5
			}
		}
	}
}
