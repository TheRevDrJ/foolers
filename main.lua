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
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    config = { extra = { can_graduate = false } },

    calculate = function(self, card, context)
        if defeated_boss_this_round(context) and not card.ability.extra.can_graduate then
            card.ability.extra.can_graduate = true
            return { message = "Ready!", colour = G.C.GOLD, card = card }
        end

        if context.before
           and context.cardarea == G.jokers
           and not context.blueprint then
            for _, played_card in ipairs(context.full_hand) do
                if played_card:get_id() ~= 13 or played_card.base.suit ~= "Clubs" then
                    played_card:set_debuff(true)
                    if played_card.debuff then
                        played_card.debuffed_by_blind = true
                    end
                    played_card.foole_infant_debuff = true
                end
            end
        end

        if context.after
           and context.cardarea == G.jokers
           and not context.blueprint then
            for _, played_card in ipairs(context.full_hand) do
                if played_card.foole_infant_debuff then
                    played_card.debuffed_by_blind = false
                    played_card:set_debuff(false)
                    played_card.foole_infant_debuff = nil
                end
            end
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
            "{C:clubs}Kings of Clubs{} retrigger",
            "when scored",
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
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    config = { extra = { can_graduate = false } },

    in_pool = function(self, args) return false end,

    calculate = function(self, card, context)
        if defeated_boss_this_round(context) and not card.ability.extra.can_graduate then
            card.ability.extra.can_graduate = true
            return { message = "Ready!", colour = G.C.GOLD, card = card }
        end

        if context.repetition
           and context.cardarea == G.play
           and context.other_card:get_id() == 13
           and context.other_card.base.suit == "Clubs" then
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
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
    rarity = 2,
    cost = 6,
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
