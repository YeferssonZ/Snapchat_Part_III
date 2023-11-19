//
//  ViewController.swift
//  ZunigaSnapchat
//
//  Created by Yefersson Guillermo Zuñiga Justo on 7/11/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseDatabase

class iniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    var verificationID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuración adicional si es necesaria
    }

    // MARK: - Autenticación con Correo y Contraseña
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        // Intentar iniciar sesión
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            print("Intentando Iniciar Sesión")
            if error != nil {
                print("Se presentó el siguiente error al iniciar sesión: \(error)")

                // Mostrar alerta y dar opciones al usuario
                let alerta = UIAlertController(title: "Error de Inicio de Sesión", message: "El usuario no existe. ¿Quieres crear uno?", preferredStyle: .alert)

                // Acción para crear un nuevo usuario
                let accionCrear = UIAlertAction(title: "Crear", style: .default) { (UIAlertAction) in
                    // Redirigir al usuario a la pantalla de registro
                    self.performSegue(withIdentifier: "registroSegue", sender: nil)
                }

                // Acción para cancelar
                let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)

                // Agregar las acciones a la alerta
                alerta.addAction(accionCrear)
                alerta.addAction(accionCancelar)

                // Mostrar la alerta
                self.present(alerta, animated: true, completion: nil)
            } else {
                // Inicio de sesión exitoso
                print("Inicio de Sesión Exitoso")
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
    }

    // MARK: - Crear Usuario Tapped
    @IBAction func crearUsuarioTapped(_ sender: Any) {
        // Transición a la vista de creación de usuario
        self.performSegue(withIdentifier: "registroSegue", sender: nil)
    }

    // MARK: - Autenticación con Teléfono
    @IBAction func iniciarSesionTelefonoTapped(_ sender: Any) {
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

    // MARK: - Manejo del Resultado de Autenticación
    private func handleAuthResult(_ user: AuthDataResult?, _ error: Error?) {
        print("Intentando Iniciar Sesión")
        if let error = error {
            print("Se presentó el siguiente error: \(error.localizedDescription)")
        } else {
            print("Inicio de sesión exitoso por Teléfono")
            // Puedes realizar acciones adicionales aquí después de un inicio de sesión exitoso
        }
    }

    // MARK: - Mostrar Alerta para Código de Verificación
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

    // MARK: - Verificar Código de Verificación del Teléfono
    func verificarCodigoDeVerificacion(_ codigo: String) {
        guard let verificationID = verificationID else { return }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: codigo)

        Auth.auth().signIn(with: credential) { (user, error) in
            self.handleAuthResult(user, error)
            // Después de iniciar sesión, realiza la transición
            self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
        }
    }

    // MARK: - Autenticación con Google
    @IBAction func iniciarSesionGoogleTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print("Error al iniciar sesión con Google: \(error!.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                print("Error al obtener información del usuario de Google")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error al iniciar sesión con Google: \(error.localizedDescription)")
                } else {
                    print("Inicio de sesión exitoso con Google")
                    // Puedes realizar acciones adicionales aquí después de un inicio de sesión exitoso

                    // Después de iniciar sesión, realiza la transición
                    self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                }
            }
        }
    }
}
