//
//  LocationSearchViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/17.
//

import UIKit
import MapKit

class LocationSearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var matchingItems:[MKMapItem] = []
    var mapView:MKMapView? = nil
    var handleMapSearchDelegate : HandMapSearch? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
  
    }    
    
    func parseAddress(selectedItem: MKPlacemark) -> String{
        var space = " "
            
        //こうしないと該当しない場合にアプリが落ちる
        var addresLine:String = ""
        if let subThoroughfare = selectedItem.subThoroughfare,let thoroughfare = selectedItem.thoroughfare,let locality = selectedItem.locality,let administrativeArea = selectedItem.administrativeArea{
            
            addresLine = String(format: "%@%@%@%@%@%@%@", administrativeArea,space,locality,space,thoroughfare,space,subThoroughfare)
        }

        return addresLine        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
     
        dismiss(animated: true, completion: nil)
    }    

}

extension LocationSearchViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,let searchBarText = searchController.searchBar.text else {return}
        
            let request = MKLocalSearch.Request()
            
            request.naturalLanguageQuery = searchBarText
            request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard let response = response else{return}

            self.matchingItems = response.mapItems
            self.tableView.reloadData()

        }
        
    }    
    
}

