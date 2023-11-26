//
//  ImagenViewController.swift
//  ZunigaSnapchat
//
//  Created by Yefersson Guillermo Zuñiga Justo on 14/11/23.
//

import UIKit
import FirebaseStorage
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    @IBOutlet weak var grabarAudioBoton: UIButton!

    var imagePicker = UIImagePickerController()
    var audioRecorder: AVAudioRecorder?
    var audioURL: URL?
    var imagenID = NSUUID().uuidString

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
        setupGrabarAudio()
    }

    // MARK: - Acción del botón de folder
    @IBAction func mediaTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - Acción del botón de la cámara
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - Acción del botón "Elegir Contacto"
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false

        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData = imageView.image?.jpegData(compressionQuality: 0.50)

        // Subir la imagen con observación del progreso
        let cargarImagen = imagenesFolder.child("\(imagenID).jpg")
        cargarImagen.putData(imagenData!, metadata: nil) { (metadata, error) in
            if let error = error {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen. Verifique su conexión a internet y vuelva a intentarlo.", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrió un error al subir imagen: \(error)")
                return
            } else {
                cargarImagen.downloadURL { url, error in
                    guard let enlaceURL = url else {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen", accion: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrió un error al obtener información de la imagen \(error)")
                        return
                    }
                    self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: enlaceURL.absoluteString)
                }
            }
        }
    }

    // MARK: - Acción del botón "Grabar Audio"
    @IBAction func grabarAudioTapped(_ sender: Any) {
        if audioRecorder?.isRecording == true {
            detenerGrabacion()
        } else {
            empezarGrabacion()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seleccionarContactoSegue" {
            let siguienteVC = segue.destination as! ElegirUsuarioViewController
            siguienteVC.imagenURL = sender as! String
            siguienteVC.descrip = descripcionTextField.text!
            siguienteVC.imagenID = imagenID
            siguienteVC.audioURL = audioURL
        }
    }

    // MARK: - Delegado de UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        picker.dismiss(animated: true, completion: nil)
    }

    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }

    // MARK: - Funciones de grabación de audio
    func setupGrabarAudio() {
        let directorioPath = getDirectorioDocumentos().appendingPathComponent("grabacionAudio.m4a")

        let configuracionGrabacion: [String : Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: directorioPath, settings: configuracionGrabacion)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
        } catch {
            print(error.localizedDescription)
        }
    }

    func empezarGrabacion() {
        audioURL = getDirectorioDocumentos().appendingPathComponent("grabacionAudio.m4a")
        audioRecorder?.record()
        grabarAudioBoton.setTitle("Detener Grabación", for: .normal)
    }

    func detenerGrabacion() {
        audioRecorder?.stop()
        grabarAudioBoton.setTitle("Grabar Audio", for: .normal)
    }

    func getDirectorioDocumentos() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    // MARK: - Delegado de AVAudioRecorder
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Grabación de audio exitosa")
        } else {
            print("Error en la grabación de audio")
        }
    }
}
