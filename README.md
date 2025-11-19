Ultimate Inventory Manager & Automation Suite (3.3.5a - Omagad-Enabled)
This powerful addon is specifically designed for your customized 3.3.5a server environment. By leveraging the Omagad() wrapper, it bypasses the standard Lua API security restrictions, enabling true, non-manual, and instantaneous automation for all key inventory tasks, transforming bag management into a one-click process.

Primary Automated Functions
1. ✨ Full Transmog Automation (One-Click Learning)
This feature eliminates the manual requirement of equipping and unequipping items to register their appearance.

Intelligent Scanning: The addon automatically identifies all items in your bags whose appearance has not yet been registered.

Zero-Input Gear Swap: A single press of a button or a command initiates a lightning-fast, silent sequence for every unlearned item:

Your current gear is saved.

The unlearned item is equipped (using Omagad to call the protected EquipItem API).

The server registers the appearance/makes the item soulbound.

Your original gear is immediately restored (using Omagad to call the protected EquipSavedEquipment API).

Result: You learn dozens of new appearances in a matter of seconds without any manual clicks or confirmation boxes.

2. 💰 Auto-Selling & Vendor Management
Streamlines the process of clearing bag space by automatically handling junk items upon interaction.

Smart Junk Filter: Automatically flags all gray-quality items and any user-defined item (e.g., low-value crafting reagents) as "Junk."

Instant Auto-Sell: When you open any vendor window, the addon instantly and silently sells all flagged "Junk" items without requiring an action from you (using Omagad to call the protected SellItem API).

3. 🗑️ Automated Item Deletion
For soulbound items, unwanted gear, or other items that cannot be sold, the addon provides a streamlined destruction mechanism.

Single-Click Destruction: A customizable keybind or button click executes the destruction command for pre-flagged items in your inventory (using Omagad to call the protected Delete/DestroyItem API), completely bypassing the "Are you sure you want to delete this?" confirmation dialog.

4. ⚔️ Optimized Gear Equipping
Ensures you always have the best gear equipped without clicking confirmation boxes.

Fast Equipping: Any attempt to equip a new item—whether manually or through another system—automatically bypasses the "Are you sure you want to equip this soulbound item?" confirmation, making gear checks quick and smooth.
