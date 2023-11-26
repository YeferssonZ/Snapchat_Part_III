//
//  ElegirUsuarioViewController.swift
//  ZunigaSnapchat
//
//  Created by Yefersson Guillermo Zuñiga Justo on 14/11/23.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ElegirUsuarioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listaUsuarios: UITableView!
    var usuarios: [Usuario] = []
    var imagenURL = ""
    var descrip = ""
    var imagenID = ""
    var audioURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        listaUsuarios.delegate = self
        listaUsuarios.dataSource = self
        Database.database().reference().child("usuarios").observe(DataEventType.childAdded, with: { (snapshot) in
            print(snapshot)
            let usuario = Usuario()
            usuario.email = (snapshot.value as! NSDictionary)["email"] as! String
            usuario.uid = snapshot.key
            self.usuarios.append(usuario)
            self.listaUsuarios.reloadData()
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usuarios.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let usuario = usuarios[indexPath.row]
        cell.textLabel?.text = usuario.email
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let usuario = usuarios[indexPath.row]
        var snapData: [String: Any] = [
            "from": Auth.auth().currentUser?.email,
            "descripcion": descrip,
            "imagenURL": imagenURL,
            "imagenID": imagenID
        ]

        if let audioURL = audioURL {
            // Agregar información del audio al snapData
            snapData["audioID"] = NSUUID().uuidString // Generar un nuevo ID para el audio
            // Subir el audio con observación del progreso
            let audiosFolder = Storage.storage().reference().child("audios")
            let cargarAudio = audiosFolder.child("\(snapData["audioID"] as! String).m4a")
            cargarAudio.putFile(from: audioURL, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Ocurrió un error al subir el audio: \(error)")
                } else {
                    cargarAudio.downloadURL { (url, error) in
                        if let audioURL = url {
                            snapData["audioURL"] = audioURL.absoluteString
                            // Guardar el snap en la base de datos
                            self.guardarSnapEnFirebase(usuario: usuario, snapData: snapData)
                        }
                    }
                }
            }
        } else {
            guardarSnapEnFirebase(usuario: usuario, snapData: snapData)
        }
    }

    func guardarSnapEnFirebase(usuario: Usuario, snapData: [String: Any]) {
        Database.database().reference().child("usuarios")
            .child(usuario.uid)
            .child("snaps")
            .childByAutoId()
            .setValue(snapData)
        navigationController?.popViewController(animated: true)
    }
}
