import SwiftUI
import Combine

struct DecimalField : View {
    let label: LocalizedStringKey
    @Binding var value: Decimal?
    let formatter: NumberFormatter
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    
    private let editStringFormatter: NumberFormatter
    
    @State private var textValue: String = ""
    
    @State private var hasInitialTextValue = false
    
    init(
        _ label: LocalizedStringKey,
        value: Binding<Decimal?>,
        formatter: NumberFormatter,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = {}
    ) {
        self.label = label
        self._value = value
        self.formatter = formatter
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        
        // We configure the edit string formatter to behave like the
        // input formatter without add the currency symbol,
        // percent symbol, etc...
        self.editStringFormatter = NumberFormatter()
        self.editStringFormatter.allowsFloats = formatter.allowsFloats
        self.editStringFormatter.alwaysShowsDecimalSeparator = formatter.alwaysShowsDecimalSeparator
        self.editStringFormatter.decimalSeparator = formatter.decimalSeparator
        self.editStringFormatter.maximumIntegerDigits = formatter.maximumIntegerDigits
        self.editStringFormatter.maximumSignificantDigits = formatter.maximumSignificantDigits
        self.editStringFormatter.maximumFractionDigits = formatter.maximumFractionDigits
        self.editStringFormatter.multiplier = formatter.multiplier
    }
    
    var body: some View {
        TextField(label, text: $textValue, onEditingChanged: { isInFocus in
            // When the field is in focus we replace the field's contents
            // with a plain specifically formatted number. When not in focus, the field
            // is treated as a label and shows the formatted value.
            if isInFocus {
                let newValue = self.formatter.number(from: self.textValue)
                self.textValue = self.editStringFormatter.string(for: newValue) ?? ""
            } else {
                let f = self.formatter
                let newValue = f.number(from: self.textValue)?.decimalValue
                self.textValue = f.string(for: newValue) ?? ""
            }
            self.onEditingChanged(isInFocus)
        }, onCommit: {
            self.onCommit()
        })
            .onReceive(Just(textValue)) {
                guard self.hasInitialTextValue else {
                    return
                }

                self.value = self.formatter.number(from: $0)?.decimalValue
        }
            .onAppear(){
                self.hasInitialTextValue = true
  
                if let value = self.value {

                    self.textValue = self.formatter.string(from: NSDecimalNumber(decimal: value)) ?? ""
                }
        }
        .keyboardType(.decimalPad)
    }
}

struct DecimalField_Previews: PreviewProvider {
    static var previews: some View {
        TipCalculator()
    }
    
    struct TipCalculator: View {
        @State var amount: Decimal? = 50
        @State var tipRate: Decimal?
        
        var tipValue: Decimal {
            guard let amount = self.amount, let tipRate = self.tipRate else {
                return 0
            }
            return amount * tipRate
        }
        
        var totalValue: Decimal {
            guard let amount = self.amount else {
                return tipValue
            }
            return amount + tipValue
        }
        
        static var currencyFormatter: NumberFormatter {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.isLenient = true
            return nf
        }
        
        static var percentFormatter: NumberFormatter {
            let nf = NumberFormatter()
            nf.numberStyle = .percent
            nf.isLenient = true
            return nf
        }
        
        var body: some View {
            Form {
                Section {
                    DecimalField("Amount", value: $amount, formatter: Self.currencyFormatter)
                    DecimalField("Tip Rate", value: $tipRate, formatter: Self.percentFormatter)
                }
                Section {
                    HStack {
                        Text("Tip Amount")
                        Spacer()
                        Text(Self.currencyFormatter.string(for: tipValue)!)
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(Self.currencyFormatter.string(for: totalValue)!)
                    }
                }
            }
        }
    }
}
