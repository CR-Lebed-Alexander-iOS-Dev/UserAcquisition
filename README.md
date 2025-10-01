# UserAcquisition

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

iOS библиотека для отслеживания источников привлечения пользователей и аналитики покупок. Поддерживает интеграцию с популярными платформами аттрибуции и аналитики.

## 🎯 Возможности

- ✅ Отслеживание источников привлечения пользователей
- ✅ Логирование in-app покупок (StoreKit 1 и StoreKit 2)
- ✅ Регистрация push-токенов
- ✅ Обработка возвратов (refunds)
- ✅ Интеграция с платформами аттрибуции:
  - AppsFlyer
  - Adjust
  - Branch
- ✅ Интеграция с аналитикой:
  - YandexMetrica
  - Amplitude
- ✅ Поддержка Apple Search Ads
- ✅ Async/await API
- ✅ Сбор детальных метрик (IDFA, IDFV, версия приложения и т.д.)

## 📋 Требования

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## 📦 Установка

### CocoaPods

Добавьте в ваш `Podfile`:

```ruby
platform :ios, '15.0'

target 'YourApp' do
  use_frameworks!

  # Использование конкретной версии (рекомендуется)
  pod 'UserAcquisition', :git => 'https://github.com/CR-Lebed-Alexander-iOS-Dev/UserAcquisition.git', :tag => '0.4'
  
  # Или использование ветки dev (для разработки)
  # pod 'UserAcquisition', :git => 'https://github.com/CR-Lebed-Alexander-iOS-Dev/UserAcquisition.git', :branch => 'dev'
end
```

Затем выполните:

```bash
pod install
```

## 🚀 Быстрый старт

### 1. Инициализация

```swift
import UserAcquisition
import SwiftyStoreKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var userAcquisitionService: UserAcquisitionService!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Инициализация UserAcquisitionService
        userAcquisitionService = UserAcquisitionService(
            apiKey: "YOUR_API_KEY",
            serverUrl: "your-server.com",
            sharedSecret: "YOUR_SHARED_SECRET",
            appleReceiptValidator: .production // или .sandbox для тестирования
        )
        
        return true
    }
}
```

### 2. Логирование покупок

#### StoreKit 1 (SKProduct)

```swift
import StoreKit

func purchaseCompleted(product: SKProduct) {
    Task {
        await userAcquisitionService.logPurchase(of: product)
    }
}
```

#### StoreKit 2 (Product)

```swift
import StoreKit

func purchaseCompleted(product: Product) async {
    await userAcquisitionService.logPurchase(of: product)
}
```

### 3. Регистрация Push-токена

```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    
    Task {
        await userAcquisitionService.log(
            pushDeviceToken: tokenString,
            and: "originalTransactionID"
        )
    }
}
```

### 4. Обработка возвратов

```swift
func handleRefund(userConsented: Bool) {
    Task {
        await userAcquisitionService.refund(consented: userConsented)
    }
}
```

### 5. Дополнительные параметры

Вы можете добавлять кастомные параметры для трекинга:

```swift
userAcquisitionService.setExtraValue("premium_user", forKey: "user_tier")
userAcquisitionService.setExtraValue(true, forKey: "is_subscribed")
```

## 🔌 Интеграция с платформами аттрибуции

### AppsFlyer

```swift
import AppsFlyerLib

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        if let data = conversionInfo as? [String: Any] {
            // Передача данных в UserAcquisitionService
            // Требуется доступ к conversionInfo через публичное API
            // (см. раздел "Известные ограничения")
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("AppsFlyer error: \(error)")
    }
}
```

### YandexMetrica

```swift
import YandexMobileMetrica

YMMYandexMetrica.requestAppMetricaDeviceID(withCompletionQueue: .main) { deviceID, error in
    if let deviceID = deviceID {
        // Сохранение ID для использования в UserAcquisitionService
        print("YandexMetrica Device ID: \(deviceID)")
    }
}
```

### Amplitude

```swift
import Amplitude

let amplitudeDeviceId = Amplitude.instance().deviceId
// Передача ID в UserAcquisitionService
```

### Apple Search Ads

```swift
import iAd

ADClient.shared().requestAttributionDetails { attributionDetails, error in
    guard let attributionDetails = attributionDetails else {
        print("Search Ads error: \(error?.localizedDescription ?? "")")
        return
    }
    
    // Обработка данных атрибуции Search Ads
    print("Search Ads attribution: \(attributionDetails)")
}
```

## 📚 API Reference

### UserAcquisitionProtocol

Основной протокол, определяющий интерфейс сервиса:

```swift
protocol UserAcquisitionProtocol {
    /// Обработка возврата средств
    func refund(consented: Bool) async
    
    /// Логирование push-токена с ID транзакции
    func log(pushDeviceToken: String, and originalTransactionID: String) async
    
    /// Логирование покупки SKProduct
    func logPurchase(of product: SKProduct) async
    
    /// Логирование покупки StoreKit 2 Product
    func logPurchase(of product: Product) async
    
    /// Установка дополнительного значения
    func setExtraValue(_ value: Any, forKey key: String)
}
```

### UserAcquisitionService

Основная имплементация сервиса:

```swift
final class UserAcquisitionService: NSObject {
    init(
        apiKey: String,
        serverUrl: String,
        sharedSecret: String,
        appleReceiptValidator: AppleReceiptValidator.VerifyReceiptURLType
    )
}
```

## 🔧 Архитектура

Библиотека использует протокол-ориентированную архитектуру:

```
UserAcquisitionProtocol (Protocol)
         ↑
         |
UserAcquisitionService (Implementation)
```

Это позволяет легко тестировать и mock-ировать сервис в unit-тестах.

## 📡 API Endpoints

Библиотека взаимодействует со следующими endpoints:

- `POST /v2/receipt` - отправка данных о покупках
- `POST /v2/ios/push_token` - регистрация push-токенов
- `POST /v1/ios/user_info` - информация о пользователе и возвратах

## 🔒 Приватность

Библиотека собирает следующие данные:

- ✅ IDFA (Identifier for Advertisers)
- ✅ IDFV (Identifier for Vendor)
- ✅ Bundle ID
- ✅ Версия и build приложения
- ✅ Данные о покупках
- ✅ Push-токены

**Важно:** Убедитесь, что вы запрашиваете разрешение на отслеживание (App Tracking Transparency) перед доступом к IDFA:

```swift
import AppTrackingTransparency

func requestTrackingPermission() {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("Tracking authorized")
            case .denied, .restricted, .notDetermined:
                print("Tracking not authorized")
            @unknown default:
                break
            }
        }
    }
}
```

## ⚠️ Известные ограничения

1. **Версия iOS**: Требуется iOS 15.0+ для поддержки StoreKit 2 API
2. **Публичный API**: Текущая версия имеет ограниченный публичный API. Для доступа к `conversionInfo` требуется расширение сервиса
3. **iOS 16 API**: Некоторые API (например, `Locale.currency`, `Locale.region`) доступны только с iOS 16+

## 🛠 Разработка

### Локальная разработка

Для локальной разработки используйте:

```ruby
pod 'UserAcquisition', :path => '../UserAcquisition'
```

### Запуск тестов

```bash
xcodebuild test -workspace UserAcquisition.xcworkspace -scheme UserAcquisition -destination 'platform=iOS Simulator,name=iPhone 14'
```

## 📝 Changelog

### Version 0.4 (Current - dev branch)
- ✨ Рефакторинг: разделение на Protocol и Service
- ✨ Поддержка iOS 15.0+
- ✨ Улучшенная архитектура
- ✨ Обновлен podspec с правильными путями к файлам
- 📚 Улучшена документация

### Version 0.3
- Previous stable version

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Alex Lebed**
- Email: al@createx.by
- GitHub: [@CR-Lebed-Alexander-iOS-Dev](https://github.com/CR-Lebed-Alexander-iOS-Dev)

## 🔗 Links

- [GitHub Repository](https://github.com/CR-Lebed-Alexander-iOS-Dev/UserAcquisition)
- [Issues](https://github.com/CR-Lebed-Alexander-iOS-Dev/UserAcquisition/issues)
- [Pull Requests](https://github.com/CR-Lebed-Alexander-iOS-Dev/UserAcquisition/pulls)

## ⭐️ Support

If you find this library useful, please give it a star ⭐️

---

Made with ❤️ by Alex Lebed
