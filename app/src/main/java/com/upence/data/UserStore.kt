package com.upence.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

// Create the DataStore
val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

class UserStore(private val context: Context) {
    // Define the keys
    companion object {
        val IS_SETUP_COMPLETE = booleanPreferencesKey("is_setup_complete")
        val THEME_MODE = intPreferencesKey("theme_mode")
        val CURRENCY_CODE = stringPreferencesKey("currency_code")
        val CURRENCY_SYMBOL = stringPreferencesKey("currency_symbol")
        val USE_CUSTOM_CURRENCY = booleanPreferencesKey("use_custom_currency")
        val USE_INDIA_SENDER_RULESET = booleanPreferencesKey("use_india_sender_ruleset")
    }

    // Get the flow (stream) of data
    val isSetupComplete: Flow<Boolean> =
        context.dataStore.data
            .map { preferences ->
                preferences[IS_SETUP_COMPLETE] ?: false // Default to false
            }

    // Function to save the completion state
    suspend fun setSetupComplete(isComplete: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[IS_SETUP_COMPLETE] = isComplete
        }
    }

    // Theme mode preferences (0 = Light, 1 = Dark, 2 = System)
    val themeMode: Flow<Int> =
        context.dataStore.data
            .map { preferences ->
                preferences[THEME_MODE] ?: 2 // Default to System
            }

    suspend fun setThemeMode(mode: Int) {
        context.dataStore.edit { preferences ->
            preferences[THEME_MODE] = mode
        }
    }

    // Currency preferences
    val currencyCode: Flow<String> =
        context.dataStore.data
            .map { preferences ->
                preferences[CURRENCY_CODE] ?: "INR" // Default to INR
            }

    suspend fun setCurrencyCode(code: String) {
        context.dataStore.edit { preferences ->
            preferences[CURRENCY_CODE] = code
        }
    }

    val currencySymbol: Flow<String> =
        context.dataStore.data
            .map { preferences ->
                preferences[CURRENCY_SYMBOL] ?: "₹" // Default to ₹
            }

    suspend fun setCurrencySymbol(symbol: String) {
        context.dataStore.edit { preferences ->
            preferences[CURRENCY_SYMBOL] = symbol
        }
    }

    val useCustomCurrency: Flow<Boolean> =
        context.dataStore.data
            .map { preferences ->
                preferences[USE_CUSTOM_CURRENCY] ?: false // Default to false
            }

    suspend fun setUseCustomCurrency(use: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[USE_CUSTOM_CURRENCY] = use
        }
    }

    val useIndiaSenderRuleset: Flow<Boolean> =
        context.dataStore.data
            .map { preferences ->
                preferences[USE_INDIA_SENDER_RULESET] ?: true // Default to ENABLED
            }

    suspend fun setUseIndiaSenderRuleset(use: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[USE_INDIA_SENDER_RULESET] = use
        }
    }
}
