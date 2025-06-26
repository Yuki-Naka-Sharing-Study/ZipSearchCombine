//
//  ZipCodeViewModel.swift
//  ZipSearchCombine
//
//  Created by 仲優樹 on 2025/06/26.
//

import SwiftUI
import Combine

// MARK: - モデル
struct ZipCloudResponse: Decodable {
    struct Address: Decodable {
        let address1: String  // 都道府県
        let address2: String  // 市区町村
        let address3: String  // 町域
    }
    let results: [Address]?
    let message: String?
    let status: Int
}

// MARK: - ViewModel
class ZipCodeViewModel: ObservableObject {
    @Published var zipcode = ""
    @Published var address = ""
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchAddress() {
        getAddress(from: zipcode)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.address = ""
                }
            } receiveValue: { address in
                self.address = address
                self.errorMessage = ""
            }
            .store(in: &cancellables)
    }
    
    private func getAddress(from zipcode: String) -> Future<String, Error> {
        return Future { promise in
            guard let url = URL(string: "https://zipcloud.ibsnet.co.jp/api/search?zipcode=\(zipcode)") else {
                return promise(.failure(URLError(.badURL)))
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    return promise(.failure(error))
                }
                guard let data = data else {
                    return promise(.failure(URLError(.badServerResponse)))
                }
                do {
                    let decoded = try JSONDecoder().decode(ZipCloudResponse.self, from: data)
                    if let first = decoded.results?.first {
                        let fullAddress = "\(first.address1)\(first.address2)\(first.address3)"
                        promise(.success(fullAddress))
                    } else {
                        promise(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "住所が見つかりませんでした"])))
                    }
                } catch {
                    promise(.failure(error))
                }
            }.resume()
        }
    }
}
