//
//  MypageViewController.swift
//  NaMuApp
//
//  Created by 정성윤 on 1/24/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyPageViewController: BaseViewController {
    private let myProfileView = MyProfileView()
    private let buttonStackView = UIStackView()
    private let categoryStackView = UIStackView()
    private let countLabel = UILabel()
    private let aniBoxButton = UIButton()
    private let teaserBoxButton = UIButton()
    private let changeProfileButton = UIButton()
    
    private let viewModel = MyPageViewModel()
    let inputTrigger = MyPageViewModel.Input(
        listBtnTrigger: PublishRelay<MyPageViewModel.MyPageButtonType>(),
        categoryBtnTrigger: PublishRelay<MyPageViewModel.MyPageCategoryType>()
    )
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setBindView() {
        [aniBoxButton, teaserBoxButton, changeProfileButton].forEach({ btn in
            btn.rx.tap
                .bind(with: self) { owner, _ in
                    let type = MyPageViewModel.MyPageCategoryType.allCases[btn.tag]
                    owner.inputTrigger.categoryBtnTrigger.accept(type)
                }.disposed(by: disposeBag)
        })
    }
    
    override func setBinding() {
        let output = viewModel.transform(inputTrigger)
        
        output.profileResult
            .bind(with: self, onNext: { owner, userInfo in
                owner.myProfileView.configure(userInfo)
            }).disposed(by: disposeBag)
        
        output.listBtnResult
            .bind(with: self) { owner, type in
                switch type {
                case .oftenQS:
                    print("자주묻는 질문")
                case .feedback:
                    print("피드백")
                case .withdraw:
                    owner.customAlert(
                        "탈퇴하기",
                        "탈퇴를 하면 데이터가 모두 초기화됩니다. 탈퇴 하시겠습니까?",
                        [.ok, .cancel]
                    ) {
                        owner.viewModel.removeUserInfo()
                        let rootVC = UINavigationController(rootViewController: OnboardingViewController())
                        owner.setRootView(rootVC)
                    }
                }
            }.disposed(by: disposeBag)
        
        output.categoryBtnResult
            .bind(with: self, onNext: { owner, type in
                switch type {
                case .aniBox:
                    owner.push(SheetProfileViewController())
                case .watchBox:
                    owner.push(SheetProfileViewController())
                case .profile:
                    owner.push(SheetProfileViewController())
                }
            }).disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [aniBoxButton, teaserBoxButton, changeProfileButton].forEach({
            self.categoryStackView.addArrangedSubview($0)
        })
        [myProfileView, categoryStackView, buttonStackView, countLabel].forEach({
            self.view.addSubview($0)
        })
    }
    
    override func configureLayout() {
        
        myProfileView.snp.makeConstraints { make in            make.height.equalTo(230)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.top.equalTo(myProfileView.snp.bottom).offset(12)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().offset(-24)
            make.top.equalTo(categoryStackView.snp.bottom).offset(24)
        }
        
        countLabel.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(20)
            make.centerX.equalTo(aniBoxButton.snp.centerX)
            make.top.equalTo(aniBoxButton.snp.top).offset(-20)
        }
        
    }
    
    override func configureView() {
        self.setNavigation("프로필")
        self.view.backgroundColor = .customWhite
        
        //TODO: - 간소화
        aniBoxButton.tag = 0
        aniBoxButton.configuration = self.buttonConfiguration(MyPageViewModel.MyPageCategoryType.aniBox.rawValue, MyPageViewModel.MyPageCategoryType.aniBox.image)
        
        aniBoxButton.tag = 1
        teaserBoxButton.configuration = self.buttonConfiguration(MyPageViewModel.MyPageCategoryType.watchBox.rawValue, MyPageViewModel.MyPageCategoryType.watchBox.image)
        
        aniBoxButton.tag = 2
        changeProfileButton.configuration = self.buttonConfiguration(MyPageViewModel.MyPageCategoryType.profile.rawValue, MyPageViewModel.MyPageCategoryType.profile.image)
        
        [aniBoxButton, teaserBoxButton, changeProfileButton].forEach({
            $0.tintColor = .black
        })
        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .center
        categoryStackView.distribution = .fillEqually
        
        countLabel.textColor = .white
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 5
        countLabel.textAlignment = .center
        countLabel.backgroundColor = .point
        //TODO: 갯수 대응 - 최대 저장 갯수
        countLabel.text = viewModel.getUserInfo() + "개 보관중"
        countLabel.font = .systemFont(ofSize: 12, weight: .heavy)
        
        configureButtonStack()
    }
    
    deinit {
        print(#function, self)
    }
    
}

extension MyPageViewController {
    
    private func configureButtonStack() {
        buttonStackView.spacing = 30
        buttonStackView.axis = .vertical
        buttonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (type) in MyPageViewModel.MyPageButtonType.allCases {
            let button = MyPageSectionButton()
            if type == .withdraw {
                button.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.inputTrigger.listBtnTrigger.accept(type)
                    }.disposed(by: disposeBag)
            }
            button.configure(type.rawValue)
            buttonStackView.addArrangedSubview(button)
        }
    }
    
    private func buttonConfiguration(_ title: String,_ image: String) -> UIButton.Configuration {
        let image = UIImage(systemName: image)
        var config = UIButton.Configuration.plain()
        config.image = image
        config.title = title
        config.imagePlacement = .top
        config.imagePadding = CGFloat(12)
        config.baseForegroundColor = .black
        config.imageColorTransformer = .monochromeTint
        return config
    }
    
}
