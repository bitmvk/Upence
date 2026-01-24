package com.upence.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun AppearanceCard(
    themeMode: Int,
    onThemeModeChange: (Int) -> Unit,
) {
    Card {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(bottom = 16.dp),
            ) {
                Icon(Icons.Default.Palette, contentDescription = null, modifier = Modifier.size(24.dp))
                Spacer(modifier = Modifier.width(12.dp))
                Text("Appearance", style = MaterialTheme.typography.titleMedium)
            }

            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                RadioButtonWithLabel(
                    selected = themeMode == 0,
                    onClick = { onThemeModeChange(0) },
                    label = "Light Mode",
                )

                RadioButtonWithLabel(
                    selected = themeMode == 1,
                    onClick = { onThemeModeChange(1) },
                    label = "Dark Mode",
                )

                RadioButtonWithLabel(
                    selected = themeMode == 2,
                    onClick = { onThemeModeChange(2) },
                    label = "Follow System",
                )
            }
        }
    }
}

@Composable
fun RadioButtonWithLabel(
    selected: Boolean,
    onClick: () -> Unit,
    label: String,
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.fillMaxWidth(),
    ) {
        RadioButton(
            selected = selected,
            onClick = onClick,
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(label, style = MaterialTheme.typography.bodyMedium)
    }
}
