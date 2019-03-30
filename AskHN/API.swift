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
    
    private func request(endpoint: String, completionHandler: @escaping (Data?, Error?) throws -> Void) {
        URLSession.shared.dataTask(with: url(for: endpoint)) { data, response, error in
            do {
                if let error = error {
                    try completionHandler(nil, error)
                }
                
                if let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.mimeType == "application/json" {
                    try completionHandler(data, nil)
                }
            } catch let completionError {
                print("Completion Handler Error")
                print(completionError.localizedDescription)
            }
        }.resume()
    }
    
    private func url(for endpoint: String) -> URL {
        return URL(string: rootURL + endpoint + ".json")!
    }
    
    func getAskStories(completionHandler: @escaping ([Int]?, Error?) -> Void) {
        request(endpoint: "askstories") { (data, error) throws in
            guard let data = data else { return }
            guard error == nil else { return completionHandler(nil, error) }
            do {
                // attempt to decode response as Int array
                let decoder = JSONDecoder()
                let items = try decoder.decode([Int].self, from: data)
                completionHandler(items, nil)
            } catch let jsonError as DecodingError {
                // if something went wrong with decoding, return the error
                print(jsonError)
                completionHandler(nil, jsonError)
            }
        }
    }
    
    func getItem(with id: Int, completionHandler: @escaping (HNItem?, Error?) -> Void) {
        request(endpoint: "item/\(id)") { (data, error) throws in
            guard let data = data else { return }
            guard error == nil else { return completionHandler(nil, error) }
            do {
                let decoder = JSONDecoder()
                let item = try decoder.decode(HNItem.self, from: data)
                completionHandler(item, nil)
            } catch let jsonError as DecodingError {
                print(jsonError)
                completionHandler(nil, jsonError)
            }
        }
    }
    
    func getItems(for ids: [Int], completionHandler: @escaping ([HNItem]?, Error?) -> Void) {
        let group = DispatchGroup()
        var responses = [HNItem]()
        
        for id in ids {
            group.enter()
            getItem(with: id) { (item, error) in
                if error != nil {
                    let message = "⚠️ Error with item \(id)"
                    let error = NSError(domain: message, code: 2)
                    print(message)
                    completionHandler(nil, error)
                }
                if let item = item {
                    responses.append(item)
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

struct HNItem: Codable {
    var by: String
    var descendants: Int
    var id: Int
    var kids: [Int]?
    var score: Int
    var text: String? // TODO: use attributeable string to convert from HTML
    var time: Double // TODO: convert to date object from UNIX time
    var title: String // TODO: trim off Ask HN prefixes
    var type: ItemType
    var parent: Int?
    var url: URL?

    enum ItemType: String, Codable {
        case story
        case comment
        case ask
    }
}
