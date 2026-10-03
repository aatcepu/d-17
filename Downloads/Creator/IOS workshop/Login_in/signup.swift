//
//  signup.swift
//  Login_in
//
//  Created by Student on 07/01/2026.
//

import UIKit
import FirebaseAuth

class signup: UIViewController {
    
    
    @IBOutlet weak var email: UITextField!
    

    @IBOutlet weak var createPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUpButton(_ sender: UIButton) {
        if let email = email.text, let password = createPassword.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
              
                if error != nil {
                    print("SignUp Error: ", error!.localizedDescription)
                }
                
                else{
                    self?.performSegue(withIdentifier: "SignUpToHome", sender: self)
                }
            }
        }
    }
    
    

}
