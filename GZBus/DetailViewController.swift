//
//  DetailViewController.swift
//  GZBus
//
//  Created by NendorS on 3/5/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper


class DetailViewController: UIViewController {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var stationTableView: UITableView!
    

    var route: String!
    private let http = HTTPUtils()
    private let refreshControl = UIRefreshControl()
    
    private var dir: Int = 0
    private var stationList: [String]!
    private var locationList: [Int]!
    private var startStation: String!
    private var endStation: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UISetting()
        
        http.delegate = self
        getData()
    }
    
    func UISetting() {
        stationList = []
        locationList = []
        setPullToRefresh()
        self.automaticallyAdjustsScrollViewInsets = false
        stationTableView.hidden = true
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
        self.refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        self.stationTableView.addSubview(self.refreshControl)
    }

    func refresh() {
        stationList.removeAll()
        locationList.removeAll()
        stationTableView.reloadData()
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
        stopAnimating()
    }

}

extension DetailViewController: HTTPDelegate {
    func didReceiveError(error: NSError) {
        alert("网络连接错误", message: error.localizedDescription, handle: nil)
    }
    
    func didReceiveResult(result: NSData) {
        stopAnimating()

        let json = JSON(data: result)
        let jsonString = String(json)
        
        if let station = Mapper<Station>().map(jsonString) {
            
            guard station.code == 0 else {
                let title = station.errorMessage!
                alert(title, message: nil, handle: nil)
                return
            }
            stationList = station.stationName!.characters.split(",").map(String.init)
            startStation = station.startPlatName
            endStation = station.endPlatName
            if let busLocation = station.busLocation {
                for one in busLocation {
//                    print(one["stationSeq"])
                    locationList.append(one["stationSeq"]!)
                }
            }
        }
        
        self.stationTableView.hidden = false
        self.stationTableView.reloadData()
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return stationList.count
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("mapCell", forIndexPath: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("busInfoCell", forIndexPath: indexPath) as! BusInfoCell
            cell.startLabel.text = startStation
            cell.endLabel.text = endStation
            cell.busLabel.text = route
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("stationCell", forIndexPath: indexPath) as! StationCell
            cell.stationLabel.text = stationList[indexPath.row]
            if locationList.contains(indexPath.row) {
                cell.locationLabel.hidden = false
            }
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 300
        case 1:
            return 120
        case 2:
            return 60
        default:
            return 0
        }
    }
}

class BusInfoCell: UITableViewCell {
    @IBOutlet weak var busLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
}

class StationCell: UITableViewCell {
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
}
