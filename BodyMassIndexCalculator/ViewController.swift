//
//  ViewController.swift
//  BodyMassIndexCalculator
//
//  Created by Jeremy Broutin on 1/26/17.
//  Copyright © 2017 Jeremy Broutin. All rights reserved.
//

import UIKit
import BMICalculator

class ViewController: UIViewController {

	// MARK: Outlets
	
	@IBOutlet var weightTextField: UITextField!
	@IBOutlet var heightTextField: UITextField!
	@IBOutlet var calculateButton: UIButton!
	@IBOutlet var BMILabel: UILabel!
	@IBOutlet var resultsInfoLabel: UILabel!
	@IBOutlet var BMIUnitsLabel: UILabel!
	@IBOutlet var showHelpViewButton: UIButton!
	@IBOutlet var helpView: UIView!
	@IBOutlet var helpLabel: UILabel!
	@IBOutlet var helpViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet var hideHelpViewButton: UIButton!
	
	// MARK: Properties
	
	let weightKGPlaceholderText = "Insert weight (kg)"
	let heightCMPlaceholderText = "Insert height (m)"
	let weightLBSPlaceholderText = "Insert weight (lbs)"
	let heightFTPlaceholderText = "Insert height (in)"
	let bmiUnitTextMetric = "kg/m2"
	let bmiUnitTextImperial = "lbs/in"
	let metricPreferenceKey = "metric_preference"
	
	// Types available in BMICalculator module
	var bmiCalculator: BMICalculator!
	var preference: SystemPreference!
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Instantiate BMICalculator
		bmiCalculator = BMICalculator()
		
		// Configure text fields
		weightTextField.delegate = self
		weightTextField.placeholder = weightKGPlaceholderText
		heightTextField.delegate = self
		heightTextField.placeholder = heightCMPlaceholderText
		
		// Safety: clear any BMI text
		BMILabel.text = ""
		resultsInfoLabel.text = ""
		
		// Get user preference for metric system
		preference = getUserSystemPreference()
		setHelpText(system: preference)
		
		// Add observer for default changes
		NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged(notification:)), name: UserDefaults.didChangeNotification, object: nil)
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Hide helpView
		self.hideHelpTapped(hideHelpViewButton)
	}
	
	// MARK: Helper functions
	
	func defaultsChanged(notification: Notification){
		// Update UI and results if system preference changes
		preference = getUserSystemPreference()
		switchMetricSystem(to: preference) { (finished) in
			if finished {
				if let (weight, height) = getUserInputsForBMI() {
					showBMI(weight: weight, height: height, system: preference)
				} else {
					BMILabel.text = ""
				}
			}
		}
	}
	
	func switchMetricSystem(to system: SystemPreference, completion: ((_: Bool) -> Void)) {
		// Switch any UI elements related to metric system
		switch system {
		case .Metric:
			DispatchQueue.main.async {
				self.weightTextField.placeholder = self.weightKGPlaceholderText
				self.heightTextField.placeholder = self.heightCMPlaceholderText
				self.BMIUnitsLabel.text = self.bmiUnitTextMetric
			}
		case .Imperial:
			DispatchQueue.main.async {
				self.weightTextField.placeholder = self.weightLBSPlaceholderText
				self.heightTextField.placeholder = self.heightFTPlaceholderText
				self.BMIUnitsLabel.text = self.bmiUnitTextImperial
			}
		}
		setHelpText(system: system)
		completion(true)
	}
	
	func getUserSystemPreference() -> SystemPreference {
		// Forced unwrapping is okay as setting has a default value
		let setting = UserDefaults.standard.value(forKey: metricPreferenceKey) as! String
		return SystemPreference(rawValue: setting)!
	}
	
	func getUserInputsForBMI() -> (Double, Double)? {
		// Get user inputs and convert it into any type that conforms to NumericType
		guard let weightStr = weightTextField.text, let weight = Double(weightStr),
			let heightStr = heightTextField.text, let height = Double(heightStr) else {
				print("Unable to convert textfields text into Double.")
				return nil
		}
		return (weight, height)
	}
	
	func showBMI<T: NumericType>(weight: T, height: T, system: SystemPreference){
		let bmi = bmiCalculator.calculateBMI(weight: weight, height: height, system: preference)
		displayResultsInfo(bmi: bmi)
	}
	
	func displayResultsInfo(bmi: Double) {
		
		// Show BMI index
		let bmiString = String(format: "%.2f", bmi)
		BMILabel.text = bmiString
		BMIUnitsLabel.isHidden = false
		
		// Show BMI result interpretation
		switch bmi {
		case 0..<16.00:
			resultsInfoLabel.text = "Severe thinness"
			resultsInfoLabel.textColor = UIColor.customRed
		case 16.00...17.00:
			resultsInfoLabel.text = "Moderate thinness"
			resultsInfoLabel.textColor = UIColor.customOrange
		case 17.00...18.50:
			resultsInfoLabel.text = "Mild thinness"
			resultsInfoLabel.textColor = UIColor.customYellow
		case 18.50...25:
			resultsInfoLabel.text = "Normal range"
			resultsInfoLabel.textColor = UIColor.customGreen
		case 25.00...30.00:
			resultsInfoLabel.text = "Pre-obese"
			resultsInfoLabel.textColor = UIColor.customYellow
		case 30.00...35.00:
			resultsInfoLabel.text = "Obese class I"
			resultsInfoLabel.textColor = UIColor.customOrange
		case 35.00...40.00:
			resultsInfoLabel.text = "Obese class II"
			resultsInfoLabel.textColor = UIColor.customRed
		default:
			resultsInfoLabel.text = "Obese class III"
			resultsInfoLabel.textColor = UIColor.brown
		}
	}
	
	func setHelpText(system: SystemPreference) {
		helpLabel.text = "Current using \(system.rawValue) system.\nCheck app settings to modify."
	}
}

// MARK: - IBActions

extension ViewController {
	
	@IBAction func anywhereTapped(_ sender: UITapGestureRecognizer) {
		// Dismiss any editing view (eg: keyboard)
		view.endEditing(true)
	}
	
	@IBAction func calculateTapped(_ sender: UIButton) {
		// Dismiss keyboard if present
		view.endEditing(true)
		
		// Calculate BMI if valid user inputs and metric system pref
		if let (weight, height) = getUserInputsForBMI(), let preference = preference {
			showBMI(weight: weight, height: height, system: preference)
		} else {
			print("Error getting weight, height or preference.")
		}
	}
	
	@IBAction func showHelpTapped(_ sender: UIButton) {
		sender.isHidden = true
		helpViewBottomConstraint.constant = 0
		viewDidLayoutSubviews()
	}
	
	@IBAction func hideHelpTapped(_ sender: UIButton) {
		helpViewBottomConstraint.constant -= self.helpView.frame.height*2
		showHelpViewButton.isHidden = false
		viewDidLayoutSubviews()
	}
}


// MARK: - Textfield Delegate Methods

extension ViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return view.endEditing(true)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// Reset any BMI labels existing
		BMILabel.text = ""
		BMIUnitsLabel.isHidden = true
		resultsInfoLabel.text = ""
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		// Check for values in both fields to enable calculate button
		if !weightTextField.text!.isEmpty && !heightTextField.text!.isEmpty {
			calculateButton.isEnabled = true
		} else {
			calculateButton.isEnabled = false
		}
	}
}




