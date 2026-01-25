package com.upence.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Category
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Message
import androidx.compose.material.icons.filled.Receipt
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Wallet
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.upence.data.*
import java.text.NumberFormat
import java.time.LocalDateTime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomePage(
    transactionDao: TransactionDao,
    categoryDao: CategoriesDao,
    bankAccountsDao: BankAccountsDao,
    smsDao: SMSDao,
    navController: androidx.navigation.NavController,
) {
    var isSidebarOpen by remember { mutableStateOf(false) }
    val transactions by transactionDao.getAllTransactions().collectAsState(initial = emptyList())
    val categories by categoryDao.getAllCategories().collectAsState(initial = emptyList())
    val bankAccounts by bankAccountsDao.getAllAccounts().collectAsState(initial = emptyList())
    val smsList by smsDao.selectUnprocessedSMS().collectAsState(initial = emptyList())

    // Calculate financial metrics
    val (netBalance, monthlyIncome, monthlyExpense) =
        remember(transactions) {
            val endDate = LocalDateTime.now()
            val startDate = endDate.minusMonths(1)

            var totalIncome = 0.0
            var totalExpense = 0.0

            transactions.forEach { transaction ->
                if (transaction.timestamp.isAfter(startDate.atZone(java.time.ZoneId.systemDefault()).toInstant()) &&
                    transaction.timestamp.isBefore(endDate.atZone(java.time.ZoneId.systemDefault()).toInstant())
                ) {
                    when (transaction.transactionType) {
                        TransactionType.CREDIT -> totalIncome += transaction.amount
                        TransactionType.DEBIT -> totalExpense += transaction.amount
                    }
                }
            }

            Triple(totalIncome - totalExpense, totalIncome, totalExpense)
        }

    Box(modifier = Modifier.fillMaxSize()) {
        SlideInFromRightAnimation(
            key = "home",
        ) {
            Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Upence",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { isSidebarOpen = true }) {
                        Icon(Icons.Default.Menu, contentDescription = "Menu")
                    }
                },
                colors =
                    TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                        titleContentColor = MaterialTheme.colorScheme.onSurface,
                    ),
            )
        },
        floatingActionButton = {
            if (smsList.isNotEmpty()) {
                FloatingActionButton(
                    onClick = { navController.navigate("unprocessed_sms") },
                    containerColor = MaterialTheme.colorScheme.primary,
                ) {
                    Badge(
                        modifier =
                            Modifier
                                .offset(x = (-6).dp, y = 6.dp),
                    ) {
                        Text(smsList.size.toString(), fontSize = 10.sp)
                    }
                    Icon(
                        Icons.Default.Message,
                        contentDescription = "Unprocessed SMS",
                        modifier = Modifier.size(24.dp),
                    )
                }
            }
        },
    ) { innerPadding ->
        Column(
            modifier =
                Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .background(MaterialTheme.colorScheme.background),
        ) {
            // Financial Overview Card
            Box(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                        .clip(RoundedCornerShape(20.dp))
                        .background(
                            MaterialTheme.colorScheme.surface,
                            shape = RoundedCornerShape(20.dp),
                        )
                        .border(
                            1.dp,
                            MaterialTheme.colorScheme.outline.copy(alpha = 0.1f),
                            RoundedCornerShape(20.dp),
                        ),
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                ) {
                    // Balance section
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Text(
                            "Current Balance",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = NumberFormat.getCurrencyInstance().format(netBalance),
                            style = MaterialTheme.typography.displayMedium,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface,
                        )
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    // Income/Expense section
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        // Income Card
                        Box(
                            modifier =
                                Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(
                                        Color(0xFF06D6A0).copy(alpha = 0.1f),
                                        shape = RoundedCornerShape(12.dp),
                                    )
                                    .border(
                                        1.dp,
                                        Color(0xFF06D6A0).copy(alpha = 0.2f),
                                        RoundedCornerShape(12.dp),
                                    ),
                        ) {
                            Column(
                                modifier = Modifier.padding(16.dp),
                                horizontalAlignment = Alignment.CenterHorizontally,
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.ArrowUpward,
                                        contentDescription = "Income",
                                        tint = Color(0xFF06D6A0),
                                        modifier = Modifier.size(16.dp),
                                    )
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(
                                        "Income",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = Color(0xFF06D6A0),
                                    )
                                }
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = NumberFormat.getCurrencyInstance().format(monthlyIncome),
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface,
                                )
                            }
                        }

                        Spacer(modifier = Modifier.width(12.dp))

                        // Expense Card
                        Box(
                            modifier =
                                Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(
                                        Color(0xFFEF476F).copy(alpha = 0.1f),
                                        shape = RoundedCornerShape(12.dp),
                                    )
                                    .border(
                                        1.dp,
                                        Color(0xFFEF476F).copy(alpha = 0.2f),
                                        RoundedCornerShape(12.dp),
                                    ),
                        ) {
                            Column(
                                modifier = Modifier.padding(16.dp),
                                horizontalAlignment = Alignment.CenterHorizontally,
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.ArrowDownward,
                                        contentDescription = "Expense",
                                        tint = Color(0xFFEF476F),
                                        modifier = Modifier.size(16.dp),
                                    )
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(
                                        "Expense",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = Color(0xFFEF476F),
                                    )
                                }
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = NumberFormat.getCurrencyInstance().format(monthlyExpense),
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface,
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Accounts summary
                    if (bankAccounts.isNotEmpty()) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Icon(
                                    Icons.Default.Wallet,
                                    contentDescription = "Accounts",
                                    modifier = Modifier.size(16.dp),
                                    tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    "Accounts",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                                )
                            }
                            Text(
                                "${bankAccounts.size} account${if (bankAccounts.size != 1) "s" else ""}",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                            )
                        }
                    }

                    // Categories summary
                    if (categories.isNotEmpty()) {
                        Spacer(modifier = Modifier.height(12.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Icon(
                                    Icons.Default.Category,
                                    contentDescription = "Categories",
                                    modifier = Modifier.size(16.dp),
                                    tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    "Categories",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                                )
                            }
                            Text(
                                "${categories.size} categor${if (categories.size != 1) "ies" else "y"}",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                            )
                        }
                    }
                }
            }

            // Recent Transactions Header
            Row(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .padding(top = 8.dp, bottom = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    "Recent Transactions",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface,
                )

                Text(
                    "${transactions.size} total",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                )
            }

            // Transactions List
            LazyColumn(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(1.dp),
            ) {
                if (transactions.isEmpty()) {
                    item {
                        Box(
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .padding(32.dp),
                            contentAlignment = Alignment.Center,
                        ) {
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally,
                            ) {
                                Icon(
                                    Icons.Default.Receipt,
                                    contentDescription = "No transactions",
                                    modifier = Modifier.size(48.dp),
                                    tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.3f),
                                )
                                Spacer(modifier = Modifier.height(16.dp))
                                Text(
                                    "No transactions yet",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    "SMS transactions will appear here",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f),
                                )
                            }
                        }
                    }
                } else {
                    items(transactions.take(20)) { transaction ->
                        TransactionListItem(transaction = transaction)
                    }
                }
            }
            }
            }
        }

        NavigationSidebar(
            isOpen = isSidebarOpen,
            onClose = { isSidebarOpen = false },
            currentRoute = "home",
            navController = navController,
        )
    }
}

@Composable
fun TransactionListItem(transaction: Transaction) {
    Card(
        modifier =
            Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .padding(vertical = 4.dp),
        shape = RoundedCornerShape(12.dp),
        colors =
            CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.onSurface,
            ),
    ) {
        Row(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Left side: Icon and details
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.weight(1f),
            ) {
                // Type indicator
                Box(
                    modifier =
                        Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(
                                when (transaction.transactionType) {
                                    TransactionType.CREDIT -> Color(0xFF06D6A0).copy(alpha = 0.1f)
                                    TransactionType.DEBIT -> Color(0xFFEF476F).copy(alpha = 0.1f)
                                },
                                shape = CircleShape,
                            ),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        imageVector =
                            when (transaction.transactionType) {
                                TransactionType.CREDIT -> Icons.Default.ArrowUpward
                                TransactionType.DEBIT -> Icons.Default.ArrowDownward
                            },
                        contentDescription = null,
                        tint =
                            when (transaction.transactionType) {
                                TransactionType.CREDIT -> Color(0xFF06D6A0)
                                TransactionType.DEBIT -> Color(0xFFEF476F)
                            },
                        modifier = Modifier.size(20.dp),
                    )
                }

                Spacer(modifier = Modifier.width(12.dp))

                // Transaction details
                Column(
                    modifier = Modifier.weight(1f),
                ) {
                    Text(
                        text = transaction.counterParty,
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Medium,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        if (transaction.referenceNumber.isNotBlank()) {
                            Text(
                                text = transaction.referenceNumber.take(8),
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                    }
                }
            }

            // Right side: Amount
            Text(
                text = "${if (transaction.transactionType == TransactionType.DEBIT) "-" else ""}₹${String.format(
                    "%.2f",
                    transaction.amount,
                )}",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color =
                    when (transaction.transactionType) {
                        TransactionType.CREDIT -> Color(0xFF06D6A0)
                        TransactionType.DEBIT -> Color(0xFFEF476F)
                    },
            )
        }

        // Description (if exists)
        if (transaction.description.isNotBlank()) {
            Divider(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .height(1.dp),
                color = MaterialTheme.colorScheme.outline.copy(alpha = 0.1f),
            )

            Text(
                text = transaction.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                modifier = Modifier.padding(horizontal = 16.dp).padding(bottom = 12.dp, top = 8.dp),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}
