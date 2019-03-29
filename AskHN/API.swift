//
//  API.swift
//  AskHN
//
//  Created by Andrew Nater on 3/27/19.
//  Copyright © 2019 Andrew Nater. All rights reserved.
//

import Foundation

class HackerNewsAPI {
    
    let rootURL = "https://hacker-news.firebaseio.com/v0/"
    
    private func request(endpoint: String, completionHandler: @escaping (Any?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url(for: endpoint)) { data, response, error in
            print("request for \(endpoint)")
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let data = data,
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.mimeType != nil && httpResponse.mimeType == "application/json" {
                print("we have data!")
                do {
                    let options = JSONSerialization.ReadingOptions(arrayLiteral: .mutableContainers)
                    let json = try JSONSerialization.jsonObject(with: data, options: options)
                    completionHandler(json, nil)
                } catch {
                    print("json failed")
                    let error = NSError(domain: "JSON Error", code: 0)
                    completionHandler(nil, error)
                }
            }
        }.resume()
    }
    
    private func url(for endpoint: String) -> URL {
        return URL(string: rootURL + endpoint + ".json")!
    }
    
    func ask(completionHandler: @escaping (Any?, Error?) -> Void) {
        request(endpoint: "askstories", completionHandler: completionHandler)
    }
    
    func item(withID id: Int, completionHandler: @escaping (Any?, Error?) -> Void) {
        request(endpoint: "item/\(id)", completionHandler: completionHandler)
    }
    
    func items(ids: Array<Int>, completionHandler: @escaping (Any?, Error?) -> Void) {
        let group = DispatchGroup()
        var responses = [Any]()
        
        for id in ids {
            group.enter()
            item(withID: id) { (data, error) in
                if error != nil {
                    let message = "⚠️ Error with item \(id)"
                    let error = NSError(domain: message, code: 2)
                    print(message)
                    completionHandler(nil, error)
                }
                if data != nil {
                    responses.append(data!)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("items have all loaded")
            if (responses.count > 0 && responses.count == ids.count) {
                completionHandler(responses, nil)
            }
        }
    }
}
