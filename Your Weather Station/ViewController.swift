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
    @IBOutlet var weatherIcon: UIImageView!
    @IBOutlet var bgImage: UIImageView!

    @IBOutlet var extraItemsView: UIView!
    @IBOutlet var forcastView: UICollectionView!

    
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
    var application = UIApplication.sharedApplication()
    
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
    var forcastioKey = "1add606a5c48b959004d938dd5b7dcb3"
    var forcastBaseUrl = NSURL(string: "https://api.forecast.io/forecast/")!
    //Get users preferred "chosen" language
    var preLang = NSLocale.preferredLanguages()[0]
    var searchController: UISearchController!
    var refreshing = false
    var myLocation = true
    var fromSearchEngine = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
        forcastTemp.removeAll(keepCapacity: true)
        forcastTempMin.removeAll(keepCapacity: true)
        forcastTempMax.removeAll(keepCapacity: true)
        forcastTime.removeAll(keepCapacity: true)
        forcastDay.removeAll(keepCapacity: true)
     //   forcastIconString.removeAll(keepCapacity: true)
        forcastWeekDay.removeAll(keepCapacity: true)
        forcastIconImg.removeAll(keepCapacity: true)
       // forcastDate.removeAll(keepCapacity: true)

//        tempLabel.layer.masksToBounds = true
//        tempLabel.layer.cornerRadius = 12
//        pressureLabel.layer.cornerRadius = 12
//        pressureLabel.layer.masksToBounds = true
//        humidityLabel.layer.cornerRadius = 12
//        humidityLabel.layer.masksToBounds = true
//        windDirectionLabel.layer.masksToBounds = true
//        windDirectionLabel.layer.cornerRadius = 12
//        windSpeedLabel.layer.cornerRadius = 12
//        windSpeedLabel.layer.masksToBounds = true
//        descriptionLabel.layer.masksToBounds = true
//        descriptionLabel.layer.cornerRadius = 12
//        cityLabel.layer.masksToBounds = true
//        cityLabel.layer.cornerRadius = 12
//        realFeelLabel.layer.cornerRadius = 7
//        realFeelLabel.layer.masksToBounds = true
//        visibilityLabel.layer.cornerRadius = 12
//        visibilityLabel.layer.masksToBounds = true
//        rainChanceLabel.layer.cornerRadius = 12
//        rainChanceLabel.layer.masksToBounds = true
        
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "5C.png")!)

       // bgImage.image = UIImage(named: "foggy2x.png")
       // self.bgImage.alpha = 0.9
        bgImage.sendSubviewToBack(view)
        extraItemsView.layer.cornerRadius = 12
        extraItemsView.layer.masksToBounds = true
        realFeelView.layer.cornerRadius = 10
        realFeelView.layer.masksToBounds = true
     
        //Mark: To notifiy that app is brought back to forground
        notificationCenter = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self] notification in
            
            self.messageFrame.removeFromSuperview()
            let timeAfter = CFAbsoluteTimeGetCurrent()
            let timeElapsed = (timeAfter - self.timeBefore)/60
            //print(timeElapsed)
            
            //To check if the time passed since going to background is more than 10 min
            if timeElapsed > 10{
                
                self.forcastTemp.removeAll(keepCapacity: true)
                self.forcastTempMin.removeAll(keepCapacity: true)
                self.forcastTempMax.removeAll(keepCapacity: true)
                self.forcastTime.removeAll(keepCapacity: true)
                self.forcastDay.removeAll(keepCapacity: true)
             //   self.forcastIconString.removeAll(keepCapacity: true)
                self.forcastWeekDay.removeAll(keepCapacity: true)
                self.forcastIconImg.removeAll(keepCapacity: true)
             //   self.forcastDate.removeAll(keepCapacity: true)
                
                
                self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.manager.startUpdatingLocation()    // Update the weather stats
            }
            
        }
        
        //Mark: To notifiy that app went to the background
        notificationCenter = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self] notification in
            
            //Save current time to compare when it comes to forground
            self.timeBefore = CFAbsoluteTimeGetCurrent()

        }
        
        self.messageFrame.removeFromSuperview()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters

    }
    
    
    //Mark: Remove observer after the app view controller is dissmised
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(notificationCenter)
    }
    @IBAction func searchAction(sender: AnyObject) {
        
        self.searchController.searchBar.hidden = false
        self.searchController.active = true
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    override func viewDidAppear(animated: Bool) {
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchBar.placeholder = "City"
        self.searchController.searchBar.hidden = true
        self.searchController.active = false
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.searchBar.tintColor = UIColor(red: 252/255, green: 147/255, blue: 95/255, alpha: 1)
        // self.navigationController!.navigationBar.topItem!.title = "Nasr City"
        self.definesPresentationContext = true


        let nav = self.navigationController?.navigationBar
        nav?.backgroundColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 0.2)
        nav?.barStyle = UIBarStyle.BlackTranslucent
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if searchBar.text != ""{
            if let searchText = searchBar.text{
                let editedSearchText = searchStringChecker(searchText)
                findLongLat(editedSearchText, key: googleKey, handler: { (lat, long) -> Void in

                    self.forcastTemp.removeAll(keepCapacity: true)
                    self.forcastTempMin.removeAll(keepCapacity: true)
                    self.forcastTempMax.removeAll(keepCapacity: true)
                    self.forcastTime.removeAll(keepCapacity: true)
                    self.forcastDay.removeAll(keepCapacity: true)

                    self.forcastWeekDay.removeAll(keepCapacity: true)
                    self.forcastIconImg.removeAll(keepCapacity: true)
                    self.fromSearchEngine = true

                    self.getLocationAddress(lat, long: long, key: self.googleKey)
                    self.getWeather(lat, long: long, key: self.forcastioKey)
                })
               
            }
        }
        
    }

    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .AuthorizedWhenInUse:
            self.messageFrame.removeFromSuperview()
            manager.startUpdatingLocation()
            break
        case .AuthorizedAlways:
            manager.startUpdatingLocation()
            break
        case .Restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .Denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
    //    default:
      //      break
            
        }
    }
    
    
    
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        
       // println(msg)
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 100, height: 25))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 25))
        messageFrame.layer.cornerRadius = 4
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.5)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
    }

    
  
    @IBAction func refresh(sender: AnyObject) {
        
        forcastTemp.removeAll(keepCapacity: true)
        forcastTempMin.removeAll(keepCapacity: true)
        forcastTempMax.removeAll(keepCapacity: true)
        forcastTime.removeAll(keepCapacity: true)
        forcastDay.removeAll(keepCapacity: true)
        //   forcastIconString.removeAll(keepCapacity: true)
        forcastWeekDay.removeAll(keepCapacity: true)
        forcastIconImg.removeAll(keepCapacity: true)
        // forcastDate.removeAll(keepCapacity: true)
        
        self.searchController.searchBar.hidden = true
        self.messageFrame.removeFromSuperview()
        self.myLocation = true
        self.fromSearchEngine = false
        self.getLocationAddress(latitude, long: longitude, key: googleKey)
        self.getWeather(latitude, long: longitude, key: forcastioKey)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        
        self.messageFrame.removeFromSuperview()
        forcastTemp.removeAll(keepCapacity: true)
        forcastTempMin.removeAll(keepCapacity: true)
        forcastTempMax.removeAll(keepCapacity: true)
        forcastTime.removeAll(keepCapacity: true)
        forcastDay.removeAll(keepCapacity: true)
     //   forcastIconString.removeAll(keepCapacity: true)
        forcastIconImg.removeAll(keepCapacity: true)
        forcastWeekDay.removeAll(keepCapacity: true)
        
        if myLocation == true{
        getLocationAddress(latitude, long: longitude, key: googleKey)
        getWeather(latitude, long: longitude, key: forcastioKey)
            
        } else {
            
        }
    }
    
    //https://maps.googleapis.com/maps/api/geocode/json?address=alexandria,egypt&key=AIzaSyAffaG0NDNz_vbuUnMGN9fuEP1tf3BaKkY //return lat & long
    
    func searchStringChecker(searchString: String) -> String{
        
        var searchStringText = searchController.searchBar.text
        
        if ((searchStringText?.rangeOfString(" ")) != nil) {
            if let words = searchStringText?.componentsSeparatedByString(" "){
                searchStringText = words[0] + "," + words[1]
            }
        }
        print(searchStringText!)
        return searchStringText!
    }
    
    func findLongLat(locationSearch: String, key: String ,handler: (lat: Double, long:Double) -> Void){
        
        var lat = Double()
        var long = Double()
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(locationSearch)&key=\(key)")
     dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)){
      
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in

            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {             //Has to have a min of 500 response
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.alert = UIAlertController(title:  NSLocalizedString ("Connection Error", comment: "Error in connection title"), message: NSLocalizedString("Connection is down. Please try again later", comment: "No connection found to server") , preferredStyle: UIAlertControllerStyle.Alert)
                        self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            
                            //   self.alert.dismissViewControllerAnimated(true, completion: nil)
                            self.alert.removeFromParentViewController()
                            
                        })
                        self.alert.addAction(self.alertAction)
                        self.presentViewController(self.alert, animated: true, completion: nil)
                        //  self.messageFrame.removeFromSuperview()
                    })
                    
                    return
            }
                
                let jsonResult = JSON(data: data!)
                
                guard let latOptional = jsonResult["results"][0]["geometry"]["location"]["lat"].double,

                    let longOptional = jsonResult["results"][0]["geometry"]["location"]["lng"].double
                        
                else{
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.alert = UIAlertController(title: NSLocalizedString("Location Error", comment: "Error in location title"), message: NSLocalizedString("Location not found!", comment: "No location found") , preferredStyle: UIAlertControllerStyle.Alert)
                        self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            
                            //   self.alert.dismissViewControllerAnimated(true, completion: nil)
                            self.alert.removeFromParentViewController()
                            
                        })
                        self.alert.addAction(self.alertAction)
                        self.presentViewController(self.alert, animated: true, completion: nil)
                        //  self.messageFrame.removeFromSuperview()
                    })

                    
                            return
                }
                    lat = latOptional
                    long = longOptional
              //  print(jsonResult)
                print(jsonResult["results"][0]["geometry"]["location"])
                print(lat,long)
                self.myLocation = false
                return handler(lat: lat, long: long)
          
            
        })
        task.resume()
      }
    
    }

    func getLocationAddress(lat: Double, long: Double, key: String){
       dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)){
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(key)")
      //  self.progressBarDisplayer("Refreshing", true)     // Progress bar show
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {             //Has to have a min of 500 response
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.alert = UIAlertController(title:  NSLocalizedString ("Connection Error", comment: "Error in connection title"), message: NSLocalizedString("Connection is down. Please try again later", comment: "No connection found to server") , preferredStyle: UIAlertControllerStyle.Alert)
                        self.alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            
                            //   self.alert.dismissViewControllerAnimated(true, completion: nil)
                              self.alert.removeFromParentViewController()
                            
                        })
                        self.alert.addAction(self.alertAction)
                        self.presentViewController(self.alert, animated: true, completion: nil)
                      //  self.messageFrame.removeFromSuperview()
                    })
                    return
                    
            }
            
                
                let jsonResult = JSON(data: data!)
             guard let areaLongName = jsonResult["results"][0]["address_components"][2]["long_name"].string
                
                else{
                    dispatch_async(dispatch_get_main_queue(), {
                     self.cityLabel.text = "Error not found"
                    // self.messageFrame.removeFromSuperview()
                        })
                    return
                }
             dispatch_async(dispatch_get_main_queue(), {
                self.cityLabel.text = areaLongName
                self.navigationItem.title = areaLongName
              //  print(areaLongName)
             //   print(jsonResult)
              //  self.messageFrame.removeFromSuperview()
            })
        
        }
        task.resume()
     //   self.messageFrame.removeFromSuperview()
        }
    }
    

    
    func getDaysOfWeek(dates: [NSDate])->[Int]? {
        var weekDays = [Int]()
        for date in dates{
            let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            let myComponents = myCalendar?.components(.NSWeekdayCalendarUnit, fromDate: date)
            weekDays.append((myComponents?.weekday)!)
        }
        return weekDays
    }
    
    func getDayOfWeek(date: NSDate)->String {
        
        var day = ""
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        if let myComponents = myCalendar?.components(.NSWeekdayCalendarUnit, fromDate: date) {
            let weekDay = (myComponents.weekday)
            
            if preLang.containsString("ar"){
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
                
            } else if preLang.containsString("fr") {
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
                
            } else if preLang.containsString("it") {
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
                
            } else if preLang.containsString("es") {
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

    
    func getWeather(lat: Double, long: Double, key: String){
        
        var url = NSURL()
        
        if latitude != nil && longitude != nil{
            
                if preLang.containsString("fr") {
                
                    if segmentedControl.selectedSegmentIndex == 0{
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags&lang=fr", relativeToURL: forcastBaseUrl)!
                    } else {
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags&lang=fr", relativeToURL: forcastBaseUrl)!
                    }
                } else if preLang.containsString("ar") {
                
                    if segmentedControl.selectedSegmentIndex == 0{
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags&lang=ar", relativeToURL: forcastBaseUrl)!
                    } else {
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags&lang=ar", relativeToURL: forcastBaseUrl)!
                    }
                } else if preLang.containsString("it") {
                
                    if segmentedControl.selectedSegmentIndex == 0{
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags&lang=it", relativeToURL: forcastBaseUrl)!
                    } else {
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags&lang=it", relativeToURL: forcastBaseUrl)!
                    }
                } else if preLang.containsString("es") {
                
                    if segmentedControl.selectedSegmentIndex == 0{
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags&lang=es", relativeToURL: forcastBaseUrl)!
                    } else {
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags&lang=es", relativeToURL: forcastBaseUrl)!
                    }
                } else {
                    
                    if segmentedControl.selectedSegmentIndex == 0{
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=ca&exclude=hourly,alerts,flags", relativeToURL: forcastBaseUrl)!
                    } else {
                        url = NSURL(string: "\(key)/\(lat),\(long)?units=us&exclude=hourly,alerts,flags", relativeToURL: forcastBaseUrl)!
                    }
            }
             // Progress bar show
            dispatch_async(dispatch_get_main_queue(), {
                if self.refreshing == false{
            self.progressBarDisplayer("Refreshing", true)
                    self.refreshing = true
                print("refreshing")
                }
            })
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)){
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                guard let realResponse = response as? NSHTTPURLResponse where
                    realResponse.statusCode == 200 else {             //Has to have a min of 500 response
                        
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
                            }
                
               
                    print(cIconString)
                    //Forecast Grabber
                    if let data = jsonContent["daily"]["data"].array{
                        for data in data {
                            
                            self.forcastTempMin.append(Int(round(data["temperatureMin"].double!)))
                            self.forcastTempMax.append(Int(round(data["temperatureMax"].double!)))
                           // self.forcastIconString.append(data["icon"].string!)
                            let dIconString = data["icon"].string!
                            let date = NSDate(timeIntervalSince1970: data["time"].double!)
                            self.forcastWeekDay.append(self.getDayOfWeek(date))
                            let dateS = String(date)
                            let dateArrayWithTime = dateS.componentsSeparatedByString("-")
                            let dateArrayDayOnly = dateArrayWithTime[2].componentsSeparatedByString(" ")
                            self.forcastDay.append(dateArrayDayOnly[0])
                            self.forcastIconImg.append(self.iconChecker(dIconString))
                           // print(dateArrayDayOnly[0])
                           
                           
                        }
                        
                      //  self.maxForcastTemp = self.forcastTempMax.maxElement()!
                    }
                    
                dispatch_async(dispatch_get_main_queue(), {
                 //   self.messageFrame.removeFromSuperview()
                    
                    self.forcastView.reloadData()
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        if self.fromSearchEngine == false{
                            UIApplication.sharedApplication().applicationIconBadgeNumber = Int(round(cTemp))
                        }
                        self.tempLabel.text = String(Int(round(cTemp))) + "˚"
                        self.humidityLabel.text = String(Int(round(cHumidity*100))) + "%"
                        self.pressureLabel.text = String(Int(round(cPressure))) +  NSLocalizedString(" mBar", comment: "milli Bar")
                        self.windSpeedLabel.text = String(Int(round(cWindSpeed))) + NSLocalizedString(" Km/h", comment: "Kilo fe El sa3a")
                        self.realFeelLabel.text = String(Int(round(cFeelsLike))) + "˚"
                        self.windDirectionLabel.text = self.windDirectionNotation(cWindDirection)
                        self.rainChanceLabel.text = String(Int(round(cRainChance * 100))) + "%"
                        if let cVisibility = jsonContent["currently"]["visibility"].double{
                            self.visibilityLabel.text = String(Int(round(cVisibility))) + NSLocalizedString(" Km", comment: "Km")
                        } else {
                            self.visibilityLabel.text = "n/a" + NSLocalizedString(" Km", comment: "Km")
                        }
                        self.descriptionLabel.text = cSummary
                        self.descriptionMoreLabel.text = cDailySummary
                        self.bgImage.image = self.bgPicker(cIconString) //Change BG according to currently weather conditions.
                        
                    } else {
                        if self.fromSearchEngine == false{
                            UIApplication.sharedApplication().applicationIconBadgeNumber = Int(round(cTemp))
                        }
                        self.tempLabel.text = String(Int(round(cTemp))) + "˚"
                        self.humidityLabel.text = String(Int(round(cHumidity*100))) + "%"
                        self.pressureLabel.text = String(Int(round(cPressure))) + NSLocalizedString(" mBar", comment: "milli Bar")
                        self.windSpeedLabel.text = String(Int(round(cWindSpeed))) + NSLocalizedString(" mph", comment: "meel fee el sa3a")
                        self.realFeelLabel.text = String(Int(round(cFeelsLike))) + "˚"
                        self.windDirectionLabel.text = self.windDirectionNotation(cWindDirection)
                        self.rainChanceLabel.text = String(Int(round(cRainChance * 100))) + "%"
                        if let cVisibility = jsonContent["currently"]["visibility"].double{
                            self.visibilityLabel.text = String(Int(round(cVisibility))) + NSLocalizedString(" mi", comment: "meel")
                        } else {
                            self.visibilityLabel.text = "n/a" + NSLocalizedString(" mi", comment: "meel")
                        }
                        self.descriptionLabel.text = cSummary
                        self.descriptionMoreLabel.text = cDailySummary
                        self.bgImage.image = self.bgPicker(cIconString) //Change BG according to currently weather conditions.
                        
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
        }

        
    }

    
    func bgPicker(iconString: String) -> UIImage{
        
        var bg = UIImage()
        if iconString == "clear-day"{
            bg = UIImage(named: "ClearDayBg2x.png")!
        } else if iconString == "clear-night"{
            bg = UIImage(named: "clear nightBg2x.png")!
        } else if iconString == "rain"{
            bg = UIImage(named: "RainBg2x.png")!
        } else if iconString == "snow"{
            bg = UIImage(named: "snowBg2x.png")!
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
    
    func iconChecker(iconString: String) -> UIImage {
        
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
    
    func windDirectionNotation(direction: Double) -> String{
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let userLocation = locations.last
        longitude = (userLocation?.coordinate.longitude)!
        latitude = (userLocation?.coordinate.latitude)!
        manager.stopUpdatingLocation()

        self.getLocationAddress(latitude, long: longitude, key: googleKey)
        self.getWeather(latitude, long: longitude, key: forcastioKey)
        

    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return forcastTempMin.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collection", forIndexPath: indexPath) as! ForcastCollectionViewCell


        cell.cellImage.image = forcastIconImg[indexPath.row]
        cell.timeLabel.text = forcastWeekDay[indexPath.row]
        
//        if (forcastTempMin[indexPath.row] == forcastTempMin.minElement()){
//            cell.tempLabel.textColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1.0)
//            print(forcastTempMin.minElement())
//        }
        cell.tempLabel.text = String(forcastTempMin[indexPath.row])+"˚"
   
//            if (forcastTempMax[indexPath.row] == forcastTempMax.maxElement()){
//                cell.temp2Label.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1.0)
//                print(forcastTempMax.maxElement())
//            }

        cell.temp2Label.text = String(forcastTempMax[indexPath.row])+"˚"
        cell.dayLabel.text = String(forcastDay[indexPath.row])
        
        
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }


}


