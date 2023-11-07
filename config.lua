Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------

Config.restoreLifejacket = true -- Restore Lifejacket after Player Connect
Config.saveSkin = true -- Set false if you have Skin problems on playerConnect

Config.Animations = {
    dict = 'clothingtie',
    anim = 'try_tie_neutral_a',
    time = 2 -- in seconds (default: 2 seconds)
}
----------------------------------------------------------------
Config.Lifejackets = {
    ['jacket1'] = { -- Item // Add this to your database
        skin = {
            male = {skin1 = 82, skin2 = 0},
            female = {skin1 = 82, skin2 = 0}
        },
    },
    ['jacket2'] = { -- Item // Add this to your database
        skin = {
            male = {skin1 = 81, skin2 = 0},
            female = {skin1 = 81, skin2 = 0}
        },
    },
}