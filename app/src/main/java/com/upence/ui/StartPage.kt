package com.upence.ui

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.ShoppingBag
import androidx.compose.material.icons.filled.Train
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toColorLong
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.upence.data.BankAccounts
import com.upence.data.BankAccountsDao
import com.upence.data.Categories
import com.upence.data.CategoriesDao
import com.upence.ui.component.ColorPicker
import com.upence.ui.component.IconPicker
import com.upence.ui.theme.UpenceTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.math.roundToInt

@Composable
fun StartPage(
    onSetupFinished: () -> Unit, // <--- NEW CALLBACK
    categoryDao: CategoriesDao,
    bankAccountsDao: BankAccountsDao,
) {
    var currentStep by remember { mutableIntStateOf(0) }

    // Account Data
    var accountName by remember { mutableStateOf("") }
    var accountNumber by remember { mutableStateOf("") }
    var accountDesc by remember { mutableStateOf("") }

    // Validation & Animation
    var isAccountNameError by remember { mutableStateOf(false) }
    val accountShakeOffset = remember { Animatable(0f) }
    val scope = rememberCoroutineScope()

    // Permissions
    val context = LocalContext.current
    var hasSmsPermission by remember {
        mutableStateOf(
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.RECEIVE_SMS,
            ) == PackageManager.PERMISSION_GRANTED,
        )
    }
    var hasNotificationPermission by remember {
        mutableStateOf(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.POST_NOTIFICATIONS,
                ) == PackageManager.PERMISSION_GRANTED
            } else {
                true
            },
        )
    }

    // Dialogs
    var showSmsBlockerDialog by remember { mutableStateOf(false) }
    var showNotificationWarningDialog by remember { mutableStateOf(false) }

    // Lifecycle Observer (omitted for brevity, keep your existing one)

    val categories =
        remember {
            mutableStateListOf<CategoryData>(
                CategoryData(
                    color = Color(0xFFffadad),
                    text = "Food and Groceries",
                    icon = Icons.Default.Restaurant,
                    desc = "",
                ),
                CategoryData(
                    color = Color(0xFFcaffbf),
                    text = "Travel",
                    icon = Icons.Default.Train,
                    desc = "",
                ),
                CategoryData(
                    color = Color(0xFF9bf6ff),
                    text = "To People",
                    icon = Icons.Default.Person,
                    desc = "",
                ),
                CategoryData(
                    color = Color(0xFFa0c4ff),
                    text = "Tolls",
                    icon = Icons.Default.DirectionsCar,
                    desc = "",
                ),
                CategoryData(
                    color = Color(0xFFbdb2ff),
                    text = "Online Shopping",
                    icon = Icons.Default.ShoppingBag,
                    desc = "",
                ),
                CategoryData(
                    color = Color(0xFFffd6a5),
                    text = "Bills and Utilities",
                    icon = Icons.Default.ShoppingBag,
                    desc = "",
                ),
            )
        }

    UpenceTheme {
        Scaffold(modifier = Modifier.fillMaxSize(), bottomBar = {
            Box(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .padding(24.dp)
                        .navigationBarsPadding(),
            ) {
                if (currentStep > 0) {
                    TextButton(
                        onClick = { currentStep-- },
                        modifier = Modifier.align(Alignment.CenterStart),
                    ) { Text("Previous") }
                }
                Button(
                    onClick = {
                        when (currentStep) {
                            0 -> currentStep++ // Welcome
                            1 -> { // Permissions
                                if (!hasSmsPermission) {
                                    showSmsBlockerDialog = true
                                } else if (!hasNotificationPermission) {
                                    showNotificationWarningDialog =
                                        true
                                } else {
                                    currentStep++
                                }
                            }

                            2 -> { // Account
                                if (accountName.isBlank()) {
                                    isAccountNameError = true
                                    scope.launch {
                                        accountShakeOffset.animateTo(0f, tween(50))
                                        repeat(3) {
                                            accountShakeOffset.animateTo(15f, tween(50))
                                            accountShakeOffset.animateTo(-15f, tween(50))
                                        }
                                        accountShakeOffset.animateTo(0f, tween(50))
                                    }
                                } else {
                                    currentStep++
                                }
                            }

                            3 -> {
                                // Categories (Last Step) - This triggers the finish

                                scope.launch {
                                    withContext(Dispatchers.IO) {
                                        bankAccountsDao.insertBankAccount(
                                            BankAccounts(
                                                accountName = accountName,
                                                accountNumber = accountNumber,
                                                description = accountDesc,
                                            ),
                                        )

                                        categories.forEach { categoryData ->
                                            categoryDao.insertCategory(
                                                Categories(
                                                    id = 0,
                                                    name = categoryData.text,
                                                    description = categoryData.desc,
                                                    color = categoryData.color.toColorLong(),
                                                    icon = categoryData.icon.name,
                                                ),
                                            )
                                        }
                                    }
                                    onSetupFinished()
                                }
                            }
                        }
                    },
                    modifier = Modifier.align(Alignment.CenterEnd),
                ) {
                    // Change text based on step
                    Text(if (currentStep == 3) "Finish" else "Next")
                }
            }
        }) { innerPadding ->
            Box(modifier = Modifier.padding(innerPadding)) {
                when (currentStep) {
                    0 -> WelcomeStep()
                    1 ->
                        PermissionsStep(
                            hasSmsPermission,
                            hasNotificationPermission,
                        ) { s, n ->
                            hasSmsPermission = s
                            hasNotificationPermission = n
                        }

                    2 ->
                        AccountStep(
                            accountName,
                            {
                                accountName = it
                                isAccountNameError = false
                            },
                            accountNumber,
                            { accountNumber = it },
                            accountDesc,
                            { accountDesc = it },
                            isAccountNameError,
                            accountShakeOffset.value,
                        )

                    3 ->
                        CategoriesStep(
                            categories,
                            { categories.remove(it) },
                            { categories.add(it) },
                        )
                }

                // Keep your Dialog Logic here (SmsBlockerDialog, etc.)
                // ...
            }
        }
    }
}

@Composable
fun StandardStepLayout(
    topContent: @Composable () -> Unit,
    bottomContent: @Composable () -> Unit,
) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(0.75f),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                topContent()
            }
            Column(modifier = Modifier.weight(2f), verticalArrangement = Arrangement.Top) {
                bottomContent()
            }
        }
    }
}

@Composable
fun WelcomeStep() {
    StandardStepLayout(
        topContent = {
            Text(
                "Welcome to Upence",
                style = MaterialTheme.typography.headlineLarge,
                modifier = Modifier.padding(20.dp),
                textAlign = TextAlign.Center,
            )
        },
        bottomContent = {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(
                    "We will now run you through the basic set up for getting started.",
                    style = MaterialTheme.typography.bodyLarge,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(20.dp),
                )
                Text(
                    "We will set up permissions, accounts, and categories before entering the app. You will be able to edit the set up you are about to make later in the app.",
                    style = MaterialTheme.typography.bodyLarge,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(20.dp),
                )
            }
        },
    )
}

@Composable
fun PermissionsStep(
    hasSms: Boolean,
    hasNotif: Boolean,
    onPermissionsChanged: (Boolean, Boolean) -> Unit,
) {
    val context = LocalContext.current
    val activity = context as? Activity
    var showSettingsDialog by remember { mutableStateOf(false) }

    // Track if permissions are permanently denied to prevent useless requests
    var isSmsPermanentlyDenied by remember { mutableStateOf(false) }
    var isNotifPermanentlyDenied by remember { mutableStateOf(false) }

    // Launcher for multiple permissions
    val permissionLauncher =
        rememberLauncherForActivityResult(
            contract = ActivityResultContracts.RequestMultiplePermissions(),
        ) { result ->
            val smsGranted = result[Manifest.permission.RECEIVE_SMS] ?: false
            val notifGranted =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    result[Manifest.permission.POST_NOTIFICATIONS] ?: false
                } else {
                    true
                }

            onPermissionsChanged(smsGranted, notifGranted)

            // Logic to detect if permission was permanently denied inside the callback
            if (activity != null) {
                // Check SMS status
                if (!smsGranted) {
                    isSmsPermanentlyDenied =
                        !ActivityCompat.shouldShowRequestPermissionRationale(
                            activity,
                            Manifest.permission.RECEIVE_SMS,
                        )
                } else {
                    isSmsPermanentlyDenied = false
                }

                // Check Notification status (Tiramisu+)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !notifGranted) {
                    isNotifPermanentlyDenied =
                        !ActivityCompat.shouldShowRequestPermissionRationale(
                            activity,
                            Manifest.permission.POST_NOTIFICATIONS,
                        )
                } else {
                    isNotifPermanentlyDenied = false
                }
            }
        }

    StandardStepLayout(
        topContent = {
            Text(
                "SMS and Notification Permissions",
                style = MaterialTheme.typography.headlineLarge,
                modifier = Modifier.padding(20.dp),
                textAlign = TextAlign.Center,
            )
        },
        bottomContent = {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(
                    "Upence requires the following permissions to run optimally.",
                    style = MaterialTheme.typography.bodyLarge,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(20.dp),
                )
                Text(
                    "SMS: Upence reads the incoming SMS to check if any of them are related to transactions and if any related ones are found, adds them to the transaction database\n\nNotification: When a transaction SMS is recieved, Upence notifies the user to categorize and tag the transaction for tracking of spending.",
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.padding(20.dp),
                )

                Button(
                    modifier = Modifier.fillMaxWidth(0.6f),
                    // Disable only if ALL required permissions are already granted
                    enabled = !(hasSms && hasNotif),
                    onClick = {
                        val permissionsToRequest = mutableListOf<String>()

                        // Intelligently ask only for what is missing AND not permanently denied
                        if (!hasSms && !isSmsPermanentlyDenied) {
                            permissionsToRequest.add(Manifest.permission.RECEIVE_SMS)
                            permissionsToRequest.add(Manifest.permission.READ_SMS)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !hasNotif && !isNotifPermanentlyDenied) {
                            permissionsToRequest.add(Manifest.permission.POST_NOTIFICATIONS)
                        }

                        if (permissionsToRequest.isNotEmpty()) {
                            // Launch only the ones that are likely to show a dialog
                            permissionLauncher.launch(permissionsToRequest.toTypedArray())
                        } else {
                            // If we have nothing to request, but permissions are still missing,
                            // it means they are permanently denied. NOW we show the settings dialog.
                            if (!hasSms || !hasNotif) {
                                showSettingsDialog = true
                            }
                        }
                    },
                ) {
                    if (hasSms && hasNotif) {
                        Text("Permissions Granted")
                    } else {
                        Text("Grant Permission")
                    }
                }

                // --- New Status Text Section ---
                Column(
                    modifier = Modifier.padding(top = 16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    AnimatedVisibility(visible = hasSms) {
                        Text(
                            "✓ SMS Permission Granted",
                            color = Color(0xFF4CAF50), // Green
                            style = MaterialTheme.typography.bodyMedium,
                            modifier = Modifier.padding(vertical = 4.dp),
                        )
                    }
                    AnimatedVisibility(visible = hasNotif) {
                        Text(
                            "✓ Notification Permission Granted",
                            color = Color(0xFF4CAF50), // Green
                            style = MaterialTheme.typography.bodyMedium,
                            modifier = Modifier.padding(vertical = 4.dp),
                        )
                    }
                    // Optional: Show warning text if perm denied
                    if (!hasSms && isSmsPermanentlyDenied) {
                        Text(
                            "⚠ SMS Permission Denied (Requires Settings)",
                            color = MaterialTheme.colorScheme.error,
                            style = MaterialTheme.typography.bodySmall,
                            modifier = Modifier.padding(vertical = 4.dp),
                        )
                    }
                }

                // Alert Dialog to guide user to Settings if permanently denied
                if (showSettingsDialog) {
                    AlertDialog(
                        onDismissRequest = { showSettingsDialog = false },
                        title = { Text("Permission Required") },
                        text = {
                            Text(
                                "One or more required permissions have been permanently denied. Please go to app settings to enable them manually to continue.",
                            )
                        },
                        confirmButton = {
                            Button(onClick = {
                                showSettingsDialog = false
                                val intent =
                                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                        data = Uri.fromParts("package", context.packageName, null)
                                    }
                                context.startActivity(intent)
                            }) {
                                Text("Open Settings")
                            }
                        },
                        dismissButton = {
                            TextButton(onClick = { showSettingsDialog = false }) {
                                Text("Cancel")
                            }
                        },
                    )
                }
            }
        },
    )
}

@Composable
fun AccountStep(
    accountName: String,
    onAccountNameChange: (String) -> Unit,
    accountNumber: String,
    onAccountNumberChange: (String) -> Unit,
    accountDesc: String,
    onAccountDescChange: (String) -> Unit,
    isError: Boolean,
    shakeOffset: Float,
) {
    StandardStepLayout(topContent = {
        Column(modifier = Modifier, horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                "Set up Bank Account",
                style = MaterialTheme.typography.headlineLarge,
                modifier = Modifier.padding(20.dp),
            )
            Text(
                "The account will be used for storing\nthe transaction information.",
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
            )
            Text(
                "You can add more bank accounts later",
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 5.dp),
            )
        }
    }, bottomContent = {
        OutlinedTextField(
            value = accountName,
            onValueChange = onAccountNameChange,
            label = { Text("Account Name") },
            singleLine = true,
            isError = isError,
            modifier =
                Modifier
                    .padding(top = 16.dp)
                    .offset { IntOffset(shakeOffset.roundToInt(), 0) },
        )
        OutlinedTextField(
            value = accountNumber,
            onValueChange = onAccountNumberChange,
            label = { Text("Account Number(Optional)") },
            singleLine = true,
            modifier =
                Modifier
                    .padding(top = 16.dp),
        )
        OutlinedTextField(
            value = accountDesc,
            onValueChange = onAccountDescChange,
            label = { Text("Description(Optional)") },
            singleLine = true,
            modifier =
                Modifier
                    .padding(top = 16.dp),
        )
    })
}

private enum class SheetView { FORM, ICON_PICKER, COLOR_PICKER }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoriesStep(
    categories: List<CategoryData>,
    onCategoryDelete: (CategoryData) -> Unit,
    onCategoryAdd: (CategoryData) -> Unit,
) {
    var showBottomSheet by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    // State for the inputs
    var newCategoryName by remember { mutableStateOf("") }
    val newCategoryColor = remember { mutableStateOf(Color(0XFF0000FF)) }
    var newCategoryDesc by remember { mutableStateOf("") }
    var newCategoryIcon by remember { mutableStateOf<ImageVector>(Icons.Default.Add) }

    // State for Animation View Switching
    var currentView by remember { mutableStateOf(SheetView.FORM) }

    var isNameError by remember { mutableStateOf(false) }
    val shakeOffset = remember { Animatable(0f) }
    val scope = rememberCoroutineScope()

    StandardStepLayout(topContent = {
        Text("Set up Categories", style = MaterialTheme.typography.headlineLarge)
    }, bottomContent = {
        Column(modifier = Modifier, horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                "Currently we have the following categories set up.\nFeel free to add your own",
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                modifier =
                    Modifier
                        .fillMaxWidth(0.75f)
                        .padding(bottom = 10.dp),
            )
            FlowRow(
                modifier =
                    Modifier
                        .fillMaxWidth(0.9f)
                        .border(
                            width = 1.dp,
                            color = MaterialTheme.colorScheme.secondary,
                            shape = RoundedCornerShape(12.dp),
                        )
                        .padding(12.dp),
                horizontalArrangement = Arrangement.spacedBy(2.dp),
                verticalArrangement = Arrangement.spacedBy(2.dp),
            ) {
                categories.forEach { item ->
                    CategoryItem(
                        color = item.color,
                        text = item.text,
                        icon = item.icon,
                        onClose = { onCategoryDelete(item) },
                    )
                }
            }
            Spacer(modifier = Modifier.padding(bottom = 10.dp))

            // Open Sheet Button
            IconButton(
                onClick = {
                    newCategoryName = ""
                    newCategoryDesc = ""
                    newCategoryIcon = Icons.Default.Add
                    newCategoryColor.value = Color(0XFF0000FF)
                    isNameError = false
                    currentView = SheetView.FORM // Reset to form
                    showBottomSheet = true
                },
                modifier =
                    Modifier
                        .fillMaxWidth(0.5f)
                        .background(
                            color = MaterialTheme.colorScheme.primary,
                            shape = RoundedCornerShape(100),
                        ),
            ) {
                Icon(
                    Icons.Default.Add,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimary,
                )
            }

            if (showBottomSheet) {
                ModalBottomSheet(
                    onDismissRequest = { showBottomSheet = false },
                    sheetState = sheetState,
                    containerColor = MaterialTheme.colorScheme.surface,
                ) {
                    // Main Container
                    Column(
                        modifier =
                            Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 24.dp)
                                .padding(bottom = 24.dp)
                                .navigationBarsPadding()
                                .imePadding(),
                        // REMOVED .animateContentSize() here to prevent conflict
                    ) {
                        // Dynamic Title
                        Text(
                            text =
                                when (currentView) {
                                    SheetView.ICON_PICKER -> "Select Icon"
                                    SheetView.COLOR_PICKER -> "Select Color"
                                    SheetView.FORM -> "New Category"
                                },
                            style = MaterialTheme.typography.headlineSmall,
                            modifier =
                                Modifier
                                    .align(Alignment.CenterHorizontally)
                                    .padding(bottom = 24.dp),
                        )

                        // Animated Content Switcher
                        AnimatedContent(
                            targetState = currentView,
                            label = "SheetContentAnimation",
                            contentAlignment = Alignment.TopCenter, // Anchors content to top during resize
                            transitionSpec = {
                                val animationDuration = 300
                                val slideSpec = tween<IntOffset>(animationDuration)
                                val fadeSpec = tween<Float>(animationDuration)
                                val sizeSpec = tween<IntSize>(animationDuration)

                                if (targetState != SheetView.FORM) {
                                    // Opening a picker: Slide in from Right
                                    (
                                        slideInHorizontally(slideSpec) { width -> width } +
                                            fadeIn(
                                                fadeSpec,
                                            )
                                    ).togetherWith(
                                        slideOutHorizontally(slideSpec) { width -> -width } +
                                            fadeOut(
                                                fadeSpec,
                                            ),
                                    )
                                } else {
                                    // Going back to Form: Slide in from Left
                                    (
                                        slideInHorizontally(slideSpec) { width -> -width } +
                                            fadeIn(
                                                fadeSpec,
                                            )
                                    ).togetherWith(
                                        slideOutHorizontally(slideSpec) { width -> width } +
                                            fadeOut(
                                                fadeSpec,
                                            ),
                                    )
                                }.using(
                                    // Synchronize the size animation with the slide using the same duration
                                    SizeTransform(
                                        clip = true,
                                        sizeAnimationSpec = { _, _ -> sizeSpec },
                                    ),
                                )
                            },
                        ) { viewState ->
                            Column(modifier = Modifier.fillMaxWidth()) {
                                when (viewState) {
                                    SheetView.ICON_PICKER -> {
                                        IconPicker(
                                            selectedIcon = newCategoryIcon,
                                            onIconSelect = { newCategoryIcon = it },
                                            modifier = Modifier.heightIn(max = 400.dp),
                                        )
                                        Row(
                                            modifier =
                                                Modifier
                                                    .fillMaxWidth()
                                                    .padding(top = 16.dp),
                                            horizontalArrangement = Arrangement.End,
                                        ) {
                                            Button(onClick = { currentView = SheetView.FORM }) {
                                                Text("Done")
                                            }
                                        }
                                    }

                                    SheetView.COLOR_PICKER -> {
                                        ColorPicker(
                                            modifier = Modifier.fillMaxWidth(),
                                            colorBoxPickerModifier =
                                                Modifier
                                                    .fillMaxWidth()
                                                    .aspectRatio(1f)
                                                    .border(1.dp, Color.Black),
                                            colorSliderModifier =
                                                Modifier
                                                    .fillMaxWidth()
                                                    .aspectRatio(10f)
                                                    .padding(top = 5.dp),
                                            colorBoxModifier =
                                                Modifier
                                                    .fillMaxWidth(0.2f)
                                                    .aspectRatio(1f)
                                                    .padding(top = 5.dp),
                                            onColorChange = { newCategoryColor.value = it },
                                        )
                                        Row(
                                            modifier =
                                                Modifier
                                                    .fillMaxWidth()
                                                    .padding(top = 16.dp),
                                            horizontalArrangement = Arrangement.End,
                                        ) {
                                            Button(onClick = { currentView = SheetView.FORM }) {
                                                Text("Done")
                                            }
                                        }
                                    }

                                    SheetView.FORM -> {
                                        // Icon Row
                                        Row(verticalAlignment = Alignment.CenterVertically) {
                                            Text("Icon", style = MaterialTheme.typography.bodyLarge)
                                            IconButton(onClick = {
                                                currentView = SheetView.ICON_PICKER
                                            }) {
                                                Icon(
                                                    imageVector = newCategoryIcon,
                                                    contentDescription = null,
                                                    modifier =
                                                        Modifier
                                                            .size(32.dp)
                                                            .background(
                                                                Color.Black.copy(alpha = 0.05f),
                                                                shape = RoundedCornerShape(8.dp),
                                                            )
                                                            .padding(4.dp),
                                                )
                                            }
                                        }

                                        // Name Input
                                        OutlinedTextField(
                                            value = newCategoryName,
                                            onValueChange = {
                                                newCategoryName = it
                                                if (isNameError) isNameError = false
                                            },
                                            label = { Text("Name") },
                                            singleLine = true,
                                            isError = isNameError,
                                            modifier =
                                                Modifier
                                                    .fillMaxWidth()
                                                    .offset {
                                                        IntOffset(
                                                            shakeOffset.value.roundToInt(),
                                                            0,
                                                        )
                                                    },
                                        )

                                        // Desc Input
                                        OutlinedTextField(
                                            modifier =
                                                Modifier
                                                    .fillMaxWidth()
                                                    .padding(top = 8.dp, bottom = 10.dp),
                                            value = newCategoryDesc,
                                            onValueChange = { newCategoryDesc = it },
                                            label = { Text("Description") },
                                        )

                                        // Color Row
                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            modifier = Modifier.padding(top = 10.dp),
                                        ) {
                                            Text(
                                                "Color",
                                                style = MaterialTheme.typography.bodyLarge,
                                                modifier = Modifier.padding(end = 16.dp),
                                            )
                                            Box(
                                                modifier =
                                                    Modifier
                                                        .size(36.dp)
                                                        .background(
                                                            color = newCategoryColor.value,
                                                            shape = RoundedCornerShape(8.dp),
                                                        )
                                                        .border(
                                                            1.dp,
                                                            MaterialTheme.colorScheme.onSurface,
                                                            RoundedCornerShape(8.dp),
                                                        )
                                                        .clickable {
                                                            currentView = SheetView.COLOR_PICKER
                                                        },
                                            )
                                        }

                                        // Action Buttons
                                        Row(
                                            modifier =
                                                Modifier
                                                    .fillMaxWidth()
                                                    .padding(top = 32.dp),
                                            horizontalArrangement = Arrangement.End,
                                        ) {
                                            TextButton(onClick = { showBottomSheet = false }) {
                                                Text("Cancel")
                                            }
                                            Spacer(modifier = Modifier.width(8.dp))
                                            Button(
                                                onClick = {
                                                    if (newCategoryName.isBlank()) {
                                                        isNameError = true
                                                        scope.launch {
                                                            shakeOffset.animateTo(0f, tween(50))
                                                            repeat(3) {
                                                                shakeOffset.animateTo(
                                                                    15f,
                                                                    tween(50),
                                                                )
                                                                shakeOffset.animateTo(
                                                                    -15f,
                                                                    tween(50),
                                                                )
                                                            }
                                                            shakeOffset.animateTo(0f, tween(50))
                                                        }
                                                    } else {
                                                        showBottomSheet = false
                                                        onCategoryAdd(
                                                            CategoryData(
                                                                color = newCategoryColor.value,
                                                                text = newCategoryName,
                                                                icon = newCategoryIcon,
                                                                desc = newCategoryDesc,
                                                            ),
                                                        )
                                                    }
                                                },
                                            ) {
                                                Text("Save")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    })
}

@Composable
fun CategoryItem(
    color: Color,
    text: String,
    icon: ImageVector,
    onClose: () -> Unit,
) {
    Row(
        modifier =
            Modifier.background(
                color = color,
                shape = RoundedCornerShape(100),
            ),
    ) {
        IconButton(
            onClick = onClose,
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
                imageVector = Icons.Default.Close,
                contentDescription = null,
            )
        }
        Icon(
            modifier =
                Modifier
                    .align(Alignment.CenterVertically)
                    .size(18.dp),
            imageVector = icon,
            contentDescription = null,
        )
        Text(
            text,
            modifier =
                Modifier
                    .padding(top = 5.dp, bottom = 5.dp, start = 2.dp, end = 10.dp)
                    .align(Alignment.CenterVertically),
        )
    }
}

data class CategoryData(
    val color: Color,
    val text: String,
    val icon: ImageVector,
    val desc: String,
)

@Preview(showBackground = true)
@Composable
fun Preview() {
    UpenceTheme {
        StartPage(
            onSetupFinished = {},
            categoryDao = TODO(),
            bankAccountsDao = TODO(),
        )
    }
}
