-- Foole mod entry point.
-- Steamodded calls this file once at load, after parsing Foole.json.

sendInfoMessage("Foole loaded.", "Foole")


-- Mod icon shown on the Foole card in the Mods menu. SMODS looks for
-- an atlas with key "modicon" (or "<prefix>_modicon") at draw time.
SMODS.Atlas {
    key = "modicon",
    path = "modicon.png",
    px = 32,
    py = 32
}

-- One atlas per Foole stage. Steamodded auto-loads the matching files
-- from assets/1x and assets/2x. px/py are the @1x sprite dimensions.
SMODS.Atlas { key = "foole_infant", path = "j_foole_infant.png", px = 71, py = 95 }
SMODS.Atlas { key = "foole_child",  path = "j_foole_child.png",  px = 71, py = 95 }
SMODS.Atlas { key = "foole",        path = "j_foole.png",        px = 71, py = 95 }
SMODS.Atlas { key = "sommers_infant", path = "j_sommers_infant.png", px = 71, py = 95 }
SMODS.Atlas { key = "sommers_child",  path = "j_sommers_child.png",  px = 71, py = 95 }
SMODS.Atlas { key = "sommers",        path = "j_sommers.png",        px = 71, py = 95 }


-- =============================================================================
-- Helper: spawn the next-stage joker after this one is sold.
-- Pattern matches vanilla Invisible Joker (card.lua:2688): on selling_self,
-- emplace a fresh card of the target center directly into G.jokers.
-- =============================================================================
local function graduate_to(next_key)
    local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil, next_key)
    new_card:add_to_deck()
    G.jokers:emplace(new_card)
end

-- Returns true once on the round we defeat a boss blind. Used by infant
-- and child stages to flip their can_graduate flag exactly once. Vanilla
-- Rocket (card.lua:3284) and Campfire (card.lua:3277) use the same
-- end_of_round + G.GAME.blind.boss check.
local function defeated_boss_this_round(context)
    return context.end_of_round
       and not context.individual
       and not context.repetition
       and not context.blueprint
       and G.GAME.blind
       and G.GAME.blind.boss
end

-- Wiggle the card while it's eligible to graduate. Pattern matches vanilla
-- Invisible Joker (card.lua:3315) which calls juice_card_until once the
-- count hits its threshold. The card.foole_juicing flag prevents stacking
-- juice loops if we're called twice in a session. Flag isn't persisted, so
-- a save/reload re-arms it via add_to_deck.
local function start_juicing_if_ready(card)
    if card.ability.extra.can_graduate and not card.foole_juicing then
        card.foole_juicing = true
        local eval = function(c)
            return c.ability.extra.can_graduate and not c.REMOVED and c.foole_juicing
        end
        juice_card_until(card, eval, true)
    end
end

-- Re-evaluate debuff state on every playing card after Infant joins or
-- leaves the joker row. set_debuff(false) is a *recalc*, not a force-clear:
-- it runs all SMODS mod hooks, including our set_debuff below, which
-- returns true for non-KoC playing cards while Infant is in jokers.
local function recalc_playing_card_debuffs()
    for _, area in ipairs({ G.deck, G.hand, G.play, G.discard }) do
        if area and area.cards then
            for _, c in pairs(area.cards) do
                if c.playing_card then c:set_debuff(false) end
            end
        end
    end
end

local function joker_in_play(key)
    if not G.jokers or not G.jokers.cards then return false end
    for _, j in pairs(G.jokers.cards) do
        if j.config and j.config.center and j.config.center.key == key then
            return true
        end
    end
    return false
end

local function infant_in_play() return joker_in_play("j_fool_foole_infant") end
local function child_in_play()  return joker_in_play("j_fool_foole_child")  end

-- Mod-level set_debuff hook. SMODS calls this for every card whose debuff
-- state is being evaluated (Card:set_debuff in card.lua:674). Returning
-- true forces the card debuffed; the standard X / dim shaders then render
-- via card.lua:4941 the same way they do for boss-blind debuffs. Persistent
-- state (vs. an in-scoring approach) is what makes the visual actually show
-- up — the in-scoring window was too brief.
--
-- Infant debuffs every non-(King of Clubs).
-- Child INVERTS that: KoCs themselves are debuffed. The deck the player
-- spent Infant building toward becomes useless during Child, forcing
-- one round of play around what they previously played around.
-- If both stages are somehow in play (Showman, copies, etc.), the
-- debuffs union — everything ends up debuffed.
SMODS.current_mod.set_debuff = function(card)
    if not card.playing_card then return false end
    -- is_suit(suit, bypass_debuff=true) sees through Wild Cards, Smeared
    -- Joker, and other suit-mutators. Raw card.base.suit would miss them.
    local is_koc = card:get_id() == 13 and card:is_suit("Clubs", true)
    if infant_in_play() and not is_koc then return true end
    if child_in_play()  and is_koc     then return true end
    return false
end

-- Count of every Queen of Hearts currently in the player's playing cards
-- (deck, hand, play, discard). Wild Q and Smeared-equivalent Q♦ count
-- via Card:is_suit. Sommers (Child) reads this each frame to size the
-- hand-shrink effect.
local function count_q_hearts_in_deck()
    if not G.playing_cards then return 0 end
    local n = 0
    for _, c in pairs(G.playing_cards) do
        if c:get_id() == 12 and c:is_suit("Hearts", true) then
            n = n + 1
        end
    end
    return n
end

-- True if any card contributing to the poker hand type (the actual
-- scoring portion, kickers excluded) is a Queen of Hearts.
local function scoring_hand_has_qoh(scoring_hand)
    if not scoring_hand then return false end
    for _, c in ipairs(scoring_hand) do
        if c:get_id() == 12 and c:is_suit("Hearts", true) then
            return true
        end
    end
    return false
end


-- =============================================================================
-- Stage 1: Foole (Infant). Only Kings of Clubs score.
-- The lone shop-eligible stage; sell after the next boss to grow up.
-- =============================================================================
SMODS.Joker {
    key = "foole_infant",
    loc_txt = {
        name = "Foole (Infant)",
        text = {
            "Only {C:clubs}Kings of Clubs{} score",
            "{C:inactive}Sell after defeating a boss",
            "{C:inactive}blind to grow up..."
        }
    },
    atlas = "foole_infant",
    pos = { x = 0, y = 0 },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    config = { extra = { can_graduate = false } },

    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            start_juicing_if_ready(card)
            recalc_playing_card_debuffs()
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then recalc_playing_card_debuffs() end
    end,

    calculate = function(self, card, context)
        if defeated_boss_this_round(context) and not card.ability.extra.can_graduate then
            card.ability.extra.can_graduate = true
            start_juicing_if_ready(card)
            return { message = "Ready!", colour = G.C.GOLD, card = card }
        end

        if context.selling_self
           and not context.blueprint
           and card.ability.extra.can_graduate then
            graduate_to("j_fool_foole_child")
            return nil, true
        end
    end
}


-- =============================================================================
-- Stage 2: Foole (Child). Kings of Clubs retrigger when scored.
-- Never in shop. Obtained by selling the infant after a boss defeat.
-- =============================================================================
SMODS.Joker {
    key = "foole_child",
    loc_txt = {
        name = "Foole (Child)",
        text = {
            "{C:clubs}Kings of Clubs{} are debuffed",
            "{C:inactive}Sell after defeating a boss",
            "{C:inactive}blind to grow up..."
        }
    },
    atlas = "foole_child",
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    config = { extra = { can_graduate = false } },

    in_pool = function(self, args) return false end,

    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            start_juicing_if_ready(card)
            recalc_playing_card_debuffs()
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then recalc_playing_card_debuffs() end
    end,

    calculate = function(self, card, context)
        if defeated_boss_this_round(context) and not card.ability.extra.can_graduate then
            card.ability.extra.can_graduate = true
            start_juicing_if_ready(card)
            return { message = "Ready!", colour = G.C.GOLD, card = card }
        end

        if context.selling_self
           and not context.blueprint
           and card.ability.extra.can_graduate then
            graduate_to("j_fool_foole")
            return nil, true
        end
    end
}


-- =============================================================================
-- Stage 3: Foole (Adult). Every played card becomes a King of Clubs with
-- Polychrome, Glass, and a Red Seal. Final form. Never in shop.
-- =============================================================================
SMODS.Joker {
    key = "foole",
    loc_txt = {
        name = "Foole",
        text = {
            "Every scored card becomes a",
            "{C:clubs}King of Clubs{} with",
            "{C:dark_edition}Polychrome{}, {C:attention}Glass{},",
            "and a {C:red}Red Seal{}"
        }
    },
    atlas = "foole",
    pos = { x = 0, y = 0 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    in_pool = function(self, args) return false end,

    calculate = function(self, card, context)
        if context.before
           and context.cardarea == G.jokers
           and not context.blueprint then
            for _, played_card in ipairs(context.scoring_hand) do
                SMODS.change_base(played_card, 'Clubs', 'King')
                played_card:set_ability(G.P_CENTERS.m_glass)
                played_card:set_edition({ polychrome = true }, true)
                played_card:set_seal('Red', true)
            end
            return {
                message = "Transmuted!",
                colour = G.C.GOLD,
                card = card
            }
        end
    end
}


-- =============================================================================
-- Sommers Stage 1: William Sommers (Infant). Every scoring hand must
-- contain a Queen of Hearts, or this joker is destroyed permanently
-- (rebuyable from shops since Common rarity).
-- =============================================================================
SMODS.Joker {
    key = "sommers_infant",
    loc_txt = {
        name = "Sommers (Infant)",
        text = {
            "Hands without a {C:hearts}Queen of Hearts{}",
            "{C:attention}destroy this joker{}",
            "{C:inactive}Sell after defeating a boss",
            "{C:inactive}blind to grow up..."
        }
    },
    atlas = "sommers_infant",
    pos = { x = 0, y = 0 },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    config = { extra = { can_graduate = false } },

    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then start_juicing_if_ready(card) end
    end,

    calculate = function(self, card, context)
        if defeated_boss_this_round(context) and not card.ability.extra.can_graduate then
            card.ability.extra.can_graduate = true
            start_juicing_if_ready(card)
            return { message = "Ready!", colour = G.C.GOLD, card = card }
        end

        -- Q♥-less hand: debuff every scoring card so the hand doesn't
        -- score, AND mark each so context.after can clear them and trigger
        -- our destruction. Doing the destroy in context.after lets us
        -- clean up the debuff state first; if we destroyed Sommers in
        -- context.before, the after hook wouldn't fire and the cards
        -- would stay debuffed into next round.
        if context.before
           and context.cardarea == G.jokers
           and not context.blueprint then
            if not scoring_hand_has_qoh(context.scoring_hand) then
                for _, played_card in ipairs(context.scoring_hand) do
                    played_card:set_debuff(true)
                    played_card.sommers_infant_debuff = true
                end
                return {
                    message = "I take my leave!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.after
           and context.cardarea == G.jokers
           and not context.blueprint
           and context.scoring_hand then
            local marked = false
            for _, played_card in ipairs(context.scoring_hand) do
                if played_card.sommers_infant_debuff then
                    played_card:set_debuff(false)
                    played_card.sommers_infant_debuff = nil
                    marked = true
                end
            end
            if marked then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        SMODS.destroy_cards({card})
                        return true
                    end
                }))
            end
        end

        if context.selling_self
           and not context.blueprint
           and card.ability.extra.can_graduate then
            graduate_to("j_fool_sommers_child")
            return nil, true
        end
    end
}


-- =============================================================================
-- Sommers Stage 2: William Sommers (Child). Same Q♥-required rule, but
-- failure is soft (no scoring instead of joker death). Hand size shrinks
-- by 1 per Q♥ in the deck (min 1) — the over-commitment tax.
-- =============================================================================
SMODS.Joker {
    key = "sommers_child",
    loc_txt = {
        name = "Sommers (Child)",
        text = {
            "Scoring hands need a",
            "{C:hearts}Queen of Hearts{}",
            "{C:attention}-1{} hand size per {C:hearts}Q♥{} in deck"
        }
    },
    atlas = "sommers_child",
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    config = { extra = { can_graduate = false, applied_reduction = 0 } },

    in_pool = function(self, args) return false end,

    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then start_juicing_if_ready(card) end
    end,

    -- On removal, restore whatever hand-size we took. Otherwise selling
    -- Sommers Child to graduate would leave the player permanently
    -- short-handed.
    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff
           and card.ability.extra.applied_reduction
           and card.ability.extra.applied_reduction > 0
           and G.hand then
            G.hand:change_size(card.ability.extra.applied_reduction)
            card.ability.extra.applied_reduction = 0
        end
    end,

    -- Update fires every frame. Recompute the desired hand-size reduction
    -- from current Q♥ count and apply only the delta. Floors hand size
    -- at 1 so High Card is always playable.
    update = function(self, card, dt)
        if not G.hand or not G.playing_cards or not G.GAME or not G.GAME.starting_params then return end
        local q_count = count_q_hearts_in_deck()
        local default_hand_size = G.GAME.starting_params.hand_size or 8
        local target = math.min(q_count, math.max(0, default_hand_size - 1))
        local current = card.ability.extra.applied_reduction or 0
        if target ~= current then
            G.hand:change_size(-(target - current))
            card.ability.extra.applied_reduction = target
        end
    end,

    calculate = function(self, card, context)
        if defeated_boss_this_round(context) and not card.ability.extra.can_graduate then
            card.ability.extra.can_graduate = true
            start_juicing_if_ready(card)
            return { message = "Ready!", colour = G.C.GOLD, card = card }
        end

        -- Soft failure: debuff every scoring card so nothing scores. The
        -- visual is brief (only across the eval pass) but the score
        -- behavior is the point — joker survives.
        if context.before
           and context.cardarea == G.jokers
           and not context.blueprint then
            if not scoring_hand_has_qoh(context.scoring_hand) then
                for _, played_card in ipairs(context.scoring_hand) do
                    played_card:set_debuff(true)
                    played_card.sommers_child_debuff = true
                end
            end
        end

        if context.after
           and context.cardarea == G.jokers
           and not context.blueprint
           and context.scoring_hand then
            for _, played_card in ipairs(context.scoring_hand) do
                if played_card.sommers_child_debuff then
                    played_card:set_debuff(false)
                    played_card.sommers_child_debuff = nil
                end
            end
        end

        if context.selling_self
           and not context.blueprint
           and card.ability.extra.can_graduate then
            graduate_to("j_fool_sommers")
            return nil, true
        end
    end
}


-- =============================================================================
-- Sommers Stage 3: William Sommers (Adult). Every scored card becomes a
-- Queen of Hearts with Polychrome, Steel, and a Red Seal. Steel doesn't
-- break — deck stays full forever, and held mult is the new scaling
-- axis. Inverts Foole Adult's "play big" by rewarding small hands.
-- =============================================================================
SMODS.Joker {
    key = "sommers",
    loc_txt = {
        name = "Sommers",
        text = {
            "Every scored card becomes a",
            "{C:hearts}Queen of Hearts{} with",
            "{C:dark_edition}Polychrome{}, {C:attention}Steel{},",
            "and a {C:red}Red Seal{}"
        }
    },
    atlas = "sommers",
    pos = { x = 0, y = 0 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    in_pool = function(self, args) return false end,

    calculate = function(self, card, context)
        if context.before
           and context.cardarea == G.jokers
           and not context.blueprint then
            for _, played_card in ipairs(context.scoring_hand) do
                SMODS.change_base(played_card, 'Hearts', 'Queen')
                played_card:set_ability(G.P_CENTERS.m_steel)
                played_card:set_edition({ polychrome = true }, true)
                played_card:set_seal('Red', true)
            end
            return {
                message = "Indeed!",
                colour = G.C.GOLD,
                card = card
            }
        end
    end
}


-- =============================================================================
-- JokerDisplay integration. No-op if the JokerDisplay mod isn't loaded.
-- Mirrors vanilla Invisible Joker's pattern (Definitions[j_invisible]):
-- shows "(0/1)" in inactive grey before boss defeat, "(Active!)" in green
-- once the joker is ready to graduate.
-- =============================================================================
-- =============================================================================
-- Pre-play warning for Sommers (Infant/Child). Vanilla shows a "Will Not
-- Score" warning above the play area when the boss blind would debuff
-- the highlighted hand (cardarea.lua:194 sets G.boss_throw_hand,
-- game.lua:2604 builds the UIBox). We monkey-patch parse_highlighted
-- to ALSO trip that flag — and override the message via SMODS.debuff_text
-- and SMODS.hand_debuff_source — when Sommers' Q♥-required rule would
-- fail on the current selection.
--
-- Defers to the boss if the boss is already debuffing the hand: don't
-- stomp the boss message. The player will discover Sommers' fate on play.
-- =============================================================================
local _orig_parse_highlighted = CardArea.parse_highlighted
function CardArea:parse_highlighted()
    _orig_parse_highlighted(self)

    if self ~= G.hand then return end
    if not self.highlighted or #self.highlighted == 0 then return end
    if G.boss_throw_hand then return end -- boss is already warning; don't stomp

    local stage_key, stage_label
    if joker_in_play("j_fool_sommers_infant") then
        stage_key, stage_label = "j_fool_sommers_infant", "and William will take his leave!"
    elseif joker_in_play("j_fool_sommers_child") then
        stage_key, stage_label = "j_fool_sommers_child", "No Queen of Hearts"
    else
        return
    end

    local text, _, poker_hands = G.FUNCS.get_poker_hand_info(self.highlighted)
    if text == 'NULL' then return end
    local scoring = poker_hands[text] and poker_hands[text][1]
    if not scoring then return end
    if scoring_hand_has_qoh(scoring) then return end

    G.boss_throw_hand = true
    SMODS.debuff_text = stage_label
    for _, j in pairs(G.jokers.cards) do
        if j.config and j.config.center and j.config.center.key == stage_key then
            SMODS.hand_debuff_source = j
            break
        end
    end
end


if JokerDisplay and JokerDisplay.Definitions then
    local function progression_display()
        return {
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "active" },
                { text = ")" },
            },
            calc_function = function(card)
                local ready = card.ability.extra and card.ability.extra.can_graduate or false
                card.joker_display_values.is_active = ready
                card.joker_display_values.active = ready and localize("jdis_active") or "0/1"
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour =
                        card.joker_display_values.is_active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
                end
            end,
        }
    end
    JokerDisplay.Definitions["j_fool_foole_infant"]   = progression_display()
    JokerDisplay.Definitions["j_fool_foole_child"]    = progression_display()
    JokerDisplay.Definitions["j_fool_sommers_infant"] = progression_display()
    JokerDisplay.Definitions["j_fool_sommers_child"]  = progression_display()
end
