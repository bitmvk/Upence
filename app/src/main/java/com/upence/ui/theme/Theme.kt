package com.upence.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

enum class ThemeMode {
    LIGHT,
    DARK,
    SYSTEM,
}

@Composable
fun getThemeMode(mode: Int): ThemeMode {
    return when (mode) {
        0 -> ThemeMode.LIGHT
        1 -> ThemeMode.DARK
        2 -> ThemeMode.SYSTEM
        else -> ThemeMode.SYSTEM
    }
}

private val DarkColorScheme =
    darkColorScheme(
        primary = DarkPrimary,
        onPrimary = DarkText,
        secondary = DarkSecondary,
        onSecondary = DarkText,
        tertiary = DarkAccent,
        onTertiary = DarkText,
        background = DarkBackground,
        onBackground = DarkText,
        surface = DarkSurface,
        onSurface = DarkText,
        surfaceVariant = DarkSurfaceVariant,
        onSurfaceVariant = DarkText,
        error = DarkError,
        onError = DarkText,
    )

private val LightColorScheme =
    lightColorScheme(
        primary = LightPrimary,
        onPrimary = LightText,
        secondary = LightSecondary,
        onSecondary = LightText,
        tertiary = LightAccent,
        onTertiary = LightText,
        background = LightBackground,
        onBackground = LightText,
        surface = LightSurface,
        onSurface = LightText,
        surfaceVariant = LightSurfaceVariant,
        onSurfaceVariant = LightText,
        error = LightError,
        onError = LightText,
    )

@Composable
fun UpenceTheme(
    themeMode: Int = 2,
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit,
) {
    val actualThemeMode = getThemeMode(themeMode)
    val darkTheme =
        when (actualThemeMode) {
            ThemeMode.LIGHT -> false
            ThemeMode.DARK -> true
            ThemeMode.SYSTEM -> isSystemInDarkTheme()
        }

    val colorScheme =
        when {
            dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
                val context = LocalContext.current
                if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
            }

            darkTheme -> DarkColorScheme
            else -> LightColorScheme
        }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content,
    )
}
