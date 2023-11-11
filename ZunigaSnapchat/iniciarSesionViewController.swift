//
//  ViewController.swift
//  ZunigaSnapchat
//
//  Created by Yefersson Guillermo Zuñiga Justo on 7/11/23.
//

import UIKit
import FirebaseAuth

class iniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    var verificationID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuración adicional si es necesaria
    }

    @IBAction func iniciarSesionTapped(_ sender: Any) {
        // Autenticación con correo y contraseña
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            self.handleAuthResult(user, error)
        }
    }

    @IBAction func iniciarSesionTelefonoTapped(_ sender: Any) {
        // Autenticación con teléfono
        guard let phoneNumber = phoneNumberTextField.text else { return }

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error al solicitar verificación de teléfono: \(error.localizedDescription)")
                return
            }

            // Almacena verificationID
            self.verificationID = verificationID

            // Presenta la vista para ingresar el código de verificación
            self.mostrarAlertaParaCodigo()
        }
    }

    // Función para manejar el resultado de la autenticación
    private func handleAuthResult(_ user: AuthDataResult?, _ error: Error?) {
        print("Intentando Iniciar Sesión")
        if let error = error {
            print("Se presentó el siguiente error: \(error.localizedDescription)")
        } else {
            print("Inicio de sesión exitoso")
            // Puedes realizar acciones adicionales aquí después de un inicio de sesión exitoso
        }
    }

    // Función para mostrar un UIAlertController para ingresar el código de verificación
    private func mostrarAlertaParaCodigo() {
        let alertController = UIAlertController(title: "Código de Verificación", message: "Ingrese el código enviado por mensaje de texto", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Código"
        }

        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { (_) in
            if let codigo = alertController.textFields?[0].text {
                self.verificarCodigoDeVerificacion(codigo)
            }
        }

        alertController.addAction(confirmAction)

        present(alertController, animated: true, completion: nil)
    }

    // Función para verificar el código de verificación del teléfono
    func verificarCodigoDeVerificacion(_ codigo: String) {
        guard let verificationID = verificationID else { return }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: codigo)

        Auth.auth().signIn(with: credential) { (user, error) in
            self.handleAuthResult(user, error)
        }
    }
}
