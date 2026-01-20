package com.upence.ui.component

import android.app.Application
import android.util.Log
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
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
import androidx.compose.ui.text.style.LineHeightStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import dalvik.system.DexFile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Enumeration

// --- Data Models ---

data class IconItem(
    val name: String,
    val image: ImageVector
)

data class IconPickerState(
    val displayedIcons: List<IconItem> = emptyList(),
    val isLoading: Boolean = true,
    val totalIconsLoaded: Int = 0,
    val loadingStatus: String = "Initializing..."
)

// --- ViewModel ---

class IconPickerViewModel(application: Application) : AndroidViewModel(application) {

    var state by mutableStateOf(IconPickerState())
        private set

    private var allIconsCache: List<IconItem> = emptyList()
    private var searchJob: Job? = null

    // Track selection and query internally to re-sort when needed
    private var currentSelection: ImageVector? = null
    private var lastQuery: String = ""

    init {
        loadIconsViaDexScan()
    }

    fun updateSelection(icon: ImageVector?) {
        if (currentSelection != icon) {
            currentSelection = icon
            // Re-run the search logic with the current query to re-apply sorting
            updateSearch(lastQuery)
        }
    }

    /**
     * Scans the application's Dex file to find all classes in the material icons package.
     */
    @Suppress("DEPRECATION")
    private fun loadIconsViaDexScan() {
        val context = getApplication<Application>()

        viewModelScope.launch(Dispatchers.IO) {
            val icons = mutableListOf<IconItem>()
            val searchPackage = "androidx.compose.material.icons.filled"

            withContext(Dispatchers.Main) {
                state = state.copy(loadingStatus = "Scanning app code...")
            }

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

            // 2. If query is blank and we have a selection, move it to the top
            val sortedList = if (query.isBlank() && currentSelection != null) {
                val selectedItem = allIconsCache.find { it.image == currentSelection }
                if (selectedItem != null) {
                    // Create a list with the selected item first, followed by the rest (excluding the selected one)
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
                    totalIconsLoaded = allIconsCache.size,
                    loadingStatus = "Loaded"
                )
            }
        }
    }
}

// --- Composable ---

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun IconPicker(
    selectedIcon: ImageVector?,
    onIconSelect: (ImageVector) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: IconPickerViewModel = viewModel()
) {
    val state = viewModel.state
    var searchQuery by remember { mutableStateOf("") }

    // Sync the selected icon to the ViewModel to handle sorting
    LaunchedEffect(selectedIcon) {
        viewModel.updateSelection(selectedIcon)
    }

    Column(
        modifier = modifier
            .padding(16.dp)
            .fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 1. Search Bar
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 8.dp)
        ) {
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { query ->
                    searchQuery = query
                    viewModel.updateSearch(query)
                },
                label = { Text("Search Icon") },
                placeholder = { Text("Type to search...") },
                leadingIcon = { Icon(Icons.Filled.Search, contentDescription = "Search") },
                modifier = Modifier
                    .fillMaxWidth(),
                singleLine = true,
                enabled = !state.isLoading,
            )
        }

        // 2. Icon Grid Area
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState()),
            contentAlignment = Alignment.TopCenter
        ) {
            if (state.isLoading) {
                CircularProgressIndicator(modifier = Modifier.padding(16.dp))
            } else {
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
}

@Composable
private fun SelectableIconItem(
    iconItem: IconItem,
    isSelected: Boolean,
    onSelect: () -> Unit
) {
    val backgroundColor = if (isSelected) {
        MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
    } else {
        MaterialTheme.colorScheme.surfaceVariant
    }

    val borderColor = if (isSelected) {
        MaterialTheme.colorScheme.primary
    } else {
        Color.Transparent
    }

    val contentColor = if (isSelected) {
        MaterialTheme.colorScheme.onPrimaryContainer
    } else {
        MaterialTheme.colorScheme.onSurfaceVariant
    }

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.width(64.dp)
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(56.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(backgroundColor)
                .border(2.dp, borderColor, RoundedCornerShape(12.dp))
                .clickable(onClick = onSelect)
        ) {
            Icon(
                imageVector = iconItem.image,
                contentDescription = iconItem.name,
                tint = contentColor,
                modifier = Modifier.size(24.dp)
            )
        }
        Text(
            text = iconItem.name,
            style = MaterialTheme.typography.labelSmall,
            maxLines = 1,
            modifier = Modifier.padding(top = 4.dp),
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}

@Preview(showBackground = true)
@Composable
fun IconPickerPreview() {
    var currentIcon by remember { mutableStateOf<ImageVector?>(null) }

    Column(modifier = Modifier.fillMaxSize()) {
        IconPicker(
            selectedIcon = currentIcon,
            modifier = Modifier.height(400.dp),
            onIconSelect = { newIcon ->
                currentIcon = newIcon
            }
        )
    }
}