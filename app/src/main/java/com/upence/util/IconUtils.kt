package com.upence.util

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.QuestionMark
import androidx.compose.ui.graphics.vector.ImageVector

// ============================================================================
// ICON UTILS - SIMPLIFIED FILLED ICON LOADER
// ============================================================================
// DESIGN DECISION:
// ===============
// This utility only supports Filled icons to match IconPicker behavior.
// Other icon styles (Outlined, Rounded, Sharp, TwoTone) are intentionally
// not supported to maintain consistency and reduce complexity.
//
// ICON NAME FORMATS:
// ==================
// Icons in database can be stored in two formats:
// 1. "Filled.Restaurant" - with style prefix (legacy)
// 2. "Restaurant" - without style prefix (new, preferred)
//
// Both formats are normalized by removing "Filled." prefix.
//
// PERFORMANCE:
// ===========
// Icons are cached after first load to avoid repeated reflection.
//
// ERROR HANDLING:
// ===============
// If icon loading fails (e.g., icon doesn't exist or ProGuard stripped it),
// falls back to QuestionMark icon to prevent crashes.
// ============================================================================
object IconUtils {

    private val iconCache = mutableMapOf<String, ImageVector>()

    /**
     * Load a Filled icon by its name.
     *
     * @param dbName Icon name from database
     * @return Filled ImageVector, or QuestionMark if not found
     */
    fun getIconByName(dbName: String): ImageVector {
        // Normalize: remove "Filled." prefix if present
        val normalizedName = dbName.removePrefix("Filled.")

        // Return cached if available
        if (iconCache.containsKey(normalizedName)) return iconCache[normalizedName]!!

        try {
            // Load icon class via reflection
            // Structure: androidx.compose.material.icons.filled.{Name}Kt
            val className = "androidx.compose.material.icons.filled.${normalizedName}Kt"
            val iconClass = Class.forName(className)

            // Get icon getter method
            val methodName = "get$normalizedName"
            val method = iconClass.getMethod(methodName, Icons.Filled::class.java)

            // Invoke method to get ImageVector
            val imageVector = method.invoke(null, Icons.Filled) as ImageVector

            // Cache and return
            iconCache[normalizedName] = imageVector
            return imageVector

        } catch (e: Exception) {
            // Fallback to QuestionMark icon if loading fails
            return Icons.Default.QuestionMark
        }
    }
}
