package com.upence.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun MigrationDialog(
    onDismiss: () -> Unit,
    onConfirm: (migrateTo: Any?) -> Unit,
    title: String,
    message: String,
    options: List<Any>,
    getOptionLabel: (Any) -> String,
) {
    var selectedOption by remember { mutableStateOf(if (options.isNotEmpty()) options[0] else null) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = {
            Column {
                Text(message)
                Spacer(modifier = Modifier.height(16.dp))
                Text("Select where to migrate transactions:", style = MaterialTheme.typography.bodyMedium)
                Spacer(modifier = Modifier.height(8.dp))
                options.forEach { option ->
                    Row(
                        verticalAlignment = androidx.compose.ui.Alignment.CenterVertically,
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        RadioButton(
                            selected = selectedOption == option,
                            onClick = { selectedOption = option },
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(getOptionLabel(option))
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))
                OutlinedButton(
                    onClick = {
                        onConfirm(null) // Migrate to null/uncategorized
                        onDismiss()
                    },
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text("Mark as Uncategorized")
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    selectedOption?.let { onConfirm(it) }
                    onDismiss()
                },
            ) {
                Text("Migrate")
            }
        },
        dismissButton = {
            OutlinedButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
    )
}
