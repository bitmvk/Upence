package com.upence.ui.settings

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.upence.data.Categories
import com.upence.ui.components.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoryManagementPage(
    categoryDao: com.upence.data.CategoriesDao,
    transactionDao: com.upence.data.TransactionDao,
    navController: NavController
) {
    val scope = rememberCoroutineScope()
    val categories by categoryDao.getAllCategories().collectAsState(initial = emptyList())
    
    var showAddDialog by remember { mutableStateOf(false) }
    var showDeleteDialog by remember { mutableStateOf<Categories?>(null) }
    var showMigrationDialog by remember { mutableStateOf<Categories?>(null) }
    var showSimpleConfirmDialog by remember { mutableStateOf<Categories?>(null) }
    
    if (showAddDialog) {
        AddEditCategoryDialog(
            category = null,
            onDismiss = { showAddDialog = false },
            onSave = { icon, name, color, description ->
                scope.launch {
                    withContext(Dispatchers.IO) {
                        categoryDao.insertCategory(
                            Categories(
                                id = System.currentTimeMillis().toInt(),
                                icon = icon,
                                name = name,
                                color = color,
                                description = description
                            )
                        )
                    }
                    showAddDialog = false
                }
            },
            allCategories = categories
        )
    }
    
    if (showDeleteDialog != null) {
        showMigrationDialog = showDeleteDialog
        showDeleteDialog = null
    }
    
    if (showMigrationDialog != null) {
        val categoryToDelete = showMigrationDialog!!
        MigrationDialog(
            onDismiss = { showMigrationDialog = null },
            onConfirm = { migrateTo ->
                scope.launch {
                    withContext(Dispatchers.IO) {
                        if (migrateTo == null) {
                            // Set to empty string (uncategorized)
                            categoryDao.migrateCategoryTransactions(
                                categoryToDelete.id.toString(),
                                ""
                            )
                        } else if (migrateTo is Categories) {
                            categoryDao.migrateCategoryTransactions(
                                categoryToDelete.id.toString(),
                                migrateTo.id.toString()
                            )
                        }
                        categoryDao.deleteCategory(categoryToDelete)
                    }
                    showMigrationDialog = null
                }
            },
            title = "Move transactions from ${categoryToDelete.name}",
            message = "This category has transactions. Please select another category to move them to:",
            options = categories.filter { it.id != categoryToDelete.id },
            getOptionLabel = { (it as Categories).name }
        )
    }
    
    if (showSimpleConfirmDialog != null) {
        val category = showSimpleConfirmDialog!!
        ConfirmDeleteDialog(
            onDismiss = { showSimpleConfirmDialog = null },
            onConfirm = {
                scope.launch {
                    categoryDao.deleteCategory(category)
                    showSimpleConfirmDialog = null
                }
            },
            itemText = "Category"
        )
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Manage Categories") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { showAddDialog = true }) {
                Icon(Icons.Default.Add, contentDescription = "Add Category")
            }
        }
    ) { paddingValues ->
        if (categories.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "No categories yet",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "Tap the + button to add your first category",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(categories) { category ->
                    CategoryItem(
                        category = category,
                        onEdit = { 
                            // For simplicity, we'll only handle delete in this version
                        },
                        onDelete = {
                            scope.launch {
                                val count = categoryDao.getTransactionCount(category.id.toString())
                                if (count > 0) {
                                    showMigrationDialog = category
                                } else {
                                    showSimpleConfirmDialog = category
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun CategoryItem(
    category: Categories,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    var showMenu by remember { mutableStateOf(false) }
    
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Icon
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(Color(category.color)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    category.icon,
                    style = MaterialTheme.typography.titleLarge
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            // Name
            Text(
                category.name,
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.weight(1f)
            )
            
            MenuButton(showMenu = showMenu, onDismiss = { showMenu = false }, onEdit = onEdit, onDelete = onDelete)
        }
    }
}

@Composable
fun MenuButton(
    showMenu: Boolean,
    onDismiss: () -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    var localMenu by remember { mutableStateOf(showMenu) }
    
    LaunchedEffect(showMenu) {
        localMenu = showMenu
    }
    
    Box {
        IconButton(onClick = { localMenu = !localMenu }) {
            Icon(Icons.Default.MoreVert, contentDescription = "Menu")
        }
        
        if (localMenu) {
            DropdownMenu(
                expanded = localMenu,
                onDismissRequest = { 
                    localMenu = false
                    onDismiss()
                }
            ) {
                DropdownMenuItem(
                    text = { Text("Edit") },
                    onClick = {
                        onEdit()
                        localMenu = false
                        onDismiss()
                    },
                    leadingIcon = { Icon(Icons.Default.Edit, null) }
                )
                DropdownMenuItem(
                    text = { 
                        Text("Delete", color = MaterialTheme.colorScheme.error)
                    },
                    onClick = {
                        onDelete()
                        localMenu = false
                        onDismiss()
                    },
                    leadingIcon = { 
                        Icon(Icons.Default.Delete, null, tint = MaterialTheme.colorScheme.error)
                    },
                    colors = MenuDefaults.itemColors(
                        textColor = MaterialTheme.colorScheme.error
                    )
                )
            }
        }
    }
}

@Composable
fun AddEditCategoryDialog(
    category: Categories?,
    onDismiss: () -> Unit,
    onSave: (String, String, Long, String) -> Unit,
    allCategories: List<Categories>
) {
    var name by remember { mutableStateOf(category?.name ?: "") }
    var color by remember { mutableStateOf(category?.color ?: 0xFF4361EE) }
    var description by remember { mutableStateOf(category?.description ?: "") }
    var selectedIcon by remember { mutableStateOf(category?.icon ?: "🍔") }
    
    val icons = listOf("🍔", "🚂", "👤", "🚗", "🛒", "💡", "🎬", "✈️", "📱", "💻", "🏠", "⚽", "🎮", "📚", "🎵", "🏥", "⛽")
    val colors = listOf(0xFF4361EE, 0xFF06D6A0, 0xFFEF476F, 0xFFFFD166, 0xFF118AB2, 0xFF9D4EDD, 0xFF8F78FA, 0xFFFF9E45)
    
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (category == null) "Add Category" else "Edit Category") },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Name") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )
                
                Text("Icon", style = MaterialTheme.typography.labelMedium)
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    icons.forEach { icon ->
                        FilterChip(
                            selected = selectedIcon == icon,
                            onClick = { selectedIcon = icon },
                            label = { Text(icon, style = MaterialTheme.typography.titleLarge) },
                            modifier = Modifier.size(48.dp)
                        )
                    }
                }
                
                Text("Color", style = MaterialTheme.typography.labelMedium)
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    colors.forEach { col ->
                        val colorVal = Color(col)
                        Surface(
                            onClick = { color = col },
                            shape = CircleShape,
                            color = colorVal,
                            border = if (color == col) {
                                BorderStroke(2.dp, MaterialTheme.colorScheme.primary)
                            } else null,
                            modifier = Modifier.size(40.dp)
                        ) {}
                    }
                }
                
                OutlinedTextField(
                    value = description,
                    onValueChange = { description = it },
                    label = { Text("Description (optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )
            }
        },
        confirmButton = {
            Button(
                onClick = { onSave(selectedIcon, name, color, description) },
                enabled = name.isNotBlank()
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            OutlinedButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
