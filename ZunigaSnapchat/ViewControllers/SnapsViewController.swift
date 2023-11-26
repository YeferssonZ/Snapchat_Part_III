//
//  SnapsViewController.swift
//  ZunigaSnapchat
//
//  Created by Yefersson Guillermo Zuñiga Justo on 14/11/23.
//

import UIKit
import Firebase

class SnapsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tablaSnaps: UITableView!
    var snaps: [Snap] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tablaSnaps.delegate = self
        tablaSnaps.dataSource = self

        // Observar los snaps entrantes del usuario actual
        if let currentUserID = Auth.auth().currentUser?.uid {
            // Observar snaps añadidos
            Database.database().reference().child("usuarios").child(currentUserID).child("snaps").observe(DataEventType.childAdded) { (snapshot) in
                let snap = Snap()
                snap.imagenURL = (snapshot.value as! NSDictionary)["imagenURL"] as! String
                snap.from = (snapshot.value as! NSDictionary)["from"] as! String
                snap.descrip = (snapshot.value as! NSDictionary)["descripcion"] as! String
                snap.id = snapshot.key
                snap.imagenID = (snapshot.value as! NSDictionary)["imagenID"] as! String
                snap.audioID = (snapshot.value as! NSDictionary)["audioID"] as! String  // Agregado para el audio
                self.snaps.append(snap)
                self.tablaSnaps.reloadData()
            }

            // Observar snaps eliminados
            Database.database().reference().child("usuarios").child(currentUserID).child("snaps").observe(DataEventType.childRemoved) { (snapshot) in
                var iterator = 0
                for snap in self.snaps {
                    if snap.id == snapshot.key {
                        self.snaps.remove(at: iterator)
                        break
                    }
                    iterator += 1
                }
                self.tablaSnaps.reloadData()
            }
        }
    }
    
    @IBAction func CerrarSesionTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if snaps.count == 0 {
            return 1
        } else {
            return snaps.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        if snaps.count == 0 {
            cell.textLabel?.text = "No Tienes Snaps 😟"
        } else {
            let snap = snaps[indexPath.row]
            cell.textLabel?.text = snap.from
        }

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snap = snaps[indexPath.row]
        performSegue(withIdentifier: "versnapsegue", sender: snap)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "versnapsegue" {
            let siguienteVC = segue.destination as! VerSnapViewController
            siguienteVC.snap = sender as! Snap
        }
    }

}
