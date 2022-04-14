//
//  SearchAPI.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/14.
//

import Foundation

struct SearchApi {
    
    static func fetchSearchAPI(queryValue: String, compltion: @escaping (Result<[SearchModel], Error>) -> Void) {
        let clientID = "AZNe9xs00tGIlUvyHPXj"
        let secretID = "XbdL_MZyWc"
        
        let query = "https://openapi.naver.com/v1/search/local.json?query=\(queryValue)&display=10&start=1&sort=random"
    
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {return}
        
        guard let url = URL(string: encodedQuery) else {return}
        
        var requestURL = URLRequest(url: url)
        
        requestURL.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        requestURL.addValue(secretID, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        URLSession.shared.dataTask(with: requestURL) { data, respones, error in
            if error != nil {
                compltion(.failure(error!))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
            let decodeData = try JSONDecoder().decode(SearchModelList.self, from: data)
                let searhModels = decodeData.items.map {
                   SearchModel(name: $0.title, address: $0.roadAddress, x: $0.mapx, y: $0.mapy)
                }
                compltion(.success(searhModels))
            } catch {
            }
            
        }.resume()
        
    }
}

