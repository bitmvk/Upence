package com.upence.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.upence.data.ALL_CURRENCIES

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CurrencyCard(
    currencyCode: String,
    currencySymbol: String,
    useCustomCurrency: Boolean,
    onCurrencyCodeChange: (String) -> Unit,
    onCurrencySymbolChange: (String) -> Unit,
    onUseCustomCurrencyChange: (Boolean) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    var customSymbolState by remember { mutableStateOf(androidx.compose.ui.text.input.TextFieldValue(currencySymbol)) }

    androidx.compose.runtime.LaunchedEffect(currencySymbol) {
        customSymbolState = customSymbolState.copy(text = currencySymbol)
    }

    Column(modifier = Modifier.padding(16.dp)) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(bottom = 16.dp),
        ) {
            Icon(Icons.Default.AttachMoney, contentDescription = null, modifier = Modifier.size(24.dp))
            Spacer(modifier = Modifier.width(12.dp))
            Text("Currency", style = MaterialTheme.typography.titleMedium)
        }

        ExposedDropdownMenuBox(
            expanded = expanded && !useCustomCurrency,
            onExpandedChange = { if (!useCustomCurrency) expanded = !expanded },
        ) {
            OutlinedTextField(
                value = ALL_CURRENCIES.find { it.code == currencyCode }?.name ?: "Select Currency",
                onValueChange = {},
                readOnly = true,
                enabled = !useCustomCurrency,
                label = { Text("Currency") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .menuAnchor(),
            )

            DropdownMenu(
                expanded = expanded && !useCustomCurrency,
                onDismissRequest = { expanded = false },
            ) {
                ALL_CURRENCIES.filter { it.code != "CUSTOM" }.forEach { currency ->
                    DropdownMenuItem(
                        text = {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(currency.flagEmoji, modifier = Modifier.padding(end = 8.dp))
                                Text("${currency.name} (${currency.code})")
                            }
                        },
                        onClick = {
                            if (!useCustomCurrency) {
                                onCurrencyCodeChange(currency.code)
                                onCurrencySymbolChange(currency.symbol)
                                expanded = false
                            }
                        },
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth(),
        ) {
            Switch(
                checked = useCustomCurrency,
                onCheckedChange = onUseCustomCurrencyChange,
            )
            Spacer(modifier = Modifier.width(12.dp))
            Text("Use custom currency symbol")
        }

        if (useCustomCurrency) {
            Spacer(modifier = Modifier.height(12.dp))
            OutlinedTextField(
                value = customSymbolState,
                onValueChange = { newValue ->
                    customSymbolState = newValue
                    onCurrencySymbolChange(newValue.text)
                },
                label = { Text("Custom Symbol") },
                placeholder = { Text("e.g., BTC, 🪙, ★") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            colors =
                CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                ),
        ) {
            Text(
                "Preview: $currencySymbol 1,234.56",
                modifier = Modifier.padding(12.dp),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onPrimaryContainer,
            )
        }
    }
}
