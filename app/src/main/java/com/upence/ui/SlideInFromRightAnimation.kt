package com.upence.ui

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay

@Composable
fun SlideInFromRightAnimation(
    key: Any? = null,
    content: @Composable () -> Unit,
) {
    var hasAnimated by remember { mutableStateOf(false) }

    LaunchedEffect(key) {
        if (!hasAnimated) {
            delay(50)
            hasAnimated = true
        }
    }

    val screenWidth = with(LocalDensity.current) { 400.dp }
    val slideOffset by animateDpAsState(
        targetValue = if (hasAnimated) 0.dp else screenWidth,
        animationSpec = tween(durationMillis = 300),
        label = "slideOffset",
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .offset { IntOffset(slideOffset.roundToPx(), 0) },
    ) {
        content()
    }
}
