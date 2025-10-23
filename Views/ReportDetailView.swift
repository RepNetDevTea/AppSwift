//
//  ReportDetailView.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
// esta es la vista de "detalle de reporte". muestra toda la informacion
// de un solo reporte y permite al usuario votar.

// -- componentes utilizados --
// - tagcomponent
// - votecomponent
// - inforow (vista auxiliar local)

import SwiftUI

struct ReportDetailView: View {

    @StateObject private var viewModel: ReportDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager // For checking current user

    // State for full-screen image view
    @State private var isShowingFullScreenImage = false
    @State private var selectedImageURL: URL?

    // Store the ID of the currently logged-in user
    private let currentUserId: Int?

    init(report: Report, currentUserId: Int?) {
        _viewModel = StateObject(wrappedValue: ReportDetailViewModel(report: report))
        self.currentUserId = currentUserId
    }

    // ✨ BODY SIMPLIFIED ✨
    var body: some View {
        ZStack { // ZStack allows the full-screen image view to overlay
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {

                    // Use the computed property for the main card
                    reportCard

                    // --- Voting Section ---
                    if viewModel.report.statusText?.lowercased() == "approved" {
                        let scoreBinding = Binding<Int>(get: { viewModel.report.voteScore ?? 0 }, set: { _ in })
                        let statusBinding = Binding<UserVoteStatus?>(get: { viewModel.report.userVoteStatus }, set: { _ in })

                        VoteComponent(
                            score: scoreBinding,
                            voteStatus: statusBinding,
                            onUpvote: { viewModel.handleUpvote() },
                            onDownvote: { viewModel.handleDownvote() }
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                } // End Main VStack
                .padding()

            } // End ScrollView
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Detalle del Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { // Toolbar remains the same
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primaryBlue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isReportEditable() {
                        NavigationLink(destination: EditReportView(report: viewModel.report)) {
                            Text("Editar")
                                .fontWeight(.bold)
                                .foregroundColor(.primaryBlue)
                        }
                    }
                }
            }

            // Full-screen image overlay (remains the same)
            if isShowingFullScreenImage, let url = selectedImageURL {
                FullScreenImageView(url: url, isPresented: $isShowingFullScreenImage)
            }

        } // End ZStack
    } // End body

    // ✨ NEW COMPUTED PROPERTY for the main report card ✨
    private var reportCard: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack(alignment: .top) {
                Text(viewModel.report.title)
                    .font(.title).bold()
                Spacer()
                TagComponent(text: viewModel.report.severity)
            }

            Text("Reporte de sitio \"\(viewModel.report.url)\" por el usuario \"\(viewModel.report.user.username)\"")
                .font(.subheadline).foregroundColor(.textSecondary)

            Divider().padding(.vertical, 5)

            InfoRow(label: "ID:", value: viewModel.report.displayId)
            InfoRow(label: "Fecha:", value: viewModel.report.date)
            InfoRow(label: "URL:", value: viewModel.report.url)
            InfoRow(label: "Puntuación de Severidad:", value: "\(viewModel.report.severityScore)")

            Divider().padding(.vertical, 5)

            InfoRow(label: "Categorías:") {
                FlexibleHStackView(items: viewModel.report.category.components(separatedBy: ", ")) { tagText in
                    TagComponent(text: tagText)
                }
            }

            InfoRow(label: "Impactos:") {
                FlexibleHStackView(items: viewModel.report.impacts) { impactText in
                    TagComponent(text: impactText)
                }
            }

            InfoRow(label: "Descripción:", value: viewModel.report.description)

            InfoRow(label: "Evidencias:") {
                if viewModel.report.evidences.isEmpty {
                    Text("No hay evidencias adjuntas.").foregroundColor(.textSecondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.report.evidences) { evidence in
                                if let urlString = evidence.evidenceFileUrl, let url = URL(string: urlString) {
                                    Button(action: {
                                        selectedImageURL = url
                                        isShowingFullScreenImage = true
                                    }) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            case .failure:
                                                Image(systemName: "photo.on.rectangle.angled").font(.largeTitle).foregroundColor(.textSecondary)
                                            case .empty:
                                                ProgressView()
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(width: 200, height: 120)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                        .clipped()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // --- Admin Feedback Box ---
            if let feedback = viewModel.report.adminFeedback, !feedback.isEmpty,
               viewModel.report.userId == currentUserId {
                FeedbackBoxComponent(feedback: feedback)
            }
        }
        .padding()
        .background(Color.textFieldBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // isReportEditable function (remains the same)
    private func isReportEditable() -> Bool {
        guard let status = viewModel.report.statusText?.lowercased() else {
            return false
        }
        return status == "pending" || status == "revision" || status == "rejected" || status == "rechazado"
    }

} // End Struct

// --- Full Screen Image View Component (remains the same) ---
struct FullScreenImageView: View {
    let url: URL
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            ScrollView([.horizontal, .vertical]) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView().tint(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .transition(.opacity.animation(.easeInOut))
    }
}

// --- Auxiliary Components (InfoRow, FlexibleHStackView) (remain the same) ---
private struct InfoRow<Content: View>: View {
    let label: String
    var content: Content?

    init(label: String, value: String) where Content == Text {
        self.label = label
        self.content = Text(value).font(.body)
    }

    init(label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.subheadline).foregroundColor(.textSecondary)
            content
        }
    }
}

struct FlexibleHStackView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let spacing: CGFloat = 8
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        let itemsArray = Array(items)
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(itemsArray.indices, id: \.self) { index in
                let item = itemsArray[index]

                self.content(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        if index == itemsArray.endIndex - 1 {
                            width = 0
                        } else {
                            width -= d.width + spacing
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if index == itemsArray.endIndex - 1 {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

// MARK: --- Preview Provider ---
