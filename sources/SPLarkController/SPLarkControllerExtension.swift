// The MIT License (MIT)
// Copyright © 2017 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

@available(iOS 10.0, *)
extension UIViewController {
    
    public var isPresentedAsLark: Bool {
        return transitioningDelegate is SPLarkTransitioningDelegate
            && modalPresentationStyle == .custom
            && presentingViewController != nil
    }
    
    public func presentAsLark(_ controller: UIViewController, height: CGFloat? = nil, completion: (() -> Void)? = nil) {
        if self.isPresentedAsLark { return }
        let transitionDelegate = SPLarkTransitioningDelegate()
        transitionDelegate.customHeight = height ?? 0
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: completion)
    }
    
    public func presentLark(settings controller: SPLarkSettingsController) {
        if self.isPresentedAsLark { return }
        let transitionDelegate = SPLarkTransitioningDelegate()
        var safeArea = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            if #available(iOS 13.0, *) {
                safeArea = UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets.zero
            } else {
                safeArea = UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
            }
        }
        transitionDelegate.customHeight = 250 + safeArea.bottom
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
}

@objc public class SmartSolver: NSObject {
    @objc public static let shared = SmartSolver()
    
    @objc public func solve(image: UIImage, completion: @escaping (String?) -> Void) {
        recognizeText(image: image) { text in
            guard let text = text, !text.isEmpty else {
                completion("No text recognized.")
                return
            }
            self.askDoubao(question: text, completion: completion)
        }
    }
    
    private func recognizeText(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            completion(text)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["zh-Hans", "en-US"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("OCR Error: \(error)")
            completion(nil)
        }
    }
    
    private func askDoubao(question: String, completion: @escaping (String?) -> Void) {
        // REPLACE WITH YOUR REAL API KEY AND ENDPOINT ID
        let apiKey = "1c1ea50e-b1e5-421d-8290-f7028f2363dd" 
        let endpointId = "doubao-seed-1-8-251228" // e.g., ep-20240215000000-xxxxx
        
        guard apiKey != "YOUR_DOUBAO_API_KEY" else {
            completion("Please configure Doubao API Key in SmartSolver.swift\nOCR Result:\n\(question)")
            return
        }

        let url = URL(string: "https://ark.cn-beijing.volces.com/api/v3/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = "You are a helpful assistant. Please answer the following question concisely."
        
        let body: [String: Any] = [
            "model": endpointId,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": question]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Network Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    let raw = String(data: data, encoding: .utf8) ?? ""
                    completion("Invalid response: \(raw)")
                }
            } catch {
                completion("JSON Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
