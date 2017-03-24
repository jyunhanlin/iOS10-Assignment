//
//  TweetMentionsImageTableViewCell.swift
//  Smashtag
//
//  Created by JHLin on 2017/3/23.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit

class TweetMentionsImageTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var url: URL? { didSet { updateUI() } }
    
    private func updateUI() {
        
        if let imageURL = url {
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: imageURL)
                if let imageData = urlContents, imageURL == self?.url {
                    DispatchQueue.main.async {
                        self?.tweetImageView?.image = UIImage(data: imageData)
                        self?.spinner.stopAnimating()
                    }
                }
            }
        } else {
            tweetImageView?.image = nil
        }
    }
}
