# Nexus Vault Addon Overview

Nexus Vault is a high-performance inventory, gear, and appearance management suite for custom 3.3.5a servers. It relies on the injected `:Omagad("...")` bypass wrapper to automate traditionally manual tasks without confirmation dialogs.

## Core Goals
- Provide a single control surface (`/nv` command and minimap button) to toggle automation features on or off.
- Deliver stat-weighted gear evaluation and auto-equip to keep the best items equipped per specialization.
- Automate transmog appearance learning while restoring the optimal gear set afterward.
- Streamline bag cleanup through rule-driven selling and destruction.

## Functional Areas

### 1) Control Panel & Interface
- **Dedicated configuration frame** using default Blizzard UI elements, accessible via `/nv` and a minimap button.
- **Feature toggles** for auto-sell, auto-destroy, transmog automation, and stat-weight profile selection.
- **State awareness** so toggles reflect live enable/disable settings and persist between sessions.

### 2) Omagad Wrapper Utilities
- Provide helper functions (e.g., `CastSpell(spellName)`, `DestroyItem(item)`, `EquipItem(bag, slot)`) that internally call `:Omagad("...")` to bypass confirmation dialogs.
- Centralize validation and error logging to keep automation safe and predictable.
- Reuse these wrappers across gear evaluation, transmog learning, selling, and deletion flows.

### 3) Stat Weights & Gear Evaluation
- **Per-spec profiles**: Store three weight tables per character (one for each specialization), with an option to manually select which profile is active. Persist selections per character.
- **Scoring function**: Multiply item stats by their weights to produce a total score. Compare bag items to currently equipped gear to detect upgrades.
- **Auto-equip upgrades**: When a higher-scoring item is found, equip it via the Omagad wrapper to avoid confirmation prompts. Notify the player of changes.
- **Transmog cooperation**: After any transmog learning session, re-run evaluation to ensure the best-stat items are re-equipped.

### 4) Transmog Appearance Automation
- **Smart filtering**: Scan bags for items usable by the player’s class/armor types and not yet learned.
- **Rapid equip/unequip**: Temporarily equip each candidate item via the Omagad wrapper to register its appearance, then restore the prior best-in-slot gear.
- **Run control**: Simple start/stop control in the UI with status feedback so users know progress.

### 5) Automated Selling & Destruction
- **Composite rules**: Combine quality filters with value thresholds (e.g., "destroy green items below X vendor value").
- **Instant vendor selling**: On vendor interaction, automatically sell items matching the selling rules using the Omagad wrapper.
- **Instant destruction**: Items matching destruction rules are deleted without prompts using the Omagad wrapper. Deletion is gated by both quality and value to avoid accidental loss.
- **Logging/feedback**: Provide optional summaries of sold/destroyed items for transparency.

## Implementation Steps (High Level)
1. **Build Omagad utility module** with safe wrapper functions for casting, equipping, and destroying items.
2. **Add saved variable schema** for per-character, per-spec stat weights; initialize defaults and expose load/save helpers.
3. **Implement gear scoring and auto-equip logic**, integrating with loot/bag change events.
4. **Create configuration UI** using Blizzard frames with toggles, profile selectors, and value/quality sliders for selling/destruction rules. Wire `/nv` command and minimap button.
5. **Develop transmog learning pipeline** to iterate bag items, equip via Omagad, and restore best gear after learning.
6. **Implement vendor sell & destruction routines** that apply composite rules and call the wrappers for instant actions.
7. **Add status messaging** to surface actions (sold items, destroyed items, gear upgrades) and ensure feature toggles are honored.

## What We Agreed On
- Use the injected Omagad wrapper pattern (e.g., `:Omagad("CastSpellByName('Spell')")`) with addon-level helper functions.
- Maintain three stat-weight profiles per character (one per specialization) with UI selection and persistence.
- Use default Blizzard frames for the configuration interface; no custom skinning required.
- Destruction rules combine item quality and value thresholds (e.g., delete green items under a specified gold value).
- No keybinds or localization are required beyond the `/nv` slash command and minimap button.

## Testing Notes
- Manual in-game verification will be required to confirm Omagad interactions, gear equip flows, transmog appearance registration, and vendor/destruction rules.

