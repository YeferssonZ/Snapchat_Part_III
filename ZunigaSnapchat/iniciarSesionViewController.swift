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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if needed
    }	

    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            print("Intentando Iniciar Sesión")
            if error != nil{
                print("Se presentó el siguiente error: \(error)")
            } else {
                print("Inicio de sesión exitoso")
            }
        }
    }
}


