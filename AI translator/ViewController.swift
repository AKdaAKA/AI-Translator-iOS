//
//  ViewController.swift
//  AI translator
//
//  Created by Aakash Bhagavathi on 5/25/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var outputTextView: UITextView!
    
    // Loads the API key safely from Keys.plist (which is ignored by Git)
    var apiKey: String {
        if let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: filePath),
           let value = plist.object(forKey: "GEMINI_API_KEY") as? String {
            return value
        }
        print("WARNING: Keys.plist or GEMINI_API_KEY not found in bundle! Make sure to add it to the Xcode project and check Target Membership.")
        return ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        outputTextView.text = ""
    }

    @IBAction func translateButtonTapped(_ sender: UIButton) {
        let originalText = inputTextView.text ?? ""
        
        if originalText.isEmpty || originalText == "Enter text here to translate..." {
            outputTextView.text = "Please enter some text first!"
            return
        }
        
        outputTextView.text = "Translating..."
        translateWithGemini(text: originalText)
    }
    
    func translateWithGemini(text: String) {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        //  This is the prompt engineering — tells Gemini to translate cleanly
        let prompt = """
        Translate the following text to Spanish. \
        Output ONLY the translated text. \
        No explanations, no alternatives, no punctuation changes, no fluff, it should be natural. \
        Just the direct translation:
        
        \(text)
        """
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Always update UI on the main thread
            DispatchQueue.main.async {
                if let error = error {
                    self.outputTextView.text = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.outputTextView.text = "No response received."
                    return
                }
                
                // Parse the Gemini JSON response
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let first = candidates.first,
                   let content = first["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let translatedText = parts.first?["text"] as? String {
                    self.outputTextView.text = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    // Print the raw response so we can see what went wrong
                    if let rawString = String(data: data, encoding: .utf8) {
                        print("RAW RESPONSE: \(rawString)")
                        self.outputTextView.text = "Debug: \(rawString)"
                    } else {
                        self.outputTextView.text = "Could not read response at all."
                    }
                }
                
            }
        }.resume()
    }
}
