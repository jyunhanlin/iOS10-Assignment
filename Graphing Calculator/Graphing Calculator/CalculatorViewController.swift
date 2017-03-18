//
//  ViewController.swift
//  Calculator
//
//  Created by JHLin on 2017/2/19.
//  Copyright © 2017年 JHL. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
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
    
    @IBAction func getMemoryValue() {
        brain.setOperand(variable: "M")
    }
    
    @IBAction func setMemoryValue() {
        brain.memoryValue = displayValue!
        (displayValue, _, sequence.text!) = brain.evaluate(using: ["M":brain.memoryValue])
    }
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTyping {
            if (display.text?.characters.count)! > 1 {
                display.text?.remove(at: (display.text?.index(before: (display.text?.endIndex)!))!)
            } else {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            }  
        } else {
            (displayValue, sequence.text!) = brain.undo()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let graphVC = (segue.destination.contents as? GraphViewController) {
            graphVC.navigationItem.title = brain.memoryBrain.last?.description
            
            var tempFucntion: ((Double) -> Double)? = nil
            var userPushMemoryButton = false
            for memoryData in brain.memoryBrain {
                if userPushMemoryButton {
                    let function2 = tempFucntion
                    if memoryData.secondOperand == nil {
                        tempFucntion = { x in
                            return memoryData.unaryFunction!(function2!(x))
                        }
                    } else {
                        tempFucntion = { x in
                            return memoryData.binaryFunction!(function2!(x), memoryData.secondOperand!)
                        }
                    }
                }
                
                if memoryData.mButton != Constants.MemoryButton.didNotPress && userPushMemoryButton == false{
                    userPushMemoryButton = true
                    if memoryData.secondOperand == nil {
                        tempFucntion = memoryData.unaryFunction!
                    } else {
                        if memoryData.mButton == Constants.MemoryButton.atFirstOperand {
                            tempFucntion = { x in
                                return memoryData.binaryFunction!(x, memoryData.secondOperand!)
                            }
                        } else {
                            tempFucntion = { x in
                                return memoryData.binaryFunction!(memoryData.firstOperand!, x)
                            }
                        }
                    }
                    
                }
            }
            
            if tempFucntion == nil {
                graphVC.function = { [weak self] x in
                    return CGFloat((self?.displayValue)!)
                }
            } else {
                graphVC.function = { x in
                    return CGFloat(tempFucntion!(x))
                }
            }

            
        }
        
    }
}

extension UIViewController
{
    // a friendly var we've added to UIViewController
    // it returns the "contents" of this UIViewController
    // which, if this UIViewController is a UINavigationController
    // means "the UIViewController contained in me (and visible)"
    // otherwise, it just means the UIViewController itself
    // could easily imagine extending this for UITabBarController too
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

