//
//  ViewController.swift
//  SearchBar
//
//  Created by Inpyo Hong on 2021/02/13.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    public var searchBarTextField: UITextField {
        searchBar.searchTextField
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let searchBtn: UIButton = UIButton()

    var shownCities = [String]() // Data source for UITableView
    let allCities = ["New York", "London", "Oslo", "Warsaw", "Frankfurt", "Prag", "Berlin", "Philadelphia", "Sao Paulo", "Milan", "Manila", "Tokyo", "Los Angeles", "Paris", "Portland"] // Mocked API data
    let disposeBag = DisposeBag() // Bag of disposables to release them when view is being deallocated (protect agains retain cycle)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search Cities"
        
        self.tableView.dataSource = self
        
        configSearchBar()
    }
    
    override func viewDidLayoutSubviews() {
        searchBarTextField.addLeftPadding()

        searchBarTextField.rightViewMode = UITextField.ViewMode.always
    }
    
    func configSearchBar() {
        self.searchBar.rx.text.orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
//            .filter { $0.count > 0 }
            .flatMapLatest{ query -> Observable<String> in
                print("query", query)
                if query.count == 0 {
                    self.shownCities = self.allCities
                }
                else{
                    self.shownCities = self.allCities.filter { $0.hasPrefix(query) } // do the "API Request" to find cities
                }
                self.tableView.reloadData() //T reload data in table view
                
                return Observable.of(query)
            }
            .subscribe(onNext: { query in
                print("query", query)
            }).disposed(by: disposeBag)

        let image: UIImage = UIImage(named: "icoSearch")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.searchBtn.setImage(image, for: .normal)
        
        self.searchBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("SearchBtn Clicked")
                let query = self.searchBar.text!
                print("query", query)

                if query.count == 0 {
                    self.shownCities = self.allCities
                }
                else{
                    self.shownCities = self.allCities.filter { $0.hasPrefix(query) } // do the "API Request" to find cities
                }

                self.tableView.reloadData()

            }).disposed(by: self.disposeBag)
        
        searchBar.setPositionAdjustment(UIOffset(horizontal: -10, vertical: 0), for: .bookmark)
        searchBar.backgroundImage = UIImage()
        searchBtn.tintColor = .lightGray

        searchBarTextField.leftView = nil
        searchBarTextField.placeholder = "닉네임/아이디 검색"
        searchBarTextField.textAlignment = .left
        searchBarTextField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        searchBarTextField.layer.cornerRadius = 4
        searchBarTextField.layer.borderWidth = 1
        searchBarTextField.layer.borderColor = UIColor(white: 219.0 / 255.0, alpha: 1.0).cgColor
        searchBarTextField.layer.masksToBounds = true
        searchBarTextField.backgroundColor = .white
        searchBarTextField.rightView = searchBtn
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        cell.textLabel?.text = shownCities[indexPath.row]

        return cell
    }
}
extension UITextField {
  func addLeftPadding() {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
    self.leftView = paddingView
    self.leftViewMode = ViewMode.always
  }
}
