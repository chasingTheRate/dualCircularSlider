//
//  dualSlider.swift
//  customSlider
//
//  Created by ChasingTheRate on 2/19/16.
//  Copyright © 2016. All rights reserved.


import UIKit

class DualSlider: UIControl{
    
    
    //MARK: Class Declarations
    
    let trackLayer = DualSliderTrackLayer()
    let lowerThumb = DualSliderThumb()
    let upperThumb = DualSliderThumb()
    
    //Super, Shadow views required to add shadow effect to thumb views.
    
    private let upperSuperview = UIView()
    private let lowerSuperview = UIView()
    
    private let upperShadowView = UIView()
    private let lowerShadowView = UIView()
    
    //MARK: Slider Variables
    
    var titleLabel = UILabel()
    
    var title: String?{
        didSet{
            updateUI()
        }
    }
    
    var minimumValue: Double = 0.0 {
        didSet {
            updateUI()
        }
    }
    
    var maximumValue: Double = 100.0 {
        didSet {
            updateUI()
        }
    }
    
    //MARK: Thumb Variables
    
    var thumbWidth: CGFloat = 30.0{
        didSet {
            upperThumb.setNeedsDisplay()
            lowerThumb.setNeedsDisplay()
        }
    }
    
    var thumbTintColor: UIColor = UIColor.blackColor() {
        didSet {
            upperThumb.setNeedsDisplay()
            lowerThumb.setNeedsDisplay()
        }
    }
    
    var thumbBackgroundColor: UIColor = UIColor.whiteColor(){
        didSet {
            upperThumb.setNeedsDisplay()
            lowerThumb.setNeedsDisplay()
        }
    }
    
    var thumbBorderWidth: CGFloat = 0.5{
        didSet{
            upperThumb.setNeedsDisplay()
            lowerThumb.setNeedsDisplay()
        }
    }
    
    var thumbBorderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).CGColor{
        didSet{
            lowerThumb.setNeedsDisplay()
            upperThumb.setNeedsDisplay()
        }
    }
    
    var thumbShadowColor: UIColor = UIColor.lightGrayColor(){
        didSet{
            updateUI()
        }
    }
    
    var thumbShadowOffsetMultiplier: CGFloat = 2.0{
        didSet{
           updateUI()
        }
    }
    var thumbShadowOffset: CGSize = CGSize(width: 0, height: 0){
        didSet{
            updateUI()
        }
    }
    
    var thumbShadowOpacity: Float = 0.5{
        didSet{
            updateUI()
        }
    }
    
    var thumbShadowRadius: CGFloat = 3.0{
        didSet{
            updateUI()
        }
    }
    
    //MARK: Thumb Location Variables
    
    var lowerAngle: Double = 270{
        didSet{
            updateUI()
        }
    }
    
    var upperAngle: Double = 335{
        didSet{
            updateUI()
        }
    }
    
    var outputToAngleRatio: Double = 3.6{
        didSet{
            updateUI()
        }
    }
    
    private var lowerThumbRevolutions: Double = 0
    private var upperThumbRevolutions: Double = 0
    
    //MARK: Thumb Tracking Variables
    
    private var lastLowerPoint = CGPoint()
    private var lastUpperPoint = CGPoint()
    private var thumbIsMoving = false
    private var movingThumbTag: Int = 0
    
    //MARK: Track Variables
    
    var trackWidth: CGFloat = 2.0{
        didSet{
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackRadius: CGFloat = 50.0{
        didSet{
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    //MARK: Gestures
    
    var tap: UITapGestureRecognizer?
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Add Track
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        //Add Title
        addSubview(titleLabel)
        titleLabel.textAlignment = .Center
        
        //Add Thumbs

        upperShadowView.addSubview(upperThumb)
        upperSuperview.addSubview(upperShadowView)
        addSubview(upperSuperview)

        lowerShadowView.addSubview(lowerThumb)
        lowerSuperview.addSubview(lowerShadowView)
        addSubview(lowerSuperview)
        
        upperSuperview.userInteractionEnabled = false
        upperShadowView.userInteractionEnabled = false
        lowerSuperview.userInteractionEnabled = false
        lowerShadowView.userInteractionEnabled = false
        
        upperThumb.tag = 1
        lowerThumb.tag = 0
        
        //Gestures
        
        tap = UITapGestureRecognizer(target: self, action: "thumbTapped:")
        tap?.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Update UI
    
    func updateUI() {
    
        //Update Title
        
        titleLabel.frame = bounds
        titleLabel.font = UIFont(name: titleLabel.font!.fontName, size: 30.0)
     
        if thumbIsMoving{
            
            if lowerThumb.highlighted{
                titleLabel.text = Int(self.lowerAngle/outputToAngleRatio).description
            }else if upperThumb.highlighted{
                titleLabel.text = Int(self.upperAngle/outputToAngleRatio).description
            }
            
        }else{
            if let string = title{
                titleLabel.text = string
            }else{
                titleLabel.text = nil
            }
        }
        
        //Update Track
        
        trackLayer.dualSlider = self
        trackLayer.frame = bounds
        trackLayer.setNeedsDisplay()
        
        //Upper Thumb
    
        upperSuperview.frame = CGRect(origin: getPointFromAngle(upperAngle), size: CGSize(width: thumbWidth, height: thumbWidth))
        
        upperShadowView.frame = upperSuperview.bounds
        upperShadowView.layer.shadowColor = thumbShadowColor.CGColor
        upperShadowView.layer.shadowOffset = CGSize(width: thumbShadowOffsetMultiplier * cos(convertDegToRadians(upperAngle)), height: thumbShadowOffsetMultiplier * sin(convertDegToRadians(upperAngle)))
        upperShadowView.layer.shadowOpacity = thumbShadowOpacity
        upperShadowView.layer.shadowRadius = thumbShadowRadius
        
        upperThumb.frame = upperSuperview.bounds
        upperThumb.dualSlider = self
        upperThumb.backgroundColor = thumbBackgroundColor
        upperThumb.label.text = Int(self.upperAngle/outputToAngleRatio).description
        
        //Lower Thumb
        
        lowerSuperview.frame = CGRect(origin: getPointFromAngle(lowerAngle), size: CGSize(width: thumbWidth, height: thumbWidth))
        lowerShadowView.frame = lowerSuperview.bounds
        
        lowerShadowView.layer.shadowColor = thumbShadowColor.CGColor
        lowerShadowView.layer.shadowOffset = CGSize(width: thumbShadowOffsetMultiplier * cos(convertDegToRadians(lowerAngle)), height: thumbShadowOffsetMultiplier * sin(convertDegToRadians(lowerAngle)))
        lowerShadowView.layer.shadowOpacity = thumbShadowOpacity
        lowerShadowView.layer.shadowRadius = thumbShadowRadius
        
        lowerThumb.dualSlider = self
        lowerThumb.frame = lowerSuperview.bounds
        lowerThumb.backgroundColor = thumbBackgroundColor
        lowerThumb.label.text = Int(self.lowerAngle/outputToAngleRatio).description
    }
    

    //MARK: Track Thumb Movements Functions
    
    func getPointFromAngle(angleInt:Double)->CGPoint{
        
        //Circle center
        let centerPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        
        //Point Location on track circumference
        var point = CGPointZero
        let y = sin(Double(convertDegToRadians(angleInt))) * Double(self.trackRadius) + Double(centerPoint.x)
        let x = cos(Double(convertDegToRadians(angleInt))) * Double(self.trackRadius) + Double(centerPoint.y)
        
        point.y = CGFloat(y-Double(self.thumbWidth/2))
        point.x = CGFloat(x-Double(self.thumbWidth/2))
        
        return point;
    }
    
    private func moveThumb(previousLocation: CGPoint, tag: Int){
    
        var revolutions: Double
        var lastAngle: Double
        
        //Get the center
        let centerPoint:CGPoint  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        //Calculate the direction from a center point and a arbitrary position.
        let currentAngle:Double = AngleFromNorth(centerPoint, p2: previousLocation)
        
        if tag == 0{
            revolutions = lowerThumbRevolutions
            lastAngle = lowerAngle
        }else{
            revolutions = upperThumbRevolutions
            lastAngle = upperAngle
        }
        
        if revolutions == 0{
            
            if currentAngle - lastAngle > 180{
                lastAngle = 0
            }else if lastAngle - currentAngle > 180{
                revolutions += 1
                lastAngle = 360 + floor(currentAngle)
            }else{
                lastAngle = floor(currentAngle)
            }
            
        }else{
            
            if (currentAngle + (360 * revolutions) - lastAngle) > 300{
                
                lastAngle = lastAngle - (360-floor(currentAngle))
                revolutions -= 1
            
            }else if lastAngle - (currentAngle + Double(360 * revolutions)) > 300{
                lastAngle = lastAngle + floor(currentAngle)
                revolutions += 1
            }else{
                lastAngle = Double(360 * revolutions) + floor(currentAngle)
            }
        }
        if tag==0{
            lowerThumbRevolutions = revolutions
            if lastAngle <= upperAngle{
                lowerAngle = lastAngle
            }else{
                lowerAngle = upperAngle
            }
        }else{
            upperThumbRevolutions = revolutions
            if lastAngle >= lowerAngle{
                 upperAngle = lastAngle
            }else{
                upperAngle = lowerAngle
            }
        }
    }
    
    //From Apple - Clock Control
    
    private func AngleFromNorth(p1:CGPoint , p2:CGPoint) -> Double {
        
        var v:CGPoint  = CGPointMake(p2.x - p1.x, p2.y - p1.y)
        let vmag:CGFloat = square(square(v.x) + square(v.y))
        var result:Double = 0.0
        v.x /= vmag;
        v.y /= vmag;
        let radians = Double(atan2(v.y,v.x))
        result = Double(convertRadianToDeg(radians))
        return (result >= 0  ? result : result + 360.0);
    }
    
    func square(sender: CGFloat) -> CGFloat{
        return sender * sender
    }


    override var frame: CGRect {
        didSet {
            updateUI()
        }
    }
    
    //MARK: Touch Tracking Overrides
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        let touchPoint = touch.locationInView(self)
        
        var animateLabel = UILabel()
        
        if lowerAngle < 10.0{
            
            // Hit test the thumb layers
            if upperSuperview.frame.contains(touchPoint) && upperThumb.locked == false{
                lastUpperPoint = touchPoint
                upperThumb.highlighted = true
                thumbIsMoving = true
                animateLabel = self.upperThumb.label
            }else if lowerSuperview.frame.contains(touchPoint) && lowerThumb.locked == false{
                lastLowerPoint = touchPoint
                lowerThumb.highlighted = true
                thumbIsMoving = true
                animateLabel = self.lowerThumb.label
            }
            
        }else{
            
            // Hit test the thumb layers
            if lowerSuperview.frame.contains(touchPoint) && lowerThumb.locked == false{
                lastLowerPoint = touchPoint
                lowerThumb.highlighted = true
                thumbIsMoving = true
                animateLabel = self.lowerThumb.label
            }else if upperSuperview.frame.contains(touchPoint) && upperThumb.locked == false{
                lastUpperPoint = touchPoint
                upperThumb.highlighted = true
                thumbIsMoving = true
                animateLabel = self.upperThumb.label
            }
        }
        
        
        UIView.animateWithDuration(0.10, animations: {
                animateLabel.alpha = 0.0
        })
    
        return lowerThumb.highlighted || upperThumb.highlighted

    }
    

    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        if lowerThumb.highlighted {
            lastLowerPoint = location
            self.moveThumb(lastLowerPoint, tag: lowerThumb.tag)
        }else if upperThumb.highlighted{
            lastUpperPoint = location
            self.moveThumb(lastUpperPoint, tag: upperThumb.tag)
        }
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
    
        var animateLabel = UILabel()
        
        if lowerThumb.highlighted{
            animateLabel = self.lowerThumb.label
            lowerThumb.highlighted = false
        }else if upperThumb.highlighted{
            animateLabel = self.upperThumb.label
            upperThumb.highlighted = false
        }

        UIView.animateWithDuration(0.10, animations: {
            if touch != nil{
                self.titleLabel.alpha = 0.0
            }
            self.thumbIsMoving = false
            }, completion: {finished in
                
                UIView.animateWithDuration(0.25, animations: {
                    self.updateUI()
                    self.titleLabel.alpha = 1.0
                    }, completion: {finished in
                        UIView.animateWithDuration(0.10, animations: {
                            animateLabel.alpha = 0.75
                            }, completion: nil)})
        })
    }
    
    //MARK: Gesture Functions
    
    func thumbTapped(tap: UITapGestureRecognizer){
        
        var thumb: DualSliderThumb?
        
        switch tap.state{
            
        case .Ended:
            
            let touchPoint = tap.locationInView(self)
            
            if lowerSuperview.frame.contains(touchPoint){
                thumb = lowerThumb
            }else if upperSuperview.frame.contains(touchPoint){
                thumb = upperThumb
            }
            
            if thumb!.locked{
                thumb!.locked = false
            }else{
                thumb!
                    .locked = true
            }
            
            endTrackingWithTouch(nil, withEvent: nil)
            
        default:
            break
        }
        
    }
    
    //MARK: Conversions
    
    private func convertDegToRadians(degrees: Double) -> CGFloat{
        
        return CGFloat(degrees * (M_PI/180))
    }
    
    private func convertRadianToDeg(radians: Double) -> CGFloat{
        
        return CGFloat((radians * 180)/M_PI)
    }

}

class DualSliderThumb: UIView{
    
    var locked = false {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var highlighted = false
    var dualSlider: DualSlider?
    var label = UILabel()
    var tap: UITapGestureRecognizer?
  
    override func drawRect(rect: CGRect) {
        
        userInteractionEnabled = true
        addSubview(label)
    
        if let slider = dualSlider{
        
            layer.borderColor = slider.thumbBorderColor
            layer.borderWidth = slider.thumbBorderWidth
            layer.cornerRadius = layer.bounds.width/2
            layer.masksToBounds = true
        
            label.frame = bounds
    
            if locked{
                label.textColor = UIColor.lightGrayColor()
            }else{
                label.textColor = slider.thumbTintColor
            }
            
            label.textAlignment = .Center
            label.font = UIFont(name: label.font!.fontName, size: 10.0)
            label.tag = tag
            label.alpha = 0.75
        }
    }
}


class DualSliderTrackLayer: CALayer {
    
    weak var dualSlider: DualSlider?
    
    override func drawInContext(ctx: CGContext) {
        
        if let slider = dualSlider {
        
            let center =  CGPoint(x: bounds.width/2, y: bounds.height/2)
            let radius: CGFloat = slider.trackRadius
            let startAngle = convertDegToRadians(0)
            let endAngle = convertDegToRadians(360)
            let startAngle2 = convertDegToRadians(slider.lowerAngle)
            let endAngle2 = convertDegToRadians(slider.upperAngle)
            
            CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, 1)
            CGContextSetStrokeColorWithColor(ctx, UIColor.lightGrayColor().CGColor)
            CGContextSetLineWidth(ctx, slider.trackWidth)
            CGContextStrokePath(ctx)
            
            CGContextAddArc(ctx, center.x, center.y, radius, startAngle2, endAngle2, 0)
            CGContextSetStrokeColorWithColor(ctx, slider.trackHighlightTintColor.CGColor)
            CGContextSetLineWidth(ctx, slider.trackWidth)
            CGContextStrokePath(ctx)
        }
    }
    
    //MARK: Conversions
    
    private func convertDegToRadians(degrees: Double) -> CGFloat{
        return CGFloat(degrees * (M_PI/180))
    }
}
