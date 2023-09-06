//
//  ViewController.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func confirmButtonAction(_ sender: Any) {
        confirmAction()
    }
    
    private let webService = WebService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
}

// MARK: - Setup Functions
extension ViewController {
    
    private func setupViews() {
        setupLoading(isAnimating: false)
        setupResultLabel(text: "", color: .black)
    }
    
    private func setupLoading(isAnimating: Bool) {
        if isAnimating {
            loading.startAnimating()
            confirmButton.isHidden = true
        } else {
            loading.stopAnimating()
            confirmButton.isHidden = false
        }
    }
    
    private func setupResultLabel(text: String, color: UIColor) {
        resultLabel.text = text
        resultLabel.textColor = color
    }
}

// MARK: - Actions
extension ViewController {
    
    private func confirmAction() {
        guard let name = nameTextField.text, name.count > 2 else { return }
        nameAPICall(for: name) { [weak self] response in
            let text = "This name is used " + response.count.description + " times"
            self?.setupResultLabel(text: text, color: response.getGenderColor())
        }
    }
}

// MARK: - API CAlls
extension ViewController {
    
    private func nameAPICall(for name: String, completion: @escaping (NameResponse)->()) {
        setupLoading(isAnimating: true)
        Task { @MainActor in
            do {
                let response = try await webService.getNameData(name: name)
                completion(response)
                setupLoading(isAnimating: false)
            } catch {
                setupLoading(isAnimating: false)
            }
        }
    }
}
