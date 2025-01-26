//
//  PosterCollectionViewCell.swift
//  NaMuApp
//
//  Created by 정성윤 on 1/25/25.
//

import UIKit
import Kingfisher
import SnapKit

final class PosterCollectionViewCell: UICollectionViewCell {
    static let id: String = "PosterCollectionViewCell"
    private let posterImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
    }
    
    func configure(_ image: ImageDetailModel) {
        if let url = URL(string: APIEndpoint.trending.imagebaseURL + image.file_path) {
            posterImageView.kf.setImage(with: url)
            posterImageView.kf.indicatorType = .activity
        }
    }
    
}

extension PosterCollectionViewCell {
    
    private func configureHierarchy() {
        self.addSubview(posterImageView)
        configureLayout()
    }
    
    private func configureLayout() {
        
        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    private func configureView() {
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 15
        posterImageView.contentMode = .scaleToFill
        posterImageView.backgroundColor = .darkGray
        configureHierarchy()
    }
    
}
