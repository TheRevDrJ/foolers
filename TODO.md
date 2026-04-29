# Foole TODO

Things to do, in no particular order. Move items between sections as they progress.

## Active

- **William Sommers joker set** — second character. Three-stage progression like Foole. Stage 1 forces skips on Small/Big blinds (auto-call `G.FUNCS.skip_blind`, with a non-modal `attention_text` flash + `play_sound('cancel')` for feedback). Graduation gate is **two** boss-blind defeats, not one — prevents grabbing him right before a boss to dodge the punishment. No comfort buffs (no doubled tags etc.); player takes whatever skip rewards the seed deals.
  - Decide stages 2 and 3 effects
  - Source/commission art for three stages
  - Decide rarities (Common / Uncommon / Rare again? or different shape?)
  - Implementation: monkey-patch `G.FUNCS.select_blind` for the force-skip
  - Lore: pair with Jane Foole as Henry VIII's other court fool

## Deferred (waiting for inspiration / right moment)

- **Easter egg: all three Foole stages in jokers at once.** Trigger detection is trivial (`joker_in_play` for all three keys in any add_to_deck or calculate hook). The "what happens" is open — Jonathan to author. Could be a flash, a hidden joker, a quiet message, a sound, anything. Robinett-style: discovery is the reward. By the time it fires the run is soft-locked anyway (every card debuffed by Infant∪Child union), so no need to make it mechanically powerful.

## Future companions (placeholder)

- Other Tudor-court figures? Other "fools" through history? Open design space — at minimum, anyone added should follow the [design philosophy](memory/design_philosophy.md) — promise endgame fantasy, charge real currency for it.

## Done

- Foole three-stage progression (Infant → Child → Adult) with persistent X-overlay debuff, JokerDisplay integration, wiggle-when-ready, graduation-on-sell, Wild/Smeared suit detection
- Mod icon
- Rarity demotion (Common/Uncommon/Rare) to avoid Legendary RNG conflicts
- Child phase inversion (KoCs debuffed instead of retriggered)
- WIKI.md
