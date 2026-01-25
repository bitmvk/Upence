package com.upence.ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Analytics
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NavigationSidebar(
    isOpen: Boolean,
    onClose: () -> Unit,
    currentRoute: String,
    modifier: Modifier = Modifier,
    navController: NavController,
) {
    var pendingNavigation by remember { mutableStateOf<String?>(null) }

    val screenWidth = with(LocalDensity.current) { 400.dp.toPx() }
    val sidebarWidth = screenWidth * 0.7f

    val offset by animateFloatAsState(
        targetValue = if (isOpen) 0f else -sidebarWidth,
        animationSpec = androidx.compose.animation.core.tween(durationMillis = 200),
        label = "sidebarOffset",
        finishedListener = { if (!isOpen && pendingNavigation != null) {
            pendingNavigation?.let { route ->
                navController.navigate(route) {
                    popUpTo("home") {
                        saveState = true
                    }
                    launchSingleTop = true
                    restoreState = true
                }
                pendingNavigation = null
            }
        } },
    )

    val backdropAlpha by animateFloatAsState(
        targetValue = if (isOpen) 0.5f else 0f,
        animationSpec = androidx.compose.animation.core.tween(durationMillis = 200),
        label = "backdropAlpha",
    )

    data class NavItem(
        val label: String,
        val icon: ImageVector,
        val route: String,
    )

    val navItems =
        listOf(
            NavItem("Home", Icons.Default.Home, "home"),
            NavItem("Analytics", Icons.Default.Analytics, "analytics"),
            NavItem("Settings", Icons.Default.Settings, "settings"),
        )

    Box(modifier = modifier.fillMaxSize()) {
        if (isOpen) {
            Box(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .background(MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f * backdropAlpha))
                        .clickable(onClick = onClose),
            )
        }

        Surface(
            modifier =
                Modifier
                    .offset { IntOffset(offset.roundToInt(), 0) }
                    .fillMaxHeight()
                    .width(with(LocalDensity.current) { sidebarWidth.toDp() }),
            color = MaterialTheme.colorScheme.surface,
            tonalElevation = 2.dp,
        ) {
            Column(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(16.dp)
                        .padding(top = WindowInsets.statusBars.asPaddingValues().calculateTopPadding()),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Start,
                ) {
                    IconButton(onClick = onClose) {
                        Icon(Icons.Default.Close, contentDescription = "Close")
                    }
                }

                HorizontalDivider()

                navItems.forEach { item ->
                    NavigationDrawerItem(
                        label = { Text(item.label) },
                        icon = { Icon(item.icon, contentDescription = item.label) },
                        selected = currentRoute == item.route,
                        onClick = {
                            pendingNavigation = item.route
                            onClose()
                        },
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            }
        }
    }
}
