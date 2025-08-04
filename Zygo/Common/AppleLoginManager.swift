import Foundation
import AuthenticationServices
import SwiftUI
import CryptoKit

protocol AppleLoginManagerDelegate {
    func didLogin(user: ASAuthorizationAppleIDCredential)
    func didFaildLogin(error: String)
}

class AppleLoginManager: NSObject, ASAuthorizationControllerDelegate {
    static let shared = AppleLoginManager()
    var delegate: AppleLoginManagerDelegate?
    
    func login(from viewcontroller: UIViewController){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userIdentifier) {  (credentialState, error) in
                switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid.
                    break
                case .revoked:
                    // The Apple ID credential is revoked.
                    break
                case .notFound:
                    break
                // No credential was found, so show the sign-in UI.
                default:
                    break
                }
            }
            self.delegate?.didLogin(user: appleIDCredential)
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.delegate?.didFaildLogin(error: error.localizedDescription)
    }
}
