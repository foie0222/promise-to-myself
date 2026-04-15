import SwiftUI

struct PromiseInputView: View {
    let viewModel: AppViewModel
    @State private var content: String = ""
    @State private var deadline: Date = Calendar.current.date(
        byAdding: .day, value: 1, to: Date()
    )!

    private var isValid: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("自分に約束する")
                .font(AppTheme.titleText)
                .foregroundStyle(AppTheme.textSecondary)

            ZStack {
                if content.isEmpty {
                    Text("約束の内容")
                        .font(AppTheme.promiseText)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                }
                TextEditor(text: $content)
                    .font(AppTheme.promiseText)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 40, maxHeight: 120)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 8) {
                Text("いつまで")
                    .font(AppTheme.captionText)
                    .foregroundStyle(AppTheme.textSecondary)

                DatePicker(
                    "",
                    selection: $deadline,
                    in: Calendar.current.startOfDay(for: Date())...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(AppTheme.accent)
                .environment(\.locale, Locale(identifier: "ja_JP"))
            }

            Spacer()

            Button {
                viewModel.makePromise(
                    content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                    deadline: deadline
                )
            } label: {
                Text("約束する")
                    .font(AppTheme.buttonText)
                    .foregroundStyle(AppTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isValid ? AppTheme.accent : AppTheme.textSecondary.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid)
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}
