//
//  ProviderDetailViewController.swift
//  KiwiCare
//
//  Created by Vincent Hu on 09/11/2026.
//

import UIKit
import SwiftUI

final class ProviderDetailViewController: UIViewController {
    private var item: NearbyProvider
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var headerController =  UIHostingController(
        rootView: makeHeader()
    )
    private let fetchDetail: FetchProviderDetailUseCase
    private var loadTask: Task<Void, Never>?
    
    var onCreateInvoice: ((NearbyProvider) -> Void)?
    
    private enum Row {
        case address
        case distance
        case serviceArea
        case bio
    }
    
    private var rows: [Row] {
        var rows: [Row] = [.address, .distance, .serviceArea]
        if let bio = item.provider.bio, !bio.isEmpty {
            rows.append(.bio)
        }
        return rows
    }
    
    init(item: NearbyProvider, fetchDetail: FetchProviderDetailUseCase) {
        self.item = item
        self.fetchDetail = fetchDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        title = item.provider.name
        navigationItem.largeTitleDisplayMode = .never
        
        setupHeader()
        setupTableView()
        
        loadDetail()
    }
    
    private func loadDetail() {
        let fetchDetail = self.fetchDetail
        let id = item.id
        
        loadTask = Task { [weak self] in
            do {
                let provider = try await fetchDetail.execute(id: id)
                self?.apply(provider)
            } catch ProviderError.notFound {
                self?.showNotFound()
            } catch {
                
            }
        }
    }
    
    private func makeHeader() -> ProviderHeaderView {
        ProviderHeaderView(item: item) { [weak self] in
            guard let self else { return }
            self.onCreateInvoice?(self.item)
        }
    }
    
    private func showNotFound() {
        let alert = UIAlertController(
            title: String(localized: "Provider unavailable"),
            message: String(localized: "This provider is no longer available."),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "OK"), style: .default))
        present(alert, animated: true)
    }
    
    private func apply(_ provider: Provider) {
        item = NearbyProvider(provider: provider, distanceKm: item.distanceKm)
        headerController.rootView = makeHeader()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerController.view.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    private func setupHeader() {
        let header = UIHostingController(rootView: ProviderHeaderView(item: item))
        header.sizingOptions = .intrinsicContentSize
        header.view.backgroundColor = .clear
        header.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(header)
        view.addSubview(header.view)
        header.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            header.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        headerController = header
    }
}

extension ProviderDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        
        switch rows[indexPath.row] {
        case .address:
            var content = UIListContentConfiguration.valueCell()
            content.text = String(localized: "Address")
            content.secondaryText = item.provider.address
            cell.contentConfiguration = content
            
        case .distance:
            var content = UIListContentConfiguration.valueCell()
            content.text = String(localized: "Distance")
            content.secondaryText = Measurement(value: item.distanceKm, unit: UnitLength.kilometers)
                .formatted(.measurement(width: .abbreviated, usage: .road))
            cell.contentConfiguration = content
            
        case .serviceArea:
            var content = UIListContentConfiguration.valueCell()
            content.text = String(localized: "Service area")
            content.secondaryText = Measurement(value: item.provider.serviceRadiusKm, unit: UnitLength.kilometers)
                .formatted(.measurement(width: .abbreviated, usage: .road))
            cell.contentConfiguration = content
            
        case .bio:
            var content = UIListContentConfiguration.subtitleCell()
            content.text = String(localized: "About")
            content.secondaryText = item.provider.bio
            content.secondaryTextProperties.numberOfLines = 0
            cell.contentConfiguration = content
        }
        return cell
    }
}

#Preview {
    UINavigationController(rootViewController: ProviderDetailViewController(item: NearbyProvider.previewSamples[0], fetchDetail: PreviewFetchProviderDetail()))
}
