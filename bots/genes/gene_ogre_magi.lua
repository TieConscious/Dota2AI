local gene = {
    --tune this
    teamworkDist = 500.0,
    teamworkMod = 15.0,
    teamworkThreshold = 30.0,
    huntTOTWMod = 80.0,
    retreatTOTWMod = 120.0,
    PowerMinConsider = -50.000000,
    PowerMaxConsider = 60.403930,
    PowerMaxMult = 154.600780,
    PowerMinMult = 50.000000,
    PowerMaxFlee = 179.646370,
    FleeMinMult = 100.000000,
    FleeMaxMult = 174.375560,

    ----hunt----
    enemyHealth = 40.372420,
    enemyDistance = 10.191350,
    isUnderTower = 25.748390,
    weDisabled = 33.034770,
    eUnderTower = 37.318380,
    EnemyDisabled = 26.965860,
    allyInFight = 41.149950,

    enemyHealthMax = 149.039330,
    perfectAttackRange = 36.361580,
    huntMinHealth = 108.556740,
    huntMaxHealth = 85.144690,

    ----retreat----
    willEnemyTowerTargetMe = 15.576260,
    isEnemyTowerTargetingMeNoAlly = 59.621880,
    hasEnemyCreepsNearby = 11.144080,
    hardRetreat = 74.212990,
    enemyRetreat = 113.440350,
    FountainMana = 29.577580,
    AreThereDangerPings = 14.233790,

    creepCount = 35.427680,
    hardHealth = 25.636790,
    dangerTime = 55.341650,
    dangerDistance = 474.061050,

    ----farm----
    creepsAround = 21.384390,
    calcEnemyCreepHealth = 83.319900,
    calcEnemyCreepDist = 39.227860,

    creepHealthMaxClamp = 23.148140,

    ----finish him----
    timeToFinish = 1.489210,
    chaseWeight = 23.510640,
    chaseDistance = 1611.966540,
    
    retreatEarly = 147.661880,
    retreatLate = 137.375760,
    farmEarly = 128.369730,
    farmLate = 59.950720,
    huntEarly = 101.754440,
    huntLate = 111.452140,
    
    towerWeight = 15.720640,
    buildingWeight = 37.909101
}

return gene

