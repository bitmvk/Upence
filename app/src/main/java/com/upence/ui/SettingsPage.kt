package com.upence.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.upence.data.*
import com.upence.ui.settings.PatternManagementCard
import com.upence.ui.settings.TagsManagementCard
import com.upence.ui.settings.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsPage(
    userStore: UserStore,
    categoryDao: CategoriesDao,
    bankAccountsDao: BankAccountsDao,
    senderDao: SenderDao,
    smsParsingPatternDao: SMSParsingPatternDao,
    tagsDao: com.upence.data.TagsDao,
    navController: NavController,
    modifier: Modifier = Modifier,
) {
    var isSidebarOpen by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val themeMode by userStore.themeMode.collectAsState(initial = 2)
    val currencyCode by userStore.currencyCode.collectAsState(initial = "INR")
    val currencySymbol by userStore.currencySymbol.collectAsState(initial = "₹")
    val useCustomCurrency by userStore.useCustomCurrency.collectAsState(initial = false)
    val useIndiaRuleset by userStore.useIndiaSenderRuleset.collectAsState(initial = true)

    Box(modifier = Modifier.fillMaxSize()) {
        SlideInFromRightAnimation(
            key = "settings",
        ) {
            Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = {
                    IconButton(onClick = { isSidebarOpen = true }) {
                        Icon(Icons.Default.Menu, contentDescription = "Menu")
                    }
                },
            )
        },
    ) { paddingValues ->
        LazyColumn(
            modifier =
                Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(0.dp),
        ) {
            item {
                AppearanceCard(
                    themeMode = themeMode,
                    onThemeModeChange = { mode ->
                        scope.launch { userStore.setThemeMode(mode) }
                    },
                )
            }

            item {
                HorizontalDivider()
            }

            item {
                CurrencyCard(
                    currencyCode = currencyCode,
                    currencySymbol = currencySymbol,
                    useCustomCurrency = useCustomCurrency,
                    onCurrencyCodeChange = { code ->
                        scope.launch { userStore.setCurrencyCode(code) }
                    },
                    onCurrencySymbolChange = { symbol ->
                        scope.launch { userStore.setCurrencySymbol(symbol) }
                    },
                    onUseCustomCurrencyChange = { use ->
                        scope.launch { userStore.setUseCustomCurrency(use) }
                    },
                )
            }

            item {
                HorizontalDivider()
            }

            item {
                DataManagementCard(navController = navController)
            }

            item {
                HorizontalDivider()
            }

            item {
                val tags by tagsDao.getAllTags().collectAsState(initial = emptyList())
                TagsManagementCard(
                    tagCount = tags.size,
                    navController = navController,
                )
            }

            item {
                HorizontalDivider()
            }

            item {
                val patterns by smsParsingPatternDao.getAllPatterns().collectAsState(initial = emptyList())
                PatternManagementCard(
                    patternCount = patterns.size,
                    navController = navController,
                )
            }

            item {
                HorizontalDivider()
            }

            item {
                val ignoredSenders by senderDao.getIgnoredSenders().collectAsState(initial = emptyList())
                IgnoredSendersCard(
                    ignoredSendersCount = ignoredSenders.size,
                    navController = navController,
                )
            }

            item {
                HorizontalDivider()
            }

            item {
                IndiaSenderRulesetCard(
                    useIndiaRuleset = useIndiaRuleset,
                    onUseIndiaRulesetChange = { enabled ->
                        scope.launch { userStore.setUseIndiaSenderRuleset(enabled) }
                    },
                )
            }

            item {
                HorizontalDivider()
            }

            item {
                ResetDefaultsCard(
                    categoryDao = categoryDao,
                    bankAccountsDao = bankAccountsDao,
                    scope = scope,
                )
            }

            item {
                HorizontalDivider()
            }

            item {
                AppInfoCard()
            }

            item {
                Spacer(modifier = Modifier.height(16.dp))
            }
        }
            }
        }

        NavigationSidebar(
            isOpen = isSidebarOpen,
            onClose = { isSidebarOpen = false },
            currentRoute = "settings",
            navController = navController,
        )
    }
}
