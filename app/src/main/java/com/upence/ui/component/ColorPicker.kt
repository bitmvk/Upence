package com.upence.ui.component

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ComposeShader
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.RectF
import android.graphics.Shader
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.PressInteraction
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.core.graphics.createBitmap
import androidx.core.graphics.toRect
import kotlinx.coroutines.launch
import android.graphics.Color as AndroidColor

@Composable
fun ColorPicker(
    modifier: Modifier,
    colorBoxPickerModifier: Modifier,
    colorSliderModifier: Modifier,
    colorBoxModifier: Modifier,
    onColorChange: (Color) -> Unit,
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        val hsv =
            remember {
                val hsv = floatArrayOf(0f, 0f, 0f)
                AndroidColor.colorToHSV(Color.Blue.toArgb(), hsv)

                mutableStateOf(
                    Triple(hsv[0], hsv[1], hsv[2]),
                )
            }
        val backgroundColor =
            remember(hsv.value) {
                mutableStateOf(Color.hsv(hsv.value.first, hsv.value.second, hsv.value.third))
            }

        // 1. SatValPanel with explicit modifier for size
        SatValPanel(
            modifier = colorBoxPickerModifier,
            hue = hsv.value.first,
            sat = hsv.value.second,
            value = hsv.value.third,
        ) { sat, value ->
            hsv.value = Triple(hsv.value.first, sat, value)
            onColorChange(Color.hsv(hsv.value.first, sat, value))
        }
        // 2. HueBar with explicit modifier for size and shape
        HueBar(
            modifier = colorSliderModifier,
            hue = hsv.value.first,
        ) { hue ->
            hsv.value = Triple(hue, hsv.value.second, hsv.value.third)
        }

        Box(
            modifier =
                colorBoxModifier
                    .background(backgroundColor.value),
        )
    }
}

@Composable
fun HueBar(
    modifier: Modifier = Modifier,
    hue: Float,
    setColor: (Float) -> Unit,
) {
    val interactionSource = remember { MutableInteractionSource() }
    var barSize by remember { mutableStateOf(IntSize.Zero) }

    LaunchedEffect(interactionSource) {
        interactionSource.interactions.collect { interaction ->
            (interaction as? PressInteraction.Press)?.pressPosition?.let { pos ->
                val width = barSize.width.toFloat()
                if (width > 0) {
                    val clampedX = pos.x.coerceIn(0f, width)
                    val selectedHue = (clampedX / width) * 360f
                    setColor(selectedHue)
                }
            }
        }
    }

    Canvas(
        modifier =
            modifier
                .onSizeChanged { barSize = it }
                .emitDragGesture(interactionSource),
    ) {
        // Ensure we have a valid size before creating the bitmap
        if (size.width <= 0 || size.height <= 0) return@Canvas

        val bitmap = createBitmap(size.width.toInt(), size.height.toInt())
        val hueCanvas = Canvas(bitmap)

        val huePanel = RectF(0f, 0f, bitmap.width.toFloat(), bitmap.height.toFloat())

        val hueColors = IntArray((huePanel.width()).toInt())
        var currentHue = 0f
        for (i in hueColors.indices) {
            hueColors[i] = AndroidColor.HSVToColor(floatArrayOf(currentHue, 1f, 1f))
            currentHue += 360f / hueColors.size
        }

        val linePaint = Paint()
        linePaint.strokeWidth = 0F
        for (i in hueColors.indices) {
            linePaint.color = hueColors[i]
            hueCanvas.drawLine(i.toFloat(), 0F, i.toFloat(), huePanel.bottom, linePaint)
        }

        drawBitmap(
            bitmap = bitmap,
            panel = huePanel,
        )

        val positionX = (hue / 360f) * size.width

        drawLine(
            color = Color.White,
            start = Offset(positionX, 0f),
            end = Offset(positionX, size.height),
            strokeWidth = 10.dp.toPx(),
        )
    }
}

@Composable
fun SatValPanel(
    modifier: Modifier = Modifier,
    hue: Float,
    sat: Float,
    value: Float,
    setSatVal: (Float, Float) -> Unit,
) {
    val interactionSource = remember { MutableInteractionSource() }
    var panelSize by remember { mutableStateOf(IntSize.Zero) }

    LaunchedEffect(interactionSource) {
        interactionSource.interactions.collect { interaction ->
            (interaction as? PressInteraction.Press)?.pressPosition?.let { pos ->
                val width = panelSize.width.toFloat()
                val height = panelSize.height.toFloat()

                if (width > 0 && height > 0) {
                    val clampedX = pos.x.coerceIn(0f, width)
                    val clampedY = pos.y.coerceIn(0f, height)

                    val newSat = (clampedX / width)
                    val newValue = 1f - (clampedY / height)

                    setSatVal(newSat, newValue)
                }
            }
        }
    }

    Canvas(
        modifier =
            modifier
                .onSizeChanged { panelSize = it }
                .emitDragGesture(interactionSource),
    ) {
        if (size.width <= 0 || size.height <= 0) return@Canvas

        val bitmap = createBitmap(size.width.toInt(), size.height.toInt())
        val canvas = Canvas(bitmap)
        val satValPanel = RectF(0f, 0f, bitmap.width.toFloat(), bitmap.height.toFloat())

        val rgb = AndroidColor.HSVToColor(floatArrayOf(hue, 1f, 1f))

        val satShader =
            LinearGradient(
                satValPanel.left,
                satValPanel.top,
                satValPanel.right,
                satValPanel.top,
                -0x1,
                rgb,
                Shader.TileMode.CLAMP,
            )
        val valShader =
            LinearGradient(
                satValPanel.left,
                satValPanel.top,
                satValPanel.left,
                satValPanel.bottom,
                -0x1,
                -0x1000000,
                Shader.TileMode.CLAMP,
            )

        canvas.drawRect(
            satValPanel,
            Paint().apply {
                shader =
                    ComposeShader(
                        valShader,
                        satShader,
                        PorterDuff.Mode.MULTIPLY,
                    )
            },
        )

        drawBitmap(
            bitmap = bitmap,
            panel = satValPanel,
        )

        val positionX = sat * size.width
        val positionY = (1f - value) * size.height

        val pointOffset = Offset(positionX, positionY)

        drawCircle(
            color = Color.White,
            radius = 8.dp.toPx(),
            center = pointOffset,
            style =
                Stroke(
                    width = 2.dp.toPx(),
                ),
        )

        drawCircle(
            color = Color.White,
            radius = 2.dp.toPx(),
            center = pointOffset,
        )
    }
}

private fun Modifier.emitDragGesture(interactionSource: MutableInteractionSource): Modifier =
    composed {
        val scope = rememberCoroutineScope()

        pointerInput(Unit) {
            detectDragGestures { input, _ ->
                scope.launch {
                    interactionSource.emit(PressInteraction.Press(input.position))
                }
            }
        }.clickable(interactionSource, null) {
        }
    }

private fun DrawScope.drawBitmap(
    bitmap: Bitmap,
    panel: RectF,
) {
    drawIntoCanvas {
        it.nativeCanvas.drawBitmap(
            bitmap,
            null,
            panel.toRect(),
            null,
        )
    }
}

@Composable
@Preview
fun ColorPickerPreview() {
    ColorPicker(
        modifier = Modifier,
        colorBoxPickerModifier = Modifier.size(300.dp),
        colorSliderModifier =
            Modifier
                .height(40.dp)
                .width(300.dp)
                .clip(RoundedCornerShape(10.dp)),
        colorBoxModifier = Modifier.size(100.dp),
        onColorChange = {},
    )
}
