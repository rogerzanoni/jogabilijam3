local vertical_lanes = 8;
local vertical_increment = CONF_SCREEN_HEIGHT / vertical_lanes;

local melee_life = 300;
local melee_damage = 30;

local medic_life = 200;
local medic_damage = -20;

local gunner_life = 100;
local gunner_damage = 70;

local tank_life = 1500;
local tank_damage = 200;

return {
    { unit=Melee, x=0, y=0,                      life=melee_life, damage=melee_damage, time=0 },
    { unit=Melee, x=0, y=vertical_increment,     life=melee_life, damage=melee_damage, time=0 },
    { unit=Melee, x=0, y=vertical_increment * 2, life=melee_life, damage=melee_damage, time=0 },
    { unit=Melee, x=0, y=vertical_increment * 3, life=melee_life, damage=melee_damage, time=0 },
    { unit=Melee, x=0, y=vertical_increment * 4, life=melee_life, damage=melee_damage, time=0 },
    { unit=Melee, x=0, y=vertical_increment * 5, life=melee_life, damage=melee_damage, time=0 },
    { unit=Melee, x=0, y=vertical_increment * 6, life=melee_life, damage=melee_damage, time=0 },
    { unit=Melee, x=0, y=vertical_increment * 7, life=melee_life, damage=melee_damage, time=0 },

    { unit=Medic, x=0, y=vertical_increment * 3, life=100, damage=medic_damage, time=20 },
    { unit=Medic, x=0, y=vertical_increment * 6, life=100, damage=medic_damage, time=20 },


    { unit=Melee, x=0, y=vertical_increment * 2, life=melee_life, damage=melee_damage, time=30 },
    { unit=Melee, x=0, y=vertical_increment * 6, life=melee_life, damage=melee_damage, time=30 },

    { unit=Gunner, x=0, y=0,                      life=gunner_life, damage=gunner_damage, time=35 },
    { unit=Gunner, x=0, y=vertical_increment * 7, life=gunner_life, damage=gunner_damage, time=35 },

    { unit=Tank, x=0, y=vertical_increment * 2, life=tank_life, damage=tank_damage, time=35 },

    { unit=Melee, x=0, y=0,                      life=melee_life, damage=melee_damage, time=40 },
    { unit=Melee, x=0, y=vertical_increment,     life=melee_life, damage=melee_damage, time=40 },
    { unit=Melee, x=0, y=vertical_increment * 2, life=melee_life, damage=melee_damage, time=40 },
    { unit=Melee, x=0, y=vertical_increment * 3, life=melee_life, damage=melee_damage, time=40 },
    { unit=Melee, x=0, y=vertical_increment * 4, life=melee_life, damage=melee_damage, time=40 },
    { unit=Melee, x=0, y=vertical_increment * 5, life=melee_life, damage=melee_damage, time=40 },
    { unit=Melee, x=0, y=vertical_increment * 6, life=melee_life, damage=melee_damage, time=40 },
    { unit=Melee, x=0, y=vertical_increment * 7, life=melee_life, damage=melee_damage, time=40 },


    { unit=Gunner, x=0, y=vertical_increment * 3, life=gunner_life, damage=gunner_damage, time=45 },
    { unit=Gunner, x=0, y=vertical_increment * 6, life=gunner_life, damage=gunner_damage, time=45 },

    { unit=Melee, x=0, y=0,                      life=melee_life, damage=melee_damage, time=50 },
    { unit=Melee, x=0, y=vertical_increment,     life=melee_life, damage=melee_damage, time=50 },
    { unit=Melee, x=0, y=vertical_increment * 2, life=melee_life, damage=melee_damage, time=50 },
    { unit=Melee, x=0, y=vertical_increment * 3, life=melee_life, damage=melee_damage, time=50 },
    { unit=Melee, x=0, y=vertical_increment * 4, life=melee_life, damage=melee_damage, time=50 },
    { unit=Melee, x=0, y=vertical_increment * 5, life=melee_life, damage=melee_damage, time=50 },
    { unit=Melee, x=0, y=vertical_increment * 6, life=melee_life, damage=melee_damage, time=50 },
    { unit=Melee, x=0, y=vertical_increment * 7, life=melee_life, damage=melee_damage, time=50 },


    { unit=Tank, x=0, y=vertical_increment * 6, life=tank_life, damage=tank_damage, time=55 },
}
