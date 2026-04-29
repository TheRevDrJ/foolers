# Foole TODO

Things to do, in no particular order. Move items between sections as they progress.

## Active

*(Nothing currently in flight — both characters shipped, repo is public.)*

## Deferred (waiting for inspiration / right moment)

- **Easter egg: all three Foole stages in jokers at once.** Trigger detection is trivial (`joker_in_play` for all three keys in any add_to_deck or calculate hook). The "what happens" is open — Jonathan to author. Could be a flash, a hidden joker, a quiet message, a sound, anything. Robinett-style: discovery is the reward. By the time it fires the run is soft-locked anyway (every card debuffed by Infant∪Child union), so no need to make it mechanically powerful.

- **Easter egg: all three Sommers stages in jokers at once.** Same shape as the Foole egg — detection trivial, content open. By the time it fires, hand size is reduced by Q♥ count (Child) AND every Q♥-less hand destroys the Infant (Stage 1 rule), so the run is similarly soft-locked. Author the egg when inspiration hits.

- **Stretch: cross-character merge.** If both eggs fire simultaneously (all six staged jokers in play... vanishingly rare without cheating), maybe they combine into something even bigger — a "Court of Fools" joker that synergizes both decks. Open question: is there anything more insane than a full polychrome-glass-red-seal-King-of-Clubs / steel-polychrome-red-seal-Queen-of-Hearts double deck? Maybe just the *act* of triggering both is the reward. Keep loose.

## Future companions (placeholder)

- Other Tudor-court figures? Other "fools" through history? Open design space — at minimum, anyone added should follow the [design philosophy](memory/design_philosophy.md) — promise endgame fantasy, charge real currency for it.

## Done

- Foole three-stage progression (Infant → Child → Adult) with persistent X-overlay debuff, JokerDisplay integration, wiggle-when-ready, graduation-on-sell, Wild/Smeared suit detection
- Mod icon
- Rarity demotion (Common/Uncommon/Rare) to avoid Legendary RNG conflicts
- Child phase inversion (KoCs debuffed instead of retriggered)
- WIKI.md (both characters)
- William Sommers three-stage progression (built around Queen of Hearts; Stage 1 hand-zero + joker-destruction on Q♥-less scoring, Stage 2 hand-size shrink scaled by deck Q♥ count, Stage 3 Steel+Polychrome+Red Seal transmute)
- Sommers pre-play warning UI ("Will Not Score / and William will take his leave!") via `Blind:debuff_hand` patch
- Adult skip-if-already-transmuted (no redundant transmutes / message spam on fully-converted decks)
- Pack conversion: while Foole is in jokers, the leftmost-eligible card of every Standard pack becomes a King of Clubs; same for Sommers with Queen of Hearts. Both characters in jokers = both cards. Intentionally undocumented (discoverable easter-egg-style).
- Repo published public at https://github.com/TheRevDrJ/foolers
