//
//  ImageView.swift
//  JsonApp
//
//  Created by  Pavel on 13.02.2021.
//

import UIKit

class ImageView: UIImageView {
    
    func fetchImage(with url: String?) {
        guard let url = url else { return }
        guard let imageURL = url.getURL() else {
            image = #imageLiteral(resourceName: "placeholder-1000x1000")
            return
        }
        
        if let cachedImage = getCachedImage(url: imageURL) {
            image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            
            if let error = error { print(error); return }
            guard let data = data, let response = response else { return }
            guard let responseURL = response.url else { return }
            
            if responseURL.absoluteString != url { return }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
            self.saveImageToCache(data: data, response: response)
        }.resume()
    }
    
    private func saveImageToCache(data: Data, response: URLResponse) {
        guard let responseURL = response.url else { return }
        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: responseURL))
    }
    
    private func getCachedImage(url: URL) -> UIImage? {
        if let cacheResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            return UIImage(data: cacheResponse.data)
        }
        return nil
    }
}

fileprivate extension String {
    func getURL() -> URL? {
        guard let url = URL(string: self) else { return nil }
        return url
    }
}
