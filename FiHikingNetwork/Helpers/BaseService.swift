import FirebaseFirestore
import RxSwift

class BaseService {
    let db = Firestore.firestore()

    func addDocument(collection: String, data: [String: Any]) -> Single<Void> {
        return Single.create { single in
            self.db.collection(collection).addDocument(data: data) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func updateDocument(collection: String, documentId: String, data: [String: Any]) -> Single<Void> {
        return Single.create { single in
            self.db.collection(collection).document(documentId).updateData(data) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func deleteDocument(collection: String, documentId: String) -> Single<Void> {
        return Single.create { single in
            self.db.collection(collection).document(documentId).delete { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func fetchDocument(collection: String, documentId: String) -> Single<[String: Any]> {
        return Single.create { single in
            self.db.collection(collection).document(documentId).getDocument { document, error in
                if let error = error {
                    single(.failure(error))
                } else if let document = document, document.exists {
                    single(.success(document.data() ?? [:]))
                } else {
                    single(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                }
            }
            return Disposables.create()
        }
    }

    func fetchDocuments(collection: String) -> Single<[[String: Any]]> {
        return Single.create { single in
            self.db.collection(collection).getDocuments { snapshot, error in
                if let error = error {
                    single(.failure(error))
                } else if let documents = snapshot?.documents {
                    let data = documents.map { $0.data() }
                    single(.success(data))
                } else {
                    single(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
                }
            }
            return Disposables.create()
        }
    }
}
