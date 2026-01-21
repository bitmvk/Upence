package com.upence.ui.component

import android.content.Context
import android.util.Log
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import dalvik.system.DexFile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Enumeration

// ============================================================================
// DATA MODELS
// ============================================================================

data class IconItem(
    val name: String,
    val image: ImageVector
)

data class IconPickerState(
    val displayedIcons: List<IconItem> = emptyList(),
    val isLoading: Boolean = true,
    val totalIconsLoaded: Int = 0
)

// ============================================================================
// VIEW MODEL
// ============================================================================

class IconPickerViewModel : ViewModel() {

    var state by mutableStateOf(IconPickerState())
        private set

    private var allIconsCache: List<IconItem> = emptyList()
    private var searchJob: Job? = null

    // Track selection and query internally to re-sort when needed
    private var currentSelection: ImageVector? = null
    private var lastQuery: String = ""

    /**
     * Scans application's Dex file to find all Filled icons.
     * Uses DexFile scanning to discover ALL icons at runtime.
     *
     * @param context Application context
     */
    @Suppress("DEPRECATION")
    fun loadIconsViaDexScan(context: Context) {
        viewModelScope.launch(Dispatchers.IO) {
            val icons = mutableListOf<IconItem>()
            val searchPackage = "androidx.compose.material.icons.filled"

            try {
                val dexFile = DexFile(context.packageCodePath)
                val entries: Enumeration<String> = dexFile.entries()

                while (entries.hasMoreElements()) {
                    val className = entries.nextElement()
                    if (className.startsWith(searchPackage) && className.endsWith("Kt")) {
                        try {
                            val clazz = Class.forName(className)
                            clazz.methods.forEach { method ->
                                if (method.returnType == ImageVector::class.java &&
                                    method.parameterCount == 1
                                ) {
                                    val icon = method.invoke(null, Icons.Filled) as? ImageVector
                                    if (icon != null) {
                                        val name = method.name.removePrefix("get")
                                        icons.add(IconItem(name, icon))
                                    }
                                }
                            }
                        } catch (e: Throwable) {
                            // ignore
                        }
                    }
                }
                dexFile.close()
            } catch (e: Exception) {
                Log.e("IconPicker", "Dex scan failed", e)
            }

            val sortedIcons = icons.sortedBy { it.name }
            allIconsCache = sortedIcons

            // Delegate to updateSearch to handle initial display and selection sorting logic
            updateSearch("")
        }
    }

    fun updateSelection(icon: ImageVector?) {
        if (currentSelection != icon) {
            currentSelection = icon
            // Re-run search logic with current query to re-apply sorting
            updateSearch(lastQuery)
        }
    }

    fun updateSearch(query: String) {
        lastQuery = query
        searchJob?.cancel()
        searchJob = viewModelScope.launch(Dispatchers.Default) {
            if (query.isNotEmpty()) delay(300)

            // 1. Filter based on text
            val filtered = if (query.isBlank()) {
                allIconsCache
            } else {
                allIconsCache.filter {
                    it.name.contains(query, ignoreCase = true)
                }
            }

            // 2. If query is blank and we have a selection, move it to top
            val sortedList = if (query.isBlank() && currentSelection != null) {
                val selectedItem = allIconsCache.find { it.image == currentSelection }
                if (selectedItem != null) {
                    // Create a list with selected item first, followed by the rest
                    listOf(selectedItem) + filtered.filter { it.image != currentSelection }
                } else {
                    filtered
                }
            } else {
                filtered
            }

            // 3. Limit result size
            val limitedList = sortedList.take(50)

            withContext(Dispatchers.Main) {
                state = state.copy(
                    displayedIcons = limitedList,
                    isLoading = false,
                    totalIconsLoaded = allIconsCache.size
                )
            }
        }
    }
}

// ============================================================================
// CONTEXT PROVIDER
// ============================================================================

interface ContextProvider {
    fun getContext(): Context
}

// ============================================================================
// ICON PICKER COMPONENT
// ============================================================================

/**
 * Icon Picker - Select Material Design icons
 *
 * FEATURES:
 * =========
 * 1. Search: Real-time filtering with 300ms debounce
 * 2. All Filled Icons: Scans entire Compose icon library
 * 3. Selection Management: Selected icon moves to top of list
 * 4. Grid Display: Icons shown in scrollable FlowRow
 *
 * ICON DISCOVERY:
 * ==============
 * Uses DexFile scanning to discover ALL Filled icons at runtime.
 * This ensures:
 * - No curated list limitations
 * - All icons are available
 * - Future Compose icon updates are automatically included
 *
 * PERFORMANCE:
 * ===========
 * - Icons are cached in ViewModel
 * - Debounced search prevents excessive filtering
 * - Limited to 50 displayed icons for performance
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun IconPicker(
    selectedIcon: ImageVector?,
    onIconSelect: (ImageVector) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: IconPickerViewModel = viewModel()
) {
    val context = LocalContext.current
    val state = viewModel.state
    var searchQuery by remember { mutableStateOf("") }

    // Load icons on first composition
    LaunchedEffect(Unit) {
        viewModel.loadIconsViaDexScan(context)
    }

    // Sync: selected icon with ViewModel to handle sorting
    LaunchedEffect(selectedIcon) {
        viewModel.updateSelection(selectedIcon)
    }

    // Sync: search query with ViewModel
    LaunchedEffect(searchQuery) {
        viewModel.updateSearch(searchQuery)
    }

    // Sync the search query with ViewModel
    LaunchedEffect(searchQuery) {
        viewModel.updateSearch(searchQuery)
    }

    Column(
        modifier = modifier
            .padding(16.dp)
            .fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // 1. Search Bar
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { searchQuery = it },
            placeholder = { Text("Search icons...") },
            leadingIcon = {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = "Search"
                )
            },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )

        // 2. Icon Count
        if (state.totalIconsLoaded > 0) {
            Text(
                text = "${state.displayedIcons.size} of ${state.totalIconsLoaded} icons",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        // 3. Icon Grid Area
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState()),
            contentAlignment = Alignment.TopCenter
        ) {
            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
                verticalArrangement = Arrangement.spacedBy(8.dp),
                maxItemsInEachRow = Int.MAX_VALUE
            ) {
                state.displayedIcons.forEach { iconItem ->
                    val isSelected = iconItem.image == selectedIcon
                    SelectableIconItem(
                        iconItem = iconItem,
                        isSelected = isSelected,
                        onSelect = { onIconSelect(iconItem.image) }
                    )
                }

                if (state.displayedIcons.isEmpty() && !state.isLoading) {
                    Text(
                        text = "No icons found matching '$searchQuery'",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(16.dp)
                    )
                }
            }
        }
    }
}

// ============================================================================
// SELECTABLE ICON ITEM COMPONENT
// ============================================================================

@Composable
fun SelectableIconItem(
    iconItem: IconItem,
    isSelected: Boolean,
    onSelect: () -> Unit
) {
    Surface(
        onClick = onSelect,
        shape = RoundedCornerShape(12.dp),
        color = if (isSelected) {
            MaterialTheme.colorScheme.primaryContainer
        } else {
            MaterialTheme.colorScheme.surfaceVariant
        },
        border = if (isSelected) {
            BorderStroke(
                width = 2.dp,
                color = MaterialTheme.colorScheme.primary
            )
        } else {
            null
        },
        modifier = Modifier
            .size(48.dp)
            .clip(RoundedCornerShape(12.dp))
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = iconItem.image,
                contentDescription = iconItem.name,
                tint = if (isSelected) {
                    MaterialTheme.colorScheme.primary
                } else {
                    MaterialTheme.colorScheme.onSurfaceVariant
                }
            )
        }
    }
}

// ============================================================================
// PREVIEW
// ============================================================================

@Preview(showBackground = true)
@Composable
fun IconPickerPreview() {
    MaterialTheme {
        IconPicker(
            selectedIcon = null,
            onIconSelect = {}
        )
    }
}
