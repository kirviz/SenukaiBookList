//
//  UIImage+Extensions.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 29/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import UIKit

extension UIImageView {
    func load(img: String, withTransitionView transitionView: UIView) -> URLSessionTask? {
        guard let url = URL(string: img) else {
            return nil
        }
        return load(url: url, withTransitionView: transitionView)
    }
    
    func load(url: URL, withTransitionView transitionView: UIView) -> URLSessionTask? {
        return CachedRequest.request(url: url) { data, isCached in
            guard let data = data else { return }
            let img = UIImage(data: data)
            
            DispatchQueue.main.async { [weak self] in
                if isCached {
                    self?.image = img
                } else {
                    UIView.transition(with: transitionView, duration: 0.5, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                        self?.image = img
                    }, completion: nil)
                }
            }
        }
    }
}
