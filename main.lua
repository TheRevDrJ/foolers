-- Foolers mod entry point.
-- Steamodded calls this file once at load, after parsing foolers.json.

sendInfoMessage("Foolers loaded.", "Foolers")


-- Atlas for the Foole sprite. Steamodded auto-loads assets/1x and assets/2x
-- using the same filename in each. px/py are the @1x sprite dimensions.
SMODS.Atlas {
    key = "foole",
    path = "j_foole.png",
    px = 71,
    py = 95
}

-- Foole (for Jane the Fool): every played card becomes a King of Clubs with
-- Polychrome, Glass, and a Red Seal. Ridiculous on purpose.
SMODS.Joker {
    key = "foole",
    loc_txt = {
        name = "Foole",
        text = {
            "Every played card becomes a",
            "{C:clubs}King of Clubs{} with",
            "{C:dark_edition}Polychrome{}, {C:attention}Glass{},",
            "and a {C:red}Red Seal{}"
        }
    },
    atlas = "foole",
    pos = { x = 0, y = 0 },
    rarity = 2,                  -- Uncommon
    cost = 6,
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        if context.before
           and context.cardarea == G.jokers
           and not context.blueprint then
            for _, played_card in ipairs(context.full_hand) do
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
