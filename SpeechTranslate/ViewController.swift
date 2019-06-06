//
//  ViewController.swift
//  SpeechTranslate
//
//  Created by Krishna Hingu on 6/6/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import UIKit
import Speech
import Foundation

extension UIButton {
    //MARK: StartBlink
    func startPulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.94
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
    
    func startBlink() {
        UIView.animate(withDuration: 0.8,//Time duration
            delay:0.0,
            options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
            animations: { self.alpha = 0 },
            completion: nil)
    }
    
    //MARK: StopBlink
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
class ViewController: UIViewController {
    
    public var speechRecognizer = SFSpeechRecognizer (locale: Locale.init(identifier: "en"))
    public var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    public var recognitionTask: SFSpeechRecognitionTask?
    public var audioEngine = AVAudioEngine ()
    var lang: String = "en"
    var lang2: String = "es"
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var translation: UITextView!
    @IBOutlet weak var speechBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 1, green: 0.9882, blue: 0.9686, alpha: 1.0)
        //startStopButton.isEnabled = false
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate
        speechRecognizer = SFSpeechRecognizer (locale: Locale.init(identifier: lang))
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            //var isButtonEnabled = false
//            switch authStatus {
//            case .authorized:
//                isButtonEnabled = true
//            case .denied:
//                isButtonEnabled = false
//                print ("User denied access to speech recognition")
//            case .restricted:
//                isButtonEnabled = false
//                print ("Speech recognition restricted on this device")
//            case .notDetermined:
//                isButtonEnabled = false
//                print ("Speech recognition not yet authorized")
//            @unknown default:
//                print ("Speech recognition not yet authorized")
//            }
//
//            OperationQueue.main.addOperation() {
//                //self.startStopButton.isEnabled = isButtonEnabled
//            }
        }
        
    }

    @IBAction func recordButtonTapped(_ sender: Any) {
        speechBtn.startBlink()
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        startRecording()
    }
   
    @IBAction func translateButton(_ sender: UIButton) {
        sender.startPulsate()
        speechBtn.stopBlink()
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        let translator = GoogleTranslate()
        translator.apiKey = "AIzaSyBcCqUyTuUHQTU-cv2mLoicLDHD9_dW2RU"
        
        var params = GoogleTranslateParameters()
        params.source = lang
        params.target = lang2
        params.text = textView.text
        
        translator.translate(params: params) { (result) in
            DispatchQueue.main.async {
                self.translation.text = "\(result)"
            }
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            
        } catch {
            print("audioSession properties were not set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: {(result, error) in
            var isFinal = false
            if result != nil {
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil

            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            
            try audioEngine.start()
            
        } catch { print("auidoEngine couldnt start because of an error.") }
        
        textView.text = "I am Listening Now ... Say Something!"
    }
    
    @IBAction func firstLanguageChange(_ sender: Any) {
        
    }
    @IBAction func secondLangugaeChange(_ sender: Any) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

