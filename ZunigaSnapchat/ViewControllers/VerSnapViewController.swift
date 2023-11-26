//
//  VerSnapViewController.swift
//  ZunigaSnapchat
//
//  Created by Yefersson Guillermo Zuñiga Justo on 21/11/23.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseStorage
import AVFoundation

class VerSnapViewController: UIViewController {
    
    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reproducirAudioButton: UIButton!
    
    var snap = Snap()
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMensaje.text = "Mensaje: " + snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL), completed: nil)
    }
    
    @IBAction func reproducirAudioTapped(_ sender: Any) {
        // Reproducir audio
        if let audioURL = URL(string: snap.audioURL) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
                reproducirAudioButton.setTitle("REPRODUCIR", for: .normal)
            } catch {
                print("Error al reproducir audio: \(error.localizedDescription)")
            }
        }
        print("Reproduciendo...")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let currentUserID = Auth.auth().currentUser?.uid {
            let imagenRef = Storage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg")
            
            imagenRef.delete { error in
                if let error = error {
                    print("Error al eliminar la imagen: \(error.localizedDescription)")
                } else {
                    print("Imagen eliminada correctamente")
                }
            }
            
            // Eliminar audio al salir
            let audioRef = Storage.storage().reference().child("audios").child("\(snap.audioID).m4a")
            audioRef.delete { error in
                if let error = error {
                    print("Error al eliminar el audio: \(error.localizedDescription)")
                } else {
                    print("Audio eliminado correctamente")
                }
            }
            
            Database.database().reference().child("usuarios").child(currentUserID).child("snaps").child(snap.id).removeValue()
        }
    }

}
