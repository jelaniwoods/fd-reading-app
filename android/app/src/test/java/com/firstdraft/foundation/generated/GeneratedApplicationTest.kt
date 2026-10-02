package com.firstdraft.foundation.generated

import com.firstdraft.foundation.BuildConfig
import org.junit.Assert.assertEquals
import org.junit.Test

class GeneratedApplicationTest {
    @Test fun emittedIdentityAndNavigationMatchThePlan() {
        assertEquals("bdb2da3752ea1b8a7c9b1fe0ee80a4690302406c3e47729ebc332467439be74f", GeneratedApplication.foundationPlanSha256)
        assertEquals(BuildConfig.FOUNDATION_PLAN_SHA256, GeneratedApplication.foundationPlanSha256)
        assertEquals("invalid.firstdraft.reading_list", BuildConfig.APPLICATION_ID)
        assertEquals("https://reading-list.invalid", GeneratedApplication.railsOrigin)
        assertEquals(listOf("entity-index:01a0fd25-6b01-7bcb-979c-4c1ab9fe12a9"), GeneratedApplication.entries.map { it.id })
        assertEquals(listOf("/books"), GeneratedApplication.entries.map { it.path })
        assertEquals(1, GeneratedApplication.hostIds.size)
    }
}
