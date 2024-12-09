import StoreKit
import Foundation

class APPSunManager: NSObject {
    static let shared = APPSunManager()
    
    // 内购商品ID
    enum ProductID: String, CaseIterable {
        // VIP 档位
        case vipWeekly = "com.oiyo.weekly"     // 周卡
        case vipMonthly = "com.oiyo.monthly"   // 月卡
        
        // 金币档位
        case oiyo2 = "com.oiyo.coins.2"
        case oiyo5 = "com.oiyo.coins.5"
        case oiyo9 = "com.oiyo.coins.9"
        case oiyo19 = "com.oiyo.coins.19"
        case oiyo49 = "com.oiyo.coins.49"
        case oiyo99 = "com.oiyo.coins.99"
        case oiyo159 = "com.oiyo.coins.159"
        case oiyo239 = "com.oiyo.coins.239"
        
        var coins: Int {
            switch self {
            case .oiyo2: return 100
            case .oiyo5: return 300
            case .oiyo9: return 600
            case .oiyo19: return 1500
            case .oiyo49: return 4000
            case .oiyo99: return 8500
            case .oiyo159: return 15000
            case .oiyo239: return 25000
            default: return 0
            }
        }
        
        var price: String {
            switch self {
            case .oiyo2: return "2.99"
            case .oiyo5: return "5.99"
            case .oiyo9: return "9.99"
            case .oiyo19: return "19.99"
            case .oiyo49: return "49.99"
            case .oiyo99: return "99.99"
            case .oiyo159: return "159.99"
            case .oiyo239: return "239.99"
            case .vipWeekly: return "12.99"
            case .vipMonthly: return "49.99"
            }
        }
        
        var title: String {
            switch self {
            case .vipWeekly: return "Weekly VIP"
            case .vipMonthly: return "Monthly VIP"
            default: return ""
            }
        }
        
        var subscriptionDays: Int {
            switch self {
            case .vipWeekly: return 7
            case .vipMonthly: return 30
            default: return 0
            }
        }
        
        var isSubscription: Bool {
            switch self {
            case .vipWeekly, .vipMonthly:
                return true
            default:
                return false
            }
        }
    }
    
    private var productsRequest: SKProductsRequest?
    private var purchaseCompletion: ((Bool, Error?) -> Void)?
    private var fetchedProducts: [SKProduct] = []
    
    override private init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    // 获取商品信息
    func fetchProducts(productIds: [ProductID], completion: @escaping ([SKProduct]?, Error?) -> Void) {
        let productIdentifiers = Set(productIds.map { $0.rawValue })
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
        
        self.purchaseCompletion = { success, error in
            if success {
                completion(self.fetchedProducts, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    // 购买商品
    func purchase(product: SKProduct, completion: @escaping (Bool, Error?) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(false, NSError(
                domain: "IAPManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "In-App Purchases are not allowed"]
            ))
            return
        }
        
        self.purchaseCompletion = completion
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // 恢复购买
    func restorePurchases(completion: @escaping (Bool, Error?) -> Void) {
        self.purchaseCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // 获取本地化价格
    func formattedPrice(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
}

// MARK: - SKProductsRequestDelegate
extension APPSunManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.fetchedProducts = response.products
        
        if response.products.isEmpty {
            let error = NSError(
                domain: "IAPManager",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "No products found"]
            )
            purchaseCompletion?(false, error)
            return
        }
        
        purchaseCompletion?(true, nil)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        purchaseCompletion?(false, error)
    }
}

// MARK: - SKPaymentTransactionObserver
extension APPSunManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                if let product = ProductID(rawValue: transaction.payment.productIdentifier) {
                    handlePurchaseSuccess(for: product)
                }
                queue.finishTransaction(transaction)
                purchaseCompletion?(true, nil)
                
            case .failed:
                queue.finishTransaction(transaction)
                purchaseCompletion?(false, transaction.error)
                
            case .restored:
                if let product = ProductID(rawValue: transaction.payment.productIdentifier) {
                    handlePurchaseSuccess(for: product)
                }
                queue.finishTransaction(transaction)
                purchaseCompletion?(true, nil)
                
            case .deferred:
                purchaseCompletion?(false, NSError(
                    domain: "IAPManager",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Purchase deferred"]
                ))
                
            case .purchasing:
                break
                
            @unknown default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseCompletion?(true, nil)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        purchaseCompletion?(false, error)
    }
    
    private func handlePurchaseSuccess(for product: ProductID) {
        if product.isSubscription {
            UserDataManager.shared.extendVIPPeriod(days: product.subscriptionDays)
        } else {
            UserDataManager.shared.addCoins(product.coins)
        }
    }
}

