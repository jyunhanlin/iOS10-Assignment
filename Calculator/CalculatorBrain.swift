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
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumlator != nil {
            accumlator = pendingBinaryOperation!.perform(with: accumlator!)
            descriptionAccumlator = pendingBinaryOperation!.performDescription(with: descriptionAccumlator!)
            pendingBinaryOperation = nil
        }
    }
    

    mutating func performOperation(_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumlator = value
                descriptionAccumlator = symbol
            case .unaryOperation(let function, let descriptionFunction):
                if accumlator != nil {
                    accumlator = function(accumlator!)
                    descriptionAccumlator = descriptionFunction(descriptionAccumlator!)
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
                    
                }
            case .randomOperation :
                descriptionAccumlator = "random"
                accumlator = Double(Float(arc4random()) / Float(UInt32.max))
            case .equal:
                resultIsPending = false
                performPendingBinaryOperation()
            }
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumlator = operand
        descriptionAccumlator = String(format: "%g", operand)
    }
    
    var result: Double? {
        get {
            return accumlator
        }
    }
    
    func getDescription() -> String? {
        if resultIsPending {
            return description! + "..."
        } else {
            return description! + "="
        }
  
    }
    
    mutating func clear() {
        pendingBinaryOperation = nil
        accumlator = 0.0
        descriptionAccumlator = ""
    }
    
    
}
