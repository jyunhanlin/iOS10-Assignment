//
//  GraphViewController.swift
//  Graphing Calculator
//
//  Created by JHLin on 2017/3/15.
//  Copyright © 2017年 JHL. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.zoom(byReactingTo:))))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.move(byReactingTo:))))
            
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.doubleTap(byReactingTo:)))
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
            
            updateUI()
        }
    }
    
    var function: ((Double) -> CGFloat)?
    
    private func updateUI() {
        graphView?.function = function
    }
}
