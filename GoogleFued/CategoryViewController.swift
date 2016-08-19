//
//  CategoryViewController.swift
//  GoogleFued
//
//  Created by Carson Katri on 8/14/16.
//  Copyright © 2016 Carson Katri. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    
    var category = 0
    
    @IBOutlet weak var score: UILabel!
    let key = "score"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let format = NSNumberFormatter()
        format.numberStyle = NSNumberFormatterStyle.DecimalStyle
        score.text = "\(format.stringFromNumber(defaults.integerForKey(key))!)"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let GFViewController = segue.destinationViewController as! ViewController
        GFViewController.category = category
    }
    
    @IBAction func culture(sender: AnyObject) {
        category = 0
    }
    
    @IBAction func people(sender: AnyObject) {
        category = 1
    }
    
    @IBAction func names(sender: AnyObject) {
        category = 2
    }
    
    @IBAction func questions(sender: AnyObject) {
        category = 3
    }
    
    @IBAction func resetScore(sender: AnyObject) {
        defaults.setInteger(0, forKey: key)
        let format = NSNumberFormatter()
        format.numberStyle = NSNumberFormatterStyle.DecimalStyle
        score.text = "\(format.stringFromNumber(defaults.integerForKey(key))!)"
    }
}