package com.upence.util

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.QuestionMark
import androidx.compose.ui.graphics.vector.ImageVector
import java.util.Locale

object IconUtils {

    private val iconCache = mutableMapOf<String, ImageVector>()

    /**
     * Dynamically loads an icon by its name (e.g., "Filled.Restaurant").
     * Works for both Core and Extended icons.
     */
    fun getIconByName(dbName: String): ImageVector {
        // 1. Return cached if available
        if (iconCache.containsKey(dbName)) return iconCache[dbName]!!

        // 2. Parse the name (e.g., "Filled.Restaurant" -> Style: "Filled", Name: "Restaurant")
        val parts = dbName.split(".")
        if (parts.size != 2) return Icons.Default.QuestionMark

        val style = parts[0] // "Filled", "Outlined", "Rounded", etc.
        val name = parts[1]  // "Restaurant", "AccountBox", etc.

        try {
            // 3. Construct the expected class path for Extended icons
            // Structure: androidx.compose.material.icons.<style>.<Name>Kt
            val packageStyle = style.lowercase(Locale.ROOT) // "filled"
            val className = "androidx.compose.material.icons.$packageStyle.${name}Kt"

            // 4. Load the Class
            val iconClass = Class.forName(className)

            // 5. Find the static getter method (e.g., getRestaurant)
            // The method usually requires the Theme Object (Icons.Filled) as a receiver
            val methodName = "get$name"
            val receiverObj = when (style) {
                "Filled" -> Icons.Filled
                "Outlined" -> Icons.Outlined
                "Rounded" -> Icons.Rounded
                "Sharp" -> Icons.Sharp
                "TwoTone" -> Icons.TwoTone
                else -> Icons.Filled
            }

            // 6. Invoke the method to get the ImageVector
            // Note: Extension properties in Kotlin compile to static methods accepting the receiver as the first arg.
            val method = iconClass.getMethod(methodName, receiverObj::class.java)
            val imageVector = method.invoke(null, receiverObj) as ImageVector

            // 7. Cache and return
            iconCache[dbName] = imageVector
            return imageVector

        } catch (e: Exception) {
            // Fallback: If reflection fails (e.g. icon doesn't exist or ProGuard stripped it), return QuestionMark
            e.printStackTrace()
            return Icons.Default.QuestionMark
        }
    }
}