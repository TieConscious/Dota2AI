local gene = {
    --tune this
    teamworkDist = 500.0,
    teamworkMod = 15.0,
    teamworkThreshold = 30.0,
    huntTOTWMod = 80.0,
    retreatTOTWMod = 120.0,
    PowerMinConsider = -55.749880,
    PowerMaxConsider = 50.000000,
    PowerMaxMult = 138.826730,
    PowerMinMult = 50.000000,
    PowerMaxFlee = 200.000000,
    FleeMinMult = 100.000000,
    FleeMaxMult = 223.108070,

    ----hunt----
    enemyHealth = 15.817840,
    enemyDistance = 24.234010,
    isUnderTower = 59.108510,
    weDisabled = 26.724880,
    eUnderTower = 6.563080,
    EnemyDisabled = 22.540840,
    allyInFight = 45.042130,

    enemyHealthMax = 36.242050,
    perfectAttackRange = 126.370250,
    huntMinHealth = 149.068900,
    huntMaxHealth = 93.160510,

    ----retreat----
    willEnemyTowerTargetMe = 39.126690,
    isEnemyTowerTargetingMeNoAlly = 40.945780,
    hasEnemyCreepsNearby = 15.251380,
    hardRetreat = 58.509360,
    enemyRetreat = 48.370160,
    FountainMana = 27.535190,
    AreThereDangerPings = 33.774840,

    creepCount = 103.854880,
    hardHealth = 30.447210,
    dangerTime = 30.583250,
    dangerDistance = 767.197790,

    ----farm----
    creepsAround = 33.353560,
    calcEnemyCreepHealth = 99.836180,
    calcEnemyCreepDist = 42.310270,

    creepHealthMaxClamp = 65.375790,

    ----finish him----
    timeToFinish = 1.474280,
    chaseWeight = 25.889430,
    chaseDistance = 391.623180,
    
    retreatEarly = 139.283610,
    retreatLate = 136.331580,
    farmEarly = 94.978380,
    farmLate = 67.350260,
    huntEarly = 92.166280,
    huntLate = 142.057860,
    
    towerWeight = 22.590050,
    buildingWeight = 26.041527
}

return gene

