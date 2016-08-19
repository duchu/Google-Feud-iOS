//
//  ViewController.swift
//  GoogleFued
//
//  Created by Carson Katri on 8/11/16.
//  Copyright © 2016 Carson Katri. All rights reserved.
//
//  Concept by Justin Hook
//  View his site at http://googlefeud.com

import UIKit
import SwiftyJSON
import Alamofire
import PromiseKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    // MARK: Completions UI
    
    @IBOutlet weak var comp1: UIView!
    @IBOutlet weak var comp2: UIView!
    @IBOutlet weak var comp3: UIView!
    @IBOutlet weak var comp4: UIView!
    @IBOutlet weak var comp5: UIView!
    @IBOutlet weak var comp6: UIView!
    @IBOutlet weak var comp7: UIView!
    @IBOutlet weak var comp8: UIView!
    @IBOutlet weak var comp9: UIView!
    @IBOutlet weak var comp10: UIView!
    
    
    
    // MARK: Variable setup
    
    @IBOutlet weak var answer: UITextField!
    
    @IBOutlet weak var nextRound: UIButton!
    // gfXs is the huge red Xs
    @IBOutlet weak var gfXs: UIImageView!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    // Query has to be added
    let url: String = "http://suggestqueries.google.com/complete/search?client=firefox&q="
    
    var category: Int = 0
    var question: String = "Nothing found.. :("
    
    var tries = 0
    
    let identifier = "GFCell"
    
    @IBOutlet weak var playerScore: UILabel!
    var score = 0
    let defaults = NSUserDefaults.standardUserDefaults()
    let key = "score"
    
    
    
    // MARK: Initial Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fix the score
        score = defaults.integerForKey(key)
        updateScore()
        
        // Do any additional setup after loading the view, typically from a nib.
        newQuestion(category)
        
        // Hide some stuff
        self.nextRound.hidden = true
        self.answer.hidden = false
        self.searchBtn.hidden = false
        //self.gfXs.hidden = true
        
        // Squared opacity radius on text field
        answer.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    override func viewDidAppear(animated: Bool) {
        answer.delegate = self
        
        // Make the textField active
        answer.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showItemSegue") {
            let controller: CategoryViewController = (segue.destinationViewController as! UINavigationController).topViewController as! CategoryViewController
        }
    }
    
    
    
    // MARK: IBActions
    @IBAction func search(sender: AnyObject) {
        
        // End editing
        self.answer.endEditing(true)
        
        /*
        if checkAnswer() {
            // They were right!
            // Fix textbox
            
            self.answer.text = ""
            createPrefix()
        } else {
            if tries > 2 {
                tries = 0
                newQuestion(category)
            }
        }
        */

        checkAnswer()
        
        print("\n\nTRIES LEFT: \(tries)")
    }
    
    // Pressing Enter does the same as pressing search
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkAnswer()
        print("\n\nTRIES LEFT: \(tries)")
        return true
    }
    
    @IBAction func nextRound(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Functions
    
    // Prefix
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //This makes the new text black.
        textField.typingAttributes = [NSForegroundColorAttributeName:UIColor.blackColor()]
        let protectedRange = NSMakeRange(0, 6)
        let intersection = NSIntersectionRange(protectedRange, range)
        if intersection.length > 0 {
            
            return false
        }
        
        if range.location < self.question.characters.count + 1 {
            return false
        }
        
        return true
    }
    
    func createPrefix() {
        let attributedString = NSMutableAttributedString(string: question + " ")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, question.characters.count))
        answer.attributedText = attributedString
    }
    
    
    // Questions
    func newQuestion(category: Int) {
        
        question = GFQuestions().getQuestionByCategory(category)
        createPrefix()
        
        // Fill the completions view
        var query: String = self.question
        query = query.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        print(query)
        Alamofire.request(.GET, "\(url)\(query)%20").validate().responseJSON { response in
            switch response.result {
            case .Success:
                print("SUCCESS")
                if let value = response.result.value {
                    let json = JSON(value)
                    print("JSON: \(json)")
                    let completions = json[1]
                    print(completions)
                    var index = 0
                    for completion in completions {
                        
                        print(completion.1)
                        switch index {
                        case 0:
                            let label = self.comp1.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 1:
                            let label = self.comp2.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 2:
                            let label = self.comp3.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 3:
                            let label = self.comp4.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 4:
                            let label = self.comp5.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 5:
                            let label = self.comp6.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 6:
                            let label = self.comp7.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 7:
                            let label = self.comp8.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 8:
                            let label = self.comp9.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        case 9:
                            let label = self.comp10.viewWithTag(1) as? UILabel
                            label?.text = completion.1.string
                            break
                        default:
                            break
                        }
                        
                        index += 1
                    }
                    
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
        
        // Fix the covers
        comp1.viewWithTag(0)!.hidden = false
        comp2.viewWithTag(0)!.hidden = false
        comp3.viewWithTag(0)!.hidden = false
        comp4.viewWithTag(0)!.hidden = false
        comp5.viewWithTag(0)!.hidden = false
        comp6.viewWithTag(0)!.hidden = false
        comp7.viewWithTag(0)!.hidden = false
        comp8.viewWithTag(0)!.hidden = false
        comp9.viewWithTag(0)!.hidden = false
        comp10.viewWithTag(0)!.hidden = false
        
    }
    
    func callService(query: String) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            Alamofire.request(.GET, "\(url)\(query)%20").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    print("SUCCESS")
                    if let value = response.result.value {
                        let json = JSON(value)
                        print("JSON: \(json)")
                        let completions = json[1]
                        print(completions)
                        var index = 10
                        for completion in completions {
                            
                            print(completion.1)
                            
                            if completion.1 == JSON((self.answer.text?.lowercaseString)!) {
                                print("CORRECT!")
                                
                                print("\((self.answer.text?.lowercaseString)!)")
                                print("\n\(completion.1) equals \(JSON((self.answer.text?.lowercaseString)!))")
                                
                                // Show the answer
                                switch completion.1 {
                                case json[1][0]:
                                    let cover = self.comp1.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][1]:
                                    let cover = self.comp2.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][2]:
                                    let cover = self.comp3.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][3]:
                                    let cover = self.comp4.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][4]:
                                    let cover = self.comp5.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][5]:
                                    let cover = self.comp6.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][6]:
                                    let cover = self.comp7.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][7]:
                                    let cover = self.comp8.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][8]:
                                    let cover = self.comp9.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                case json[1][9]:
                                    let cover = self.comp10.viewWithTag(0)! as UIView
                                    cover.hidden = true
                                    break
                                default:
                                    break
                                }
                                
                                // Give the player the points they deserve
                                self.score += index * 1000
                                self.updateScore()
                                
                                fulfill(true)
                                return
                            }
                            
                            index -= 1
                        }
                        self.tries += 1
                        // Show an X
                        switch self.tries {
                        case 1:
                            self.gfXs.image = UIImage(named: "Google Feud 1 X.png")
                            break
                        case 2:
                            self.gfXs.image = UIImage(named: "Google Feud 2 X.png")
                            break
                        case 3:
                            self.gfXs.image = UIImage(named: "Google Feud 3 X.png")
                            break
                        default:
                            self.gfXs.image = UIImage(named: "GFLogo.png")
                            break
                        }
                        fulfill(false)
                    }
                case .Failure(let error):
                    print(error)
                    reject(error)
                }
            }
            
        }
    }
    
    
    func checkAnswer() -> Void {
        
       
        // Get the content from suggestqueries.google.com
        // Replace spaces with %20
        var query: String = self.question
        query = query.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        print(query)
        
        firstly {
            callService(query)
        }
        .then { correct -> Bool in
            
            // Set the player score
            
            
            if correct {
                
                // Check if they won
                let cover = self.comp1.viewWithTag(0)! as UIView
                let cover1 = self.comp2.viewWithTag(0)! as UIView
                let cover2 = self.comp3.viewWithTag(0)! as UIView
                let cover3 = self.comp4.viewWithTag(0)! as UIView
                let cover4 = self.comp5.viewWithTag(0)! as UIView
                let cover5 = self.comp6.viewWithTag(0)! as UIView
                let cover6 = self.comp7.viewWithTag(0)! as UIView
                let cover7 = self.comp8.viewWithTag(0)! as UIView
                let cover8 = self.comp9.viewWithTag(0)! as UIView
                let cover9 = self.comp10.viewWithTag(0)! as UIView
                
                if cover.hidden == true && cover1.hidden == true && cover2.hidden == true && cover3.hidden == true && cover4.hidden == true && cover5.hidden == true && cover6.hidden == true && cover7.hidden == true && cover8.hidden == true && cover9.hidden == true {
                    
                    self.tries = 0
                    // self.newQuestion(self.category)
                    self.nextRound.hidden = false
                    self.answer.hidden = true
                    self.searchBtn.hidden = true
                    self.showAnswers()
                    
                }
            }
            else {
                print("WRONG")
                if self.tries > 2 {
                    self.tries = 0
                    // self.newQuestion(self.category)
                    self.nextRound.hidden = false
                    self.answer.hidden = true
                    self.searchBtn.hidden = true
                    self.showAnswers()
                    // Save the players new score to defaults
                    self.defaults.setInteger(self.score, forKey: self.key)
                }
            }
            
            self.answer.text = ""
            self.createPrefix()
            
            return correct
        }
    }
    
    
    func showAnswers() {
        
        let cover = self.comp1.viewWithTag(0)! as UIView
        cover.hidden = true
        let cover1 = self.comp2.viewWithTag(0)! as UIView
        cover1.hidden = true
        let cover2 = self.comp3.viewWithTag(0)! as UIView
        cover2.hidden = true
        let cover3 = self.comp4.viewWithTag(0)! as UIView
        cover3.hidden = true
        let cover4 = self.comp5.viewWithTag(0)! as UIView
        cover4.hidden = true
        let cover5 = self.comp6.viewWithTag(0)! as UIView
        cover5.hidden = true
        let cover6 = self.comp7.viewWithTag(0)! as UIView
        cover6.hidden = true
        let cover7 = self.comp8.viewWithTag(0)! as UIView
        cover7.hidden = true
        let cover8 = self.comp9.viewWithTag(0)! as UIView
        cover8.hidden = true
        let cover9 = self.comp10.viewWithTag(0)! as UIView
        cover9.hidden = true
        
    }
    
    func updateScore() {
        
        let scoreForm = NSNumberFormatter()
        scoreForm.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        playerScore.text = "\(scoreForm.stringFromNumber(score)!)"
        
    }
    
    @IBAction func searchAnswer(sender: UIButton) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.google.com/#q=\(sender.titleLabel?.text)")!)
        
    }
    
}
