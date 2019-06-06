//
//  GoogleTranslate.swift
//  SpeechTranslate
//
//  Created by Krishna Hingu on 6/6/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//
 // this is test 
import Foundation

public struct GoogleTranslateParameters {
    
    public init() {
        
    }
    
    public init(source:String, target:String, text:String) {
        self.source = source
        self.target = target
        self.text = text
    }
    
    public var source = "en"
    public var target = "de"
    public var text = "This cool app is done by Pouriya-Krish-Ashna"
}

open class GoogleTranslate {
    
    public var apiKey = "AIzaSyBcCqUyTuUHQTU-cv2mLoicLDHD9_dW2RU"
    
    public init() {
        
    }
    
    open func translate(params:GoogleTranslateParameters, callback:@escaping (_ translatedText:String) -> ()) {
        
        guard apiKey != "" else {
            print("Warning: You should set the api key before calling the translate method.")
            return
        }
        
        if let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            if let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(self.apiKey)&q=\(urlEncodedText)&source=\(params.source)&target=\(params.target)&format=text") {
                
                let httprequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        print("Something went wrong: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        guard httpResponse.statusCode == 200 else {
                            
                            if let data = data {
                                print("Response [\(httpResponse.statusCode)] - \(data)")
                            }
                            
                            return
                        }
                        
                        do {
                            if let data = data {
                                if let json = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                                    if let jsonData = json["data"] as? [String : Any] {
                                        if let translations = jsonData["translations"] as? [NSDictionary] {
                                            if let translation = translations.first as? [String : Any] {
                                                if let translatedText = translation["translatedText"] as? String {
                                                    callback(translatedText)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("Serialization failed: \(error.localizedDescription)")
                        }
                    }
                })
                
                httprequest.resume()
            }
        }
    }
}

