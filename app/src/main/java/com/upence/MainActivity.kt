package com.upence

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.core.content.ContextCompat
import androidx.core.content.edit
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.upence.data.AppDatabase
import com.upence.data.UserStore
import com.upence.ui.HomePage
import com.upence.ui.SMSPageEnhanced
import com.upence.ui.SettingsPage
import com.upence.ui.StartPage
import com.upence.ui.UnprocessedSMSListPage
import com.upence.ui.settings.AccountManagementPage
import com.upence.ui.settings.CategoryManagementPage
import com.upence.ui.settings.TagsManagementPage
import com.upence.ui.settings.PatternManagementPage
import com.upence.ui.theme.UpenceTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    private var smsIdToNavigate by mutableStateOf<Long?>(null)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        handleIntent(intent)

        val userStore = UserStore(applicationContext)

        setContent {
            val navController = rememberNavController()
            val scope = rememberCoroutineScope()
            val isSetupComplete by userStore.isSetupComplete.collectAsState(initial = null)
            val themeMode by userStore.themeMode.collectAsState(initial = 2)

            val database = remember { AppDatabase.getDatabase(applicationContext) }
            val transactionDao = remember { database.transactionDao() }
            val categoryDao = remember { database.categoryDao() }
            val bankAccountsDao = remember { database.BankAccountsDao() }
            val smsDao = remember { database.SMSDao() }

            LaunchedEffect(smsIdToNavigate) {
                smsIdToNavigate?.let {
                    navController.navigate("sms_view/$it")
                    smsIdToNavigate = null
                }
            }

            UpenceTheme(
                themeMode = themeMode,
                dynamicColor = false,
            ) {
                NavHost(navController = navController, startDestination = "home") {
                    composable("home") {
                        when (isSetupComplete) {
                            null -> Box(modifier = Modifier.fillMaxSize())
                            false -> {
                                StartPage(
                                    onSetupFinished = {
                                        scope.launch { userStore.setSetupComplete(true) }
                                    },
                                    categoryDao = categoryDao,
                                    bankAccountsDao = bankAccountsDao,
                                )
                            }

                            true -> {
                                EnsureSmsPermission {
                                    HomePage(
                                        transactionDao = transactionDao,
                                        categoryDao = categoryDao,
                                        bankAccountsDao = bankAccountsDao,
                                        smsDao = smsDao,
                                        navController = navController,
                                    )
                                }
                            }
                        }
                    }
                    composable(
                        route = "sms_view/{smsId}",
                        arguments =
                            listOf(
                                navArgument("smsId") { type = NavType.LongType },
                            ),
                    ) { backStackEntry ->
                        val smsId = backStackEntry.arguments?.getLong("smsId") ?: -1L
                        val tagsDao = remember { database.TagsDao() }
                        val smsParsingPatternDao = remember { database.SMSParsingPatternDao() }

                        SMSPageEnhanced(
                            smsId = smsId,
                            onBack = { navController.popBackStack() },
                            smsDao = smsDao,
                            smsParsingPatternDao = smsParsingPatternDao,
                            transactionDao = transactionDao,
                            categoryDao = categoryDao,
                            bankAccountsDao = bankAccountsDao,
                            tagsDao = tagsDao,
                            senderDao = database.SenderDao(),
                            userStore = userStore,
                            scope = scope,
                            navController = navController,
                        )
                    }
                    composable("manage_accounts") {
                        AccountManagementPage(
                            bankAccountsDao = bankAccountsDao,
                            transactionDao = transactionDao,
                            navController = navController,
                        )
                    }
                    composable("manage_categories") {
                        CategoryManagementPage(
                            categoryDao = categoryDao,
                            transactionDao = transactionDao,
                            navController = navController,
                        )
                    }
                    composable("manage_tags") {
                        TagsManagementPage(
                            tagsDao = database.TagsDao(),
                            navController = navController,
                        )
                    }
                    composable("unprocessed_sms") {
                        UnprocessedSMSListPage(
                            smsDao = smsDao,
                            navController = navController,
                        )
                    }
                    composable("settings") {
                        SettingsPage(
                            userStore = userStore,
                            categoryDao = categoryDao,
                            bankAccountsDao = bankAccountsDao,
                            senderDao = database.SenderDao(),
                            smsParsingPatternDao = database.SMSParsingPatternDao(),
                            navController = navController,
                        )
                    }
                    composable("manage_patterns") {
                        PatternManagementPage(
                            smsParsingPatternDao = database.SMSParsingPatternDao(),
                            navController = navController,
                        )
                    }
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (intent.hasExtra("sms_id")) {
            val smsId = intent.getLongExtra("sms_id", -1)
            if (smsId != -1L) {
                smsIdToNavigate = smsId
                Log.d("MainActivity", "Received SMS ID: $smsId")

                val notificationManager =
                    getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.cancel(smsId.toInt())
            }
        }
    }
}

@Composable
fun EnsureSmsPermission(content: @Composable () -> Unit) {
    val context = LocalContext.current
    val activity = context as? Activity
    val sharedPrefs = context.getSharedPreferences("upence_prefs", Context.MODE_PRIVATE)
    val permissions = arrayOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS)

    var hasPermissions by remember {
        mutableStateOf(permissions.all { ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED })
    }
    var isPermanentlyDenied by remember { mutableStateOf(false) }

    fun updatePermissionStatus() {
        val allGranted = permissions.all { ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED }
        hasPermissions = allGranted
        if (!allGranted && activity != null) {
            val shouldShowRationale = permissions.any { activity.shouldShowRequestPermissionRationale(it) }
            val alreadyAsked = sharedPrefs.getBoolean("sms_asked", false)
            isPermanentlyDenied = !shouldShowRationale && alreadyAsked
        }
    }

    val lifecycleOwner = LocalLifecycleOwner.current
    DisposableEffect(lifecycleOwner) {
        val observer =
            LifecycleEventObserver { _, event ->
                if (event == Lifecycle.Event.ON_RESUME) updatePermissionStatus()
            }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    val launcher =
        rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
            sharedPrefs.edit { putBoolean("sms_asked", true) }
            updatePermissionStatus()
        }

    if (hasPermissions) {
        content()
    } else {
        AlertDialog(
            onDismissRequest = {},
            title = { Text("Permissions Required") },
            text = {
                Text(
                    if (isPermanentlyDenied) {
                        "SMS permissions are permanently disabled. Enable them in Settings."
                    } else {
                        "This app needs to Read and Receive SMS to track transactions automatically."
                    },
                )
            },
            confirmButton = {
                if (!isPermanentlyDenied) {
                    Button(onClick = { launcher.launch(permissions) }) { Text("Grant") }
                }
            },
            dismissButton = {
                TextButton(onClick = {
                    val intent =
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.fromParts("package", context.packageName, null)
                        }
                    context.startActivity(intent)
                }) { Text("Settings") }
            },
        )
    }
}

@Preview(showBackground = true)
@Composable
fun DefaultPreview() {
    UpenceTheme {
        HomePage(
            transactionDao = TODO(),
            categoryDao = TODO(),
            bankAccountsDao = TODO(),
            smsDao = TODO(),
            navController = TODO(),
        )
    }
}
