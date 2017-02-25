//
//  ViewController.swift
//  Calculator
//
//  Created by JHLin on 2017/2/19.
//  Copyright © 2017年 JHL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var sequence: UILabel!
    private var userIsInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textInCurrentlyDisplay = display.text!
            if digit != "." || textInCurrentlyDisplay.range(of: ".") == nil {
                display.text = textInCurrentlyDisplay + digit
            }
        } else {
            if digit == "." {
                display.text = "0."
            }
            else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double? {
        get {
            return Double(display.text!)!
        }
        set {
            if let value = newValue {
                display.text = String(value)
                sequence.text = brain.getDescription()
            } else {
                display.text = "0"
                sequence.text = ""
            }
            
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
            brain.setOperand(displayValue!)
        }
        if let mathmaticalSymbol = sender.currentTitle {
            brain.performOperation(mathmaticalSymbol)
        }

        if let result = brain.result {
            displayValue = result
        }
    }
    
    @IBAction func clear() {
        brain.clear()
        displayValue = 0
        userIsInTheMiddleOfTyping = false        
    }
}

