//
//  CastTableViewCell.swift
//  NaMuApp
//
//  Created by 정성윤 on 1/26/25.
//

import UIKit
import SnapKit

class CastTableViewCell: UITableViewCell {
    static let id: String = "CastTableViewCell"
    private let titleLabel = UILabel()
    private let imageResult = UILabel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.setcollectionViewLayout())

    var castData: [CreditCast] = [] {
        didSet {
            updateResultLabel()
            collectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = false
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CastTableViewCell {
    
    private func configureHierarchy() {
        self.addSubview(titleLabel)
        self.addSubview(collectionView)
        self.addSubview(imageResult)
        configureLayout()
    }
    
    private func configureLayout() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(12)
        }
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(180)
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        imageResult.snp.makeConstraints { make in
            make.height.equalTo(180)
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
    }
    
    private func configureView() {
        self.backgroundColor = .customBlack
        updateResultLabel()
        imageResult.numberOfLines = 0
        imageResult.textColor = .white
        imageResult.textAlignment = .center
        imageResult.backgroundColor = .clear
        imageResult.font = .boldSystemFont(ofSize: 15)
        
        titleLabel.text = "Cast"
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .customWhite
        titleLabel.textAlignment = .left
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        configureCollectionView()
        configureHierarchy()
    }
    
    private func updateResultLabel() {
        imageResult.text = (!castData.isEmpty) ? nil : NetworkError.noImage
    }
}

extension CastTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .customBlack
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: CastCollectionViewCell.id)
    }
    
    private func setcollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 2
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.itemSize = CGSize(width: width, height: 80)
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return castData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCollectionViewCell.id, for: indexPath) as? CastCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(castData[indexPath.row])
        return cell
    }
}
