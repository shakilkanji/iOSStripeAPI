//
//  ViewController.swift
//  Donate
//
//  Created by Ziad TAMIM on 6/7/15.
//  Copyright (c) 2015 TAMIN LAB. All rights reserved.
//

import UIKit

class ViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expireDateTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet var textFields: [UITextField]!
    
    // MARK: - Text field delegate 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    
    // MARK: Actions
    
    @IBAction func donate(_ sender: AnyObject) {
        
        // Initiate the card
        let stripCard = STPCard()
        
        // Split the expiration date to extract Month & Year
        if self.expireDateTextField.text?.isEmpty == false {
            let expirationDate = self.expireDateTextField.text?.components(separatedBy: "/")
            let expMonth = UInt((expirationDate?[0])!)
            let expYear = UInt((expirationDate?[1])!)
            
            // Send the card info to Stripe to get token
            stripCard.number = self.cardNumberTextField.text
            stripCard.cvc = self.cvcTextField.text
            stripCard.expMonth = expMonth!
            stripCard.expYear = expYear!
        }
        
        do {
            try stripCard.validateReturningError()
        } catch let underlyingError as NSError? {
            self.spinner.stopAnimating()
            self.handleError(error: underlyingError!)
            return
        }
        
        STPAPIClient.shared().createToken(with: stripCard, completion: { (token, error) -> Void in
            
            if error != nil {
                let error2: NSError = error as! NSError
                self.handleError(error: error2)
                return
            }
            
//            self.postStripeToken(token!)
        })
    
    }
    
    func handleError(error: NSError) {
        UIAlertView(title: "Please try again:",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
    }
    
    func postStripeToken(token: STPToken) {
        let URL = "http://localhost/donate/payment.php"
        let params = ["stripeToken" : token.tokenId,
                      "amount" : Int(self.amountTextField.text!)!,
                      "currency" : "usd",
                      "description" : self.emailTextField.text] as [String : Any]
        
        let manager = AFHTTPRequestOperationManager()
        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
            
        }, failure: ((AFHTTPRequestOperation?, Error?) -> Void)!)
    }

}

