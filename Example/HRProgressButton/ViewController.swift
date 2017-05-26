//
//  ViewController.swift
//  HRProgressButton
//
//  Created by ryota hayashi on 05/24/2017.
//  Copyright (c) 2017 ryota hayashi. All rights reserved.
//

import UIKit
import HRProgressButton

extension HRTextStyle {
    static var buttonText: HRTextStyle {
        return HRTextStyle(size: 15, color: .white, textAlignment: .center, weight: .Thin)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var button: HRProgressButton!
    @IBOutlet weak var styleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.addTarget(self, action: #selector(self.handleButtonAction), for: .touchUpInside)
        let title = NSAttributedString(string: "Create Account", style: .buttonText)
        button.setAttributedTitle(title, for: .normal)
        styleSwitch.addTarget(self, action: #selector(self.handleDisableSwitchAction), for: .valueChanged)
        styleSwitch.onTintColor = button.defaultStyle.normalColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleButtonAction() {
        
        guard !button.isLoading else { return }
        
        if styleSwitch.isOn {
            
            button.isLoading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.button.isLoading = false
            }
            
        } else {
            let progress = Progress(totalUnitCount: 5)
            button.setIsLoading(with: progress)
            
            (1...5).forEach({ (i) in
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) { _ in
                    progress.completedUnitCount = i
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] _ in
                self?.button.isLoading = false
            }
        }
    }
    
    func handleDisableSwitchAction() {
        if styleSwitch.isOn {
            let title = NSAttributedString(string: "Create Account", style: .buttonText)
            button.setAttributedTitle(title, for: .normal)
        } else {
            let title = NSAttributedString(string: "Download", style: .buttonText)
            button.setAttributedTitle(title, for: .normal)
        }
    }


}

