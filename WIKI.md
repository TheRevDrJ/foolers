# Foole Wiki

A Balatro mod featuring two Tudor-era court fools: **Jane Foole** and **William Sommers**. Each has a three-stage progression — they arrive as infants, and you keep them alive across two boss-blind defeats to reach their full power. Each carves out a different "broken" axis at the endgame: Jane around per-card explosion and deck-conversion, Will around held-mult and deep-deck retention. Mechanically distinct, lore-paired.

This wiki covers Jane first, then Will, then shared design philosophy.

---

# Jane Foole

## The progression at a glance

| Stage | Rarity | Cost | Sell | In shop pool? | Effect |
|-------|--------|------|------|---------------|--------|
| Foole (Infant) | Common | $4 | $2 | ✅ | Only Kings of Clubs score |
| Foole (Child) | Uncommon | $6 | $3 | ❌ (graduation only) | Kings of Clubs are debuffed (the inverse of Infant) |
| Foole (Adult) | Rare | $8 | $4 | ❌ (graduation only) | Every scored card becomes a King of Clubs with Polychrome, Glass, and Red Seal |

Adult is intentionally **Rare** rather than Legendary. Putting it in the Legendary pool would shift vanilla Legendary RNG (breaking known legendary seeds and conflicting with Brainstorm's instant-Perkeo feature), even with `in_pool = false` filtering it out of natural spawns.

**Graduation:** While a stage is in your joker row, defeat any boss blind. The joker animates ("Ready!" appears, then starts wiggling continuously). Sell her — the next stage spawns in her slot.

JokerDisplay (if installed) shows `(0/1)` in grey until the boss defeat, then `(Active!)` in green.

## How to play

### Pre-Foole: build toward her
Before you find Foole, look for the cards that pay off the build:

- **Strength tarot** — bump a card's rank toward King
- **Death tarot** — rewrite a card's identity
- **Standard packs** — hunt for Kings of Clubs
- **Sigil / Ouija spectrals** — make all cards same suit / same rank in one move

The more King-heavy or Club-heavy your deck is when Infant arrives, the less brutal her debuff will be.

### With Infant: survive
Cards in your hand show with the **standard red X overlay** for every non-(King of Clubs) card. Only Kings of Clubs score; everything else is dead weight.

The dance:
1. Discard non-KoC aggressively to draw the few KoCs in your deck
2. Convert at every opportunity (Strength, Death, suit-changers)
3. Survive to a boss blind, then sell her

### With Child: pivot
The debuff inverts. The KoC-heavy deck you spent Infant phase building is now useless — every King of Clubs is debuffed and won't score. You have to win one round playing *around* the deck you previously played *around*. Defeat the boss blind with whatever non-KoC cards you still have, sell her, Adult arrives. The intentional design is that an over-efficient Infant phase punishes you here.

### With Adult: endgame
Adult transmutes every **scored** card into a King of Clubs with Polychrome (x1.5 mult), Glass (x2 mult), and a Red Seal (retrigger once). The change is permanent — the card stays converted across rounds.

> **Important:** Only *scored* cards are transmuted, not all played cards. Kicker cards in a Two Pair, for example, stay as they are. To convert your whole deck, you have to play each card in a hand where it actually scores. Flushes, straights, and full houses are the high-leverage plays for deck conversion.

## Synergies

### Same-deck multipliers
- **Caino** (vanilla Legendary) — gains +1 mult per face card destroyed. Glass break chance is 1/4 per scoring; every Foole'd King that breaks is permanent +1 mult on Caino. The deck self-destruct *powers* Caino instead of just costing you.
- **Triboulet** (vanilla Legendary) — Kings and Queens score x2 mult. Once Adult has converted your deck, every scored card gets x2.
- **Idol** — random rank/suit each round gets x2. With a uniform deck, Idol's "random pick" becomes deterministic.

### Retriggers
- **Hanging Chad** — first played card retriggers twice. With Polychrome+Glass+RedSeal stacked on Adult-converted cards, that's three full scoring passes for the first card.
- **Mime** — retriggers held-in-hand effects. Pairs with Steel/Chariot enhancements on held Kings.
- **Blueprint / Brainstorm** — none of the Foole stages are blueprint-compatible. Infant's debuff is idempotent under copy, Child's debuff is idempotent under copy, Adult's transmute is idempotent on already-transmuted cards. All three report as incompatible.

### Sustaining the build
Glass cards have a 1/4 break chance per scoring. A fully-Foole'd deck slowly cannibalizes itself. To go deep into endless mode you need:
- **Cryptid** (Cryptid mod spectral) — duplicates the most-recently-played card into your deck
- **Ghost Deck** — starts with The Hex spectral and boosts spectral-pack rates, giving reliable Cryptid access

## Edge cases

- **Wild Cards:** A Wild King counts as a King of Clubs. Not debuffed by Infant; retriggered by Child.
- **Smeared Joker:** Makes Clubs and Spades interchangeable. Spade Kings score under Infant when Smeared is in play.
- **Stone Cards:** No rank or suit. Debuffed by Infant. Not transmuted by Adult.
- **Save/reload:** The graduation-ready state persists, and the wiggle resumes automatically on load.

## Compatibility flags

|         | Blueprint | Eternal | Perishable |
|---------|:---------:|:-------:|:----------:|
| Infant  |     ❌    |    ❌   |     ❌     |
| Child   |     ❌    |    ❌   |     ❌     |
| Adult   |     ❌    |    ✅   |     ✅     |

Infant and Child can't be eternal because eternal blocks selling — and graduation requires selling. They can't be perishable because perishable destroys the joker on a timer, which would interrupt the progression. None of the three are blueprint-compatible: Infant's and Child's debuffs are idempotent under copy, and Adult's transmute is idempotent on already-transmuted cards.

---

# William Sommers

Henry VIII's primary court fool, paired with Jane Foole. Same three-stage shape as Jane, but built around the **Queen of Hearts** instead of the King of Clubs, with mechanically distinct punishment shapes at each stage and an endgame that inverts Jane's "play big" axis.

## The progression at a glance

| Stage | Rarity | Cost | Sell | In shop pool? | Effect |
|-------|--------|------|------|---------------|--------|
| Sommers (Infant) | Common | $4 | $2 | ✅ | Every scoring hand must include a Queen of Hearts. Otherwise, **the hand scores nothing and this joker is destroyed.** |
| Sommers (Child) | Uncommon | $6 | $3 | ❌ (graduation only) | Scoring hands still need a Queen of Hearts. Hand size is reduced by 1 per Queen of Hearts in your deck (minimum 1) |
| Sommers (Adult) | Rare | $8 | $4 | ❌ (graduation only) | Every scored card becomes a Queen of Hearts with Polychrome, Steel, and a Red Seal |

**Graduation:** Same as Jane — defeat any boss blind while a stage is in your joker row, then sell. Stage advances.

## How to play

### Pre-Sommers: build toward the Queen
Before he shows up, look for ways to acquire Queen of Hearts cards:

- **Strength tarot** — bumps a Jack of Hearts to a Queen of Hearts
- **Death tarot** — rewrites one card into another, including into Q♥
- **Standard packs** — hunt for the literal Queen of Hearts
- **Sigil / Ouija spectrals** — make all cards same suit (force Hearts) or same rank (force Queen)
- **Cryptid** — duplicates the most-recently-played card into your deck. Once you have a Q♥, copying her is the survival mechanism

A vanilla deck has *one* Q♥. That's not enough for sustained Stage 1 play — you need redundancy.

### Once Sommers is in your jokers
While any Sommers stage (Infant, Child, Adult) is in your joker row, **the first card of every Standard pack is guaranteed to be a Queen of Hearts**. Parallels the Telescope voucher's "first Planet is most-played hand" mechanic — Sommers brings his obsession with him. The forced Q♥ keeps any seal or edition that the pack's RNG roll produced, so it can show up with a Red Seal, Polychrome, etc. on top of the rank+suit guarantee. Other slots in the pack are still random.

### With Infant: stay alive
Every scoring hand must include a Queen of Hearts in the *scoring* portion (kickers don't count). If your played hand resolves with no Q♥ contributing to the poker hand type, **the hand fails to score and Sommers (Infant) is destroyed** — both punishments fire at once, and the joker is permanently lost until you find another in a shop.

The dance:
1. Discard until you have a Q♥ in your draw
2. Play her in a hand type where she actually scores (Pair of Queens, Flush of Hearts, Straight including her)
3. Sometimes you'll exhaust your discards before drawing her — you have to play *some* hand or the round fails. If that hand has no scoring Q♥, you lose the round AND Sommers.
4. Survive to a boss blind, sell to graduate

The pre-play UI warns you: highlighted cards that wouldn't score under the rule trigger a "Will Not Score / and William will take his leave!" warning above the play area, with Sommers' sprite jiggling to mark the source. Vanilla boss-blind warning machinery, repointed.

### With Child: pay the over-commitment tax
Same Q♥-required rule, but the consequence softens — failing it yields a non-scoring hand, not a dead joker. The new pressure is mechanical rather than binary: **hand size is reduced by 1 for every Queen of Hearts in your deck.** Minimum hand size is 1 so you can always play High Card.

This is where Stage 1's strategic puzzle bites both ways:

- Built lightly (2–3 Q♥s): Stage 1 was hard, Stage 2 is manageable (hand of 5–6)
- Built heavily (8+ Q♥s): Stage 1 was easy, Stage 2 cripples you (hand of 1)
- And those Q♥s are *still in the deck*, drawing into your shrunken hand and clogging it

The sweet spot exists somewhere between "barely survived Infant" and "all-in on Q♥". Finding it is the strategic puzzle.

### With Adult: hold deep
Adult transmutes every scored card into a Queen of Hearts with Polychrome (x1.5 mult on score), Steel (x1.5 mult while held in hand), and a Red Seal (retrigger when scored). Steel doesn't break — the deck stays at full size indefinitely. **No Cryptid sustainment needed.**

The endgame insight: **playing small hands maximizes Steel held mult.** With hand size 8 and most cards converted to Steel Q♥s, playing a Pair (2 scoring) leaves 6 Steel Q♥s held → x1.5⁶ ≈ x11.4 from Steel alone, before any other multiplier. Adding Shoot the Moon (+13 mult per Queen held) puts +78 flat mult on top of that multiplier stack.

This inverts standard Balatro and inverts Jane Foole's endgame: where Jane rewards *bigger* hands (more cards converted), Sommers rewards *smaller* hands (more cards held). The two characters operate on opposite axes.

## Synergies

- **Shoot the Moon** — +13 mult per Queen held in hand. With an all-Q♥ deck, every held card contributes. Headlining Sommers Adult synergy.
- **Triboulet** — Kings and Queens give x2 mult when scored. Pure multiplier amplifier, same way it amplifies Jane's Adult.
- **Mime** — retriggers held-in-hand effects. With Steel Q♥s held, Mime doubles each one's x1.5 contribution.
- **Hanging Chad** — first played card retriggers twice. With Polychrome+Steel+Red Seal stacked on Adult-converted cards, three full scoring passes for the first card.
- **Smeared Joker** — Hearts and Diamonds interchangeable, so Q♦ counts as Q♥ for Sommers' rules. Easier Stage 1 survival if you have it in play.

## Edge cases

- **Wild Cards:** A Wild Queen counts as a Queen of Hearts and satisfies the scoring requirement.
- **Smeared:** Q♦ counts as Q♥ for the Stage 1/2 rules.
- **Stone Cards:** No rank or suit. Cannot satisfy the Q♥ requirement, never count toward Sommers' rules.
- **Save/reload:** Same persistent state as Jane. Graduation-ready flag persists, juicing resumes on load.

## Compatibility flags

|         | Blueprint | Eternal | Perishable |
|---------|:---------:|:-------:|:----------:|
| Infant  |     ❌    |    ❌   |     ❌     |
| Child   |     ❌    |    ❌   |     ❌     |
| Adult   |     ❌    |    ✅   |     ✅     |

Identical reasoning to Jane — Eternal blocks selling, Perishable interrupts the progression timer, Blueprint is no-op or idempotent across all three stages.

---

# Design philosophy

The mod is **tier-translation, not power-handout.** It promises an endgame fantasy — the kind of run where deck-conversion plus multiplier-stacking produces astronomical scores — but charges real currency for it:

- **Joker slots:** Each character's progression burns a slot for ~2 antes on something actively harmful (Infant) or constrained (Child).
- **RNG dependency:** Adult forms are foundations, not finished builds. You still need supporting cast — Caino, Triboulet, Mime, Hanging Chad, Shoot the Moon, Blueprint — none guaranteed to spawn.
- **Deck-construction commitment:** Without Strength, Death, Sigil/Ouija, or specific pack pulls, Stage 1 of either character drowns you.
- **Per-character punishment shape:**
  - Jane: Glass break chance shrinks the deck over time → Cryptid-or-die in endless mode
  - Sommers: Heavy Q♥ commitment in Stage 1 → cripples hand size in Stage 2
- **Joker death (Sommers only):** A single Q♥-less play in Stage 1 ends the run for that joker. No second chances.

These costs stack. The math gets absurd. The run doesn't auto-pilot.

---

**Source:** [github.com/TheRevDrJ/foolers](https://github.com/TheRevDrJ/foolers)
