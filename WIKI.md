# Foole Wiki

A Balatro mod featuring **Jane Foole**, the Tudor-era court fool, and (eventually) her companions. The headline mechanic is a **three-stage progression**: Foole arrives as an infant, and you have to keep her alive across two boss-blind defeats to reach her full power.

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

## Design philosophy

The mod is **tier-translation, not power-handout.** It promises an endgame fantasy — the kind of run where deck-conversion plus multiplier-stacking produces astronomical scores — but charges real currency for it:

- **Joker slots:** Infant occupies a slot while being actively harmful
- **RNG dependency:** Adult's transmute is a foundation, not a finished build; you still need supporting cast (Caino, Triboulet, Mime, Hanging Chad, Blueprint, Cryptid)
- **Deck-construction commitment:** without Strength, Death, or specific pack pulls, Infant drowns you
- **Self-destruct timer:** Glass break chance shrinks the deck over time

The math gets absurd. The run doesn't auto-pilot.

---

**Source:** [github.com/TheRevDrJ/foolers](https://github.com/TheRevDrJ/foolers)
