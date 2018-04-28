//
//  ViewController.swift
//  Assignment 2
//
//  Created by Clint Sellen on 28/4/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import UIKit

//https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f
//MARK: - UIViewController Properties
class ViewController: UIViewController {

    
    
//_____________________________________________________________ Start Timer
    
    //MARK: - IBOutlets
//    @IBOutlet weak var startButton: UIButton!
//    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    var seconds = 80
    var timer = Timer()
    
    var isTimerRunning = false
    var resumeTapped = false
    
    //MARK: - IBActions
//    @IBAction func startButtonTapped(_ sender: UIButton) {
//        if isTimerRunning == false {
//            runTimer()
//            self.startButton.isEnabled = false
//        }
//    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
//        pauseButton.isEnabled = true
    }
    
//    @IBAction func pauseButtonTapped(_ sender: UIButton) {
//        if self.resumeTapped == false {
//            timer.invalidate()
//            isTimerRunning = false
//            self.resumeTapped = true
//            self.pauseButton.setTitle("Resume",for: .normal)
//        } else {
//            runTimer()
//            self.resumeTapped = false
//            isTimerRunning = true
//            self.pauseButton.setTitle("Pause",for: .normal)
//        }
//    }
    
//    @IBAction func resetButtonTapped(_ sender: UIButton) {
//        timer.invalidate()
//        seconds = 60
//        timerLabel.text = timeString(time: TimeInterval(seconds))
//        isTimerRunning = false
//        pauseButton.isEnabled = false
//        startButton.isEnabled = true
//    }
    
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            timerLabel.text = "Times Up"
            //Send alert to indicate time's up.
        } else {
            seconds -= 1
            if seconds >= 60 {
                timerLabel.text = timeString(time: TimeInterval(seconds))
            } else {
                timerLabel.text = String(seconds)
            }
            //            labelButton.setTitle(timeString(time: TimeInterval(seconds)), for: UIControlState.normal)
        }
    }
    
    func timeString(time:TimeInterval) -> String {
//        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
//        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        return String(format:"%i:%02i", minutes, seconds)
    }
    
    //_____________________________________________________________ End Timer
    //MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        timerLabel.text = "Start Now"
        runTimer()
//        pauseButton.isEnabled = false
        
        let circleFrame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
        let circle = UIView(frame: circleFrame)
        circle.backgroundColor = .red
        circle.layer.cornerRadius = 20
        circle.layer.borderColor = UIColor.black.cgColor
        circle.layer.borderWidth = 1
        circle.center = self.view.center
        
        self.view.addSubview(circle)
        
        
        self.myTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer: Timer)  in self.update(view: circle)
        })
    }
    
    var myTimer: Timer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    func update(view : UIView)  {
        let circle = view
        UIView.animate(withDuration: 0.5, animations: {
            circle.alpha = 0.75
            circle.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//            circle.transform = CGAffineTransform(translationX: +1.0, y: -1.0)
        }) { (_) in
            circle.transform = CGAffineTransform.identity
        }
    }
}

