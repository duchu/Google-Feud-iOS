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

// Extensions
extension UIViewController {
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

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
    let key = ["score", "guess"]
    
    // Hints
    @IBOutlet weak var hintBtn: UIButton!
    var hints: Bool = false
    
    // Answers found tracker
    var found: Int = 0
    var foundStrings = [String]()
    
    
    
    // MARK: Initial Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardOnTap()
        
        // Fix the score
        score = defaults.integerForKey(key[0])
        updateScore()
        
        // Do any additional setup after loading the view, typically from a nib.
        question = GFQuestions().getQuestionByCategory(category)
        createPrefix()
        newQuestion()
        
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
            print(controller)
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
        
        if !foundStrings.contains(answer.text!.lowercaseString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())) {
            checkAnswer()
        }
        
        print("\n\nTRIES LEFT: \(tries)")
    }
    
    // Pressing Enter does the same as pressing search
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print(foundStrings)
        if !foundStrings.contains(answer.text!.lowercaseString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())) {
            checkAnswer()
        }
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
    func newQuestion() {
        
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
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 1:
                            let label = self.comp2.viewWithTag(-2) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 2:
                            let label = self.comp3.viewWithTag(-3) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 3:
                            let label = self.comp4.viewWithTag(4) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 4:
                            let label = self.comp5.viewWithTag(5) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 5:
                            let label = self.comp6.viewWithTag(6) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 6:
                            let label = self.comp7.viewWithTag(7) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 7:
                            let label = self.comp8.viewWithTag(8) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 8:
                            let label = self.comp9.viewWithTag(9) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
                            break
                        case 9:
                            let label = self.comp10.viewWithTag(10) as? UILabel
                            label?.text = completion.1.string
                            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.searchLabel(_:)))
                            label?.addGestureRecognizer(tap)
                            label?.userInteractionEnabled = true
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
                            
                            if completion.1 == JSON((self.answer.text?.lowercaseString)!.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())) {
                                print("CORRECT!")
                                // Add the string to the array
                                self.foundStrings.append(completion.1.string!)
                                print("\((self.answer.text?.lowercaseString)!)")
                                print("\n\(completion.1) equals \(JSON((self.answer.text?.lowercaseString)!))")
                                
                                // Show the answer
                                switch completion.1 {
                                case json[1][0]:
                                    let cover = self.comp1.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                    }, completion: nil)
                                    let label = self.comp1.viewWithTag(1) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][1]:
                                    let cover = self.comp2.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp2.viewWithTag(-2) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][2]:
                                    let cover = self.comp3.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp3.viewWithTag(-3) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][3]:
                                    let cover = self.comp4.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp4.viewWithTag(4) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][4]:
                                    let cover = self.comp5.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp5.viewWithTag(5) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][5]:
                                    let cover = self.comp6.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp6.viewWithTag(6) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][6]:
                                    let cover = self.comp7.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp7.viewWithTag(7) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][7]:
                                    let cover = self.comp8.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp8.viewWithTag(8) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][8]:
                                    let cover = self.comp9.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp9.viewWithTag(9) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                case json[1][9]:
                                    let cover = self.comp10.viewWithTag(0)! as UIView
                                    cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
                                    for view in cover.subviews {
                                        view.hidden = true
                                    }
                                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
                                        
                                        cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
                                        
                                        }, completion: nil)
                                    let label = self.comp10.viewWithTag(10) as? UILabel
                                    label?.text = completion.1.string
                                    break
                                default:
                                    break
                                }
                                
                                // Give the player the points they deserve
                                if self.hints {
                                    self.score += index * 500
                                    self.updateScore()
                                } else {
                                    self.score += index * 1000
                                    self.updateScore()
                                }
                                
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
        
        // Add one to the guesses
        defaults.setInteger(defaults.integerForKey("guess") + 1, forKey: key[1])
       
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
                
                self.found += 1
                
                // Check if they won
                if self.found >= 9 {
                    
                    self.tries = 0
                    // self.newQuestion(self.category)
                    self.nextRound.hidden = false
                    self.answer.hidden = true
                    self.searchBtn.hidden = true
                    self.showAnswers(true)
                    
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
                    if self.hints {
                        self.newQuestion()
                    }
                    self.showAnswers(true)
                    // Save the players new score to defaults
                    self.defaults.setInteger(self.score, forKey: self.key[0])
                }
            }
            
            self.answer.text = ""
            self.createPrefix()
            
            return correct
        }
    }
    
    
    func showAnswers(shown: Bool) {
        
        let cover = self.comp1.viewWithTag(0)! as UIView
        cover.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover.frame = CGRectMake(cover.frame.maxX, 0, 0, cover.frame.height)
            
            }, completion: nil)
        let cover1 = self.comp2.viewWithTag(0)! as UIView
        cover1.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover1.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover1.frame = CGRectMake(cover1.frame.maxX, 0, 0, cover1.frame.height)
            
            }, completion: nil)
        let cover2 = self.comp3.viewWithTag(0)! as UIView
        cover2.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover2.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover2.frame = CGRectMake(cover2.frame.maxX, 0, 0, cover2.frame.height)
            
            }, completion: nil)
        let cover3 = self.comp4.viewWithTag(0)! as UIView
        cover3.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover3.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover3.frame = CGRectMake(cover3.frame.maxX, 0, 0, cover3.frame.height)
            
            }, completion: nil)
        let cover4 = self.comp5.viewWithTag(0)! as UIView
        cover4.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover4.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover4.frame = CGRectMake(cover4.frame.maxX, 0, 0, cover4.frame.height)
            
            }, completion: nil)
        let cover5 = self.comp6.viewWithTag(0)! as UIView
        cover5.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover5.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover5.frame = CGRectMake(cover5.frame.maxX, 0, 0, cover5.frame.height)
            
            }, completion: nil)
        let cover6 = self.comp7.viewWithTag(0)! as UIView
        cover6.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover6.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover6.frame = CGRectMake(cover6.frame.maxX, 0, 0, cover6.frame.height)
            
            }, completion: nil)
        let cover7 = self.comp8.viewWithTag(0)! as UIView
        cover7.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover7.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover7.frame = CGRectMake(cover7.frame.maxX, 0, 0, cover7.frame.height)
            
            }, completion: nil)
        let cover8 = self.comp9.viewWithTag(0)! as UIView
        cover8.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover8.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover8.frame = CGRectMake(cover8.frame.maxX, 0, 0, cover8.frame.height)
            
            }, completion: nil)
        let cover9 = self.comp10.viewWithTag(0)! as UIView
        cover9.backgroundColor = UIColor(red:0.29, green:0.55, blue:0.95, alpha:1.0)
        for view in cover9.subviews {
            view.hidden = true
        }
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            
            cover9.frame = CGRectMake(cover9.frame.maxX, 0, 0, cover9.frame.height)
            
            }, completion: nil)
        
    }
    
    func hideAnswers() {
        
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
    
    @IBAction func showHint(sender: AnyObject) {
        
        // Fix the button's image
        hints = !hints
        if hints {
            hintBtn.setImage(UIImage(named: "Visible-48.png"), forState: .Disabled)
            // Show the hints
            showHints()
            showAnswers(true)
            // Make the answers you already got appear
            var query: String = self.question
            query = query.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            foundStrings = []
            found = 0
            /*
            for foundAnswer in foundStrings {
                
                print(foundAnswer)
                self.answer.text = foundAnswer
                firstly {
                    
                    callService(query)
                    
                } .then { correct -> Bool in
                        
                    self.answer.text = ""
                    self.createPrefix()
                    
                    return correct
                }
                
            }
            answer.text = ""
            */
        } else {
            hintBtn.setImage(UIImage(named: "Invisible-48.png"), forState: .Disabled)
            hideAnswers()
        }
        
        // Disable the button
        hintBtn.enabled = false
        
    }
    
    func showHints() {

        for index in 0...9 {
            
            switch index {
            case 0:
                let label = self.comp1.viewWithTag(1) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 1:
                let label = self.comp2.viewWithTag(-2) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 2:
                let label = self.comp3.viewWithTag(-3) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 3:
                let label = self.comp4.viewWithTag(4) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 4:
                let label = self.comp5.viewWithTag(5) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 5:
                let label = self.comp6.viewWithTag(6) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 6:
                let label = self.comp7.viewWithTag(7) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 7:
                let label = self.comp8.viewWithTag(8) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 8:
                let label = self.comp9.viewWithTag(9) as? UILabel
                label?.text = createHintString(label?.text)
                break
            case 9:
                let label = self.comp10.viewWithTag(10) as? UILabel
                label?.text = createHintString(label?.text)
                break
            default:
                break
            }
            
            switch index {
            case 0:
                let points = self.comp1.viewWithTag(3) as? UILabel
                points?.text = "5,000"
                break
            case 1:
                let points = self.comp2.viewWithTag(3) as? UILabel
                points?.text = "4,500"
                break
            case 2:
                let points = self.comp3.viewWithTag(3) as? UILabel
                points?.text = "4,000"
                break
            case 3:
                let points = self.comp4.viewWithTag(3) as? UILabel
                points?.text = "3,500"
                break
            case 4:
                let points = self.comp5.viewWithTag(3) as? UILabel
                points?.text = "3,000"
                break
            case 5:
                let points = self.comp6.viewWithTag(3) as? UILabel
                points?.text = "2,500"
                break
            case 6:
                let points = self.comp7.viewWithTag(3) as? UILabel
                points?.text = "2,000"
                break
            case 7:
                let points = self.comp8.viewWithTag(3) as? UILabel
                points?.text = "1,500"
                break
            case 8:
                let points = self.comp9.viewWithTag(3) as? UILabel
                points?.text = "1,000"
                break
            case 9:
                let points = self.comp10.viewWithTag(3) as? UILabel
                points?.text = "500"
                break
            default:
                break
            }
            
        }
    }
    
    func createHintString(target: String?) -> String {
        
        var hint: String = ""
        
        let words: Int = (target?.componentsSeparatedByString(" ").count)!
        
        if words > question.componentsSeparatedByString(" ").count + 1 {
            
            hint = "\(words - question.componentsSeparatedByString(" ").count) words"
            
        } else {
        
            for character in target!.stringByReplacingOccurrencesOfString(question.lowercaseString, withString: "").characters {
                if character == " " {
                    hint = "\(hint) "
                } else {
                    hint = "\(hint)__ "
                }
            }
        }
        
        return hint
        
    }
    
    func searchLabel(sender: UITapGestureRecognizer) {
        
        let tag = sender.view?.tag
        let label = self.view.viewWithTag(-1)!.viewWithTag(tag!) as! UILabel
        print(label.text!)
        let url = "https://google.com/#q=\(label.text!.stringByReplacingOccurrencesOfString(" ", withString: "%20"))"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        
    }
    
}
