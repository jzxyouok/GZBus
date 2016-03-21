//
//  MainViewController.swift
//  GZBus
//
//  Created by NendorS on 3/5/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var mainTableView: UITableView!
    
    private var http = HTTPUtils()
    private var busList = Bus().busList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UISetting()
        http.delegate = self
    }
    
    func UISetting() {
        self.title = "巴士来嘅"
        indicatorView.hidden = true
        busList = []
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "NavigationBarBackground"), forBarPosition: .Any, barMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinåationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetailSegue" {
            let vc = segue.destinationViewController as! DetailViewController
            vc.route = sender as! String
        }
    }
    
    func startAnimating() {
        indicatorView.hidden = false
        indicatorView.startAnimating()
    }
    
    func stopAnimating() {
        indicatorView.stopAnimating()
        indicatorView.hidden = true
    }
    
    func alert(title: String, message: String?, handle:  ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: handle)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        getData(searchBar.text!)
        searchBar.resignFirstResponder()
        startAnimating()
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard text != " " else {
            return false
        }
        return true
    }
    
    func getData(route: String) {
        let parameters: [String: AnyObject] = [
            "oper":"fuzzy",
            "route": route
        ]
        http.get(parameters)
    }

}

extension MainViewController: HTTPDelegate {
    func didReceiveError(error: NSError) {
        stopAnimating()
        alert("网络连接错误", message: error.localizedDescription, handle: nil)
    }
    
    func didReceiveResult(result: NSData) {
        stopAnimating()
        let json = JSON(data: result)
        
        guard searchBar.text != "" else {
            alert("缺少查找关键字", message: nil, handle: nil)
            return
        }
        
        guard json["c"].int == 0 else {
            let title = json["err"]["msg"].stringValue
            alert(title, message: nil, handle: nil)
            return
        }
        
        busList = json["d"]["result"].stringValue.characters.split(",").map(String.init)
        self.mainTableView.reloadData()
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("busCell", forIndexPath: indexPath) as! BusCell
        cell.busLabel.text = busList[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("showDetailSegue", sender: busList[indexPath.row])

    }
}

class BusCell: UITableViewCell {
    @IBOutlet weak var busLabel: UILabel!
}
