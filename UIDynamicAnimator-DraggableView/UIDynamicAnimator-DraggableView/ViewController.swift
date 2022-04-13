//
//  ViewController.swift
//  UIDynamicAnimator-DraggableView
//
//  Created by Jai on 13/04/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    func setUpView(){
        let draggableView = DraggableView()
        draggableView.backgroundColor = .green
        draggableView.frame.size = CGSize(width: 120, height: 240)
        self.view.addSubview(draggableView)
        
        let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        draggableView.set(position: .bottomLeft, padding: padding)
    }
}

