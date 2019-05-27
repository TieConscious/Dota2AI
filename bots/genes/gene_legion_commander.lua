local gene = {
    --tune this
    teamworkDist = 500.0,
    teamworkMod = 15.0,
    teamworkThreshold = 30.0,
    huntTOTWMod = 80.0,
    retreatTOTWMod = 120.0,
    PowerMinConsider = -50.000000,
    PowerMaxConsider = 50.000000,
    PowerMaxMult = 150.000000,
    PowerMinMult = 50.000000,
    PowerMaxFlee = 182.025680,
    FleeMinMult = 100.000000,
    FleeMaxMult = 178.682360,

    ----hunt----
    enemyHealth = 18.551940,
    enemyDistance = 12.048070,
    isUnderTower = 59.124550,
    weDisabled = 31.879080,
    eUnderTower = 10.378500,
    EnemyDisabled = 7.428530,
    allyInFight = 40.663210,

    enemyHealthMax = 104.493590,
    perfectAttackRange = 53.555800,
    huntMinHealth = 87.367370,
    huntMaxHealth = 72.493590,

    ----retreat----
    willEnemyTowerTargetMe = 13.700520,
    isEnemyTowerTargetingMeNoAlly = 57.294700,
    hasEnemyCreepsNearby = 19.387240,
    hardRetreat = 72.408030,
    enemyRetreat = 63.988080,
    FountainMana = 37.890190,
    AreThereDangerPings = 21.323510,

    creepCount = 19.263370,
    hardHealth = 29.391650,
    dangerTime = 35.894240,
    dangerDistance = 1223.930780,

    ----farm----
    creepsAround = 15.834510,
    calcEnemyCreepHealth = 94.369100,
    calcEnemyCreepDist = 176.671630,

    creepHealthMaxClamp = 178.378100,

    ----finish him----
    timeToFinish = 2.205740,
    chaseWeight = 22.154130,
    chaseDistance = 886.952400,
    
    retreatEarly = 108.799070,
    retreatLate = 72.780400,
    farmEarly = 78.104710,
    farmLate = 95.969470,
    huntEarly = 57.601850,
    huntLate = 79.391090,
    
    towerWeight = 35.526050,
    buildingWeight = 30.338953
}

return gene

