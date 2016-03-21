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
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var stationTableView: UITableView!
    
    private var stationList = Station().stationList
    private var locationList = Station().flagSubway

    var route: String!
    private let http = HTTPUtils()
    private let refreshControl = UIRefreshControl()
    private var dir: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UISetting()
        
        http.delegate = self
        getData()
    }
    
    func UISetting() {
        self.title = route
        stationList = []
        locationList = []
        setPullToRefresh()
        self.automaticallyAdjustsScrollViewInsets = false
    }

    @IBAction func onChangeDirClick(sender: AnyObject) {
        dir = (dir == 0) ? 1 : 0
        getData()
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
        startAnimating()
        let parameters: [String: AnyObject] = [
            "oper":"detail",
            "route": route,
            "dir": dir
        ]
        http.get(parameters)
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

extension DetailViewController: HTTPDelegate {
    func didReceiveError(error: NSError) {
        alert("网络连接错误", message: error.localizedDescription, handle: nil)
    }
    
    func didReceiveResult(result: NSData) {
        let json = JSON(data: result)
        
        guard route != "" else {
            alert("缺少查找关键字", message: nil, handle: nil)
            return
        }
        
        guard json["c"].int == 0 else {
            let title = json["err"]["msg"].stringValue
            alert(title, message: nil, handle: nil)
            return
        }
        
        stationList = json["d"]["busLine"]["stationNames"].stringValue.characters.split(",").map(String.init)
        locationList = json["d"]["busLine"]["flagSubway"].stringValue.characters.split(",").map(String.init)
        stopAnimating()
        self.stationTableView.reloadData()
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stationCell", forIndexPath: indexPath) as! StationCell
        cell.stationLabel.text = stationList[indexPath.row]
        if locationList[indexPath.row] == "1" {
            cell.locationLabel.hidden = false
        }
        return cell
    }
}

class StationCell: UITableViewCell {
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

}