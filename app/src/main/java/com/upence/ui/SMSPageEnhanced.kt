package com.upence.ui

import androidx.compose.foundation.*
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.CompareArrows
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.CreditCard
import androidx.compose.material.icons.filled.CurrencyRupee
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.Money
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.upence.data.*
import com.upence.util.IconUtils.getIconByName
import com.upence.util.SMSUtils
import com.upence.util.SenderParser
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.Instant
import java.time.format.DateTimeFormatter
import java.util.Locale

// Enhanced FieldType with better UX
enum class FieldType(val displayName: String, val iconName: String, val colorValue: Long) {
    AMOUNT("Amount", "CurrencyRupee", 0xFF4361EE),
    COUNTERPARTY("Counterparty", "Person", 0xFF06D6A0),
    REFERENCE("Reference", "Receipt", 0xFFEF476F),
    ;

    val buttonDisplayName: String
        get() =
            when (this) {
                COUNTERPARTY -> "Counter Party"
                else -> displayName
            }

    @Composable
    fun color(): Color = Color(colorValue)
}

// New data model for text range selection
data class TextRangeSelection(
    val start: Int,
    val end: Int,
    val fieldType: FieldType,
    val originalText: String,
) {
    fun cleanNumericValue(): String {
        return if (fieldType == FieldType.AMOUNT || fieldType == FieldType.REFERENCE) {
            extractNumbersOnly(originalText)
        } else {
            originalText
        }
    }

    private fun extractNumbersOnly(text: String): String {
        return text.replace(Regex("[^\\d]"), "")
    }
}

// Data class to track word analysis (legacy, will be phased out)
data class WordAnalysis(
    val word: String,
    val originalIndex: Int,
    val isNumeric: Boolean = false,
    val numericValue: String = "",
    val fieldType: FieldType? = null,
    val isSelected: Boolean = false,
) {
    val displayText: String
        get() = word
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SMSPageEnhanced(
    smsId: Long,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
    smsDao: SMSDao,
    smsParsingPatternDao: SMSParsingPatternDao,
    transactionDao: TransactionDao,
    categoryDao: com.upence.data.CategoriesDao,
    bankAccountsDao: com.upence.data.BankAccountsDao,
    tagsDao: com.upence.data.TagsDao,
    senderDao: com.upence.data.SenderDao,
    userStore: com.upence.data.UserStore,
    scope: CoroutineScope,
    navController: androidx.navigation.NavController,
) {
    val sms by smsDao.selectSMSById(smsId).collectAsState(initial = null)
    val categories by categoryDao.getAllCategories().collectAsState(initial = emptyList())
    val bankAccounts by bankAccountsDao.getAllAccounts().collectAsState(initial = emptyList())
    val tags by tagsDao.getAllTags().collectAsState(initial = emptyList())
    val existingPatterns by remember { mutableStateOf(emptyList<SMSParsingPattern>()) }

    // New text selection system state
    var textSelections by remember { mutableStateOf<List<TextRangeSelection>>(emptyList()) }
    var expertMode by remember { mutableStateOf(false) }

    // Enhanced state management
    var wordAnalysis by remember { mutableStateOf<List<WordAnalysis>>(emptyList()) }
    var selectedFieldType by remember { mutableStateOf<FieldType?>(null) }
    var isLoading by remember { mutableStateOf(false) }

    // Transaction state - save IDs instead of objects
    var amount by rememberSaveable { mutableStateOf("") }
    var counterparty by rememberSaveable { mutableStateOf("") }
    var reference by rememberSaveable { mutableStateOf("") }
    var transactionType by rememberSaveable { mutableStateOf(TransactionType.DEBIT) }
    var description by rememberSaveable { mutableStateOf("") }
    var selectedCategoryId by rememberSaveable { mutableStateOf<Int?>(null) }
    var selectedAccountId by rememberSaveable { mutableStateOf<Int?>(null) }
    var selectedTagIds by rememberSaveable { mutableStateOf<List<Int>>(emptyList()) }
    var showCategoryExpanded by rememberSaveable { mutableStateOf(false) }
    var showAccountExpanded by rememberSaveable { mutableStateOf(false) }

    // SMS body collapse state
    var showSMSBodyCollapsed by rememberSaveable { mutableStateOf(false) }

    // Derive actual objects from saved IDs and current lists
    val selectedCategory by remember(categories) {
        derivedStateOf { categories.find { it.id == selectedCategoryId } }
    }
    val selectedAccount by remember(bankAccounts) {
        derivedStateOf { bankAccounts.find { it.id == selectedAccountId } }
    }
    val selectedTags by remember(tags) {
        derivedStateOf { tags.filter { it.id in selectedTagIds } }
    }

    // Track if data was auto-retrieved from pattern
    var isDataAutoRetrieved by remember { mutableStateOf(false) }

    // Track if a pattern was found (to hide save pattern checkbox)
    var patternWasFound by remember { mutableStateOf(false) }

    // Save pattern checkbox state
    var savePattern by rememberSaveable { mutableStateOf(false) }

    // Auto-select account checkbox state
    var autoSelectAccount by rememberSaveable { mutableStateOf(false) }

    // Pattern selection state
    var currentPattern by remember { mutableStateOf<SMSParsingPattern?>(null) }
    var patternMatchScore by remember { mutableStateOf(0.0) }
    var availablePatterns by remember { mutableStateOf<List<SMSParsingPattern>>(emptyList()) }
    var showPatternSelector by remember { mutableStateOf(false) }

    // India sender ruleset setting
    val useIndiaRuleset by userStore.useIndiaSenderRuleset.collectAsState(initial = true)

    // Not a Transaction dialog state
    var showNotATransactionDialog by remember { mutableStateOf(false) }
    var applyToAllFutureSMS by remember { mutableStateOf(false) }

    // Initialize word analysis
    LaunchedEffect(sms) {
        if (sms != null) {
            isLoading = true
            val smsVal = sms!!

            // Analyze words for numeric content
            val words = smsVal.message.split(Regex("""\s+""")).filter { it.isNotBlank() }
            wordAnalysis =
                words.mapIndexed { index, word ->
                    val (isNumeric, numericValue) = extractNumericContent(word)
                    WordAnalysis(
                        word = word,
                        originalIndex = index,
                        isNumeric = isNumeric,
                        numericValue = numericValue,
                    )
                }

            // Check for existing patterns
            try {
                val patterns =
                    smsParsingPatternDao.findSimilarPatterns(
                        smsVal.sender,
                        SenderParser.extractSenderName(smsVal.sender),
                        useIndiaRuleset,
                    )
                availablePatterns = patterns

                android.util.Log.d("SMSPageEnhanced", "Found ${patterns.size} patterns for sender ${smsVal.sender}")
                patterns.forEach { pattern ->
                    android.util.Log.d("SMSPageEnhanced", "  Pattern: ${pattern.patternName}, amountPattern: '${pattern.amountPattern}', counterpartyPattern: '${pattern.counterpartyPattern}'")
                }

                if (patterns.isNotEmpty()) {
                    val bestMatch = SMSUtils.findBestMatchingPattern(patterns, smsVal.message)
                    if (bestMatch != null) {
                        android.util.Log.i("SMSPageEnhanced", "✅ Best pattern found: ${bestMatch.pattern.patternName} (score: ${"%.2f".format(bestMatch.matchScore * 100)}%, valid: ${bestMatch.isValid})")
                        val pattern = bestMatch.pattern
                        currentPattern = pattern
                        patternMatchScore = bestMatch.matchScore

                        applyPatternToAnalysis(pattern, smsVal.message, wordAnalysis)?.let { analysis ->
                            wordAnalysis = analysis

                            // Extract data from pattern
                            val extracted = extractUsingPattern(smsVal.message, pattern)
                            android.util.Log.d("SMSPageEnhanced", "Pattern '${pattern.patternName}' extraction:")
                            android.util.Log.d("SMSPageEnhanced", "  Amount positions: ${pattern.amountPattern}")
                            android.util.Log.d("SMSPageEnhanced", "  Counterparty positions: ${pattern.counterpartyPattern}")
                            android.util.Log.d("SMSPageEnhanced", "  Reference positions: ${pattern.referencePattern}")
                            android.util.Log.d("SMSPageEnhanced", "  Extracted amount: ${extracted["amount"]}")
                            android.util.Log.d("SMSPageEnhanced", "  Extracted counterparty: ${extracted["counterparty"]}")
                            android.util.Log.d("SMSPageEnhanced", "  Extracted reference: ${extracted["reference"]}")

                            amount = (extracted["amount"] ?: "").trim('.')
                            counterparty = extracted["counterparty"] ?: ""
                            reference = (extracted["reference"] ?: "").trim('.')
                            transactionType = pattern.transactionType

                            android.util.Log.i("SMSPageEnhanced", "📝 State values set:")
                            android.util.Log.i("SMSPageEnhanced", "  Amount: $amount")
                            android.util.Log.i("SMSPageEnhanced", "  Counterparty: $counterparty")
                            android.util.Log.i("SMSPageEnhanced", "  Reference: $reference")
                            android.util.Log.i("SMSPageEnhanced", "  Transaction type: $transactionType")

                            // Mark data as auto-retrieved and pattern found
                            isDataAutoRetrieved = true
                            patternWasFound = true

                            // Collapse SMS body by default when auto-retrieved
                            showSMSBodyCollapsed = true

                            // Pre-fill account from pattern defaults (only if autoSelectAccount is enabled)
                            if (pattern.defaultAccountID.isNotBlank() && pattern.autoSelectAccount) {
                                selectedAccountId = pattern.defaultAccountID.toIntOrNull()
                            }
                        }
                    } else {
                        android.util.Log.w("SMSPageEnhanced", "⚠️ No valid pattern found for message")
                    }
                } else {
                    android.util.Log.w("SMSPageEnhanced", "⚠️ No patterns available for this sender")
                }
            } catch (e: Exception) {
                android.util.Log.e("SMSPageEnhanced", "❌ Error during pattern matching: ${e.message}", e)
                // Continue without patterns
            }

            isLoading = false
        }
    }

    // Loading state
    if (isLoading) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        return
    }

    // SMS not found
    if (sms == null) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("SMS not found", style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.height(16.dp))
                Button(onClick = onBack) {
                    Text("Go Back")
                }
            }
        }
        return
    }

    val smsVal = sms!!

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Complete Transaction",
                        style = MaterialTheme.typography.titleMedium,
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors =
                    TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                        titleContentColor = MaterialTheme.colorScheme.onSurface,
                    ),
            )
        },
    ) { paddingValues ->
        Surface(
            modifier =
                modifier
                    .padding(paddingValues)
                    .fillMaxSize(),
            color = MaterialTheme.colorScheme.background,
        ) {
            UnifiedTransactionScreen(
                sms = smsVal,
                wordAnalysis = wordAnalysis,
                selectedFieldType = selectedFieldType,
                amount = amount,
                onAmountChange = { amount = it.trim('.') },
                counterparty = counterparty,
                onCounterpartyChange = { counterparty = it },
                reference = reference,
                onReferenceChange = { reference = it.trim('.') },
                transactionType = transactionType,
                onTransactionTypeChange = { transactionType = it },
                savePattern = savePattern,
                onSavePatternChange = { savePattern = it },
                autoSelectAccount = autoSelectAccount,
                onAutoSelectAccountChange = { autoSelectAccount = it },
                description = description,
                onDescriptionChange = { description = it },
                categories = categories,
                selectedCategory = selectedCategory,
                onCategorySelected = { selectedCategoryId = it.id },
                showCategoryExpanded = showCategoryExpanded,
                onCategoryExpandedChange = { showCategoryExpanded = it },
                bankAccounts = bankAccounts,
                selectedAccount = selectedAccount,
                onAccountSelected = { selectedAccountId = it.id },
                showAccountExpanded = showAccountExpanded,
                onAccountExpandedChange = { showAccountExpanded = it },
                tags = tags,
                selectedTags = selectedTags,
                onTagsSelected = { selectedTagIds = it.map { tag -> tag.id } },
                isDataAutoRetrieved = isDataAutoRetrieved,
                patternWasFound = patternWasFound,
                currentPattern = currentPattern,
                patternMatchScore = patternMatchScore,
                availablePatterns = availablePatterns,
                showPatternSelector = showPatternSelector,
                onPatternSelectorChange = { showPatternSelector = it },
                onPatternSelected = { pattern ->
                    currentPattern = pattern
                    patternMatchScore =
                        SMSUtils.calculateStructureMatchScore(
                            SMSUtils.buildMessageStructureFromMessage(smsVal.message),
                            pattern.messageStructure,
                        )
                    applyPatternToAnalysis(pattern, smsVal.message, wordAnalysis)?.let { analysis ->
                        wordAnalysis = analysis

                        val extracted = extractUsingPattern(smsVal.message, pattern)
                        amount = (extracted["amount"] ?: "").trim('.')
                        counterparty = extracted["counterparty"] ?: ""
                        reference = (extracted["reference"] ?: "").trim('.')
                        transactionType = pattern.transactionType

                        if (pattern.defaultAccountID.isNotBlank() && pattern.autoSelectAccount) {
                            selectedAccountId = pattern.defaultAccountID.toIntOrNull()
                        }
                    }
                },
                showSMSBodyCollapsed = showSMSBodyCollapsed,
                onSMSBodyCollapseChange = { showSMSBodyCollapsed = it },
                onFieldTypeSelected = { fieldType ->
                    selectedFieldType = if (selectedFieldType == fieldType) null else fieldType
                },
                onWordClicked = { index ->
                    selectedFieldType?.let { fieldType ->
                        val targetAnalysis = wordAnalysis[index]
                        
                        // Toggle the clicked word
                        val newIsSelected = !targetAnalysis.isSelected
                        
                        wordAnalysis = wordAnalysis.mapIndexed { i, analysis ->
                            when {
                                i == index -> {
                                    // For amount field, only allow selection of numeric tokens
                                    if (fieldType == FieldType.AMOUNT && !analysis.isNumeric) {
                                        return@mapIndexed analysis
                                    }
                                    // Toggle selection and set/clear fieldType
                                    if (newIsSelected) {
                                        analysis.copy(fieldType = fieldType, isSelected = true)
                                    } else {
                                        analysis.copy(fieldType = null, isSelected = false)
                                    }
                                }
                                // For amount field: if selecting, deselect other amount words (single value)
                                fieldType == FieldType.AMOUNT && analysis.fieldType == FieldType.AMOUNT && newIsSelected -> {
                                    analysis.copy(isSelected = false)
                                }
                                else -> analysis
                            }
                        }
                        
                        // Update extracted values based on selected words
                        val newAmount =
                            wordAnalysis
                                .filter { it.fieldType == FieldType.AMOUNT && it.isSelected }
                                .joinToString("") { it.numericValue }
                        if (newAmount.isNotBlank()) amount = newAmount.trim('.')

                        val newCounterparty =
                            wordAnalysis
                                .filter { it.fieldType == FieldType.COUNTERPARTY && it.isSelected }
                                .joinToString(" ") { it.word }
                        if (newCounterparty.isNotBlank()) counterparty = newCounterparty

                        val newReference =
                            wordAnalysis
                                .filter { it.fieldType == FieldType.REFERENCE && it.isSelected }
                                .joinToString(" ") { it.word }
                        if (newReference.isNotBlank()) reference = extractNumbersOnly(newReference).trim('.')
                    }
                },
                onClearSelection = {
                    wordAnalysis = wordAnalysis.map { analysis ->
                        if (analysis.fieldType == selectedFieldType) {
                            analysis.copy(fieldType = null, isSelected = false)
                        } else {
                            analysis
                        }
                    }
                    amount = ""
                    counterparty = ""
                    reference = ""
                },
                onCancel = onBack,
                onNotATransactionClick = { showNotATransactionDialog = true },
                onNotATransactionLongPress = {
                    scope.launch {
                        withContext(Dispatchers.IO) {
                            smsDao.deleteSMS(smsId)
                        }
                        onBack()
                    }
                },
                onCreateTransaction = {
                    // Validate based on whether data was auto-retrieved
                    val isValid =
                        if (isDataAutoRetrieved) {
                            validateTransaction(amount, counterparty, selectedCategory, selectedAccount)
                        } else {
                            // For manually filled data, only category and account are required
                            selectedCategory != null && selectedAccount != null
                        }

                    if (isValid) {
                        // Save pattern if requested
                        if (savePattern) {
                            val pattern =
                                createPatternFromAnalysis(
                                    smsVal.sender,
                                    smsVal.message,
                                    wordAnalysis,
                                    transactionType,
                                )

                            // Validate pattern has required fields before saving
                            if (pattern.amountPattern.isNotEmpty() && pattern.counterpartyPattern.isNotEmpty()) {
                                scope.launch {
                                    withContext(Dispatchers.IO) {
                                        val patternId = smsParsingPatternDao.insertPattern(pattern).toInt()
                                        // Update pattern with defaults
                                        smsParsingPatternDao.updateDefaults(
                                            patternId,
                                            selectedCategory?.id?.toString() ?: "",
                                            selectedAccount?.id?.toString() ?: "",
                                            autoSelectAccount,
                                            SenderParser.extractSenderName(smsVal.sender),
                                        )
                                    }
                                }
                            } else {
                                android.util.Log.w("SMSPageEnhanced", "Skipping pattern save - missing required fields (amount=${pattern.amountPattern.isNotEmpty()}, counterparty=${pattern.counterpartyPattern.isNotEmpty()})")
                            }
                        }

                        // Create transaction
                        val transaction =
                            Transaction(
                                counterParty = counterparty,
                                amount = if (amount.isNotBlank()) amount.toDoubleOrNull() ?: 0.0 else 0.0,
                                timestamp = Instant.now(),
                                categoryID = selectedCategory?.id?.toString() ?: "",
                                description = description,
                                accountID = selectedAccount?.id?.toString() ?: "",
                                transactionType = transactionType,
                                referenceNumber = reference,
                            )

                        scope.launch {
                            withContext(Dispatchers.IO) {
                                transactionDao.insertTransaction(transaction)
                            }
                            onBack()
                        }
                    }
                },
                navController = navController,
            )

            // Not a Transaction Dialog
            if (showNotATransactionDialog) {
                NotATransactionDialog(
                    sender = smsVal.sender,
                    applyToAllFutureSMS = applyToAllFutureSMS,
                    onApplyToAllChange = { applyToAllFutureSMS = it },
                    onDismiss = { showNotATransactionDialog = false },
                    onConfirm = {
                        scope.launch {
                            withContext(Dispatchers.IO) {
                                if (applyToAllFutureSMS) {
                                    senderDao.markSenderAsIgnored(
                                        senderName = smsVal.sender,
                                        reason = "Not a transaction",
                                    )
                                }
                                smsDao.deleteSMS(smsId)
                            }
                            onBack()
                        }
                    },
                )
            }
        }
    }
}

@Composable
fun NotATransactionDialog(
    sender: String,
    applyToAllFutureSMS: Boolean,
    onApplyToAllChange: (Boolean) -> Unit,
    onDismiss: () -> Unit,
    onConfirm: () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text("Mark as Not a Transaction")
        },
        text = {
            Column {
                Text(
                    "Do you want to mark this SMS from '$sender' as not a transaction?",
                    style = MaterialTheme.typography.bodyMedium,
                )
                Spacer(modifier = Modifier.height(16.dp))
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Checkbox(
                        checked = applyToAllFutureSMS,
                        onCheckedChange = onApplyToAllChange,
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Apply for all future SMS from this sender",
                        style = MaterialTheme.typography.bodyMedium,
                    )
                }
            }
        },
        confirmButton = {
            Button(onClick = onConfirm) {
                Text("Confirm")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
    )
}

// TODO: Merge FirstScreenContent and SecondScreenContent into single UnifiedTransactionScreen
// - Show SMS body section (collapsible) at top
// - Show transaction details section (only when isDataAutoRetrieved == true)
// - Always show account, category, tags, and description sections
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UnifiedTransactionScreen(
    sms: SMS,
    wordAnalysis: List<WordAnalysis>,
    selectedFieldType: FieldType?,
    amount: String,
    onAmountChange: (String) -> Unit,
    counterparty: String,
    onCounterpartyChange: (String) -> Unit,
    reference: String,
    onReferenceChange: (String) -> Unit,
    transactionType: TransactionType,
    onTransactionTypeChange: (TransactionType) -> Unit,
    savePattern: Boolean,
    onSavePatternChange: (Boolean) -> Unit,
    autoSelectAccount: Boolean,
    onAutoSelectAccountChange: (Boolean) -> Unit,
    description: String,
    onDescriptionChange: (String) -> Unit,
    categories: List<Categories>,
    selectedCategory: Categories?,
    onCategorySelected: (Categories) -> Unit,
    showCategoryExpanded: Boolean,
    onCategoryExpandedChange: (Boolean) -> Unit,
    bankAccounts: List<BankAccounts>,
    selectedAccount: BankAccounts?,
    onAccountSelected: (BankAccounts) -> Unit,
    showAccountExpanded: Boolean,
    onAccountExpandedChange: (Boolean) -> Unit,
    tags: List<Tags>,
    selectedTags: List<Tags>,
    onTagsSelected: (List<Tags>) -> Unit,
    isDataAutoRetrieved: Boolean,
    patternWasFound: Boolean,
    currentPattern: SMSParsingPattern?,
    patternMatchScore: Double,
    availablePatterns: List<SMSParsingPattern>,
    showPatternSelector: Boolean,
    onPatternSelectorChange: (Boolean) -> Unit,
    onPatternSelected: (SMSParsingPattern) -> Unit,
    showSMSBodyCollapsed: Boolean,
    onSMSBodyCollapseChange: (Boolean) -> Unit,
    onFieldTypeSelected: (FieldType) -> Unit,
    onWordClicked: (Int) -> Unit,
    onClearSelection: () -> Unit,
    onCancel: () -> Unit,
    onNotATransactionClick: () -> Unit,
    onNotATransactionLongPress: () -> Unit,
    onCreateTransaction: () -> Unit,
    navController: androidx.navigation.NavController,
) {
    // TODO: Create UnifiedTransactionScreen composable that:
    // - Takes all parameters from both FirstScreenContent and SecondScreenContent
    // - Shows collapsible SMS body with word chips (when !showSMSBodyCollapsed)
    // - Shows transaction details (when isDataAutoRetrieved)
    // - Shows account/category/tags/dropdowns always
    // - Conditionally shows "Save pattern" checkbox based on !patternWasFound
    // - Validates and saves transaction

    // TODO: Implement collapsible SMS body section
    // - When isDataAutoRetrieved == true, show collapsed by default
    // - When isDataAutoRetrieved == false, show expanded by default
    // - Add clickable header to toggle collapse state

    LazyColumn(
        modifier =
            Modifier
                .fillMaxSize()
                .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        // SMS Body Section (Collapsible)
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                    ),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    // Collapsible Header
                    Row(
                        modifier =
                            Modifier
                                .fillMaxWidth()
                                .clickable { onSMSBodyCollapseChange(!showSMSBodyCollapsed) }
                                .padding(vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = if (showSMSBodyCollapsed) Icons.Filled.ExpandMore else Icons.Filled.KeyboardArrowUp,
                                contentDescription = if (showSMSBodyCollapsed) "Expand" else "Collapse",
                                tint = MaterialTheme.colorScheme.primary,
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "SMS Body",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold,
                            )
                            if (isDataAutoRetrieved) {
                                Spacer(modifier = Modifier.width(8.dp))
                                Surface(
                                    color = MaterialTheme.colorScheme.primaryContainer,
                                    shape = MaterialTheme.shapes.small,
                                ) {
                                    Text(
                                        text = "Auto-filled",
                                        style = MaterialTheme.typography.labelSmall,
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                                        color = MaterialTheme.colorScheme.onPrimaryContainer,
                                    )
                                }
                            }
                        }
                        Text(
                            text =
                                java.time.Instant.ofEpochMilli(sms.timestamp)
                                    .atZone(java.time.ZoneId.systemDefault())
                                    .format(DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm")),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    // SMS Sender and Message (Always show sender)
                    Text(
                        text = "From: ${sms.sender}",
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(modifier = Modifier.height(4.dp))

                    // SMS Message (collapsible)
                    if (!showSMSBodyCollapsed) {
                        SelectionContainer {
                            Text(
                                text = sms.message,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurface,
                            )
                        }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Pattern Match Display & Selector
                    if (patternWasFound && currentPattern != null) {
                        Column(modifier = Modifier.fillMaxWidth()) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = "Pattern: ${currentPattern.patternName}",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    )
                                    Text(
                                        text = "Match: ${(patternMatchScore * 100).toInt()}%",
                                        style = MaterialTheme.typography.labelSmall,
                                        color = MaterialTheme.colorScheme.primary,
                                    )
                                }
                                if (availablePatterns.size > 1) {
                                    TextButton(onClick = { onPatternSelectorChange(!showPatternSelector) }) {
                                        Text(if (showPatternSelector) "Hide" else "Change Pattern")
                                    }
                                }
                            }

                            if (showPatternSelector && availablePatterns.size > 1) {
                                Spacer(modifier = Modifier.height(8.dp))
                                availablePatterns.forEach { pattern ->
                                    val matchScore =
                                        SMSUtils.calculateStructureMatchScore(
                                            SMSUtils.buildMessageStructureFromMessage(sms.message),
                                            pattern.messageStructure,
                                        )
                                    val isSelected = currentPattern?.id == pattern.id

                                    Card(
                                        modifier =
                                            Modifier
                                                .fillMaxWidth()
                                                .clickable {
                                                    onPatternSelected(pattern)
                                                    onPatternSelectorChange(false)
                                                },
                                        colors =
                                            CardDefaults.cardColors(
                                                containerColor =
                                                    if (isSelected) {
                                                        MaterialTheme.colorScheme.primaryContainer
                                                    } else {
                                                        MaterialTheme.colorScheme.surfaceVariant
                                                    },
                                            ),
                                        border =
                                            if (isSelected) {
                                                BorderStroke(1.dp, MaterialTheme.colorScheme.primary)
                                            } else {
                                                null
                                            },
                                    ) {
                                        Column(modifier = Modifier.padding(12.dp)) {
                                            Row(
                                                modifier = Modifier.fillMaxWidth(),
                                                horizontalArrangement = Arrangement.SpaceBetween,
                                                verticalAlignment = Alignment.CenterVertically,
                                            ) {
                                                Text(
                                                    text = pattern.patternName,
                                                    style = MaterialTheme.typography.bodyMedium,
                                                    fontWeight =
                                                        if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                                )
                                                Text(
                                                    text = "${(matchScore * 100).toInt()}% match",
                                                    style = MaterialTheme.typography.labelSmall,
                                                    color = MaterialTheme.colorScheme.primary,
                                                )
                                            }
                                            Text(
                                                text =
                                                    "Type: ${pattern.transactionType.name} | " +
                                                        "Last used: ${pattern.lastUsedTimestamp?.let { 
                                                            val date = Instant.ofEpochMilli(it).atZone(java.time.ZoneId.systemDefault()).toLocalDateTime()
                                                            date.format(DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.US))
                                                        } ?: "Never"}",
                                                style = MaterialTheme.typography.labelSmall,
                                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                            )
                                        }
                                    }
                                    Spacer(modifier = Modifier.height(4.dp))
                                }
                            }
                        }
                        Spacer(modifier = Modifier.height(12.dp))
                    }

                        // Field Type Chips
                        FlowRow(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            FieldType.entries.forEach { fieldType ->
                                EnhancedFieldTypeChip(
                                    fieldType = fieldType,
                                    isSelected = selectedFieldType == fieldType,
                                    onClick = { onFieldTypeSelected(fieldType) },
                                )
                            }
                        }

                        if (selectedFieldType != null) {
                            Spacer(modifier = Modifier.height(12.dp))
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Text(
                                    text = "Click words to mark as ${selectedFieldType.displayName}",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                                val selectedCount = wordAnalysis.count { it.fieldType == selectedFieldType && it.isSelected }
                                if (selectedCount > 0) {
                                    TextButton(
                                        onClick = onClearSelection,
                                        contentPadding = PaddingValues(horizontal = 8.dp, vertical = 4.dp),
                                    ) {
                                        Text(
                                            "Clear ($selectedCount)",
                                            style = MaterialTheme.typography.bodySmall,
                                        )
                                    }
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        // Word Chips
                        FlowRow(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            wordAnalysis.forEachIndexed { index, analysis ->
                                EnhancedWordChip(
                                    analysis = analysis,
                                    targetFieldType = selectedFieldType,
                                    onClick = { onWordClicked(index) },
                                )
                            }
                        }
                    } else {
                        // Collapsed view - show snippet
                        Text(
                            text =
                                if (sms.message.length > 50) {
                                    sms.message.take(50) + "..."
                                } else {
                                    sms.message
                                },
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }
            }
        }

        // Transaction Details Section (Always visible)
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                    ),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    // Transaction Type
                    Text(
                        text = "Transaction Type",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                    ) {
                        TransactionType.entries.forEach { type ->
                            FilterChip(
                                selected = transactionType == type,
                                onClick = { onTransactionTypeChange(type) },
                                label = { Text(type.name) },
                                leadingIcon = {
                                    Icon(
                                        imageVector = if (type == TransactionType.CREDIT) Icons.Filled.Money else Icons.Filled.CreditCard,
                                        contentDescription = type.name,
                                    )
                                },
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Amount Field
                    OutlinedTextField(
                        value = amount,
                        onValueChange = onAmountChange,
                        label = { Text("Amount") },
                        leadingIcon = {
                            Icon(Icons.Filled.CurrencyRupee, contentDescription = "Amount")
                        },
                        modifier = Modifier.fillMaxWidth(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Counter Party Field
                    OutlinedTextField(
                        value = counterparty,
                        onValueChange = onCounterpartyChange,
                        label = { Text("Counter Party") },
                        leadingIcon = {
                            Icon(Icons.AutoMirrored.Filled.CompareArrows, contentDescription = "Counter Party")
                        },
                        modifier = Modifier.fillMaxWidth(),
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Reference Field
                    OutlinedTextField(
                        value = reference,
                        onValueChange = onReferenceChange,
                        label = { Text("Reference Number") },
                        leadingIcon = {
                            Box(
                                modifier = Modifier.size(24.dp),
                                contentAlignment = Alignment.Center,
                            ) {
                                Text(
                                    text = "R",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                    )

                    Spacer(modifier = Modifier.height(12.dp))
                }
            }
        }

        // Account Section
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                    ),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    ExposedDropdownMenuBox(
                        expanded = showAccountExpanded,
                        onExpandedChange = onAccountExpandedChange,
                    ) {
                        OutlinedTextField(
                            value = selectedAccount?.accountName ?: "Select Account",
                            onValueChange = {},
                            readOnly = true,
                            label = { Text("Account") },
                            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = showAccountExpanded) },
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .menuAnchor(),
                        )
                        ExposedDropdownMenu(
                            expanded = showAccountExpanded,
                            onDismissRequest = { onAccountExpandedChange(false) },
                        ) {
                            bankAccounts.forEach { account ->
                                DropdownMenuItem(
                                    text = {
                                        Text(
                                            text = account.accountName,
                                            style = MaterialTheme.typography.bodyMedium,
                                        )
                                    },
                                    onClick = {
                                        onAccountSelected(account)
                                        onAccountExpandedChange(false)
                                    },
                                    leadingIcon = {
                                        Icon(
                                            imageVector = Icons.Filled.CreditCard,
                                            contentDescription = "Account",
                                        )
                                    },
                                )
                            }
                        }
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.End,
                    ) {
                        TextButton(
                            onClick = { navController.navigate("manage_accounts") },
                        ) {
                            Text("Manage Accounts")
                        }
                    }
                }
            }
        }

        // Category Section
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                    ),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    ExposedDropdownMenuBox(
                        expanded = showCategoryExpanded,
                        onExpandedChange = onCategoryExpandedChange,
                    ) {
                        OutlinedTextField(
                            value = selectedCategory?.name ?: "Select Category",
                            onValueChange = {},
                            readOnly = true,
                            label = { Text("Category") },
                            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = showCategoryExpanded) },
                            modifier =
                                Modifier
                                    .fillMaxWidth()
                                    .menuAnchor(),
                        )
                        ExposedDropdownMenu(
                            expanded = showCategoryExpanded,
                            onDismissRequest = { onCategoryExpandedChange(false) },
                        ) {
                            categories.forEach { category ->
                                DropdownMenuItem(
                                    text = {
                                        Text(
                                            text = category.name,
                                            style = MaterialTheme.typography.bodyMedium,
                                        )
                                    },
                                    onClick = {
                                        onCategorySelected(category)
                                        onCategoryExpandedChange(false)
                                    },
                                    leadingIcon = {
                                        Icon(
                                            imageVector = getIconByName(category.icon),
                                            contentDescription = "Category",
                                        )
                                    },
                                )
                            }
                        }
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.End,
                    ) {
                        TextButton(
                            onClick = { navController.navigate("manage_categories") },
                        ) {
                            Text("Manage Categories")
                        }
                    }
                }
            }
        }

        // Tags Section
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                    ),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = "Tags",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                    )
                    Spacer(modifier = Modifier.height(12.dp))

                    if (tags.isEmpty()) {
                        Text(
                            text = "No tags available. Create tags in Settings.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Button(
                            onClick = { navController.navigate("tags_management") },
                            modifier = Modifier.fillMaxWidth(),
                        ) {
                            Text("Manage Tags")
                        }
                    } else {
                        FlowRow(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            tags.forEach { tag ->
                                val isSelected = selectedTags.contains(tag)
                                TagItem(
                                    tag = tag,
                                    isSelected = isSelected,
                                    onClick = {
                                        val newTags =
                                            if (isSelected) {
                                                selectedTags - tag
                                            } else {
                                                selectedTags + tag
                                            }
                                        onTagsSelected(newTags)
                                    },
                                )
                            }
                        }
                    }
                }
            }
        }

        // Description Section
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                    ),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = "Description (Optional)",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    OutlinedTextField(
                        value = description,
                        onValueChange = onDescriptionChange,
                        placeholder = { Text("Add a description for this transaction") },
                        modifier = Modifier.fillMaxWidth(),
                        minLines = 3,
                        maxLines = 5,
                    )
                }
            }
        }

        // TODO: Hide "Save pattern" checkbox when patternWasFound == true
        // - This prevents showing checkbox when pattern was already pre-applied
        if (!patternWasFound) {
            item {
                Row(
                    modifier =
                        Modifier
                            .fillMaxWidth()
                            .padding(16.dp)
                            .clickable { onSavePatternChange(!savePattern) },
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Checkbox(
                        checked = savePattern,
                        onCheckedChange = null,
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Save as Pattern",
                            style = MaterialTheme.typography.titleMedium,
                        )
                        Text(
                            text = "Save the selected field mappings as a pattern for future SMS from this sender",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )

                        if (savePattern) {
                            Spacer(modifier = Modifier.height(12.dp))
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Checkbox(
                                    checked = autoSelectAccount,
                                    onCheckedChange = { onAutoSelectAccountChange(it) },
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = "Auto-select this account for future SMS",
                                    style = MaterialTheme.typography.bodyMedium,
                                )
                            }
                        }
                    }
                }
            }
        }

        // Action Buttons Section
        item {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                // Create Transaction Button
                Button(
                    onClick = onCreateTransaction,
                    modifier = Modifier.fillMaxWidth(),
                    enabled = selectedCategory != null && selectedAccount != null,
                ) {
                    Icon(Icons.Filled.Save, contentDescription = "Save")
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Create Transaction")
                }

                // Not a Transaction Button
                OutlinedButton(
                    onClick = onNotATransactionClick,
                    modifier =
                        Modifier
                            .fillMaxWidth()
                            .combinedClickable(
                                onClick = onNotATransactionClick,
                                onLongClick = onNotATransactionLongPress,
                            ),
                ) {
                    Icon(Icons.Filled.Cancel, contentDescription = "Cancel")
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Not a Transaction")
                }

                // Cancel Button
                TextButton(
                    onClick = onCancel,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text("Cancel")
                }
            }
        }

        // Spacer at bottom
        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EnhancedFieldTypeChip(
    fieldType: FieldType,
    isSelected: Boolean,
    onClick: () -> Unit,
) {
    Surface(
        modifier = Modifier.clickable { onClick() },
        shape = CircleShape,
        color = if (isSelected) fieldType.color() else fieldType.color().copy(alpha = 0.1f),
        border =
            BorderStroke(
                width = if (isSelected) 2.dp else 1.dp,
                color = fieldType.color(),
            ),
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier =
                    Modifier
                        .size(24.dp)
                        .clip(CircleShape)
                        .background(if (isSelected) fieldType.color() else fieldType.color().copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = fieldType.displayName.first().uppercase(),
                    color = if (isSelected) MaterialTheme.colorScheme.onPrimary else fieldType.color(),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                )
            }
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = fieldType.buttonDisplayName,
                style = MaterialTheme.typography.labelMedium,
                color = if (isSelected) MaterialTheme.colorScheme.onPrimary else fieldType.color(),
            )
        }
    }
}

@Composable
fun EnhancedWordChip(
    analysis: WordAnalysis,
    targetFieldType: FieldType?,
    onClick: () -> Unit,
) {
    val isDisabled = targetFieldType == FieldType.AMOUNT && !analysis.isNumeric
    val isSelected = analysis.isSelected && analysis.fieldType != null

    val borderColor =
        when {
            isDisabled -> MaterialTheme.colorScheme.outline.copy(alpha = 0.1f)
            isSelected -> analysis.fieldType!!.color().copy(alpha = 0.5f)
            else -> MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)
        }

    val borderWidth = if (isSelected) 2.dp else 1.dp

    Surface(
        modifier =
            Modifier
                .clickable(enabled = !isDisabled) { onClick() }
                .alpha(if (isDisabled) 0.5f else 1f),
        shape = MaterialTheme.shapes.small,
        color = MaterialTheme.colorScheme.surface,
        border = BorderStroke(width = borderWidth, color = borderColor),
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (analysis.isSelected && analysis.fieldType != null) {
                when (analysis.fieldType) {
                    FieldType.AMOUNT -> {
                        Badge(
                            containerColor = FieldType.AMOUNT.color().copy(alpha = 0.2f),
                            contentColor = FieldType.AMOUNT.color(),
                        ) {
                            Text("₹", fontSize = 10.sp)
                        }
                        Spacer(modifier = Modifier.width(4.dp))
                    }
                    FieldType.COUNTERPARTY -> {
                        Badge(
                            containerColor = FieldType.COUNTERPARTY.color().copy(alpha = 0.2f),
                            contentColor = FieldType.COUNTERPARTY.color(),
                        ) {
                            Icon(Icons.AutoMirrored.Filled.CompareArrows, contentDescription = null, modifier = Modifier.size(10.dp))
                        }
                        Spacer(modifier = Modifier.width(4.dp))
                    }
                    FieldType.REFERENCE -> {
                        Badge(
                            containerColor = FieldType.REFERENCE.color().copy(alpha = 0.2f),
                            contentColor = FieldType.REFERENCE.color(),
                        ) {
                            Text("R", fontSize = 10.sp)
                        }
                        Spacer(modifier = Modifier.width(4.dp))
                    }
                }
            }
            Text(
                text = analysis.displayText,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurface,
                fontWeight = if (isSelected) FontWeight.Medium else FontWeight.Normal,
            )
        }
    }
}

// Enhanced numeric extraction with Indian format support
fun extractNumericContent(word: String): Pair<Boolean, String> {
    // Handle common Indian/International currency formats including "Rs.", "RS.", "₹"
    val cleanWord = word.replace(",", "") // Remove commas for thousands
    // Match patterns like: Rs.1.00, ₹100, $50.00, 1,234.56, 250 etc.
    val numericRegex = Regex("""(?i)[₹$\s]*RS?\.?\s*([\d]+(?:\.\d{1,2})?)""")
    val match = numericRegex.find(cleanWord)

    return if (match != null) {
        val numericValue = match.groupValues[1]
        try {
            val number = numericValue.toDoubleOrNull()
            if (number != null) {
                true to String.format(Locale.US, "%.2f", number)
            } else {
                false to ""
            }
        } catch (e: Exception) {
            false to ""
        }
    } else {
        // Alternative: look for any numeric pattern
        val altRegex = Regex("""[\d]+(?:[.,]\d{1,2})?""")
        val altMatch = altRegex.find(word)
        if (altMatch != null) {
            val numericValue = altMatch.value.replace(",", ".")
            try {
                val number = numericValue.toDoubleOrNull()
                if (number != null) {
                    true to String.format(Locale.US, "%.2f", number)
                } else {
                    false to ""
                }
            } catch (e: Exception) {
                false to ""
            }
        } else {
            false to ""
        }
    }
}

@Composable
fun TagItem(
    tag: Tags,
    isSelected: Boolean,
    onClick: () -> Unit,
) {
    Row(
        modifier =
            Modifier.background(
                color = Color(android.graphics.Color.parseColor(tag.color)),
                shape = RoundedCornerShape(100),
            ),
    ) {
        if (isSelected) {
            IconButton(
                onClick = onClick,
                modifier =
                    Modifier
                        .padding(10.dp)
                        .size(22.dp)
                        .align(Alignment.CenterVertically),
            ) {
                Icon(
                    modifier =
                        Modifier
                            .padding(start = 1.dp)
                            .align(Alignment.CenterVertically)
                            .size(24.dp),
                    imageVector = Icons.Filled.Close,
                    contentDescription = null,
                )
            }
        }
        Text(
            tag.name,
            modifier =
                Modifier
                    .padding(top = 5.dp, bottom = 5.dp, start = 2.dp, end = 10.dp)
                    .align(Alignment.CenterVertically),
            color = Color.White,
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UnprocessedSMSListPage(
    smsDao: SMSDao,
    navController: androidx.navigation.NavController,
) {
    val smsList by smsDao.selectUnprocessedSMS().collectAsState(initial = emptyList())

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Unprocessed SMS",
                        style = MaterialTheme.typography.titleMedium,
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors =
                    TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                        titleContentColor = MaterialTheme.colorScheme.onSurface,
                    ),
            )
        },
    ) { paddingValues ->
        LazyColumn(
            modifier =
                Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            if (smsList.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier.fillMaxWidth(),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            "No unprocessed SMS",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            } else {
                items(smsList) { sms ->
                    Card(
                        modifier =
                            Modifier
                                .fillMaxWidth()
                                .clickable { navController.navigate("sms_view/${sms.id}") },
                        colors =
                            CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.surface,
                            ),
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text(
                                text = sms.sender,
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold,
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = sms.message,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                maxLines = 2,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                    }
                }
            }
        }
    }
}

fun updateExtractedValues(
    analysis: List<WordAnalysis>,
    fieldType: FieldType,
    currentAmount: String,
    currentCounterparty: String,
    currentReference: String,
    onAmountChange: (String) -> Unit,
    onCounterpartyChange: (String) -> Unit,
    onReferenceChange: (String) -> Unit,
) {
    when (fieldType) {
        FieldType.AMOUNT -> {
            val amountText =
                analysis
                    .filter { it.fieldType == FieldType.AMOUNT && it.isSelected }
                    .joinToString("") { it.displayText }
            if (amountText.isNotBlank()) {
                onAmountChange(amountText)
            }
        }
        FieldType.COUNTERPARTY -> {
            val counterpartyText =
                analysis
                    .filter { it.fieldType == FieldType.COUNTERPARTY && it.isSelected }
                    .joinToString(" ") { it.word }
            if (counterpartyText.isNotBlank()) {
                onCounterpartyChange(counterpartyText)
            }
        }
        FieldType.REFERENCE -> {
            val referenceText =
                analysis
                    .filter { it.fieldType == FieldType.REFERENCE && it.isSelected }
                    .joinToString(" ") { it.word }
            if (referenceText.isNotBlank()) {
                onReferenceChange(referenceText)
            }
        }
        else -> {}
    }
}

fun applyPatternToAnalysis(
    pattern: SMSParsingPattern,
    message: String,
    currentAnalysis: List<WordAnalysis>,
): List<WordAnalysis>? {
    val words = message.split(Regex("""\s+""")).filter { it.isNotBlank() }
    android.util.Log.d("SMSPageEnhanced", "applyPatternToAnalysis:")
    android.util.Log.d("SMSPageEnhanced", "  Word count: ${words.size}")
    android.util.Log.d("SMSPageEnhanced", "  Analysis size: ${currentAnalysis.size}")
    android.util.Log.d("SMSPageEnhanced", "  Amount positions: ${pattern.amountPattern}")
    android.util.Log.d("SMSPageEnhanced", "  Counterparty positions: ${pattern.counterpartyPattern}")
    android.util.Log.d("SMSPageEnhanced", "  Reference positions: ${pattern.referencePattern}")

    // Clear all existing selections first
    val updatedAnalysis = currentAnalysis.map { it.copy(fieldType = null, isSelected = false) }.toMutableList()

    // Helper to apply pattern field
    fun applyField(patternString: String?, fieldType: FieldType) {
        if (!patternString.isNullOrEmpty()) {
            patternString.split(",").mapNotNull { it.toIntOrNull() }.forEach { pos ->
                if (pos < updatedAnalysis.size) {
                    updatedAnalysis[pos] = updatedAnalysis[pos].copy(
                        fieldType = fieldType,
                        isSelected = true
                    )
                }
            }
        }
    }

    applyField(pattern.amountPattern, FieldType.AMOUNT)
    applyField(pattern.counterpartyPattern, FieldType.COUNTERPARTY)
    applyField(pattern.referencePattern, FieldType.REFERENCE)

    android.util.Log.d("SMSPageEnhanced", "  Applied ${updatedAnalysis.count { it.isSelected }} word selections")
    return updatedAnalysis
}

fun createPatternFromAnalysis(
    sender: String,
    message: String,
    analysis: List<WordAnalysis>,
    transactionType: TransactionType,
): SMSParsingPattern {
    val amountPositions =
        analysis
            .mapIndexedNotNull { index, word -> if (word.fieldType == FieldType.AMOUNT) index else null }

    val counterpartyPositions =
        analysis
            .mapIndexedNotNull { index, word -> if (word.fieldType == FieldType.COUNTERPARTY) index else null }

    val referencePositions =
        analysis
            .mapIndexedNotNull { index, word -> if (word.fieldType == FieldType.REFERENCE) index else null }

    android.util.Log.d("SMSPageEnhanced", "createPatternFromAnalysis:")
    android.util.Log.d("SMSPageEnhanced", "  Amount positions: $amountPositions")
    android.util.Log.d("SMSPageEnhanced", "  Counterparty positions: $counterpartyPositions")
    android.util.Log.d("SMSPageEnhanced", "  Reference positions: $referencePositions")

    return SMSParsingPattern(
        senderIdentifier = sender,
        senderName = SenderParser.extractSenderName(sender),
        patternName = "Generated_${System.currentTimeMillis()}",
        messageStructure = buildMessageStructure(message, analysis),
        amountPattern = amountPositions.joinToString(","),
        counterpartyPattern = counterpartyPositions.joinToString(","),
        referencePattern = referencePositions.joinToString(",").ifEmpty { null },
        transactionType = transactionType,
        isActive = true,
    )
}

fun buildMessageStructure(
    message: String,
    analysis: List<WordAnalysis>,
): String {
    val words = message.split(Regex("""\s+""")).filter { it.isNotBlank() }
    return words.mapIndexed { index, word ->
        val wordAnalysis = analysis.getOrNull(index)
        when (wordAnalysis?.fieldType) {
            FieldType.AMOUNT -> "[AMOUNT]"
            FieldType.COUNTERPARTY -> "[COUNTERPARTY]"
            FieldType.REFERENCE -> "[REFERENCE]"
            else -> if (word.length > 3) "[TEXT]" else "[SHORT]"
        }
    }.joinToString(" ")
}

fun extractUsingPattern(
    message: String,
    pattern: SMSParsingPattern,
): Map<String, String> {
    val result = mutableMapOf<String, String>()
    val words = message.split(Regex("""\s+""")).filter { it.isNotBlank() }

    android.util.Log.d("SMSPageEnhanced", "extractUsingPattern:")
    android.util.Log.d("SMSPageEnhanced", "  Word count: ${words.size}")
    android.util.Log.d("SMSPageEnhanced", "  Words: ${words.take(20)}")
    android.util.Log.d("SMSPageEnhanced", "  Amount pattern: ${pattern.amountPattern}")
    android.util.Log.d("SMSPageEnhanced", "  Counterparty pattern: ${pattern.counterpartyPattern}")
    android.util.Log.d("SMSPageEnhanced", "  Reference pattern: ${pattern.referencePattern}")

    // Extract amount
    if (pattern.amountPattern.isNotEmpty()) {
        val amountPositions = pattern.amountPattern.split(",").mapNotNull { it.toIntOrNull() }
        val amountWords = amountPositions.mapNotNull { words.getOrNull(it) }
        val amount = amountWords.joinToString(" ")

        android.util.Log.d("SMSPageEnhanced", "  Amount positions: $amountPositions")
        android.util.Log.d("SMSPageEnhanced", "  Amount words: $amountWords")
        android.util.Log.d("SMSPageEnhanced", "  Raw amount: $amount")

        // Clean amount (extract numeric part)
        var cleanAmount = amount.replace("[^\\d.]".toRegex(), "")
        // Remove leading/trailing dots (e.g., ".1.00" -> "1.00", "1.00." -> "1.00")
        cleanAmount = cleanAmount.removePrefix(".").removeSuffix(".")
        android.util.Log.d("SMSPageEnhanced", "  Clean amount: $cleanAmount")
        if (cleanAmount.isNotBlank()) {
            result["amount"] = cleanAmount
        }
    }

    // Extract counterparty
    if (pattern.counterpartyPattern.isNotEmpty()) {
        val counterpartyPositions = pattern.counterpartyPattern.split(",").mapNotNull { it.toIntOrNull() }
        val counterpartyWords = counterpartyPositions.mapNotNull { words.getOrNull(it) }
        val counterparty = counterpartyWords.joinToString(" ")

        android.util.Log.d("SMSPageEnhanced", "  Counterparty positions: $counterpartyPositions")
        android.util.Log.d("SMSPageEnhanced", "  Counterparty words: $counterpartyWords")
        android.util.Log.d("SMSPageEnhanced", "  Counterparty: $counterparty")

        if (counterparty.isNotBlank()) {
            result["counterparty"] = counterparty
        }
    }

    // Extract reference
    if (!pattern.referencePattern.isNullOrEmpty()) {
        val referencePositions = pattern.referencePattern.split(",").mapNotNull { it.toIntOrNull() }
        val referenceWords = referencePositions.mapNotNull { words.getOrNull(it) }
        val rawReference = referenceWords.joinToString(" ")

        android.util.Log.d("SMSPageEnhanced", "  Reference positions: $referencePositions")
        android.util.Log.d("SMSPageEnhanced", "  Reference words: $referenceWords")
        android.util.Log.d("SMSPageEnhanced", "  Raw reference: $rawReference")

        if (rawReference.isNotBlank()) {
            val cleanReference = extractNumbersOnly(rawReference)
            android.util.Log.d("SMSPageEnhanced", "  Clean reference: $cleanReference")
            result["reference"] = cleanReference
        }
    }

    android.util.Log.d("SMSPageEnhanced", "  Result: $result")
    return result
}

fun extractNumbersOnly(text: String): String {
    return text.replace(Regex("[^\\d]"), "")
}

fun validateTransaction(
    amount: String,
    counterparty: String,
    category: Categories?,
    account: BankAccounts?,
): Boolean {
    return amount.isNotBlank() &&
        counterparty.isNotBlank() &&
        amount.toDoubleOrNull() != null &&
        category != null &&
        account != null
}
