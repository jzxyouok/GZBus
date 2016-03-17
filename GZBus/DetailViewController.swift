//
//  DetailViewController.swift
//  GZBus
//
//  Created by NendorS on 3/5/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stationTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var busStation = [String]()
    private var busLocation = [Int: Bool]()
    
    var route: String!
    private let http = HTTPUtils()
    private let refreshControl = UIRefreshControl()
    private var dir: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = route
        self.segmentedControl.tintColor = UIColor(Hex: ColorUtil.navigationBar)
        self.segmentedControl.setTitle("上行", forSegmentAtIndex: 0)
        self.segmentedControl.setTitle("下行", forSegmentAtIndex: 1)

        
        http.delegate = self
        getData()
    }
    
    @IBAction func changeDir(sender: AnyObject) {
        let segmentControl = sender as! UISegmentedControl
        switch segmentControl.selectedSegmentIndex {
        case 0:
            dir = 0
            getData()
            return
        case 1:
            dir = 1
            getData()
            return
        default: break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.stationTableView.addSubview(self.refreshControl)
    }

    func refresh() {
        getData()
        self.refreshControl.endRefreshing()
    }
    
    func getData() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()

        let parameters: [String: AnyObject] = [
            "oper":"detail",
            "route": route,
            "dir": dir
        ]
        http.get(parameters)
    }

}

extension DetailViewController: HTTPDelegate {
    func didReceiveError(error: NSError) {
        stopAnimating()
        alert("网络连接错误", message: error.localizedDescription, handle: nil)
    }
    
    func didReceiveResult(result: NSData) {
        stopAnimating()
        let json = JSON(data: result)
        let back: (UIAlertAction) -> Void = { _ in
            self.performSegueWithIdentifier("backToMain", sender: nil)
        }
        
        guard route != "" else {
            alert("缺少查找关键字", message: nil, handle: back)
            return
        }
        
        guard json["c"].int == 0 else {
            let title = json["err"]["msg"].stringValue
            alert(title, message: nil, handle: back)
            return
        }
        self.busStation = json["d"]["busLine"]["stationNames"].stringValue.characters.split(",").map(String.init)
        print(json["d"]["busTerminal"])
        self.stationTableView.reloadData()
    }
    
    func alert(title: String, message: String?, handle:  ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: handle)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }

}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busStation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stationCell", forIndexPath: indexPath) as! StationCell
        cell.stationLabel.text = busStation[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}

class StationCell: UITableViewCell {
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var busImage: UIImageView!
    
    override func awakeFromNib() {
        self.stationLabel.textColor = UIColor(Hex: ColorUtil.station)
    }
}