package com.upence.ui.settings

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.upence.data.Tags
import com.upence.ui.components.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TagsManagementPage(
    tagsDao: com.upence.data.TagsDao,
    navController: NavController,
) {
    val scope = rememberCoroutineScope()
    val tags by tagsDao.getAllTags().collectAsState(initial = emptyList())

    var showAddDialog by remember { mutableStateOf(false) }
    var showSimpleConfirmDialog by remember { mutableStateOf<Tags?>(null) }

    if (showAddDialog) {
        AddEditTagDialog(
            tag = null,
            onDismiss = { showAddDialog = false },
            onSave = { name, color ->
                scope.launch {
                    withContext(Dispatchers.IO) {
                        tagsDao.insertTag(
                            Tags(
                                id = System.currentTimeMillis().toInt(),
                                name = name,
                                color = color,
                            ),
                        )
                    }
                    showAddDialog = false
                }
            },
            allTags = tags,
        )
    }

    if (showSimpleConfirmDialog != null) {
        val tag = showSimpleConfirmDialog!!
        ConfirmDeleteDialog(
            onDismiss = { showSimpleConfirmDialog = null },
            onConfirm = {
                scope.launch {
                    tagsDao.deleteTag(tag.id)
                    showSimpleConfirmDialog = null
                }
            },
            itemText = "Tag",
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Manage Tags") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { showAddDialog = true }) {
                Icon(Icons.Default.Add, contentDescription = "Add Tag")
            }
        },
    ) { paddingValues ->
        if (tags.isEmpty()) {
            Box(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                contentAlignment = Alignment.Center,
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "No tags yet",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "Tap the + button to add your first tag",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        } else {
            LazyColumn(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(paddingValues)
                        .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                items(tags) { tag ->
                    TagItem(
                        tag = tag,
                        onEdit = {
                        },
                        onDelete = {
                            scope.launch {
                                showSimpleConfirmDialog = tag
                            }
                        },
                    )
                }
            }
        }
    }
}

@Composable
fun TagItem(
    tag: Tags,
    onEdit: () -> Unit,
    onDelete: () -> Unit,
) {
    var showMenu by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
    ) {
        Row(
            modifier =
                Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier =
                    Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(Color(android.graphics.Color.parseColor(tag.color))),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    tag.name.first().uppercase(),
                    style = MaterialTheme.typography.titleLarge,
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            Text(
                tag.name,
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.weight(1f),
            )

            MenuButton(showMenu = showMenu, onDismiss = { showMenu = false }, onEdit = onEdit, onDelete = onDelete)
        }
    }
}

@Composable
fun AddEditTagDialog(
    tag: Tags?,
    onDismiss: () -> Unit,
    onSave: (String, String) -> Unit,
    allTags: List<Tags>,
) {
    var name by remember { mutableStateOf(tag?.name ?: "") }
    var color by remember { mutableStateOf(tag?.color ?: "#4361EE") }

    val colors =
        listOf(
            "#4361EE",
            "#06D6A0",
            "#EF476F",
            "#FFD166",
            "#118AB2",
            "#9D4EDD",
            "#8F78FA",
            "#FF9E45",
            "#FF6B6B",
            "#4ECDC4",
            "#FFE66D",
            "#1A535C",
        )

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (tag == null) "Add Tag" else "Edit Tag") },
        text = {
            Column(
                modifier =
                    Modifier
                        .fillMaxWidth()
                        .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Name") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )

                Text("Color", style = MaterialTheme.typography.labelMedium)
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    colors.forEach { colorHex ->
                        val colorVal = Color(android.graphics.Color.parseColor(colorHex))
                        Surface(
                            onClick = { color = colorHex },
                            shape = CircleShape,
                            color = colorVal,
                            border =
                                if (color == colorHex) {
                                    BorderStroke(2.dp, MaterialTheme.colorScheme.primary)
                                } else {
                                    null
                                },
                            modifier = Modifier.size(40.dp),
                        ) {}
                    }
                }
            }
        },
        confirmButton = {
            Button(
                onClick = { onSave(name, color) },
                enabled = name.isNotBlank() && !allTags.any { it.name.equals(name, ignoreCase = true) && it.id != tag?.id },
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
    )
}
