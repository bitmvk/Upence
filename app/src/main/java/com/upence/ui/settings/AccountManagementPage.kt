package com.upence.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AccountBalance
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.upence.data.*
import com.upence.ui.components.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AccountManagementPage(
    bankAccountsDao: BankAccountsDao,
    transactionDao: TransactionDao,
    navController: NavController,
) {
    val scope = rememberCoroutineScope()
    val accounts by bankAccountsDao.getAllAccounts().collectAsState(initial = emptyList())

    var showAddDialog by remember { mutableStateOf(false) }
    var showDeleteDialog by remember { mutableStateOf<BankAccounts?>(null) }
    var showMigrationDialog by remember { mutableStateOf<BankAccounts?>(null) }
    var showSimpleConfirmDialog by remember { mutableStateOf<BankAccounts?>(null) }

    if (showAddDialog) {
        AddEditAccountDialog(
            account = null,
            onDismiss = { showAddDialog = false },
            onSave = { accountName, accountNumber, description ->
                scope.launch {
                    withContext(Dispatchers.IO) {
                        bankAccountsDao.insertBankAccount(
                            BankAccounts(
                                id = System.currentTimeMillis().toInt(),
                                accountName = accountName,
                                accountNumber = accountNumber,
                                description = description,
                            ),
                        )
                    }
                    showAddDialog = false
                }
            },
        )
    }

    if (showDeleteDialog != null) {
        showMigrationDialog = showDeleteDialog
        showDeleteDialog = null
    }

    if (showMigrationDialog != null) {
        val accountToDelete = showMigrationDialog!!
        MigrationDialog(
            onDismiss = { showMigrationDialog = null },
            onConfirm = { migrateTo ->
                scope.launch {
                    withContext(Dispatchers.IO) {
                        if (migrateTo == null) {
                            // Set to empty string (no account)
                            bankAccountsDao.migrateAccountTransactions(
                                accountToDelete.id.toString(),
                                "",
                            )
                        } else if (migrateTo is BankAccounts) {
                            bankAccountsDao.migrateAccountTransactions(
                                accountToDelete.id.toString(),
                                migrateTo.id.toString(),
                            )
                        }
                        bankAccountsDao.deleteBankAccount(accountToDelete)
                    }
                    showMigrationDialog = null
                }
            },
            title = "Move transactions from ${accountToDelete.accountName}",
            message = "This account has transactions. Please select another account to move them to:",
            options = accounts.filter { it.id != accountToDelete.id },
            getOptionLabel = { (it as BankAccounts).accountName },
        )
    }

    if (showSimpleConfirmDialog != null) {
        val account = showSimpleConfirmDialog!!
        ConfirmDeleteDialog(
            onDismiss = { showSimpleConfirmDialog = null },
            onConfirm = {
                scope.launch {
                    bankAccountsDao.deleteBankAccount(account)
                    showSimpleConfirmDialog = null
                }
            },
            itemText = "Account",
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Manage Bank Accounts") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { showAddDialog = true }) {
                Icon(Icons.Default.Add, contentDescription = "Add Account")
            }
        },
    ) { paddingValues ->
        if (accounts.isEmpty()) {
            Box(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                contentAlignment = Alignment.Center,
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "No accounts yet",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "Tap the + button to add your first account",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        } else {
            LazyColumn(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(paddingValues)
                        .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                items(accounts) { account ->
                    AccountItem(
                        account = account,
                        onEdit = {
                            // For simplicity, we'll only handle delete in this version
                        },
                        onDelete = {
                            scope.launch {
                                val count = bankAccountsDao.getTransactionCount(account.id.toString())
                                if (count > 0) {
                                    showMigrationDialog = account
                                } else {
                                    showSimpleConfirmDialog = account
                                }
                            }
                        },
                    )
                }
            }
        }
    }
}

@Composable
fun AccountItem(
    account: BankAccounts,
    onEdit: () -> Unit,
    onDelete: () -> Unit,
) {
    var showMenu by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
    ) {
        Row(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                Icons.Default.AccountBalance,
                contentDescription = null,
                modifier = Modifier.size(48.dp),
                tint = MaterialTheme.colorScheme.primary,
            )

            Spacer(modifier = Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    account.accountName,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Medium,
                )
                if (account.accountNumber.isNotBlank()) {
                    Text(
                        "Account: ****${account.accountNumber.takeLast(4)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                if (account.description.isNotBlank()) {
                    Text(
                        account.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }

            MenuButton(
                showMenu = showMenu,
                onDismiss = { showMenu = false },
                onEdit = onEdit,
                onDelete = onDelete,
            )
        }
    }
}

@Composable
fun AddEditAccountDialog(
    account: BankAccounts?,
    onDismiss: () -> Unit,
    onSave: (String, String, String) -> Unit,
) {
    var accountName by remember { mutableStateOf(account?.accountName ?: "") }
    var accountNumber by remember { mutableStateOf(account?.accountNumber ?: "") }
    var description by remember { mutableStateOf(account?.description ?: "") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (account == null) "Add Account" else "Edit Account") },
        text = {
            Column(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                OutlinedTextField(
                    value = accountName,
                    onValueChange = { accountName = it },
                    label = { Text("Account Name (required)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )

                OutlinedTextField(
                    value = accountNumber,
                    onValueChange = { accountNumber = it },
                    label = { Text("Account Number (optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    keyboardOptions =
                        androidx.compose.foundation.text.KeyboardOptions(
                            keyboardType = androidx.compose.ui.text.input.KeyboardType.Number,
                        ),
                )

                OutlinedTextField(
                    value = description,
                    onValueChange = { description = it },
                    label = { Text("Description (optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )
            }
        },
        confirmButton = {
            Button(
                onClick = { onSave(accountName, accountNumber, description) },
                enabled = accountName.isNotBlank(),
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            OutlinedButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
    )
}
