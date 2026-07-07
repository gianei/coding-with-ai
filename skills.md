# Skills & Resources

A curated list of repositories, resources, and custom skills for AI coding assistants (e.g., Claude Code, Antigravity, etc.).

## Kotlin & Android

### 🛠️ [chrisbanes/skills](https://github.com/chrisbanes/skills)
A collection of high-quality, focused skills for Kotlin, Jetpack Compose, and Android development.

*   **Key Focus Areas:**
    *   **Compose State Management:** Authoring Compose local mutable state (`compose-state-authoring`), state hoisting patterns (`compose-state-hoisting`), and splitting state holder wiring from UI for testing and previews (`compose-state-holder-ui-split`).
    *   **Compose Side Effects:** Choosing and keying Compose effect APIs for Flows, callbacks, navigation, and cleanup (`compose-side-effects`).
    *   **Compose Performance:** Recomposition performance, stability, deferred reads, and cross-recomposition optimizations (`compose-recomposition-performance`).
    *   **Kotlin Coroutines & Flow:** Structuring structured concurrency, and modeling Flows for state/event propagation (`kotlin-flow-state-event-modeling`, `kotlin-coroutines-structured-concurrency`).
*   **Installation / Usage:**
    *   Via Skills CLI: `npx skills add chrisbanes/skills`
    *   Via Claude Code plugin: `/plugin marketplace add chrisbanes/skills`

### 🤖 [android/skills](https://github.com/android/skills)
The official Google repository of AI-optimized, modular instructions and resources following the open-standard agent skills to help LLMs understand and execute patterns matching the official guidance on Android development.

*   **Key Focus Areas:**
    *   **AGP Upgrade:** Upgrading to Android Gradle Plugin 9 (`build/agp/agp-9-upgrade`).
    *   **CameraX:** CameraX API integrations (`camera/camerax`).
    *   **Device AI:** Implementing AppFunctions for local device AI (`device-ai/appfunctions`).
    *   **Identity:** Verified email patterns (`identity/verified-email`).
    *   **Jetpack Compose:** Compose-related optimizations.
    *   **Navigation:** Navigation 3 guidelines (`navigation/navigation-3`).
    *   **Performance:** R8 optimization and analyzer (`performance/r8-analyzer`).
    *   **System UI & Edge-to-Edge:** Edge-to-edge system setup (`system/edge-to-edge`).
    *   **Testing:** Modular testing and test setup (`testing/testing-setup`).
    *   **Wear OS & XR:** Wear Compose M3 (`wear/wear-compose-m3`) and XR display glasses (`xr/display-glasses-with-jetpack-compose-glimmer`).
*   **Installation / Usage:**
    *   Via Android CLI (installs a specific skill): `android skills add --skill=r8-analyzer --project=.`
    *   Add all skills: `android skills add --all`

