//
//  MainViewController.swift
//  GZBus
//
//  Created by NendorS on 3/5/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.searchTextField.backgroundColor = UIColor(Hex: ColorUtil.navigationBar)
        self.searchTextField.textColor = UIColor.whiteColor()
                
        let placeholder = NSAttributedString(string: "输入查询的线路", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.searchTextField.attributedPlaceholder = placeholder
        self.searchTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "search" {
            let vc = segue.destinationViewController as! ResultViewController
            vc.searchBus = searchTextField.text
        }
    }
    
    @IBAction func back(segue:UIStoryboardSegue) {
    }
    
    // MARK: - Action
    @IBAction func onSearchClick(sender: AnyObject) {
        self.performSegueWithIdentifier("search", sender: nil)
    }

}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTage = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
            self.performSegueWithIdentifier("search", sender: nil)
        }
        return false
    }
}

