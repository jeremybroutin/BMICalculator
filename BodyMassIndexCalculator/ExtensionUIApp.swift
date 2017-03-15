//
//  ExtensionUIApp.swift
//  BodyMassIndexCalculator
//
//  Created by Jeremy Broutin on 3/13/17.
//  Copyright © 2017 Jeremy Broutin. All rights reserved.
//

import UIKit

extension UIApplication {
	class var statusBarBackgroundColor: UIColor? {
		get {
			return (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor
		}
		set {
			(shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
		}
	}
}
