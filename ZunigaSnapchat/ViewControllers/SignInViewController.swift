//
//  SignInViewController.swift
//  ZunigaSnapchat
//
//  Created by Yefersson Guillermo Zuñiga Justo on 19/11/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuración adicional si es necesaria
    }

    // MARK: - Crear Usuario Tapped
    @IBAction func crearUsuarioTapped(_ sender: Any) {
        // Verificar que las contraseñas coincidan
        guard let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text, password == confirmPassword else {
            // Mostrar mensaje de error si las contraseñas no coinciden
            mostrarAlerta(titulo: "Error", mensaje: "Las contraseñas no coinciden. Por favor, inténtalo de nuevo.", accion: "Aceptar")
            return
        }

        // Intentar crear un nuevo usuario
        Auth.auth().createUser(withEmail: emailTextField.text!, password: password) { (user, error) in
            print("Intentando crear un usuario")
            if error != nil {
                // Si hay un error al crear el usuario
                print("Se presentó el siguiente error al crear el usuario: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al crear el usuario. Verifica tu conexión a internet y vuelve a intentarlo.", accion: "Aceptar")
            } else {
                // Usuario creado exitosamente
                print("El usuario fue creado exitosamente")
                // Guardar información adicional del usuario en la base de datos
                if let uid = user?.user.uid, let email = user?.user.email {
                    Database.database().reference().child("usuarios").child(uid).child("email").setValue(email)
                }
                // Redirigir al usuario a la pantalla de inicio de sesión
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
    }

    // Función auxiliar para mostrar alertas
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
}
