//
//  ViewController.swift
//  Your Weather Station
//
//  Created by Kegham Karsian on 2/6/16.
//  Copyright © 2016 blowmymind. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import SwiftyJSON
import GoogleMobileAds
import Alamofire


class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource,
UICollectionViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UITextFieldDelegate {
    
    
    
    
    @IBOutlet var realFeelView: UIView!
    @IBOutlet var descriptionMoreLabel: UILabel!
    @IBOutlet var visibilityLabel: UILabel!
    @IBOutlet var rainChanceLabel: UILabel!
    @IBOutlet var realFeelLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var bgImage: UIImageView!
    
    @IBOutlet var extraItemsView: UIView!
    @IBOutlet var forcastView: UICollectionView!
    @IBOutlet var googleBannerView: GADBannerView!
    
    
    var notificationCenter: NSObjectProtocol!
    var timeBefore: CFAbsoluteTime!
    
    var manager = CLLocationManager()
    var latitude: Double!
    var longitude: Double!
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var messageFrame = UIView()
    var alert: UIAlertController!
    var alertAction :UIAlertAction!
    var application = UIApplication.shared
    
    var cityId:Double!
    //  var maxForcastTemp = Int()
    var forcastTime = [String]()
    var forcastTemp = [Int]()
    var forcastDay = [String]()
    var forcastTempMin = [Int]()
    var forcastTempMax = [Int]()
    //  var forcastIconString = [String]()
    var forcastWeekDay = [String]()
    var forcastIconImg = [UIImage]()
    
    var googleKey = "AIzaSyAffaG0NDNz_vbuUnMGN9fuEP1tf3BaKkY"
    var forcastioKey = "8c60945f05f0ba1f8e522b3584718a69"
    var forcastBaseUrl = URL(string: "https://api.forecast.io/forecast/")!
    //Get users preferred "chosen" language
    var preLang = Locale.preferredLanguages[0]
    var searchController: UISearchController!
    var refreshing = false
    var myLocation = true
    var fromSearchEngine = false
    var justUpdatedLocation = false
    
    var searchLat = Double()
    var searchLong = Double()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        
        googleBannerView.adUnitID = "ca-app-pub-7533771262868755/2187181821"//"ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-7533771262868755/2187181821"  //
        googleBannerView.rootViewController = self
        googleBannerView.load(GADRequest())
        
        forcastTemp.removeAll(keepingCapacity: true)
        forcastTempMin.removeAll(keepingCapacity: true)
        forcastTempMax.removeAll(keepingCapacity: true)
        forcastTime.removeAll(keepingCapacity: true)
        forcastDay.removeAll(keepingCapacity: true)
        //   forcastIconString.removeAll(keepCapacity: true)
        forcastWeekDay.removeAll(keepingCapacity: true)
        forcastIconImg.removeAll(keepingCapacity: true)
        // forcastDate.removeAll(keepCapacity: true)
        
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "5C.png")!)
        
        // bgImage.image = UIImage(named: "foggy2x.png")
        // self.bgImage.alpha = 0.9
        bgImage.sendSubview(toBack: view)
        extraItemsView.layer.cornerRadius = 12
        extraItemsView.layer.masksToBounds = true
        realFeelView.layer.cornerRadius = 10
        realFeelView.layer.masksToBounds = true
        
        //Mark: To notifiy that app is brought back to forground
        notificationCenter = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) { [unowned self] notification in
            
            self.messageFrame.removeFromSuperview()
            let timeAfter = CFAbsoluteTimeGetCurrent()
            let timeElapsed = (timeAfter - self.timeBefore)/60
            //print(timeElapsed)
            
            //To check if the time passed since going to background is more than 10 min
            if timeElapsed > 1{
                
                self.forcastTemp.removeAll(keepingCapacity: true)
                self.forcastTempMin.removeAll(keepingCapacity: true)
                self.forcastTempMax.removeAll(keepingCapacity: true)
                self.forcastTime.removeAll(keepingCapacity: true)
                self.forcastDay.removeAll(keepingCapacity: true)
                //   self.forcastIconString.removeAll(keepCapacity: true)
                self.forcastWeekDay.removeAll(keepingCapacity: true)
                self.forcastIconImg.removeAll(keepingCapacity: true)
                //   self.forcastDate.removeAll(keepCapacity: true)
                
                self.fromSearchEngine = false
                self.justUpdatedLocation = true
                self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.manager.startUpdatingLocation()    // Update the weather stats
                
            }
            
        }
        
        //Mark: To notifiy that app went to the background
        notificationCenter = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: OperationQueue.main) { [unowned self] notification in
            
            //Save current time to compare when it comes to forground
            self.timeBefore = CFAbsoluteTimeGetCurrent()
            
        }
        
        self.messageFrame.removeFromSuperview()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
    }
    
    
    //Mark: Remove observer after the app view controller is dissmised
    deinit {
        
        NotificationCenter.default.removeObserver(notificationCenter)
    }
    @IBAction func searchAction(_ sender: AnyObject) {
        
        self.searchController.searchBar.isHidden = false
        self.searchController.isActive = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchBar.placeholder = "City"
        self.searchController.searchBar.isHidden = true
        self.searchController.isActive = false
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.searchBar.tintColor = UIColor(red: 252/255, green: 147/255, blue: 95/255, alpha: 1)
        // self.navigationController!.navigationBar.topItem!.title = "Nasr City"
        self.definesPresentationContext = true
        
        
        let nav = self.navigationController?.navigationBar
        nav?.backgroundColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 0.2)
        nav?.barStyle = UIBarStyle.blackTranslucent
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text != ""{
            if let searchText = searchBar.text{
                let editedSearchText = searchStringChecker(searchText)
                findLongLat(editedSearchText, key: googleKey, handler: { (lat, long) -> Void in
                    
                    self.forcastTemp.removeAll(keepingCapacity: true)
                    self.forcastTempMin.removeAll(keepingCapacity: true)
                    self.forcastTempMax.removeAll(keepingCapacity: true)
                    self.forcastTime.removeAll(keepingCapacity: true)
                    self.forcastDay.removeAll(keepingCapacity: true)
                    
                    self.forcastWeekDay.removeAll(keepingCapacity: true)
                    self.forcastIconImg.removeAll(keepingCapacity: true)
                    self.fromSearchEngine = true
                    
                    self.getLocationAddress(lat, long: long, key: self.googleKey)
                    self.getWeather(lat, long: long, key: self.forcastioKey)
                })
                
            }
        }
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            self.messageFrame.removeFromSuperview()
            if justUpdatedLocation == false{
                manager.startUpdatingLocation()
            }
            break
        case .authorizedAlways:
            if justUpdatedLocation == false{
                manager.startUpdatingLocation()
            }
            break
        case .restricted:
            self.alert = UIAlertController(title: NSLocalizedString("Location Error", comment: "Error in location title"), message: NSLocalizedString("Location services is not enabled!", comment: "No location found") , preferredStyle: UIAlertControllerStyle.alert)
            self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                
                //   self.alert.dismissViewControllerAnimated(true, completion: nil)
                self.alert.removeFromParentViewController()
                
            })
            self.alert.addAction(self.alertAction)
            self.present(self.alert, animated: true, completion: nil)
            
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            self.alert = UIAlertController(title: NSLocalizedString("Location Error", comment: "Error in location title"), message: NSLocalizedString("Location services is not enabled!", comment: "No location found") , preferredStyle: UIAlertControllerStyle.alert)
            self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                
                //   self.alert.dismissViewControllerAnimated(true, completion: nil)
                self.alert.removeFromParentViewController()
                
            })
            self.alert.addAction(self.alertAction)
            self.present(self.alert, animated: true, completion: nil)
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
            //    default:
            //      break
            
        }
    }
    
    
    
    func progressBarDisplayer(_ msg:String, _ indicator:Bool ) {
        
        // println(msg)
        strLabel = UILabel(frame: CGRect(x: 80, y: 0, width: 150, height: 25))
        strLabel.text = msg
        strLabel.textColor = UIColor.white
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 130, y: view.frame.midY - 25 , width:250, height: 25))
        messageFrame.layer.cornerRadius = 4
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.5)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator.frame = CGRect(x: 30, y: 0, width: 25, height: 25)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
    }
    
    
    
    @IBAction func refresh(_ sender: AnyObject) {
        
        forcastTemp.removeAll(keepingCapacity: true)
        forcastTempMin.removeAll(keepingCapacity: true)
        forcastTempMax.removeAll(keepingCapacity: true)
        forcastTime.removeAll(keepingCapacity: true)
        forcastDay.removeAll(keepingCapacity: true)
        //   forcastIconString.removeAll(keepCapacity: true)
        forcastWeekDay.removeAll(keepingCapacity: true)
        forcastIconImg.removeAll(keepingCapacity: true)
        // forcastDate.removeAll(keepCapacity: true)
        
        self.searchController.searchBar.isHidden = true
        self.messageFrame.removeFromSuperview()
        self.myLocation = true
        self.fromSearchEngine = false
        manager.startUpdatingLocation()
        // self.getLocationAddress(latitude, long: longitude, key: googleKey)
        //  self.getWeather(latitude, long: longitude, key: forcastioKey)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: AnyObject) {
        
        self.messageFrame.removeFromSuperview()
        forcastTemp.removeAll(keepingCapacity: true)
        forcastTempMin.removeAll(keepingCapacity: true)
        forcastTempMax.removeAll(keepingCapacity: true)
        forcastTime.removeAll(keepingCapacity: true)
        forcastDay.removeAll(keepingCapacity: true)
        //   forcastIconString.removeAll(keepCapacity: true)
        forcastIconImg.removeAll(keepingCapacity: true)
        forcastWeekDay.removeAll(keepingCapacity: true)
        
        if myLocation == true{
            getLocationAddress(latitude, long: longitude, key: googleKey)
            getWeather(latitude, long: longitude, key: forcastioKey)
            
        } else {
            getWeather(searchLat, long: searchLong, key: forcastioKey)
        }
    }
    
    
    func searchStringChecker(_ searchString: String) -> String{
        
        var searchStringText = searchController.searchBar.text
        
        if ((searchStringText?.range(of: " ")) != nil) {
            if let words = searchStringText?.components(separatedBy: " "){
                searchStringText = words[0] + "," + words[1]
            }
        }
        print(searchStringText!)
        return searchStringText!
    }
    
    func findLongLat(_ locationSearch: String, key: String ,handler: @escaping (_ lat: Double, _ long:Double) -> Void){
        
        //   var lat = Double()
        //    var long = Double()
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(locationSearch)&key=\(key)")
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            
            /* //Preparing Cache
             let memoryCapacity = 500 * 1024 * 1024; // 500 MB
             let diskCapacity = 500 * 1024 * 1024; // 500 MB
             let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
             let configration = URLSessionConfiguration.default
             let defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders
             configration.HTTPAdditionalHeaders = defaultHeaders
             configration.requestCachePolicy = .useProtocolCachePolicy
             configration.urlCache = cache
             
             let manager = Alamofire.Manager(configuration: configration)
             if let url = url {
             manager.request(.GET, url, parameters: nil, encoding: .URL)
             .response { (request, response, data, error) in
             //   print("REQUEST: \(request)")
             //   print("RESPONSE: \(response)")
             print("ERROR: \(error)") */
            
            // Now parse the data using SwiftyJSON
            // This will come from your custom cache if it is not expired,
            // and from the network if it is expired
            Alamofire.request(url!, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let jsonData = response.result.value {
                        let jsonResult = JSON(jsonData)
                        
                        guard let latOptional = jsonResult["results"][0]["geometry"]["location"]["lat"].double,
                            
                            let longOptional = jsonResult["results"][0]["geometry"]["location"]["lng"].double
                            
                            else{
                                
                                DispatchQueue.main.async(execute: {
                                    self.alert = UIAlertController(title: NSLocalizedString("Location Error", comment: "Error in location title"), message: NSLocalizedString("Location not found!", comment: "No location found") , preferredStyle: UIAlertControllerStyle.alert)
                                    self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                        
                                        //   self.alert.dismissViewControllerAnimated(true, completion: nil)
                                        self.alert.removeFromParentViewController()
                                        
                                    })
                                    self.alert.addAction(self.alertAction)
                                    self.present(self.alert, animated: true, completion: nil)
                                    //  self.messageFrame.removeFromSuperview()
                                })
                                
                                
                                return
                        }
                        
                        
                        self.searchLat = latOptional
                        self.searchLong = longOptional
                        //  print(jsonResult)
                        //  print(jsonResult["results"][0]["geometry"]["location"])
                        // print(lat,long)
                        self.myLocation = false
                        return handler(self.searchLat, self.searchLong)
                        
                    }
                    
                    
                case .failure(let error):
                    print(error)
                    
                    
                }
                
            }
            
      //  }
        
        
  /*  } else {
    
    DispatchQueue.main.async(execute: {
    self.alert = UIAlertController(title: NSLocalizedString("Location Error", comment: "Error in location title"), message: NSLocalizedString("Location not found!", comment: "No location found") , preferredStyle: UIAlertControllerStyle.alert)
    self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
    
    //   self.alert.dismissViewControllerAnimated(true, completion: nil)
    self.alert.removeFromParentViewController()
    
    })
    self.alert.addAction(self.alertAction)
    self.present(self.alert, animated: true, completion: nil)
    //  self.messageFrame.removeFromSuperview()
    })
    
    
    return
    
    } */
        
  }

}

func getLocationAddress(_ lat: Double, long: Double, key: String){
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(key)")
        //  self.progressBarDisplayer("Refreshing", true)     // Progress bar show
        
        
        /* //Preparing Cache
         let memoryCapacity = 500 * 1024 * 1024; // 500 MB
         let diskCapacity = 500 * 1024 * 1024; // 500 MB
         let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
         let configration = URLSessionConfiguration.default
         let defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
         configration.httpAdditionalHeaders = defaultHeaders
         configration.requestCachePolicy = .useProtocolCachePolicy
         configration.urlCache = cache
         
         let manager = Alamofire.SessionManager(configuration: configration)
         
         manager.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default)
         //   manager.request(url!, method: .get, parameters: nil, encoding: .url)
         .response { (request, response, data, error) in
         //    print("REQUEST: \(request)")
         //    print("RESPONSE: \(response)")
         print("ERROR: \(error)") */
        
        // Now parse the data using SwiftyJSON
        // This will come from your custom cache if it is not expired,
        // and from the network if it is expired
        Alamofire.request(url!, method:.get).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let jsonData = response.result.value {
                    let jsonResult = JSON(jsonData)
                    guard let areaLongName = jsonResult["results"][0]["address_components"][2]["short_name"].string
                        
                        else{
                            DispatchQueue.main.async(execute: {
                                self.cityLabel.text = "Error not found"
                                // self.messageFrame.removeFromSuperview()
                            })
                            return
                    }
                    DispatchQueue.main.async(execute: {
                        if let country = jsonResult["results"][0]["address_components"][4]["short_name"].string{
                            self.cityLabel.text = areaLongName + ", \(country)"
                        }else {
                            self.cityLabel.text = areaLongName
                        }
                        //  self.navigationItem.title = areaLongName
                        //  print(areaLongName)
                        //  print(jsonResult["results"][0]["address_components"])
                        //  self.messageFrame.removeFromSuperview()
                    })
                    
                }
            case .failure(let error):
                print(error)
                
            }
         }
            
            
        }

    }




func getDaysOfWeek(_ dates: [Date])->[Int]? {
    var weekDays = [Int]()
    for date in dates{
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let myComponents = (myCalendar as NSCalendar?)?.components(.weekday, from: date)
        weekDays.append((myComponents?.weekday)!)
    }
    return weekDays
}

func getDayOfWeek(_ date: Date)->String {
    
    var day = ""
    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
    if let myComponents = (myCalendar as NSCalendar?)?.components(.weekday, from: date) {
        let weekDay = (myComponents.weekday)!
        print(weekDay)
        if preLang.contains("ar"){
            switch weekDay{
                
            case 1:
                day = "الاحد"
            case 2:
                day = "الاثنين"
            case 3:
                day = "الثلاث"
            case 4:
                day = "الاربع"
            case 5:
                day = "الخميس"
            case 6:
                day = "الجمعة"
            case 7:
                day = "السبت"
                
            default: break
                
            }
            
        } else if preLang.contains("fr") {
            switch weekDay{
                
            case 1:
                day = "Dim"
            case 2:
                day = "Lun"
            case 3:
                day = "Mar"
            case 4:
                day = "Mer"
            case 5:
                day = "Jeu"
            case 6:
                day = "Ven"
            case 7:
                day = "Sam"
                
            default: break
                
            }
            
        } else if preLang.contains("it") {
            switch weekDay{
                
            case 1:
                day = "Dom"
            case 2:
                day = "Lun"
            case 3:
                day = "Mar"
            case 4:
                day = "Mer"
            case 5:
                day = "Gio"
            case 6:
                day = "Ven"
            case 7:
                day = "Sab"
                
            default: break
                
            }
            
        } else if preLang.contains("es") {
            switch weekDay{
                
            case 1:
                day = "Dom"
            case 2:
                day = "Lun"
            case 3:
                day = "Mar"
            case 4:
                day = "Mié"
            case 5:
                day = "Jue"
            case 6:
                day = "Vie"
            case 7:
                day = "Sáb"
                
            default: break
                
            }
            
        } else {
            switch weekDay{
                
            case 1:
                day = "Sun"
            case 2:
                day = "Mon"
            case 3:
                day = "Tue"
            case 4:
                day = "Wed"
            case 5:
                day = "Thu"
            case 6:
                day = "Fri"
            case 7:
                day = "Sat"
                
            default: break
                
            }
        }
    }
    
    return day
}


func getWeather(_ lat: Double, long: Double, key: String){
    
    var url:URL!
    
    
    if latitude != nil && longitude != nil{
        
        if preLang.contains("fr") {
            
            if segmentedControl.selectedSegmentIndex == 0{
                url = URL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags&lang=fr", relativeTo: forcastBaseUrl)!
            } else {
                url = URL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags&lang=fr", relativeTo: forcastBaseUrl)!
            }
        } else if preLang.contains("ar") {
            
            if segmentedControl.selectedSegmentIndex == 0{
                url = URL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags&lang=ar", relativeTo: forcastBaseUrl)!
            } else {
                url = URL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags&lang=ar", relativeTo: forcastBaseUrl)!
            }
        } else if preLang.contains("it") {
            
            if segmentedControl.selectedSegmentIndex == 0{
                url = URL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags&lang=it", relativeTo: forcastBaseUrl)!
            } else {
                url = URL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags&lang=it", relativeTo: forcastBaseUrl)!
            }
        } else if preLang.contains("es") {
            
            if segmentedControl.selectedSegmentIndex == 0{
                url = URL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags&lang=es", relativeTo: forcastBaseUrl)!
            } else {
                url = URL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags&lang=es", relativeTo: forcastBaseUrl)!
            }
        } else {
            
            if segmentedControl.selectedSegmentIndex == 0{
                url = URL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags", relativeTo: forcastBaseUrl)!
            } else {
                url = URL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags", relativeTo: forcastBaseUrl)!
            }
        }
        // Progress bar show
        DispatchQueue.main.async(execute: {
            if self.refreshing == false{
                self.progressBarDisplayer(NSLocalizedString("Refreshing...", comment: "Refreshing or Updating"), true)
                self.refreshing = true
                print("refreshing")
            }
        })
        
        //Preparing Cache
       /* let memoryCapacity = 500 * 1024 * 1024; // 500 MB
        let diskCapacity = 500 * 1024 * 1024; // 500 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
        let configration = URLSessionConfiguration.default
        let defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configration.httpAdditionalHeaders = defaultHeaders
        configration.requestCachePolicy = .useProtocolCachePolicy
        configration.urlCache = cache
        
        let manager = Alamofire.SessionManager(configuration: configration)
        
        manager.request(url, method: .get, parameters: nil, encoding: URLEncoding.default)
            .response { (request, response, data, error) in
                //   print("REQUEST: \(request)")
                //   print("RESPONSE: \(response)")
                print("ERROR: \(error)") */
                
                // Now parse the data using SwiftyJSON
                // This will come from your custom cache if it is not expired,
                // and from the network if it is expired
                
        Alamofire.request(url, method: .get).validate().responseJSON { response in
                    print("Time: \(response.timeline) sec")
                    switch response.result {
                    case .success:
                        if let jsonData = response.result.value {
                            let jsonContent = JSON(jsonData)
                            // let jsonContent = JSON(data: data!)
                            
                            //Forecast Grabber
                            
                            self.forcastTemp.removeAll(keepingCapacity: true)
                            self.forcastTempMin.removeAll(keepingCapacity: true)
                            self.forcastTempMax.removeAll(keepingCapacity: true)
                            self.forcastTime.removeAll(keepingCapacity: true)
                            self.forcastDay.removeAll(keepingCapacity: true)
                            //   forcastIconString.removeAll(keepingCapacity: true)
                            self.forcastWeekDay.removeAll(keepingCapacity: true)
                            self.forcastIconImg.removeAll(keepingCapacity: true)
                            // forcastDate.removeAll(keepingCapacity: true)
                            
                            if let data = jsonContent["daily"]["data"].array{
                                var secondsFromGMT:Int  { return NSTimeZone.local.secondsFromGMT(for: Date()) } //Get local time to add to timestamp
                                // print(secondsFromGMT)
                                for data in data {
                                    self.forcastTempMin.append(Int(round(data["temperatureMin"].double!)))
                                    self.forcastTempMax.append(Int(round(data["temperatureMax"].double!)))
                                    // self.forcastIconString.append(data["icon"].string!)
                                    
                                    if let dIconString = data["icon"].string{
                                        print(data["time"])
                                        let date = NSDate(timeIntervalSince1970: data["time"].double! + Double(secondsFromGMT))
                                        self.forcastWeekDay.append(self.getDayOfWeek(date as Date))
                                        let dateS = String(describing: date)
                                        let dateArrayWithTime = dateS.components(separatedBy:"-")
                                        let dateArrayDayOnly = dateArrayWithTime[2].components(separatedBy:" ")
                                        //let dataArrayDayPlusOne = String(Int(dateArrayDayOnly[0])! + 1)
                                        let dataArrayDay = String(dateArrayDayOnly[0])
                                        // let dataArrayDayPlusOne = (dateArrayDayOnly[0])
                                        self.forcastDay.append(dataArrayDay!)
                                        self.forcastIconImg.append(self.iconChecker(dIconString))
                                        print(data)
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            DispatchQueue.main.async(execute: {
                                //   self.messageFrame.removeFromSuperview()
                                
                                self.forcastView.reloadData()
                                
                                if self.segmentedControl.selectedSegmentIndex == 0 {
                                    
                                    if let cTemp = jsonContent["currently"]["temperature"].double{
                                        self.tempLabel.text = String(Int(round(cTemp))) + "˚"
                                        
                                        if self.fromSearchEngine == false{
                                            if cTemp < 0 {
                                                UIApplication.shared.applicationIconBadgeNumber = 0
                                                
                                            } else {
                                                UIApplication.shared.applicationIconBadgeNumber = Int(round(cTemp))
                                            }
                                        }
                                        
                                    } else {
                                        self.tempLabel.text = "n/a˚"
                                    }
                                    if let cHumidity = jsonContent["currently"]["humidity"].double{
                                        self.humidityLabel.text = String(Int(round(cHumidity*100))) + "%"
                                    } else {
                                        self.humidityLabel.text = "n/a %"
                                    }
                                    if let cPressure = jsonContent["currently"]["pressure"].double{
                                        self.pressureLabel.text = String(Int(round(cPressure))) +  NSLocalizedString(" mBar", comment: "milli Bar")
                                    } else {
                                        self.pressureLabel.text = "n/a mBar"
                                    }
                                    if let cWindSpeed = jsonContent["currently"]["windSpeed"].double{
                                        self.windSpeedLabel.text = String(Int(round(cWindSpeed))) + NSLocalizedString(" Km/h", comment: "Kilo fe El sa3a")
                                    } else {
                                        self.windSpeedLabel.text = "n/a Km/h"
                                    }
                                    
                                    if let cFeelsLike = jsonContent["currently"]["apparentTemperature"].double{
                                        self.realFeelLabel.text = String(Int(round(cFeelsLike))) + "˚"
                                    } else {
                                        self.realFeelLabel.text = "n/a˚"
                                    }
                                    if let cWindDirection = jsonContent["currently"]["windBearing"].double{
                                        self.windDirectionLabel.text = self.windDirectionNotation(cWindDirection)
                                    } else {
                                        self.windDirectionLabel.text = "n/a"
                                    }
                                    if let cRainChance = jsonContent["currently"]["precipProbability"].double{
                                        self.rainChanceLabel.text = String(Int(round(cRainChance * 100))) + "%"
                                    } else {
                                        self.rainChanceLabel.text = "n/a %"
                                    }
                                    
                                    if let cVisibility = jsonContent["currently"]["visibility"].double{
                                        self.visibilityLabel.text = String(Int(round(cVisibility))) + NSLocalizedString(" Km", comment: "Km")
                                    } else {
                                        self.visibilityLabel.text = "n/a Km"
                                    }
                                    if let cSummary = jsonContent["currently"]["summary"].string{
                                        self.descriptionLabel.text = cSummary
                                    } else {
                                        self.descriptionLabel.text = "n/a"
                                    }
                                    if let cDailySummary = jsonContent["daily"]["summary"].string{
                                        self.descriptionMoreLabel.text = cDailySummary
                                    } else {
                                        self.descriptionMoreLabel.text = ""
                                    }
                                    if let cIconString = jsonContent["currently"]["icon"].string{
                                        self.bgImage.image = self.bgPicker(cIconString) //Change BG according to currently weather conditions.
                                    } else {
                                        self.bgImage.image = UIImage(named: "WindBg2x.png")
                                    }
                                    
                                } else {
                                    
                                    if let cTemp = jsonContent["currently"]["temperature"].double{
                                        self.tempLabel.text = String(Int(round(cTemp))) + "˚"
                                        
                                        if self.fromSearchEngine == false{
                                            if cTemp < 0 {
                                                UIApplication.shared.applicationIconBadgeNumber = 0
                                                
                                            } else {
                                                UIApplication.shared.applicationIconBadgeNumber = Int(round(cTemp))
                                            }
                                        }
                                        
                                    } else {
                                        self.tempLabel.text = "n/a˚"
                                    }
                                    if let cHumidity = jsonContent["currently"]["humidity"].double{
                                        self.humidityLabel.text = String(Int(round(cHumidity*100))) + "%"
                                    } else {
                                        self.humidityLabel.text = "n/a %"
                                    }
                                    if let cPressure = jsonContent["currently"]["pressure"].double{
                                        self.pressureLabel.text = String(Int(round(cPressure))) + NSLocalizedString(" mBar", comment: "milli Bar")
                                    } else {
                                        self.pressureLabel.text = "n/a mBar"
                                    }
                                    if let cWindSpeed = jsonContent["currently"]["windSpeed"].double{
                                        self.windSpeedLabel.text = String(Int(round(cWindSpeed))) + NSLocalizedString(" mph", comment: "meel fee el sa3a")
                                    } else {
                                        self.windSpeedLabel.text = "n/a mph"
                                    }
                                    if let cFeelsLike = jsonContent["currently"]["apparentTemperature"].double{
                                        self.realFeelLabel.text = String(Int(round(cFeelsLike))) + "˚"
                                    } else {
                                        self.realFeelLabel.text = "n/a˚"
                                    }
                                    if let cWindDirection = jsonContent["currently"]["windBearing"].double{
                                        self.windDirectionLabel.text = self.windDirectionNotation(cWindDirection)
                                    } else {
                                        self.windDirectionLabel.text = "n/a"
                                    }
                                    
                                    if let cRainChance = jsonContent["currently"]["precipProbability"].double{
                                        self.rainChanceLabel.text = String(Int(round(cRainChance * 100))) + "%"
                                    } else {
                                        self.rainChanceLabel.text = "n/a %"
                                    }
                                    if let cVisibility = jsonContent["currently"]["visibility"].double{
                                        self.visibilityLabel.text = String(Int(round(cVisibility))) + NSLocalizedString(" mi", comment: "meel")
                                    } else {
                                        self.visibilityLabel.text = "n/a" + NSLocalizedString(" mi", comment: "meel")
                                    }
                                    if let cSummary = jsonContent["currently"]["summary"].string{
                                        self.descriptionLabel.text = cSummary
                                    } else {
                                        self.descriptionLabel.text = "n/a"
                                    }
                                    if let cDailySummary = jsonContent["daily"]["summary"].string{
                                        self.descriptionMoreLabel.text = cDailySummary
                                    } else {
                                        self.descriptionMoreLabel.text = ""
                                    }
                                    if let cIconString = jsonContent["currently"]["icon"].string{
                                        self.bgImage.image = self.bgPicker(cIconString) //Change BG according to currently weather conditions.
                                    } else {
                                        self.bgImage.image = UIImage(named: "WindBg2x.png")
                                    }
                                    
                                }
                                
                                //   print(self.forcastTempMax, self.forcastTempMin)
                                //   print(jsonContent)
                                
                                if self.refreshing == true{
                                    self.messageFrame.removeFromSuperview()
                                    self.refreshing = false
                                }
                                print("Stop refreshing")
                            })
                            
                            //  print("JSON: \(jsonContent)")
                        }
                    case .failure(let error):
                        print(error)
                        self.alert = UIAlertController(title:NSLocalizedString("Connection Error", comment: "No connection title"), message: NSLocalizedString("The internet connection appears to be offline.", comment: "No Connection") , preferredStyle: UIAlertControllerStyle.alert)
                        self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                            
                            //   self.alert.dismissViewControllerAnimated(true, completion: nil)
                            //  self.alert.removeFromParentViewController()
                            
                        })
                        self.alert.addAction(self.alertAction)
                        self.present(self.alert, animated: true, completion: nil)
                        
                        if self.refreshing == true{
                            self.messageFrame.removeFromSuperview()
                            self.refreshing = false
                        }
                        
                    }
             //   }
                
                
        }
    }
    /*
     let session = NSURLSession(configuration: configration)
     
     let urlRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 10.0 * 1000)
     urlRequest.HTTPMethod = "GET"
     
     
     dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)){
     let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) -> Void in
     
     
     
     
     guard let realResponse = response as? NSHTTPURLResponse where
     
     realResponse.statusCode == 200 else {
     
     dispatch_async(dispatch_get_main_queue(), {
     self.alert = UIAlertController(title:  NSLocalizedString ("Connection Error", comment: "Error in connection title"), message: NSLocalizedString("Connection is down. Please try again later", comment: "No connection found to server") , preferredStyle: UIAlertControllerStyle.Alert)
     self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
     
     //   self.alert.dismissViewControllerAnimated(true, completion: nil)
     //  self.alert.removeFromParentViewController()
     
     })
     self.alert.addAction(self.alertAction)
     self.presentViewController(self.alert, animated: true, completion: nil)
     if self.refreshing == true{
     self.messageFrame.removeFromSuperview()
     self.refreshing = false
     }
     })
     return
     }
     
     
     let jsonContent = JSON(data: data!)
     
     /*
     guard  let cTemp = jsonContent["currently"]["temperature"].double,
     let cFeelsLike = jsonContent["currently"]["apparentTemperature"].double,
     let cHumidity = jsonContent["currently"]["humidity"].double,
     //      let cDewPoint = jsonContent["currently"]["dewPoint"].double,
     let cPressure = jsonContent["currently"]["pressure"].double,
     //   let cVisibility = jsonContent["currently"]["visibility"].double,
     let cWindSpeed = jsonContent["currently"]["windSpeed"].double,
     let cWindDirection = jsonContent["currently"]["windBearing"].double,
     let cRainChance = jsonContent["currently"]["precipProbability"].double,
     let cIconString = jsonContent["currently"]["icon"].string,
     let cSummary = jsonContent["currently"]["summary"].string,
     let cDailySummary = jsonContent["daily"]["summary"].string
     
     else{
     //  print("Error json data nil value found")
     dispatch_async(dispatch_get_main_queue(), {
     self.alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error title"), message: NSLocalizedString("Weather data not found for this location!", comment: "if weather not found"), preferredStyle: UIAlertControllerStyle.Alert)
     self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
     
     
     
     })
     self.alert.addAction(self.alertAction)
     self.presentViewController(self.alert, animated: true, completion: nil)
     if self.refreshing == true{
     self.messageFrame.removeFromSuperview()
     self.refreshing = false
     }
     self.refresh(self)
     })
     
     return
     }    */
     
     
     //Forecast Grabber
     if let data = jsonContent["daily"]["data"].array{
     for data in data {
     self.forcastTempMin.append(Int(round(data["temperatureMin"].double!)))
     self.forcastTempMax.append(Int(round(data["temperatureMax"].double!)))
     // self.forcastIconString.append(data["icon"].string!)
     if let dIconString = data["icon"].string{
     
     let date = NSDate(timeIntervalSince1970: data["time"].double!)
     self.forcastWeekDay.append(self.getDayOfWeek(date))
     let dateS = String(date)
     let dateArrayWithTime = dateS.componentsSeparatedByString("-")
     let dateArrayDayOnly = dateArrayWithTime[2].componentsSeparatedByString(" ")
     self.forcastDay.append(dateArrayDayOnly[0])
     self.forcastIconImg.append(self.iconChecker(dIconString))
     
     }
     
     }
     
     }
     
     dispatch_async(dispatch_get_main_queue(), {
     //   self.messageFrame.removeFromSuperview()
     
     self.forcastView.reloadData()
     
     if self.segmentedControl.selectedSegmentIndex == 0 {
     
     if let cTemp = jsonContent["currently"]["temperature"].double{
     self.tempLabel.text = String(Int(round(cTemp))) + "˚"
     
     if self.fromSearchEngine == false{
     UIApplication.sharedApplication().applicationIconBadgeNumber = Int(round(cTemp))
     }
     
     } else {
     self.tempLabel.text = "n/a˚"
     }
     if let cHumidity = jsonContent["currently"]["humidity"].double{
     self.humidityLabel.text = String(Int(round(cHumidity*100))) + "%"
     } else {
     self.humidityLabel.text = "n/a %"
     }
     if let cPressure = jsonContent["currently"]["pressure"].double{
     self.pressureLabel.text = String(Int(round(cPressure))) +  NSLocalizedString(" mBar", comment: "milli Bar")
     } else {
     self.pressureLabel.text = "n/a mBar"
     }
     if let cWindSpeed = jsonContent["currently"]["windSpeed"].double{
     self.windSpeedLabel.text = String(Int(round(cWindSpeed))) + NSLocalizedString(" Km/h", comment: "Kilo fe El sa3a")
     } else {
     self.windSpeedLabel.text = "n/a Km/h"
     }
     
     if let cFeelsLike = jsonContent["currently"]["apparentTemperature"].double{
     self.realFeelLabel.text = String(Int(round(cFeelsLike))) + "˚"
     } else {
     self.realFeelLabel.text = "n/a˚"
     }
     if let cWindDirection = jsonContent["currently"]["windBearing"].double{
     self.windDirectionLabel.text = self.windDirectionNotation(cWindDirection)
     } else {
     self.windDirectionLabel.text = "n/a"
     }
     if let cRainChance = jsonContent["currently"]["precipProbability"].double{
     self.rainChanceLabel.text = String(Int(round(cRainChance * 100))) + "%"
     } else {
     self.rainChanceLabel.text = "n/a %"
     }
     
     if let cVisibility = jsonContent["currently"]["visibility"].double{
     self.visibilityLabel.text = String(Int(round(cVisibility))) + NSLocalizedString(" Km", comment: "Km")
     } else {
     self.visibilityLabel.text = "n/a Km"
     }
     if let cSummary = jsonContent["currently"]["summary"].string{
     self.descriptionLabel.text = cSummary
     } else {
     self.descriptionLabel.text = "n/a"
     }
     if let cDailySummary = jsonContent["daily"]["summary"].string{
     self.descriptionMoreLabel.text = cDailySummary
     } else {
     self.descriptionMoreLabel.text = ""
     }
     if let cIconString = jsonContent["currently"]["icon"].string{
     self.bgImage.image = self.bgPicker(cIconString) //Change BG according to currently weather conditions.
     } else {
     self.bgImage.image = UIImage(named: "WindBg2x.png")
     }
     
     } else {
     
     if let cTemp = jsonContent["currently"]["temperature"].double{
     self.tempLabel.text = String(Int(round(cTemp))) + "˚"
     
     if self.fromSearchEngine == false{
     UIApplication.sharedApplication().applicationIconBadgeNumber = Int(round(cTemp))
     }
     
     } else {
     self.tempLabel.text = "n/a˚"
     }
     if let cHumidity = jsonContent["currently"]["humidity"].double{
     self.humidityLabel.text = String(Int(round(cHumidity*100))) + "%"
     } else {
     self.humidityLabel.text = "n/a %"
     }
     if let cPressure = jsonContent["currently"]["pressure"].double{
     self.pressureLabel.text = String(Int(round(cPressure))) + NSLocalizedString(" mBar", comment: "milli Bar")
     } else {
     self.pressureLabel.text = "n/a mBar"
     }
     if let cWindSpeed = jsonContent["currently"]["windSpeed"].double{
     self.windSpeedLabel.text = String(Int(round(cWindSpeed))) + NSLocalizedString(" mph", comment: "meel fee el sa3a")
     } else {
     self.windSpeedLabel.text = "n/a mph"
     }
     if let cFeelsLike = jsonContent["currently"]["apparentTemperature"].double{
     self.realFeelLabel.text = String(Int(round(cFeelsLike))) + "˚"
     } else {
     self.realFeelLabel.text = "n/a˚"
     }
     if let cWindDirection = jsonContent["currently"]["windBearing"].double{
     self.windDirectionLabel.text = self.windDirectionNotation(cWindDirection)
     } else {
     self.windDirectionLabel.text = "n/a"
     }
     
     if let cRainChance = jsonContent["currently"]["precipProbability"].double{
     self.rainChanceLabel.text = String(Int(round(cRainChance * 100))) + "%"
     } else {
     self.rainChanceLabel.text = "n/a %"
     }
     if let cVisibility = jsonContent["currently"]["visibility"].double{
     self.visibilityLabel.text = String(Int(round(cVisibility))) + NSLocalizedString(" mi", comment: "meel")
     } else {
     self.visibilityLabel.text = "n/a" + NSLocalizedString(" mi", comment: "meel")
     }
     if let cSummary = jsonContent["currently"]["summary"].string{
     self.descriptionLabel.text = cSummary
     } else {
     self.descriptionLabel.text = "n/a"
     }
     if let cDailySummary = jsonContent["daily"]["summary"].string{
     self.descriptionMoreLabel.text = cDailySummary
     } else {
     self.descriptionMoreLabel.text = ""
     }
     if let cIconString = jsonContent["currently"]["icon"].string{
     self.bgImage.image = self.bgPicker(cIconString) //Change BG according to currently weather conditions.
     } else {
     self.bgImage.image = UIImage(named: "WindBg2x.png")
     }
     
     }
     
     //   print(self.forcastTempMax, self.forcastTempMin)
     //   print(jsonContent)
     
     if self.refreshing == true{
     self.messageFrame.removeFromSuperview()
     self.refreshing = false
     }
     print("Stop refreshing")
     })
     
     // self.messageFrame.removeFromSuperview()
     })
     task.resume()
     
     //  self.messageFrame.removeFromSuperview()
     }
     
     } else{
     
     self.alert = UIAlertController(title:NSLocalizedString("GPS Error", comment: "gps error title"), message: NSLocalizedString("GPS cannot locate your city. Please try again later", comment: "GPS location error") , preferredStyle: UIAlertControllerStyle.Alert)
     self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
     
     //   self.alert.dismissViewControllerAnimated(true, completion: nil)
     //  self.alert.removeFromParentViewController()
     
     })
     self.alert.addAction(self.alertAction)
     self.presentViewController(self.alert, animated: true, completion: nil)
     if self.refreshing == true{
     self.messageFrame.removeFromSuperview()
     self.refreshing = false
     }
     }  */
    
    
}


func bgPicker(_ iconString: String) -> UIImage{
    
    var bg = UIImage()
    if iconString == "clear-day"{
        bg = UIImage(named: "ClearDayBg2x.png")!
    } else if iconString == "clear-night"{
        bg = UIImage(named: "clear nightBg2x.png")!
    } else if iconString == "rain"{
        bg = UIImage(named: "RainBg2x.png")!
    } else if iconString == "snow"{
        bg = UIImage(named: "SnowBg2x.png")!
    } else if iconString == "sleet"{
        bg = UIImage(named: "sleetBg2x.png")!
    } else if iconString == "wind"{
        bg = UIImage(named: "WindBg2x.png")!
    } else if iconString == "fog"{
        bg = UIImage(named: "foggy2x.png")!
    } else  if iconString == "cloudy"{
        bg = UIImage(named: "Overcast_June2x.png")!
    } else if iconString == "partly-cloudy-day"{
        bg = UIImage(named: "Partly-Cloudy-Day2x.png")!
    } else if iconString == "partly-cloudy-night"{
        bg = UIImage(named: "partly cloud night2x.png")!
    } else if iconString == "thunderstorm"{
        bg = UIImage(named: "StormBg2x.png")!
        
    } else {
        bg = UIImage(named: "Partly cloud dayBg2x.png")!
    }
    return bg
}

func iconChecker(_ iconString: String) -> UIImage {
    
    var icon = UIImage()
    if iconString == "clear-day"{
        icon = UIImage(named: "Clear Sun Day.png")!
    } else if iconString == "clear-night"{
        icon = UIImage(named: "Clear Night.png")!
    } else if iconString == "rain"{
        icon = UIImage(named: "cloud H.Rain.png")!
    } else if iconString == "snow"{
        icon = UIImage(named: "cloud Snow.png")!
    } else if iconString == "sleet"{
        icon = UIImage(named: "cloud sleet.png")!
    } else if iconString == "wind"{
        icon = UIImage(named: "windForcast2x.png")!
    } else if iconString == "fog"{
        icon = UIImage(named: "fog.png")!
    } else  if iconString == "cloudy"{
        icon = UIImage(named: "cloud.png")!
    } else if iconString == "partly-cloudy-day"{
        icon = UIImage(named: "cloud partialy.png")!
    } else if iconString == "partly-cloudy-night"{
        icon = UIImage(named: "cloud Night.png")!
    } else if iconString == "thunderstorm"{
        icon = UIImage(named: "cloud Thunder.png")!
    } else if iconString == "tornado"{
        icon = UIImage(named: "tornadoIcon2x.png")!
    } else if iconString == "hail"{
        icon = UIImage(named: "hailicon2x.png")!
    } else {
        icon = UIImage(named: "cloud L.Rain.png")!
    }
    return icon
}

func windDirectionNotation(_ direction: Double) -> String{
    
    var notation = ""
    if direction < 11.25{
        notation = NSLocalizedString("N", comment: "north")
    }
    if direction > 11.25 && direction < 33.75{
        notation = NSLocalizedString("NNE", comment: "north north east")
    }
    if direction > 33.75 && direction < 56.25{
        notation = NSLocalizedString("NE", comment: "north east")
    }
    if direction > 56.25 && direction < 78.75{
        notation = NSLocalizedString("ENE", comment: "east north east")
    }
    if direction > 78.75 && direction < 101.25{
        notation = NSLocalizedString("E", comment: "east")
    }
    if direction > 101.25 && direction < 123.75{
        notation = NSLocalizedString("ESE", comment: "east south east")
    }
    if direction > 123.75 && direction < 146.25{
        notation = NSLocalizedString("SE", comment: "south east")
    }
    if direction > 146.25 && direction < 168.75{
        notation = NSLocalizedString("SSE", comment: "south south east")
    }
    if direction > 168.75 && direction < 191.25{
        notation = NSLocalizedString("S", comment: "south")
    }
    if direction > 191.25 && direction < 213.75{
        notation = NSLocalizedString("SSW", comment: "south south west")
    }
    if direction > 213.75 && direction < 236.25{
        notation = NSLocalizedString("SW", comment: "south west")
    }
    if direction > 236.25 && direction < 258.75{
        notation = NSLocalizedString("WSW", comment: "west south west")
    }
    if direction > 258.75 && direction < 281.25{
        notation = NSLocalizedString("W", comment: "west")
    }
    if direction > 281.25 && direction < 303.75{
        notation = NSLocalizedString("WNW", comment: "west north west")
    }
    if direction > 303.75 && direction < 326.25{
        notation = NSLocalizedString("NW", comment: "north west")
    }
    if direction > 326.25 && direction < 348.75{
        notation = NSLocalizedString("NNW", comment: "north north west")
    }
    if direction > 348.75{
        notation = NSLocalizedString("N", comment: "north")
    }
    
    return notation
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let userLocation = locations.last
    longitude = (userLocation?.coordinate.longitude)!
    latitude = (userLocation?.coordinate.latitude)!
    manager.stopUpdatingLocation()
    
    self.getLocationAddress(latitude, long: longitude, key: googleKey)
    self.getWeather(latitude, long: longitude, key: forcastioKey)
    
    
}

// MARK: UICollectionViewDataSource

func numberOfSections(in collectionView: UICollectionView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
}


func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return forcastTempMin.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection", for: indexPath) as! ForcastCollectionViewCell
    
    
    cell.cellImage.image = forcastIconImg[(indexPath as NSIndexPath).row]
    
    if (indexPath as NSIndexPath).row == 0 {
        cell.timeLabel.text = NSLocalizedString("Today", comment: "Today")
    } else {
        cell.timeLabel.text = String(forcastWeekDay[(indexPath as NSIndexPath).row])
    }
    
    
    //        if (forcastTempMin[indexPath.row] == forcastTempMin.minElement()){
    //            cell.tempLabel.textColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1.0)
    //            print(forcastTempMin.minElement())
    //        }
    cell.tempLabel.text = String(forcastTempMin[(indexPath as NSIndexPath).row])+"˚"
    
    //            if (forcastTempMax[indexPath.row] == forcastTempMax.maxElement()){
    //                cell.temp2Label.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1.0)
    //                print(forcastTempMax.maxElement())
    //            }
    
    cell.temp2Label.text = String(forcastTempMax[(indexPath as NSIndexPath).row])+"˚"
    cell.dayLabel.text = String(forcastDay[(indexPath as NSIndexPath).row])
    
    
    return cell
}

// MARK: UICollectionViewDelegate

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
 return true
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
 return true
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
 return false
 }
 
 override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
 return false
 }
 
 override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
 
 }
 */

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
}


}
