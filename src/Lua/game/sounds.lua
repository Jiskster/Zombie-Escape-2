-- TODO: Organize into different files and label each freeslotted sfx.

freeslot("sfx_zjump")
sfxinfo[sfx_zjump].caption = "Jump"

freeslot("sfx_bstdn", "sfx_bstup")
sfxinfo[sfx_bstdn].caption = "Zombie rage off"
sfxinfo[sfx_bstup].caption = "Zombie enrages"

freeslot("sfx_zbatk1", "sfx_zbatk2", "sfx_zbatk3")
sfxinfo[sfx_zbatk1].caption = "Slash impact"
sfxinfo[sfx_zbatk2].caption = "Slash impact"
sfxinfo[sfx_zbatk3].caption = "Slash impact"

freeslot("sfx_wpfire", "sfx_wpfir2")
sfxinfo[sfx_wpfire].caption = "Shooting"
sfxinfo[sfx_wpfir2].caption = "Shooting"

freeslot("sfx_z20s", "sfx_cone", "sfx_ctwo", "sfx_cthr", "sfx_cfou", "sfx_cfiv", "sfx_csix", "sfx_csev", "sfx_ceig", "sfx_cnin", "sfx_cten")
sfxinfo[sfx_z20s].caption = "20 Seconds remaining"
sfxinfo[sfx_cten].caption = "Ten"
sfxinfo[sfx_cnin].caption = "Nine"
sfxinfo[sfx_ceig].caption = "Eight"
sfxinfo[sfx_csev].caption = "Seven"
sfxinfo[sfx_csix].caption = "Six"
sfxinfo[sfx_cfiv].caption = "Five"
sfxinfo[sfx_cfou].caption = "Four"
sfxinfo[sfx_cthr].caption = "Three"
sfxinfo[sfx_ctwo].caption = "Two"
sfxinfo[sfx_cone].caption = "One"

freeslot("sfx_zmrel")
sfxinfo[sfx_zmrel].caption = "Evil Laugh"

freeslot("sfx_oldrad")
sfxinfo[sfx_oldrad].caption = "Notification"

local zombiesfxinfo = {
    singular = false,
    priority = 128,
    flags = SF_X4AWAYSOUND|SF_X8AWAYSOUND|SF_NOMULTIPLESOUND
}

freeslot("sfx_inf1", "sfx_inf2", "sfx_inf3", "sfx_inf4", "sfx_pipe")
sfxinfo[sfx_inf1] = zombiesfxinfo
sfxinfo[sfx_inf1].caption="\"The zombies will be back\""
sfxinfo[sfx_inf2] = zombiesfxinfo
sfxinfo[sfx_inf2].caption="\"We've been enslaved\""
sfxinfo[sfx_inf3] = zombiesfxinfo
sfxinfo[sfx_inf2].caption = "Infection"
sfxinfo[sfx_inf4] = zombiesfxinfo
sfxinfo[sfx_inf4].caption = "Infection"
sfxinfo[sfx_pipe].caption = "Metal pipe"

freeslot("sfx_zdi1","sfx_zdi2")
sfxinfo[sfx_zdi1].caption = "Zombie dies"
sfxinfo[sfx_zdi2].caption = "Zombie dies"

freeslot("sfx_zpa1","sfx_zpa2")
sfxinfo[sfx_zpa1].caption = "Zombie pains"
sfxinfo[sfx_zpa2].caption = "Zombie pains"

freeslot("sfx_zupg1", "sfx_zupg2")
sfxinfo[sfx_zupg1] = zombiesfxinfo
sfxinfo[sfx_zupg1].caption = "Zombie Upgraded"
sfxinfo[sfx_zupg2] = zombiesfxinfo
sfxinfo[sfx_zupg2].caption = "Zombie Upgraded"

freeslot("sfx_zish1","sfx_zish2","sfx_zish3")
sfxinfo[sfx_zish1].caption = "Swoop"
sfxinfo[sfx_zish2].caption = "Swoop"
sfxinfo[sfx_zish3].caption = "Swoop"

freeslot("sfx_rstart", "sfx_secret", "sfx_cleva1")
sfxinfo[sfx_rstart].caption = "Zombies escaped..."
sfxinfo[sfx_secret].caption =" Secret revealed!"
sfxinfo[sfx_cleva1].caption = "\"Calling for evac. transport!\""

freeslot("sfx_eatapl", "sfx_oyahx", "sfx_mnu1a")
sfxinfo[sfx_eatapl].caption = "Num num num!"
sfxinfo[sfx_oyahx].caption = "OHHH YEAH"
sfxinfo[sfx_mnu1a].caption = "Selecting"

-- Multiple maps use this.
freeslot("sfx_type")
sfxinfo[sfx_type].caption = "Button Press"

-- Credits to Ringslinger Neo for these sounds:
freeslot("sfx_rs_die", "sfx_rs_di2")
sfxinfo[sfx_rs_die].caption = "Bullet Death"
sfxinfo[sfx_rs_di2].caption = "Bullet Death..."