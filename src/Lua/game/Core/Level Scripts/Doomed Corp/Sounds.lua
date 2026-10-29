freeslot("sfx_dcrp01", "sfx_hell", "sfx_hell2", "sfx_electr")
sfxinfo[sfx_electr].caption = "Electric malfunction"
sfxinfo[sfx_dcrp01].caption = "(RADIO) Soldier dying"
sfxinfo[sfx_hell].caption = "\"Your hell... awaits\""
sfxinfo[sfx_hell2].caption = "\"What you hope to accomplish!\"" -- What do you hope to accomplish by coming here?

sfxinfo[sfx_electr] = {
    singular = false,
    priority = 64,
    flags = SF_X2AWAYSOUND
}