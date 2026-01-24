package com.upence.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Restore
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.upence.data.*
import com.upence.util.createDefaultCategories
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ResetDefaultsCard(
    categoryDao: CategoriesDao,
    bankAccountsDao: BankAccountsDao,
    scope: kotlinx.coroutines.CoroutineScope,
) {
    var showConfirmDialog by remember { mutableStateOf(false) }

    Card(
        colors =
            CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.errorContainer,
            ),
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(bottom = 12.dp),
            ) {
                Icon(Icons.Default.Restore, contentDescription = null, modifier = Modifier.size(24.dp))
                Spacer(modifier = Modifier.width(12.dp))
                Text("Reset to Defaults", style = MaterialTheme.typography.titleMedium)
            }

            Text(
                "Restores default categories and accounts. This will remove all custom categories and accounts, clear their transaction references.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onErrorContainer,
            )

            Spacer(modifier = Modifier.height(12.dp))

            OutlinedButton(
                onClick = { showConfirmDialog = true },
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.outlinedButtonColors(
                        contentColor = MaterialTheme.colorScheme.onErrorContainer,
                    ),
            ) {
                Text("Reset to Defaults")
            }
        }
    }

    if (showConfirmDialog) {
        AlertDialog(
            onDismissRequest = { showConfirmDialog = false },
            title = { Text("Reset to Defaults") },
            text = {
                Text("This will delete all custom categories and accounts. Their transaction references will be cleared. Are you sure?")
            },
            confirmButton = {
                Button(onClick = {
                    scope.launch {
                        withContext(Dispatchers.IO) {
                            val categories = categoryDao.getAllCategories().first()
                            categories.forEach { category ->
                                categoryDao.deleteCategory(category)
                            }
                            createDefaultCategories(categoryDao)

                            val accounts = bankAccountsDao.getAllAccounts().first()
                            accounts.forEach { account ->
                                bankAccountsDao.deleteBankAccount(account)
                            }
                        }
                        showConfirmDialog = false
                    }
                }) {
                    Text("Reset")
                }
            },
            dismissButton = {
                TextButton(onClick = { showConfirmDialog = false }) {
                    Text("Cancel")
                }
            },
        )
    }
}
