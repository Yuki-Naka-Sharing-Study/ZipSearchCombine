//
//  ZipCodeSearchView.swift
//  ZipSearchCombine
//
//  Created by 仲優樹 on 2025/06/26.
//

import Foundation
import SwiftUI

// MARK: - View
struct ZipCodeSearchView: View {
    @StateObject private var viewModel = ZipCodeViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("郵便番号を入力", text: $viewModel.zipcode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            
            Button("検索") {
                viewModel.fetchAddress()
            }
            .padding()
            
            if !viewModel.address.isEmpty {
                Text("住所: \(viewModel.address)")
                    .foregroundColor(.blue)
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text("エラー: \(viewModel.errorMessage)")
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
    }
}
