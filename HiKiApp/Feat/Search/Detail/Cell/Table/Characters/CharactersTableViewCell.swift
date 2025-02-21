//
//  CastTableViewCell.swift
//  NaMuApp
//
//  Created by 정성윤 on 1/26/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CharactersTableViewCell: BaseTableViewCell, ReusableIdentifier {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.setCollectionViewLayout())
    private let titleLabel = UILabel()
    
    private let viewModel = CharactersTableViewModel()
    let input = CharactersTableViewModel.Input(
        inputTrigger: PublishSubject()
    )
    private var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = true
        setBinding()
    }
    
    private func setBinding() {
        let output = viewModel.transform(input)
        
        output.charactersResult
            .bind(to: collectionView.rx.items(cellIdentifier: CharactersCollectionViewCell.id, cellType: CharactersCollectionViewCell.self)) { items, element, cell in
                cell.configure(element.character)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [titleLabel, collectionView].forEach({
            self.contentView.addSubview($0)
        })
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(12)
        }
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(250)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
    }
    
    override func configureView() {
        self.backgroundColor = .white
        titleLabel.text = "Characters"
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        configureCollectionView()
    }
    
}

extension CharactersTableViewCell {
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CharactersCollectionViewCell.self, forCellWithReuseIdentifier: CharactersCollectionViewCell.id)
    }
    
    private func setCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.itemSize = CGSize(width: 100, height: 120)
        return layout
    }
}
