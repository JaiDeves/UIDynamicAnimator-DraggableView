//
//  DraggableView.swift
//  UIDynamicAnimator-DraggableView
//
//  Created by Jai on 13/04/22.
//

import UIKit

enum ViewPosition:String {
    case none
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}


class DraggableView: UIView{
    private var animator: UIDynamicAnimator?
    private var snapBehaviour: UISnapBehavior?
    private var position:ViewPosition = .bottomLeft
    private var padding:UIEdgeInsets = .zero
    private var superViewSize:CGSize = .zero
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        initialise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialise()
    }
    override func layoutSubviews() {
        if superViewSize != self.superview?.bounds.size{
            self.superViewSize = self.superview?.bounds.size ?? .zero
            
            configureDynamics(position: position, padding: padding)
        }
    }
    
    override func didMoveToSuperview(){
        superViewSize = self.superview?.bounds.size ?? .zero
        self.center = getOriginFrom(position: position, padding: padding)
        configureDynamics(position: position, padding: padding)
    }
    
    func set(position:ViewPosition, padding:UIEdgeInsets){
        self.position = position
        self.padding = padding
        configureDynamics(position: position, padding: padding)
    }
    
    private func initialise(){
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(viewDragged(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    
    private func getOriginFrom(position:ViewPosition,padding:UIEdgeInsets)->CGPoint{
        guard let superView = self.superview else { return .zero }
        var snapLocation: CGPoint = .zero
        
        switch position {
        case .topLeft:
            snapLocation = CGPoint(x: padding.left + self.bounds.width / 2,
                                   y: padding.top + self.bounds.height / 2)
        case .topRight:
            snapLocation = CGPoint(x: superView.bounds.maxX -
                                   self.bounds.width / 2 - padding.right,
                                   y: padding.top + self.bounds.height / 2)
        case .bottomLeft:
            snapLocation = CGPoint(x: padding.left + self.bounds.width / 2,
                                   y: superView.bounds.maxY -
                                   self.bounds.height / 2 - padding.bottom)
        case .bottomRight:
            snapLocation = CGPoint(x: superView.bounds.maxX -
                                   self.bounds.width / 2 - padding.right,
                                   y: superView.bounds.maxY -
                                   self.bounds.height / 2 - padding.bottom)
        default:
            break
        }
        return snapLocation
    }
    
    private func configureDynamics(position:ViewPosition, padding:UIEdgeInsets) {
        guard let superView = self.superview else { return }
        animator = UIDynamicAnimator(referenceView: superView)
        
        let snapLocation = getOriginFrom(position:position,padding: padding)
        addSnapBehaviour(location: snapLocation)
     }
    
    private func addSnapBehaviour(location:CGPoint){
        if let snapBehaviour = self.snapBehaviour{
            animator?.removeBehavior(snapBehaviour)
        }
        
        snapBehaviour = UISnapBehavior(item: self, snapTo: location)
        snapBehaviour?.damping = 1
        animator?.addBehavior(snapBehaviour!)
    }
    
   @objc func viewDragged(_ gesture:UIPanGestureRecognizer){
       let draggedView = self
        guard let superView = draggedView.superview,
              let animator = self.animator
              else { return }
              
        var location: CGPoint = gesture.location(in: superView)
        switch gesture.state{
        case .began:
            if let snapBehaviour = self.snapBehaviour{
                animator.removeBehavior(snapBehaviour)
            }
        case .changed:
            let translation = gesture.translation(in: superView)
            draggedView.center = CGPoint(x: draggedView.center.x + translation.x,
                                         y: draggedView.center.y + translation.y)
            gesture.setTranslation(.zero, in: self)

        case .ended, .cancelled, .failed:
            
            if location.x > superView.bounds.width / 2  {
                if location.y > superView.bounds.height / 2{
                    location = getOriginFrom(position: .bottomRight, padding: self.padding)
                }else{
                    location = getOriginFrom(position: .topRight, padding: self.padding)
                }
            }else{
                if location.y > superView.bounds.height / 2{
                    location = getOriginFrom(position: .bottomLeft, padding: self.padding)
                }else{
                    location = getOriginFrom(position: .topLeft, padding: self.padding)
                }
            }
            
            self.addSnapBehaviour(location: location)
        case .possible:
            break
        @unknown default:
            break
        }
    }
}
