package com.upence.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.upence.data.*
import com.upence.ui.settings.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsPage(
    userStore: UserStore,
    categoryDao: CategoriesDao,
    bankAccountsDao: BankAccountsDao,
    senderDao: SenderDao,
    navController: NavController,
    modifier: Modifier = Modifier
) {
    val scope = rememberCoroutineScope()
    val themeMode by userStore.themeMode.collectAsState(initial = 2)
    val currencyCode by userStore.currencyCode.collectAsState(initial = "INR")
    val currencySymbol by userStore.currencySymbol.collectAsState(initial = "₹")
    val useCustomCurrency by userStore.useCustomCurrency.collectAsState(initial = false)
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                AppearanceCard(
                    themeMode = themeMode,
                    onThemeModeChange = { mode ->
                        scope.launch { userStore.setThemeMode(mode) }
                    }
                )
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
                    }
                )
            }
            
            item {
                DataManagementCard(navController = navController)
            }
            
            item {
                val ignoredSenders by senderDao.getIgnoredSenders().collectAsState(initial = emptyList())
                IgnoredSendersCard(
                    ignoredSendersCount = ignoredSenders.size,
                    navController = navController
                )
            }
            
            item {
                ResetDefaultsCard(
                    categoryDao = categoryDao,
                    bankAccountsDao = bankAccountsDao,
                    scope = scope
                )
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
