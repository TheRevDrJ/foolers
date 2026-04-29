# Foole TODO

Things to do, in no particular order. Move items between sections as they progress.

## Active

- **Playtest William Sommers** — all three stages shipped at commit `968ecf0`. Stage 1 destroys the joker on Q♥-less scoring hand; Stage 2 soft-fails plus shrinks hand size by Q♥ count; Stage 3 transmutes scored cards to Steel+Polychrome+Red Seal Q♥. Verify destruction timing, hand-size update responsiveness, and the Steel-held-mult endgame loop with Shoot the Moon.

## Deferred (waiting for inspiration / right moment)

- **Easter egg: all three Foole stages in jokers at once.** Trigger detection is trivial (`joker_in_play` for all three keys in any add_to_deck or calculate hook). The "what happens" is open — Jonathan to author. Could be a flash, a hidden joker, a quiet message, a sound, anything. Robinett-style: discovery is the reward. By the time it fires the run is soft-locked anyway (every card debuffed by Infant∪Child union), so no need to make it mechanically powerful.

- **Shop spawns Q♥ while Sommers is in jokers.** Inspired by Magic Trick voucher (`v_magic_trick`), which sets `G.GAME.playing_card_rate = 4`. Two implementation paths: (a) enable the rate while Sommers present (random playing cards, no Q♥ guarantee), or (b) monkey-patch `create_card_for_shop` to force the playing-card slot to be specifically Q♥, optionally with a Red Seal. (b) fits Sommers' "obsessed with the queen" theme better. Park until Jonathan confirms he wants it — Stage 1 already has Strength/Death/packs/Cryptid as Q♥ acquisition paths.

## Future companions (placeholder)

- Other Tudor-court figures? Other "fools" through history? Open design space — at minimum, anyone added should follow the [design philosophy](memory/design_philosophy.md) — promise endgame fantasy, charge real currency for it.

## Done

- Foole three-stage progression (Infant → Child → Adult) with persistent X-overlay debuff, JokerDisplay integration, wiggle-when-ready, graduation-on-sell, Wild/Smeared suit detection
- Mod icon
- Rarity demotion (Common/Uncommon/Rare) to avoid Legendary RNG conflicts
- Child phase inversion (KoCs debuffed instead of retriggered)
- WIKI.md (both characters)
- William Sommers three-stage progression (built around Queen of Hearts; Stage 1 joker-destruction-on-failure, Stage 2 hand-size shrink, Stage 3 Steel+Polychrome+Red Seal transmute)
