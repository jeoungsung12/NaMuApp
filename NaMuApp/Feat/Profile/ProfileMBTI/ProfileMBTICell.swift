//
//  ProfileMBTICell.swift
//  NaMuApp
//
//  Created by 정성윤 on 2/7/25.
//

import UIKit
import SnapKit

final class ProfileMBTICell: UICollectionViewCell {
    static let id: String = "ProfileMBTICell"
    private let topButton = UIButton()
    private let bottomButton = UIButton()
    private let stackView = UIStackView()
    private var isClicked: Bool? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ type: MbtiType) {
        switch type {
        case .IE:
            topButton.setTitle("E", for: .normal)
            bottomButton.setTitle("I", for: .normal)
        case .NS:
            topButton.setTitle("S", for: .normal)
            bottomButton.setTitle("N", for: .normal)
        case .FT:
            topButton.setTitle("T", for: .normal)
            bottomButton.setTitle("F", for: .normal)
        case .PJ:
            topButton.setTitle("J", for: .normal)
            bottomButton.setTitle("P", for: .normal)
        }
    }
    
}

extension ProfileMBTICell {
    
    private func configureHierarchy() {
        [ topButton, bottomButton ].forEach({
            self.stackView.addArrangedSubview($0)
        })
        self.addSubview(stackView)
        configureLayout()
    }
    
    private func configureLayout() {
        topButton.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        
        bottomButton.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        [topButton, bottomButton].forEach({
            $0.clipsToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 25
            $0.backgroundColor = .white
            $0.setTitleColor(.gray, for: .normal)
            $0.layer.borderColor = UIColor.gray.cgColor
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        })
        
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        
        configureHierarchy()
    }
    
    private func configureButton() {
        guard let isClicked = isClicked else { return }
        topButton.backgroundColor = (isClicked) ? .point : .white
        topButton.setTitleColor((isClicked) ? .white : .gray, for: .normal)
        bottomButton.backgroundColor = (isClicked) ? .white : .point
        bottomButton.setTitleColor((isClicked) ? .gray : .white, for: .normal)
    }
    
}

extension ProfileMBTICell {
    
    @objc
    private func buttonTapped(_ sender: UIButton) {
        if sender == topButton {
            isClicked = true
        } else {
            isClicked = false
        }
        configureButton()
    }
}
