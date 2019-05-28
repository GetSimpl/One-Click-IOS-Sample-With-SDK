//
//  PaymentViewController.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 20/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import UIKit
import SimplOneClick

class PaymentViewController: UIViewController {

    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var simplBtn: UIButton!
    
    var cartController: CartController? = nil
    var userModel: User? = nil
    var transactionStatus: TransactionStatus = TransactionStatus.incomplete
    var userNetworkClient: UserNetworkClient = UserNetworkClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let total = cartController?.getTotal()
        self.setTotal(total ?? 0)
        
        // initialize simpl
        initSimpl()
    }
    
    private func initSimpl() {
        if (initZeroClickSDK()){
//            if self.userModel?.hasZeroClickToken ?? false {
//                self.callEligility()
//            } else {
//                self.callAproval()
//            }
        }
    }
    
    private func initZeroClickSDK() -> Bool {
        GSManager.initialize(withMerchantID: "e4a905492fc1ec16d8f2d25bfd9885c7")
        GSManager.enableSandBoxEnvironment(true)
        return true;
    }
    
    private func setTotal(_ total: Int){
        totalAmount.text = "Total: \(total)"
    }
    
    private func setStatus(_ s: String){
        status.text = s
    }
    
    private func callAproval() {
        var params :[String : Any] = [:]
        params["transaction_amount_in_paise"] = cartController?.getTotal()
        let user = GSUser(phoneNumber: userModel?.phoneNumber ?? "", email: userModel?.emailId ?? "")
        user.headerParams = params
        GSManager.shared().checkApproval(for: user) {
            (approved, firstTransaction, text, error) in
            self.simplBtn.isHidden = !approved
        }
    }
    
    private func placeOrder(transactionToken: String){
        var dictionary: [String: String] = [:]
        dictionary["amount_in_paise"] = "\(String(describing: cartController?.getTotal()))"
        dictionary["order_id"] = "\(Int.random(in: 1..<1000))"
        userNetworkClient.chargeTransactionToken(token: transactionToken, dictionary: dictionary, completion: {
            (completed, jsonResponse, error) in
            if let error = error {
                NSLog("Error: \(error)")
            } else {
                if completed {
                    DispatchQueue.main.sync {
                        print("transaction is completed")
                        self.transactionStatus = TransactionStatus.complete
                    }
                }else {
                    DispatchQueue.main.sync {
                        self.setStatus("something went wrong \(String(describing: jsonResponse["errors"] as? String))")
                        self.status.textColor = UIColor.red
                    }
                }
            }
        })
    }

    @IBAction func simplBtnClick(_ sender: Any) {
        let user = GSUser(phoneNumber: userModel?.phoneNumber ?? "", email: userModel?.emailId ?? "")
        let transaction = GSTransaction(user: user, amountInPaise: self.cartController?.getTotal() ?? 0)
        GSManager.shared().authorizeTransaction(transaction) {
            (jsonResponse, error) in
            if error != nil {
                NSLog("%@", error.debugDescription)
            } else {
                self.placeOrder(transactionToken: jsonResponse!["transaction_token"] as! String)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "toCompleted" && self.transactionStatus == TransactionStatus.incomplete){
            return true
        }
        
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    enum TransactionStatus: String {
        case incomplete = "incomplete"
        case complete = "complete"
    }

}
