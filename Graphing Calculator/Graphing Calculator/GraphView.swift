//
//  GraphView.swift
//  Graphing Calculator
//
//  Created by JHLin on 2017/3/15.
//  Copyright © 2017年 JHL. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var origin: CGPoint! { didSet { setNeedsDisplay() } }

    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale = CGFloat(Constants.Drawing.pointsPerUnit) { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var color: UIColor = UIColor.red { didSet { setNeedsDisplay() } }
    
    var function: ((Double) -> CGFloat)? { didSet { setNeedsDisplay() } }
    
    private var axesHelper = AxesDrawer()
    
    private func pathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        var point = CGPoint()
        var pathIsEmpty = true
        
        let width = Int(bounds.size.width)
        for pixel in 0...width {
            point.x = CGFloat(pixel)
            
            
            let drawFunction = function ?? { x in 0.0 }

            let y = drawFunction(Double((CGFloat(pixel) - origin.x)/scale))
            if !y.isNormal && !y.isZero {
                pathIsEmpty = true
                continue
            }
            
            point.y = origin.y - y*scale

            if pathIsEmpty {
                path.move(to: point)
                pathIsEmpty = false
            } else {
                path.addLine(to: point)
            }
            
        }
        
        path.lineWidth = lineWidth
        return path
    }

    override func draw(_ rect: CGRect) {
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        color.set()
        axesHelper.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        pathForFunction().stroke()
    }
    
    
    func zoom(byReactingTo pinchRecognizer: UIPinchGestureRecognizer)
    {
        switch pinchRecognizer.state {
        case .changed,.ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    func move(byReactingTo panRecognizer: UIPanGestureRecognizer)
    {
        switch panRecognizer.state {
        case .changed,.ended:
            let translation = panRecognizer.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        default: break
        }
    }
    
    func doubleTap(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            origin = tapRecognizer.location(in: self)
        }
    }
    
}
