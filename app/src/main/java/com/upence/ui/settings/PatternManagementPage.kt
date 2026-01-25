package com.upence.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.upence.data.SMSParsingPattern
import com.upence.data.TransactionType
import com.upence.ui.components.ConfirmDeleteDialog
import com.upence.ui.extractUsingPattern
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PatternManagementPage(
    smsParsingPatternDao: com.upence.data.SMSParsingPatternDao,
    navController: NavController,
) {
    val scope = rememberCoroutineScope()
    val patterns by smsParsingPatternDao.getAllPatterns().collectAsState(initial = emptyList())

    var showDeleteDialog by remember { mutableStateOf<SMSParsingPattern?>(null) }

    if (showDeleteDialog != null) {
        val patternToDelete = showDeleteDialog!!
        ConfirmDeleteDialog(
            onDismiss = { showDeleteDialog = null },
            onConfirm = {
                scope.launch {
                    smsParsingPatternDao.deletePattern(patternToDelete.id)
                    showDeleteDialog = null
                }
            },
            itemText = "Pattern",
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Manage Patterns") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
    ) { paddingValues ->
        if (patterns.isEmpty()) {
            Box(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                contentAlignment = Alignment.Center,
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "No patterns yet",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "Patterns will be created when you process SMS messages",
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
                verticalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                items(patterns) { pattern ->
                    PatternListItem(
                        pattern = pattern,
                        onDelete = { showDeleteDialog = pattern },
                        onToggleActive = { isActive ->
                            scope.launch {
                                smsParsingPatternDao.setPatternActive(pattern.id, isActive)
                            }
                        },
                    )
                }
            }
        }
    }
}

@Composable
fun PatternListItem(
    pattern: SMSParsingPattern,
    onDelete: () -> Unit,
    onToggleActive: (Boolean) -> Unit,
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        pattern.patternName,
                        style = MaterialTheme.typography.titleMedium,
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        TransactionTypeBadge(pattern.transactionType)
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        "From: ${pattern.senderName.ifEmpty { pattern.senderIdentifier }}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                    )
                }
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        "Active",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Switch(
                        checked = pattern.isActive,
                        onCheckedChange = { onToggleActive(it) },
                    )
                }
            }

            if (pattern.sampleSMS.isNotEmpty()) {
                Text(
                    "Sample SMS:",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                )
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors =
                        CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.surfaceVariant,
                        ),
                    shape = RoundedCornerShape(8.dp),
                ) {
                    Text(
                        pattern.sampleSMS,
                        modifier = Modifier.padding(12.dp),
                        style = MaterialTheme.typography.bodySmall,
                        fontFamily = FontFamily.Monospace,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }

                Text(
                    "Auto Retrieved Data:",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                )

                val extractedData = extractUsingPattern(pattern.sampleSMS, pattern)
                val dataText = buildString {
                    if (extractedData.containsKey("amount")) {
                        append("Amount: ${extractedData["amount"]}\n")
                    }
                    if (extractedData.containsKey("counterparty")) {
                        append("Counterparty: ${extractedData["counterparty"]}\n")
                    }
                    if (extractedData.containsKey("reference")) {
                        append("Reference: ${extractedData["reference"]}")
                    }
                }

                if (dataText.isNotBlank()) {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors =
                            CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.surfaceVariant,
                            ),
                        shape = RoundedCornerShape(8.dp),
                    ) {
                        Text(
                            dataText.trim(),
                            modifier = Modifier.padding(12.dp),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End,
            ) {
                TextButton(onClick = onDelete) {
                    Icon(Icons.Default.Delete, contentDescription = null, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Delete Pattern")
                }
            }
        }
    }
}

@Composable
fun TransactionTypeBadge(transactionType: TransactionType) {
    Box(
        modifier =
            Modifier
                .clip(RoundedCornerShape(4.dp))
                .background(
                    when (transactionType) {
                        TransactionType.CREDIT -> Color(0xFF06D6A0).copy(alpha = 0.2f)
                        TransactionType.DEBIT -> Color(0xFFEF476F).copy(alpha = 0.2f)
                    },
                )
                .border(
                    1.dp,
                    when (transactionType) {
                        TransactionType.CREDIT -> Color(0xFF06D6A0).copy(alpha = 0.5f)
                        TransactionType.DEBIT -> Color(0xFFEF476F).copy(alpha = 0.5f)
                    },
                    RoundedCornerShape(4.dp),
                )
                .padding(horizontal = 8.dp, vertical = 4.dp),
    ) {
        Text(
            transactionType.name,
            style = MaterialTheme.typography.labelSmall,
            color =
                when (transactionType) {
                    TransactionType.CREDIT -> Color(0xFF06D6A0)
                    TransactionType.DEBIT -> Color(0xFFEF476F)
                },
        )
    }
}
