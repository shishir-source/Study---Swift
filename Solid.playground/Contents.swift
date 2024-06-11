
import Foundation

// MARK: - Single Responsibilty Principle (SRP)

/*
 
    NOTES:
    A class should be responsible for one thing
*/

struct Product {
    let price: Double
}

struct Invoice {
    var products: [Product]
    let id = NSUUID().uuidString
    var discountPercentage: Double = 0
    var total: Double {
        let total = products.map({$0.price}).reduce(0, {$0 + $1})
        let discountAmount = total * (discountPercentage / 100)
        return total - discountAmount
    }
    
    func printInvoice() {
        print("________________")
        print("invoice id: \(id)")
        print("Total const: $\(total)")
        print("Discounts: $\(discountPercentage)")
        print("________________")
        
        //let printer = InvoicePrinter(invoice: self)
        //printer.printInvoice()
    }
    
    func saveInvoice(){
        // save data
        
        //let persistance = InvoicePersistance(invoice: self )
        //persistance.saveInvoice()
    }
    
    //Responsible for Multiple things
}


let products: [Product] = [
    .init(price: 99.99),
    .init(price: 79.99),
    .init(price: 29.99),
    .init(price: 9.99),
]

let invoice = Invoice(products: products, discountPercentage: 20)
invoice.printInvoice()



//Refactored
struct InvoicePrinter {
    let invoice: Invoice
    
    func printInvoice() {
        print("________________")
        print("invoice id: \(invoice.id)")
        print("Total const: $\(invoice.total)")
        print("Discounts: $\(invoice.discountPercentage)")
        print("________________")
    }

}

struct InvoicePersistance {
    let invoice: Invoice
    
    func saveInvoice(){
        // save data
    }
}

let printer = InvoicePrinter(invoice: invoice)
printer.printInvoice()

let persistance = InvoicePersistance(invoice: invoice)
persistance.saveInvoice()

//Better
invoice.printInvoice()
invoice.saveInvoice()


// MARK: - Open/Closed Principle

/*
 Notes:
        Software entities (classes, modules, function, etc.) should be open for extension but closed for modification.
        In other words, we can add additional functionality without touching the existing code of an object
 */

extension Int {
    func squared() -> Int {
        return self * self
    }
}

var num = 2
num.squared()

struct InvoicePersistanceOCP {
    
    let persistance: InvoicePersistable
    
    // we could delete these funcs now
    func saveInvoiceToCoreData(){
        // save data
    }
    
    func saveInvoiceToDatabase(){
        // save data
    }
    
    //better
//    func save(invoice: Invoice) {
//        persistance.save(invoice: invoice)
//    }
}


///

protocol InvoicePersistable {
    func save(invoice: Invoice)
}

struct CoreDataPersistance: InvoicePersistable {
    func save(invoice: Invoice) {
        print("Save invoice to CoreData: \(invoice.id)")
    }
}

struct DatabasePersistance: InvoicePersistable {
    func save(invoice: Invoice) {
        print("Save invoice to Database: \(invoice.id)")
    }
}

let coreDataPersistance = CoreDataPersistance()
let persistanceOCP = InvoicePersistanceOCP(persistance: coreDataPersistance)

//persistanceOCP.save(invoice: invoice)






//MARK: - Liskov Substitution Principle (LSP)


/* 
 Notes:
 Derived or child classes/structure must be substituable for their base or parent classes.
*/
enum APIError: Error {
    case invalidUrl
    case invalidResponse
    case invalidStatusCode
}

struct MockUserService {
    
    func fetchUser() async throws {
        do {
            throw APIError.invalidResponse
        } catch {
            print("Error: \(error)")
        }
    }
}

let mockUserService = MockUserService()
Task { try await mockUserService.fetchUser() }




//MARK: - Interface Segregation Principle (ISP)

/*
 Notes:
    Do not force any client to implement an interface which is irrelevent to them
 */

protocol GestureProtocol {
    func didTap()
    func didDoubleTap()
    func didLongPress()
}

struct SuperButton: GestureProtocol {
    func didTap() { }
    
    func didDoubleTap() { }
    
    func didLongPress() { }
    
}

struct DoubleTapButton: GestureProtocol {
    func didTap() { }
    
    func didDoubleTap() { }
    
    func didLongPress() { }
    
}



protocol SingleTapProtocol {
    func didTap()
}

protocol DoubleTapProtocol {
    func didDoubleTap()
}

protocol LongPressProtocol {
    func didLongPress()
}


struct SingleButton: SingleTapProtocol{
    func didTap() {
    }
}

struct FullButton: SingleTapProtocol, DoubleTapProtocol, LongPressProtocol {
    func didTap() {
    }
    
    func didDoubleTap() {
    }
    
    func didLongPress() {
    }
    
}




//MARK: - Dependency Inversion Principle (DIP)

/*
 Notes:
    - High-level modules should not depend on low-level modules, but should depend on absraction
    - If a high-level module imports any low-level module then the code becomes tightly coupled.
    - Changes in one class should break another class.
 */



struct DebitCardPayment {
    func execute(amount: Double) {
        print("Debit card payement success for \(amount)")
    }
}

struct StripePayment {
    func execute(amount: Double) {
        print("Stripe payement success for \(amount)")
    }
}

struct ApplePayPayment {
    func execute(amount: Double) {
        print("Applepay payement success for \(amount)")
    }
}

struct Payment {
    var debitCardPayment: DebitCardPayment?
    var stripePayment: StripePayment?
    var applePayPayment: ApplePayPayment?
}

let paymentMethod = DebitCardPayment()
let payment = Payment(debitCardPayment: paymentMethod)
payment.debitCardPayment?.execute(amount: 100)



// Better

protocol PaymentMethod {
    func execute(amount: Double)
}

struct DebitCardPaymentDIP:PaymentMethod {
    func execute(amount: Double) {
        print("Debit card payement success for \(amount)")
    }
}

struct StripePaymentDIP: PaymentMethod {
    func execute(amount: Double) {
        print("Stripe payement success for \(amount)")
    }
}

struct ApplePayPaymentDIP: PaymentMethod {
    func execute(amount: Double) {
        print("Applepay payement success for \(amount)")
    }
}


struct PaymentDIP {
    let payment: PaymentMethod
    
    func makePayment(amount: Double) {
        payment.execute(amount: amount)
    }
}

let stripe = StripePaymentDIP()
let paymentDIP = PaymentDIP(payment: stripe)

paymentDIP.makePayment(amount: 200)
