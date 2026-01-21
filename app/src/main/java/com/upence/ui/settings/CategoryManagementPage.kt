package com.upence.ui.settings

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toColorLong
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.upence.data.Categories
import com.upence.ui.component.IconPicker
import com.upence.ui.components.*
import com.upence.util.IconUtils.getIconByName
import kotlinx.coroutines.launch
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import android.util.Log
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoryManagementPage(
    categoryDao: com.upence.data.CategoriesDao,
    transactionDao: com.upence.data.TransactionDao,
    navController: NavController
) {
    val scope = rememberCoroutineScope()
    val categories by categoryDao.getAllCategories().collectAsState(initial = emptyList())
    
    LaunchedEffect(categories.size) {
        Log.d("CategoryManagement", "Loaded ${categories.size} categories")
        Log.d("CategoryManagement", "Loaded $categories")
    }
    
    var showAddDialog by remember { mutableStateOf(false) }
    var showDeleteDialog by remember { mutableStateOf<Categories?>(null) }
    var showMigrationDialog by remember { mutableStateOf<Categories?>(null) }
    var showSimpleConfirmDialog by remember { mutableStateOf<Categories?>(null) }
    
    if (showAddDialog) {
        AddEditCategoryDialog(
            category = null,
            onDismiss = { 
                Log.d("CategoryManagement", "Dismissed add category dialog")
                showAddDialog = false 
            },
            onSave = { icon, name, color, description ->
                Log.d("CategoryManagement", "Saving new category: name=$name, icon=$icon, color=$color, description=$description")
                scope.launch {
                    withContext(Dispatchers.IO) {
                        val newCategory = Categories(
                            id = System.currentTimeMillis().toInt(),
                            icon = icon,
                            name = name,
                            color = color,
                            description = description
                        )
                        categoryDao.insertCategory(newCategory)
                        Log.d("CategoryManagement", "Successfully inserted category with ID: ${newCategory.id}")
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
            onDismiss = { 
                Log.d("CategoryManagement", "Dismissed migration dialog for category: ${categoryToDelete.name}")
                showMigrationDialog = null 
            },
            onConfirm = { migrateTo ->
                Log.d("CategoryManagement", "Migrating transactions from category: ${categoryToDelete.name} (ID: ${categoryToDelete.id})")
                scope.launch {
                    withContext(Dispatchers.IO) {
                        if (migrateTo == null) {
                            Log.d("CategoryManagement", "Migrating ${categoryToDelete.id} to uncategorized")
                            categoryDao.migrateCategoryTransactions(
                                categoryToDelete.id.toString(),
                                ""
                            )
                        } else if (migrateTo is Categories) {
                            Log.d("CategoryManagement", "Migrating ${categoryToDelete.id} to category: ${migrateTo.name} (ID: ${migrateTo.id})")
                            categoryDao.migrateCategoryTransactions(
                                categoryToDelete.id.toString(),
                                migrateTo.id.toString()
                            )
                        }
                        Log.d("CategoryManagement", "Deleting category: ${categoryToDelete.name} (ID: ${categoryToDelete.id})")
                        categoryDao.deleteCategory(categoryToDelete)
                        Log.d("CategoryManagement", "Successfully deleted category: ${categoryToDelete.name}")
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
            onDismiss = { 
                Log.d("CategoryManagement", "Dismissed delete confirm dialog for category: ${category.name}")
                showSimpleConfirmDialog = null 
            },
            onConfirm = {
                Log.d("CategoryManagement", "Deleting category without transactions: ${category.name} (ID: ${category.id})")
                scope.launch {
                    categoryDao.deleteCategory(category)
                    Log.d("CategoryManagement", "Successfully deleted category: ${category.name}")
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
                            Log.d("CategoryManagement", "Edit clicked for category: ${category.name} (ID: ${category.id})")
                        },
                        onDelete = {
                            scope.launch {
                                val count = categoryDao.getTransactionCount(category.id.toString())
                                Log.d("CategoryManagement", "Delete clicked for category: ${category.name} (ID: ${category.id}), transaction count: $count")
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
                Icon(getIconByName(category.icon), contentDescription = "")
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

private enum class DialogView { FORM, ICON_PICKER }

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
    var currentView by remember { mutableStateOf(DialogView.FORM) }
    
    var selectedIcon by remember { mutableStateOf<ImageVector?>(null) }
    
    LaunchedEffect(category?.icon) {
        category?.icon?.let { iconName ->
            selectedIcon = getIconByName(iconName)
            Log.d("CategoryManagement", "Loaded existing icon for category ${category?.name}: $iconName")
        }
    }

    AlertDialog(
        onDismissRequest = { 
            Log.d("CategoryManagement", "Dialog dismissed for category: $name")
            onDismiss() 
        },
        title = { 
            Text(
                text = when (currentView) {
                    DialogView.ICON_PICKER -> "Select Icon"
                    DialogView.FORM -> if (category == null) "Add Category" else "Edit Category"
                }
            )
        },
        text = {
            AnimatedContent(
                targetState = currentView,
                label = "DialogContentAnimation",
                contentAlignment = Alignment.TopCenter,
                transitionSpec = {
                    val animationDuration = 300
                    val slideSpec = androidx.compose.animation.core.tween<IntOffset>(animationDuration)
                    val fadeSpec = androidx.compose.animation.core.tween<Float>(animationDuration)
                    val sizeSpec = androidx.compose.animation.core.tween<IntSize>(animationDuration)

                    if (targetState != DialogView.FORM) {
                        (slideInHorizontally(slideSpec) { width -> width } + fadeIn(fadeSpec))
                            .togetherWith(
                                slideOutHorizontally(slideSpec) { width -> -width } + fadeOut(fadeSpec)
                            )
                    } else {
                        (slideInHorizontally(slideSpec) { width -> -width } + fadeIn(fadeSpec))
                            .togetherWith(
                                slideOutHorizontally(slideSpec) { width -> width } + fadeOut(fadeSpec)
                            )
                    }.using(
                        SizeTransform(
                            clip = true,
                            sizeAnimationSpec = { _, _ -> sizeSpec }
                        )
                    )
                }
            ) { viewState ->
                Column(modifier = Modifier.fillMaxWidth()) {
                    when (viewState) {
                        DialogView.ICON_PICKER -> {
                            IconPicker(
                                selectedIcon = selectedIcon,
                                onIconSelect = { 
                                    Log.d("CategoryManagement", "Icon selected: ${it.name}")
                                    selectedIcon = it 
                                },
                                modifier = Modifier.heightIn(max = 400.dp)
                            )
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(top = 16.dp),
                                horizontalArrangement = Arrangement.End
                            ) {
                                Button(onClick = { 
                                    Log.d("CategoryManagement", "Closing icon picker, selected icon: ${selectedIcon?.name}")
                                    currentView = DialogView.FORM 
                                }) {
                                    Text("Done")
                                }
                            }
                        }
                        DialogView.FORM -> {
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
                                IconButton(onClick = { 
                                    Log.d("CategoryManagement", "Opening icon picker for category: $name")
                                    currentView = DialogView.ICON_PICKER 
                                }) {
                                    Box(
                                        modifier = Modifier
                                            .size(40.dp)
                                            .background(
                                                Color.Black.copy(alpha = 0.05f),
                                                shape = RoundedCornerShape(8.dp)
                                            ),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        if (selectedIcon != null) {
                                            Icon(
                                                imageVector = selectedIcon!!,
                                                contentDescription = null,
                                                tint = MaterialTheme.colorScheme.onSurface
                                            )
                                        } else {
                                            Text("Select", style = MaterialTheme.typography.bodySmall)
                                        }
                                    }
                                }

                                Text("Color", style = MaterialTheme.typography.labelMedium)
                                Row(
                                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                                    modifier = Modifier.horizontalScroll(rememberScrollState())
                                ) {
                                    val colors = listOf(0xFF4361EE, 0xFF06D6A0, 0xFFEF476F, 0xFFFFD166, 0xFF118AB2, 0xFF9D4EDD, 0xFF8F78FA, 0xFFFF9E45)
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
                        }
                    }
                }
            }
        },
        confirmButton = {
            if (currentView == DialogView.FORM) {
                Button(
                    onClick = {
                        val iconName = selectedIcon?.name ?: Icons.Default.Add.name
                        Log.d("CategoryManagement", "Save clicked for category: name=$name, icon=$iconName, color=$color, description=$description")
                        onSave(iconName, name, color, description)
                    },
                    enabled = name.isNotBlank() && selectedIcon != null
                ) {
                    Text("Save")
                }
            }
        },
        dismissButton = {
            if (currentView == DialogView.FORM) {
                OutlinedButton(onClick = onDismiss) {
                    Text("Cancel")
                }
            }
        }
    )
}
