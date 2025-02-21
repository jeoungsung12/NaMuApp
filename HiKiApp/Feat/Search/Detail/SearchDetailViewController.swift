//
//  SearchDetailViewController.swift
//  NaMuApp
//
//  Created by 정성윤 on 1/25/25.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import RxSwift
import RxCocoa

final class SearchDetailViewController: BaseViewController {
    private lazy var heartButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: nil, action: nil)
    private let tableView = UITableView()
    private let loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .ballPulseSync, color: .point)
    
    //TODO: - ViewModel
    var isButton: (()->Void)?
    
    let viewModel: SearchDetailViewModel
    private lazy var inputTrigger = SearchDetailViewModel.Input(
        heartBtnTrigger: heartButton.rx.tap
    )
    private lazy var outputResult = viewModel.transform(inputTrigger)
    init(viewModel: SearchDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setBinding() {
        outputResult.animeData
            .bind(with: self) { owner, data in
                owner.tableView.reloadData()
                owner.loadingIndicator.stopAnimating()
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [tableView, loadingIndicator].forEach({
            self.view.addSubview($0)
        })
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(49)
            make.top.horizontalEdges.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        loadingIndicator.startAnimating()
    }
    
    override func configureView() {
        self.setNavigation(apperanceColor: .clear)
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = heartButton
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .point
        
        configureTableView()
    }
    
    func configure() {
        //TODO: id로 좋아요 유무 구분
    }
    
    deinit {
        print(#function, self)
    }
    
}

//MARK: - TableView
extension SearchDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(PosterTableViewCell.self, forCellReuseIdentifier: PosterTableViewCell.id)
        tableView.register(SynopsisTableViewCell.self, forCellReuseIdentifier: SynopsisTableViewCell.id)
        tableView.register(CharactersTableViewCell.self, forCellReuseIdentifier: CharactersTableViewCell.id)
        tableView.register(TeaserTableViewCell.self, forCellReuseIdentifier: TeaserTableViewCell.id)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchDetailViewModel.DetailType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SearchDetailViewModel.DetailType.allCases[indexPath.row] {
        case .poster:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PosterTableViewCell.id, for: indexPath) as? PosterTableViewCell else { return UITableViewCell() }
            //TODO: 디코딩 전략
            let value = outputResult.animeData.value
            cell.configure(title: value?.synopsis?.title, image: value?.synopsis?.images.jpg.image_url)
            return cell
            
        case .synopsis:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SynopsisTableViewCell.id, for: indexPath) as? SynopsisTableViewCell, let synopsis = outputResult.animeData.value?.synopsis?.synopsis else { return UITableViewCell() }
            cell.configure(synopsis)
            cell.reloadCell = {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return cell
            
        case .teaser:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TeaserTableViewCell.id, for: indexPath) as? TeaserTableViewCell, let teaser = outputResult.animeData.value?.teaser else { return UITableViewCell() }
            cell.input.inputTrigger.onNext(teaser)
            return cell
            
        case .characters:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CharactersTableViewCell.id, for: indexPath) as? CharactersTableViewCell, let characters = outputResult.animeData.value?.characters  else { return UITableViewCell() }
            cell.input.inputTrigger.onNext(characters)
            return cell
        }
    }
    
}
