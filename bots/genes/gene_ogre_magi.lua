local gene = {
    --tune this
    teamworkDist = 512.191290,
    teamworkMod = 14.367030,
    teamworkThreshold = 28.851870,
    huntTOTWMod = 91.241790,
    retreatTOTWMod = 128.492520,
    PowerMinConsider = -48.488860,
    PowerMaxConsider = 55.306830,
    PowerMaxMult = 145.993450,
    PowerMinMult = 49.905160,
    PowerMaxFlee = 179.646370,
    FleeMinMult = 97.551400,
    FleeMaxMult = 176.262240,

    ----hunt----
    enemyHealth = 35.780720,
    enemyDistance = 10.191350,
    isUnderTower = 21.000030,
    weDisabled = 33.034770,
    eUnderTower = 33.047850,
    EnemyDisabled = 29.280830,
    allyInFight = 41.149950,

    enemyHealthMax = 149.039330,
    perfectAttackRange = 34.125210,
    huntMinHealth = 108.556740,
    huntMaxHealth = 115.525720,

    ----retreat----
    willEnemyTowerTargetMe = 15.576260,
    isEnemyTowerTargetingMeNoAlly = 46.344220,
    hasEnemyCreepsNearby = 11.144080,
    hardRetreat = 81.764910,
    enemyRetreat = 113.440350,
    FountainMana = 26.904440,
    AreThereDangerPings = 14.233790,

    creepCount = 37.848340,
    hardHealth = 25.072890,
    dangerTime = 60.044200,
    dangerDistance = 557.897140,

    ----farm----
    creepsAround = 22.080780,
    calcEnemyCreepHealth = 73.215960,
    calcEnemyCreepDist = 40.132080,

    creepHealthMaxClamp = 26.325470,

    ----finish him----
    timeToFinish = 1.489210,
    chaseWeight = 19.105180,
    chaseDistance = 1611.966540,
    
    retreatEarly = 150.903430,
    retreatLate = 137.375760,
    farmEarly = 128.369730,
    farmLate = 61.247550,
    huntEarly = 101.754440,
    huntLate = 87.118820,
    
    towerWeight = 15.720640,
    buildingWeight = 35.124671
}

return gene

