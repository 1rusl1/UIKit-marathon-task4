//
//  ViewController.swift
//  UIKit-marathon-task4
//
//  Created by Руслан Сабиров on 10/07/2023.
//

import UIKit

enum Section {
    case first
}

struct ItemModel: Hashable {
    let id: String
    let number: Int
    var isSelected: Bool
}

class ViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var items = [ItemModel]()
    
    private var dataSource: UITableViewDiffableDataSource<Section,ItemModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        for i in 0...30 {
            let item = ItemModel(id: UUID().uuidString, number: i, isSelected: false)
            items.append(item)
        }
        view.backgroundColor = .white
        tableView.delegate = self
        configureDataSource()
        addButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.frame
    }
    
    private func addButton () {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.setRightBarButton(
            UIBarButtonItem(
                title: "Shuffle",
                style: .plain,
                target: self,
                action: #selector(shuffleButtonTapped)),
            animated: false
        )
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, model  -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if model.isSelected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.textLabel?.text = String(model.number)
            return cell
        })
        updateDataSource(items)
    }
    
    private func updateDataSource(_ items: [ItemModel], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemModel>()
        snapshot.appendSections([.first])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    @objc private func shuffleButtonTapped() {
        items = items.shuffled()
        updateDataSource(items)
    }
}

extension ViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if item.isSelected {
            items[indexPath.row].isSelected = false
        } else {
            items.remove(at: indexPath.row)
            items.insert(ItemModel(id: item.id, number: item.number, isSelected: true), at: 0)
        }
        updateDataSource(items, animated: !item.isSelected)
    }
}
