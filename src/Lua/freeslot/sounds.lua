-- TODO: Organize into different files and label each freeslotted sfx.

freeslot("sfx_zdi1","sfx_zdi2","sfx_zish1","sfx_zish2","sfx_zish3","sfx_zpa1","sfx_zpa2", "sfx_bstdn", "sfx_bstup")
freeslot("sfx_rstart", "sfx_secret", "sfx_cleva1")
freeslot("sfx_eatapl", "sfx_oyahx", "sfx_mnu1a")
freeslot("sfx_inf1", "sfx_inf2", "sfx_inf3", "sfx_inf4", "sfx_pipe")
freeslot("sfx_zbatk1", "sfx_zbatk2", "sfx_zbatk3")

freeslot("sfx_wpfire", "sfx_wpfir2")

freeslot("sfx_z_rel1", "sfx_z_rel2")
freeslot("sfx_z20s", "sfx_cone", "sfx_ctwo", "sfx_cthr", "sfx_cfou", "sfx_cfiv", "sfx_csix", "sfx_csev", "sfx_ceig", "sfx_cnin", "sfx_cten")

freeslot("sfx_zmrel")

freeslot("sfx_oldrad")

local zombiesfxinfo = {
        singular = false,
        priority = 128,
        flags = SF_X4AWAYSOUND|SF_X8AWAYSOUND|SF_NOMULTIPLESOUND
}

sfxinfo[sfx_inf1] = zombiesfxinfo
sfxinfo[sfx_inf2] = zombiesfxinfo
sfxinfo[sfx_inf3] = zombiesfxinfo
sfxinfo[sfx_inf4] = zombiesfxinfo

sfxinfo[sfx_zdi1].caption="Zombie scream"
sfxinfo[sfx_zdi2].caption="Zombie scream"
sfxinfo[sfx_zpa1].caption="Zombie pain"
sfxinfo[sfx_zpa2].caption="Zombie pain"
sfxinfo[sfx_zish1].caption="Swoop"

sfxinfo[sfx_rstart].caption="Zombies escaped..."
sfxinfo[sfx_secret].caption="Secret revealed!"
sfxinfo[sfx_cleva1].caption="\"Calling for transport!\""

sfxinfo[sfx_eatapl].caption="Num num num!"
sfxinfo[sfx_oyahx].caption="OHHH YEAH"
sfxinfo[sfx_mnu1a].caption="Selecting"

sfxinfo[sfx_inf1].caption="\"The zombies will be back\""
sfxinfo[sfx_inf2].caption="\"We've been enslaved\""
sfxinfo[sfx_pipe].caption="Pipe"

sfxinfo[sfx_oldrad].caption="Typewriter"

-- Multiple maps use this.
freeslot("sfx_type")
sfxinfo[sfx_type].caption = "Button Press"