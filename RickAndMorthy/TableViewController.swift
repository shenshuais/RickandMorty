//
//  ViewController.swift
//  RickAndMorthy
//
//  Created by Eric Rojas Pech on 01/12/23.
//

import UIKit

class TableViewController: UIViewController {

    let restClient: RESTClient<PaginatedResponse<Character>> = RESTClient(client: Client(baseURL: "https://www.rickandmortyapi.com", contentType: "application/json"))
    
    var characters: [Character]? = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var nextPage: String? = "1"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        fetchAPI()
    }
    
    func fetchAPI() {
        restClient.show("/api/character/", query: ["page": nextPage!]) { response in
            self.characters = (self.characters ?? []) + response.results
            guard let nextURL = response.info.next else {
                self.nextPage = nil
                return
            }
            self.nextPage = URLComponents(string: nextURL)?.queryItems?.first(where: {$0.name == "page"})?.value
        }
    }
    
}



extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = characters?[indexPath.row].name
        cell.detailTextLabel?.text = characters?[indexPath.row].species
        return cell
    }
}


extension TableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let max = indexPaths.map({ $0.row }).max(), let currentCount = characters?.count, let _ = self.nextPage else { return }
        if max <= (currentCount - 2) { return }
        fetchAPI()
    }
    
}
