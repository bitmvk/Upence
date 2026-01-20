package com.upence.data

data class Currency(
    val code: String,          // ISO 4217: INR, USD, EUR
    val symbol: String,        // ₹, $, €
    val name: String,         // Indian Rupee, US Dollar
    val flagEmoji: String     // 🇮🇳, 🇺🇸, 🇪🇺
)

// Complete ISO 4217 currency list
val ALL_CURRENCIES = listOf(
    // Major currencies
    Currency("INR", "₹", "Indian Rupee", "🇮🇳"),
    Currency("USD", "$", "US Dollar", "🇺🇸"),
    Currency("EUR", "€", "Euro", "🇪🇺"),
    Currency("GBP", "£", "British Pound", "🇬🇧"),
    Currency("JPY", "¥", "Japanese Yen", "🇯🇵"),
    Currency("CNY", "¥", "Chinese Yuan", "🇨🇳"),
    Currency("AUD", "A$", "Australian Dollar", "🇦🇺"),
    Currency("CAD", "C$", "Canadian Dollar", "🇨🇦"),
    Currency("CHF", "Fr", "Swiss Franc", "🇨🇭"),
    Currency("HKD", "HK$", "Hong Kong Dollar", "🇭🇰"),
    Currency("SGD", "S$", "Singapore Dollar", "🇸🇬"),
    
    // Asian currencies
    Currency("KRW", "₩", "South Korean Won", "🇰🇷"),
    Currency("TWD", "NT$", "New Taiwan Dollar", "🇹🇼"),
    Currency("THB", "฿", "Thai Baht", "🇹🇭"),
    Currency("IDR", "Rp", "Indonesian Rupiah", "🇮🇩"),
    Currency("MYR", "RM", "Malaysian Ringgit", "🇲🇾"),
    Currency("PHP", "₱", "Philippine Peso", "🇵🇭"),
    Currency("VND", "₫", "Vietnamese Dong", "🇻🇳"),
    Currency("PKR", "₨", "Pakistani Rupee", "🇵🇰"),
    Currency("BDT", "৳", "Bangladeshi Taka", "🇧🇩"),
    Currency("LKR", "රු", "Sri Lankan Rupee", "🇱🇰"),
    Currency("NPR", "₨", "Nepalese Rupee", "🇳🇵"),
    
    // Middle Eastern currencies
    Currency("AED", "د.إ", "UAE Dirham", "🇦🇪"),
    Currency("SAR", "﷼", "Saudi Riyal", "🇸🇦"),
    Currency("KWD", "د.ك", "Kuwaiti Dinar", "🇰🇼"),
    Currency("QAR", "ر.ق", "Qatari Riyal", "🇶🇦"),
    Currency("BHD", "ب.د", "Bahraini Dinar", "🇧🇭"),
    Currency("OMR", "ر.ع.", "Omani Rial", "🇴🇲"),
    
    // European currencies
    Currency("RUB", "₽", "Russian Ruble", "🇷🇺"),
    Currency("PLN", "zł", "Polish Zloty", "🇵🇱"),
    Currency("CZK", "Kč", "Czech Koruna", "🇨🇿"),
    Currency("HUF", "Ft", "Hungarian Forint", "🇭🇺"),
    Currency("RON", "lei", "Romanian Leu", "🇷🇴"),
    Currency("BGN", "лв", "Bulgarian Lev", "🇧🇬"),
    Currency("HRK", "kn", "Croatian Kuna", "🇭🇷"),
    Currency("SEK", "kr", "Swedish Krona", "🇸🇪"),
    Currency("NOK", "kr", "Norwegian Krone", "🇳🇴"),
    Currency("DKK", "kr", "Danish Krone", "🇩🇰"),
    Currency("ISK", "kr", "Icelandic Króna", "🇮🇸"),
    
    // Americas
    Currency("MXN", "$", "Mexican Peso", "🇲🇽"),
    Currency("BRL", "R$", "Brazilian Real", "🇧🇷"),
    Currency("ARS", "$", "Argentine Peso", "🇦🇷"),
    Currency("CLP", "$", "Chilean Peso", "🇨🇱"),
    Currency("COP", "$", "Colombian Peso", "🇨🇴"),
    Currency("PEN", "S/", "Peruvian Sol", "🇵🇪"),
    
    // African currencies
    Currency("ZAR", "R", "South African Rand", "🇿🇦"),
    Currency("EGP", "£", "Egyptian Pound", "🇪🇬"),
    Currency("NGN", "₦", "Nigerian Naira", "🇳🇬"),
    Currency("KES", "KSh", "Kenyan Shilling", "🇰🇪"),
    Currency("GHS", "₵", "Ghanaian Cedi", "🇬🇭"),
    
    // Oceanian
    Currency("NZD", "NZ$", "New Zealand Dollar", "🇳🇿"),
    Currency("FJD", "F$", "Fijian Dollar", "🇫🇯"),
    
    // Others
    Currency("TRY", "₺", "Turkish Lira", "🇹🇷"),
    Currency("ILS", "₪", "Israeli New Shekel", "🇮🇱"),
    Currency("CUP", "$", "Cuban Peso", "🇨🇺"),
    Currency("CNY", "¥", "Chinese Yuan", "🇨🇳"),
    Currency("BTC", "₿", "Bitcoin", "₿"),
    Currency("ETH", "Ξ", "Ethereum", "Ξ"),
    
    // Custom option
    Currency("CUSTOM", "", "Custom Symbol", "⭐")
)
