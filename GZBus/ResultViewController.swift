//
//  ResultViewController.swift
//  GZBus
//
//  Created by NendorS on 3/5/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import UIKit
import SwiftyJSON

class ResultViewController: UIViewController {
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var searchBus: String!
    
    private var result = [String]()
    private let images = [
        UIImage(named: "bus")?.tint(UIColor(Hex: ColorUtil.distance[0]), blendMode: .DestinationIn),
        UIImage(named: "bus")?.tint(UIColor(Hex: ColorUtil.distance[1]), blendMode: .DestinationIn),
        UIImage(named: "bus")?.tint(UIColor(Hex: ColorUtil.distance[2]), blendMode: .DestinationIn),
        UIImage(named: "bus")?.tint(UIColor(Hex: ColorUtil.distance[3]), blendMode: .DestinationIn),
        UIImage(named: "bus")?.tint(UIColor(Hex: ColorUtil.distance[4]), blendMode: .DestinationIn),
    ]

    private let refreshControl = UIRefreshControl()
    private let http = HTTPUtils()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "查询结果如下"
        self.activityIndicator.startAnimating()
        http.delegate = self

        getData()
        setPullToRefresh()
    }
    
    func getData() {
        let parameters: [String: AnyObject] = [
            "oper":"fuzzy",
            "route": searchBus
        ]
        http.get(parameters)
    }
    
    func setPullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.resultTable.addSubview(self.refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        self.refreshControl.endRefreshing()
        getData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinåationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detail" {
            let vc = segue.destinationViewController as! DetailViewController
            vc.route = sender as! String
        }
    }
        
}

extension ResultViewController: HTTPDelegate {
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
        
        guard searchBus != "" else {
            alert("缺少查找关键字", message: nil, handle: back)
            return
        }
        
        guard json["c"].int == 0 else {
            let title = json["err"]["msg"].stringValue
            alert(title, message: nil, handle: back)
            return
        }
        
        self.result = json["d"]["result"].stringValue.characters.split(",").map(String.init)
        self.resultTable.reloadData()
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

extension ResultViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as! ResultTableViewCell
        cell.busImage.image = images[indexPath.row % 5]
        cell.busLabel.text = result[indexPath.row]
        cell.busLabel.textColor = UIColor(Hex: ColorUtil.station)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("detail", sender: result[indexPath.row])
    }
    
}

class ResultTableViewCell: UITableViewCell {
    @IBOutlet weak var busImage: UIImageView!
    @IBOutlet weak var busLabel: UILabel!
}