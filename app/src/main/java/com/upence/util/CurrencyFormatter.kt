package com.upence.util

import java.text.NumberFormat
import java.util.Locale

object CurrencyFormatter {
    fun formatAmount(
        amount: Double,
        symbol: String,
    ): String {
        return "$symbol${String.format("%.2f", amount)}"
    }

    fun formatCurrency(
        amount: Double,
        currencyCode: String,
    ): String {
        val locale =
            when (currencyCode.uppercase()) {
                "INR" -> Locale("en", "IN")
                "USD" -> Locale.US
                "EUR" -> Locale.GERMANY
                "GBP" -> Locale.UK
                "JPY" -> Locale.JAPAN
                "CNY" -> Locale.CHINA
                "KRW" -> Locale.KOREA
                "AUD" -> Locale("en", "AU")
                "CAD" -> Locale.CANADA
                "CHF" -> Locale("de", "CH")
                "HKD" -> Locale("zh", "HK")
                "SGD" -> Locale("en", "SG")
                "MYR" -> Locale("ms", "MY")
                "THB" -> Locale("th", "TH")
                "IDR" -> Locale("id", "ID")
                "VND" -> Locale("vi", "VN")
                "PHP" -> Locale("fil", "PH")
                "AED" -> Locale("ar", "AE")
                "SAR" -> Locale("ar", "SA")
                "ZAR" -> Locale("en", "ZA")
                "NGN" -> Locale("en", "NG")
                "EGP" -> Locale("ar", "EG")
                "MXN" -> Locale("es", "MX")
                "BRL" -> Locale("pt", "BR")
                "ARS" -> Locale("es", "AR")
                "COP" -> Locale("es", "CO")
                "TRY" -> Locale("tr", "TR")
                "ILS" -> Locale("iw", "IL")
                "PLN" -> Locale("pl", "PL")
                "RUB" -> Locale("ru", "RU")
                else -> Locale.US
            }
        return NumberFormat.getCurrencyInstance(locale).format(amount)
    }

    fun getCurrencySymbol(symbol: String): String {
        return symbol
    }
}
