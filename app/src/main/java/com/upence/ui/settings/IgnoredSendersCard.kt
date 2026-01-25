package com.upence.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Block
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@Composable
fun IgnoredSendersCard(
    ignoredSendersCount: Int,
    navController: NavController,
) {
    if (ignoredSendersCount > 0) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(bottom = 16.dp),
            ) {
                Icon(Icons.Default.Block, contentDescription = null, modifier = Modifier.size(24.dp))
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text("Ignored Senders", style = MaterialTheme.typography.titleMedium)
                    Text(
                        "$ignoredSendersCount sender(s) ignored",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }

            OutlinedButton(
                onClick = { navController.navigate("ignored_senders") },
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text("View & Manage Ignored Senders")
            }
        }
    }
}
