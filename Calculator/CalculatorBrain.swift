//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by JHLin on 2017/2/19.
//  Copyright © 2017年 JHL. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumlator: Double?
    
    private var resultIsPending: Bool = false
    
    var memoryValue: Double = 0
    
    private var memoryBrain:[MemoryCalculatorBrain] = []

    private var userIsTypingM: Bool = false
    
    var description: String? {
        get {
            if pendingBinaryOperation == nil {
                return descriptionAccumlator
            } else {
                if resultIsPending {
                    return pendingBinaryOperation?.descriptionFunction((pendingBinaryOperation?.firstDescriptor)!, "")
                } else {
                    return pendingBinaryOperation?.descriptionFunction((pendingBinaryOperation?.firstDescriptor)!, descriptionAccumlator!)
                }
            }
        }
    }
    private var descriptionAccumlator: String?
    
    private enum operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case randomOperation
        case equal
    }
    
    private let operations: Dictionary<String, operation> = [
        "π" : operation.constant(M_PI),
        "e" : operation.constant(M_E),
        "√" : operation.unaryOperation(sqrt, { "√(\($0))" }),
        "cos" : operation.unaryOperation(cos, { "cos(\($0))" }),
        "±" : operation.unaryOperation({ -$0 }, { "±(\($0))" }),
        "x⁻¹" : operation.unaryOperation({ 1 / $0 }, { "\($0)⁻¹" }),
        "x²" : operation.unaryOperation({ $0 * $0 }, { "\($0)²" }),
        "+" : operation.binaryOperation({ $0 + $1 }, { "\($0)+\($1)" }),
        "−" : operation.binaryOperation({ $0 - $1 }, { "\($0)-\($1)" }),
        "×" : operation.binaryOperation({ $0 * $1 }, { "\($0)×\($1)" }),
        "÷" : operation.binaryOperation({ $0 / $1 }, { "\($0)÷\($1)" }),
        "rand" : operation.randomOperation,
        "=" : operation.equal
    ]
    
    private var pendingBinaryOperation:PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        let descriptionFunction: (String, String) -> String
        let firstDescriptor: String
        
        func perform (with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondDescriptor: String) -> String {
            return descriptionFunction(firstDescriptor, secondDescriptor)
        }
        
    }
    

    private struct MemoryCalculatorBrain {
        var mButton: Int
        var firstOperand: Double?
        var secondOperand: Double?
        var unaryFunction:((Double) -> Double)?
        var binaryFunction:((Double, Double) -> Double)?
        var description: String?
        
        func performUnaryFunction (with operand: Double) -> Double {
            return unaryFunction!(operand)
        }
        
        func performBinaryFunction (with firstOperand: Double, and secondOperand: Double) -> Double {
            return binaryFunction!(firstOperand, secondOperand)
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumlator != nil {
            accumlator = pendingBinaryOperation!.perform(with: accumlator!)
            descriptionAccumlator = pendingBinaryOperation!.performDescription(with: descriptionAccumlator!)
            pendingBinaryOperation = nil
            memoryBrain[memoryBrain.endIndex-1].description = getDescription()
        }
    }
    

    mutating func performOperation(_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumlator = value
                descriptionAccumlator = symbol
                
                let memoryData = MemoryCalculatorBrain(mButton: Constants.MemoryButton.didNotPress, firstOperand: accumlator!, secondOperand: nil, unaryFunction: nil, binaryFunction: nil, description: getDescription())
                memoryBrain.append(memoryData)
                
            case .unaryOperation(let function, let descriptionFunction):
                if accumlator != nil {
                    accumlator = function(accumlator!)
                    descriptionAccumlator = descriptionFunction(descriptionAccumlator!)
                    if userIsTypingM {
                        memoryBrain[memoryBrain.endIndex-1].mButton = Constants.MemoryButton.atFirstOperand
                        memoryBrain[memoryBrain.endIndex-1].unaryFunction = function
                        memoryBrain[memoryBrain.endIndex-1].description = getDescription()
                    } else {
                        let memoryData = MemoryCalculatorBrain(mButton: Constants.MemoryButton.didNotPress, firstOperand: accumlator!, secondOperand: nil, unaryFunction: function, binaryFunction: nil, description: getDescription())
                        memoryBrain.append(memoryData)
                    }

                }
            case .binaryOperation(let function, let descriptionFunction):
                if accumlator != nil {
                    if pendingBinaryOperation != nil {
                        accumlator = pendingBinaryOperation?.function((pendingBinaryOperation?.firstOperand)!, accumlator!)
                        descriptionAccumlator = pendingBinaryOperation?.descriptionFunction((pendingBinaryOperation?.firstDescriptor)!, descriptionAccumlator!)
                        pendingBinaryOperation = nil
                    }
 

                    resultIsPending = true
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumlator!, descriptionFunction: descriptionFunction, firstDescriptor: descriptionAccumlator!)
                    
                    if userIsTypingM {
                        memoryBrain[memoryBrain.endIndex-1].mButton = Constants.MemoryButton.atFirstOperand
                        memoryBrain[memoryBrain.endIndex-1].binaryFunction = function
                        memoryBrain[memoryBrain.endIndex-1].description = getDescription()
                    } else {
                        let memoryData = MemoryCalculatorBrain(mButton: Constants.MemoryButton.didNotPress, firstOperand: accumlator!, secondOperand: nil, unaryFunction: nil, binaryFunction: function, description: getDescription())
                        memoryBrain.append(memoryData)
                    }
                    
                }
            case .randomOperation :
                descriptionAccumlator = "random"
                accumlator = Double(Float(arc4random()) / Float(UInt32.max))
                let memoryData = MemoryCalculatorBrain(mButton: Constants.MemoryButton.didNotPress, firstOperand: accumlator!, secondOperand: nil, unaryFunction: nil, binaryFunction: nil, description: getDescription())
                memoryBrain.append(memoryData)
                
            case .equal:

                
                if userIsTypingM == false || memoryBrain[memoryBrain.endIndex-1].mButton == Constants.MemoryButton.atFirstOperand {
                    memoryBrain[memoryBrain.endIndex-1].secondOperand = accumlator!
                    memoryBrain[memoryBrain.endIndex-1].description = getDescription()
                }
                resultIsPending = false
                userIsTypingM = false

                performPendingBinaryOperation()

            }
        }

        
        print("----->\(memoryBrain)<-----")
    }
    
    mutating func setOperand(_ operand: Double) {
        accumlator = operand
        descriptionAccumlator = String(format: "%g", operand)
    }
    
    mutating func setOperand(variable named: String) {
        accumlator = memoryValue
        descriptionAccumlator = named
        userIsTypingM = true

        
        if pendingBinaryOperation != nil {
            memoryBrain[memoryBrain.endIndex-1].mButton = Constants.MemoryButton.atSecondOperand
            memoryBrain[memoryBrain.endIndex-1].secondOperand = accumlator!
            
        } else {
            let memoryData = MemoryCalculatorBrain(mButton: Constants.MemoryButton.atFirstOperand, firstOperand: nil, secondOperand: nil, unaryFunction: nil, binaryFunction: nil, description: getDescription())
            memoryBrain.append(memoryData)
        }
        
    }
    
    var result: Double? {
        get {
            return accumlator
        }
    }
    
    func getDescription() -> String? {
        if description != nil {
            if resultIsPending {
                return description! + "..."
            } else {
                return description! + "="
            }
        } else {
            return ""
        }
    }
    
    mutating func clear() {
        pendingBinaryOperation = nil
        accumlator = 0.0
        descriptionAccumlator = ""
        userIsTypingM = false
        memoryBrain.removeAll()
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var tempAccumlator = variables?["M"]
        
        var findMemoryButton = false
        //print("\(variables?["M"])")
        for memoryData in memoryBrain {
            if findMemoryButton {
                if memoryData.unaryFunction != nil {
                    tempAccumlator = memoryData.performUnaryFunction(with: tempAccumlator!)
                } else if memoryData.binaryFunction != nil {
                    tempAccumlator = memoryData.performBinaryFunction(with: tempAccumlator!, and: memoryData.secondOperand!)
                }
            }
            
            if memoryData.mButton != Constants.MemoryButton.didNotPress {
                findMemoryButton = true
                if memoryData.mButton == Constants.MemoryButton.atFirstOperand {
                    if memoryData.unaryFunction != nil {
                        tempAccumlator = memoryData.performUnaryFunction(with: tempAccumlator!)
                    } else if memoryData.binaryFunction != nil {
                        tempAccumlator = memoryData.performBinaryFunction(with: tempAccumlator!, and: memoryData.secondOperand!)
                    }
                } else if memoryData.mButton == Constants.MemoryButton.atSecondOperand {
                    tempAccumlator = memoryData.performBinaryFunction(with: memoryData.firstOperand!, and: tempAccumlator!)
                }
            }
        }
        return (tempAccumlator, resultIsPending, getDescription()!)
    }
    
    mutating func undo() -> (result:Double?, description: String){
        if !memoryBrain.isEmpty {
            if memoryBrain.endIndex == 1 {
                let tempResult = memoryBrain[memoryBrain.endIndex-1].firstOperand
                memoryBrain.remove(at: memoryBrain.endIndex-1)
                return (tempResult, " ")
            } else {
                memoryBrain.remove(at: memoryBrain.endIndex-1)
                if memoryBrain[memoryBrain.endIndex-1].binaryFunction != nil {
                    return (memoryBrain[memoryBrain.endIndex-1].performBinaryFunction(with: memoryBrain[memoryBrain.endIndex-1].firstOperand!, and: memoryBrain[memoryBrain.endIndex-1].secondOperand!), memoryBrain[memoryBrain.endIndex-1].description!)
                } else {
                    return (memoryBrain[memoryBrain.endIndex-1].firstOperand, memoryBrain[memoryBrain.endIndex-1].description!)
                }
            }

        }

        return (accumlator!, getDescription()!)
    }
    
}
