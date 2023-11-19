//
//  SnapsViewController.swift
//  ZunigaSnapchat
//
//  Created by Yefersson Guillermo Zuñiga Justo on 14/11/23.
//

import UIKit

class SnapsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func CerrarSesionTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
