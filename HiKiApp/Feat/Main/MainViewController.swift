//
//  MainViewController.swift
//  NaMuApp
//
//  Created by 정성윤 on 1/24/25.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
    private let leftLogo = UIBarButtonItem(customView: MainNavigationView())
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
    private let category = MainCategoryView()
    private let loadingIndicator = LoadingView()
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection,HomeItem>?
    
    private let viewModel = MainViewModel()
    private let inputTrigger = MainViewModel.Input(
        dataLoadTrigger: Observable((AnimateType.airing))
    )
    private lazy var outputResult = viewModel.transform(input: inputTrigger)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setBinding() {
        loadingIndicator.isStart()
        outputResult.dataLoadResult.lazyBind { [weak self] animateData in
            DispatchQueue.main.async {
                //TODO: - 수정
                if let animateData = animateData {
                    self?.setSnapShot(animateData)
                    self?.category.isUserInteractionEnabled = true
                } else {
                    self?.errorPresent(.notFount)
                }
            }
        }
    }
    
    deinit {
        print(#function, self)
    }
    
}

//MARK: - Configure UI
extension MainViewController {
    
    private func configureHierarchy() {
        [collectionView, category, loadingIndicator].forEach({
            self.view.addSubview($0)
        })
        configureLayout()
    }
    
    private func configureLayout() {
        category.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().offset(-(self.tabBarController?.tabBar.bounds.height ?? 0))
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.center.equalToSuperview()
        }
        setDataSource()
    }
    
    private func configureView() {
        self.setNavigation()
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = leftLogo
//        self.navigationController?.hidesBarsOnSwipe = true
        
        category.selectedItem = { [weak self] type  in
            self?.inputTrigger.dataLoadTrigger.value = type
            self?.category.isUserInteractionEnabled = false
            self?.loadingIndicator.isStart()
        }

        configureCollectionView()
        configureHierarchy()
    }
}

extension MainViewController {
    //TODO: - Rx
    private func setSnapShot(_ data: [[AnimateData]]) {
        var snapShot = NSDiffableDataSourceSnapshot<HomeSection,HomeItem>()
        let totalData = data.flatMap({$0})
            .filter { $0.title_english != nil }
        
        let sortedData = totalData
            .filter { $0.rank != nil }
            .sorted { $0.rank! < $1.rank! }
        
        let categorySection = HomeSection.category
        let headerSection = HomeSection.header
        let semiHeaderSection = HomeSection.semiHeader(title: HomeSection.semiHeader(title: "").title)
        let middleSection = HomeSection.middle(title: HomeSection.middle(title: "").title)
        let semiFooterSection = HomeSection.middle(title: HomeSection.semiFooter(title: "").title)
        let footerSection = HomeSection.middle(title: HomeSection.footer(title: "").title)
        
        let headerData = Set(sortedData.prefix(9)).compactMap {
            return HomeItem.poster(ItemModel(id: $0.mal_id, title: $0.title_english, synopsis: $0.synopsis, image: $0.images.jpg.image_url, star: $0.score ?? 0.0, genre: $0.genres?.compactMap({$0}))) }
        
        let semiHeaderData = Set(totalData.shuffled().prefix(10)).compactMap {
            return HomeItem.recommand(ItemModel(id: $0.mal_id, title: $0.title_english, synopsis: $0.synopsis, image: $0.images.jpg.image_url, star: $0.score ?? 0.0, genre: nil)) }
        
        let middleData = Set(totalData.filter({$0.score ?? 0 > 8.0})).compactMap {
            return HomeItem.rank(ItemModel(id: $0.mal_id, title: $0.title_english, synopsis: $0.synopsis, image: $0.images.jpg.image_url, star: $0.score ?? 0.0, genre: nil)) }
        
        let semiFooterData = Set(totalData.filter({$0.type?.uppercased() == "TV"})).compactMap {
            return HomeItem.tvList(ItemModel(id: $0.mal_id, title: $0.title_english, synopsis: $0.synopsis, image: $0.images.jpg.image_url, star: $0.score ?? 0.0, genre: nil)) }
        
        let footerData = Set(totalData.filter({$0.type?.uppercased() == "ONA"})).compactMap {
            return HomeItem.onaList(ItemModel(id: $0.mal_id, title: $0.title_english, synopsis: $0.synopsis, image: $0.images.jpg.image_url, star: $0.score ?? 0.0, genre: nil)) }
        
        [categorySection, headerSection, semiHeaderSection, middleSection, semiFooterSection, footerSection].forEach({
            snapShot.appendSections([$0])
        })
        
        snapShot.appendItems([.category], toSection: categorySection)
        snapShot.appendItems(headerData, toSection: headerSection)
        snapShot.appendItems(semiHeaderData, toSection: semiHeaderSection)
        snapShot.appendItems(middleData, toSection: middleSection)
        snapShot.appendItems(semiFooterData, toSection: semiFooterSection)
        snapShot.appendItems(footerData, toSection: footerSection)
        
        self.dataSource?.apply(snapShot) {
            DispatchQueue.main.async {
                self.collectionView.setContentOffset(.zero, animated: true)
            }
        }
        
        loadingIndicator.isStop()
    }
    
}

//MARK: - CollectionView
extension MainViewController: UICollectionViewDelegate {
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(EmptyCollectionViewCell.self, forCellWithReuseIdentifier: EmptyCollectionViewCell.id)
        collectionView.register(MainHeaderCell.self, forCellWithReuseIdentifier: MainHeaderCell.id)
        collectionView.register(MainPosterCell.self, forCellWithReuseIdentifier: MainPosterCell.id)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.id)
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 4
        config.scrollDirection = .vertical
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            let width = (UIScreen.main.bounds.width)
            if section == .header {
                return (self?.createLayout(width: 0.85, height: (width * 0.85), .groupPagingCentered))
            } else if section == .category {
                return (self?.createLayout(width: 1.0, height: 45, .none))
            } else if section == .semiHeader(title: HomeSection.semiHeader(title: "").title) {
                return (self?.createLayout(width: 0.4, height: (width * 0.4) * 1.5, .continuous))
            } else {
                return (self?.createLayout(width: 0.3, height: (width * 0.3) * 1.7, .continuous))
            }
        }, configuration: config)
    }
    
    private func createLayout(width: Double, height: CGFloat,_ alignment: UICollectionLayoutSectionOrthogonalScrollingBehavior) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(width), heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        section.interGroupSpacing = 12
        section.orthogonalScrollingBehavior = alignment
        
        if alignment == .continuous {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading
            )
            section.boundarySupplementaryItems = [header]
        }
        
        return section
    }
    
    private func setCell(_ data: ItemModel,_ type: PosterType,_ indexPath: IndexPath) -> UICollectionViewCell {
        switch type {
        case .rank:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainHeaderCell.id, for: indexPath) as? MainHeaderCell else { return UICollectionViewCell() }
            cell.configure(data, indexPath.row + 1)
            return cell
            
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainPosterCell.id, for: indexPath) as? MainPosterCell else { return UICollectionViewCell() }
            cell.configure(data, type)
            return cell
        }
    }
    
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSection,HomeItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .category:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.id, for: indexPath) as? EmptyCollectionViewCell else { return UICollectionViewCell() }
                return cell
            case .poster(let data):
                return self.setCell(data, .rank, indexPath)
            case .rank(let data):
                return self.setCell(data, .star, indexPath)
            case .recommand(let data),
                    .tvList(let data),
                    .onaList(let data):
                return self.setCell(data, .other, indexPath)
            }
        })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.id, for: indexPath)
            let section = self?.dataSource?.sectionIdentifier(for: indexPath.section)
            switch section {
            case .semiHeader(let title),
                    .middle(let title),
                    .semiFooter(let title),
                    .footer(let title):
                (header as? HeaderView)?.configure(title: title)
            default:
                return UICollectionReusableView()
            }
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        switch selectedItem {
        case .poster(let itemModel),
                .recommand(let itemModel),
                .rank(let itemModel),
                .tvList(let itemModel),
                .onaList(let itemModel):
            let vc = SearchDetailViewController()
            vc.id = itemModel.id
            self.push(vc)
        default:
            print("카테고리")
        }
    }
    
}
