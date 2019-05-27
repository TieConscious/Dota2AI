local gene = {
    --tune this
    teamworkDist = 500.000000,
    teamworkMod = 16.137640,
    teamworkThreshold = 30.000000,
    huntTOTWMod = 85.106400,
    retreatTOTWMod = 130.285410,
    PowerMinConsider = -42.856410,
    PowerMaxConsider = 46.715830,
    PowerMaxMult = 131.343150,
    PowerMinMult = 57.107110,
    PowerMaxFlee = 229.876650,
    FleeMinMult = 72.712170,
    FleeMaxMult = 229.530820,

    ----hunt----
    enemyHealth = 8.979740,
    enemyDistance = 9.970530,
    isUnderTower = 27.069870,
    weDisabled = 48.751200,
    eUnderTower = 24.833070,
    EnemyDisabled = 14.351860,
    allyInFight = 25.582180,

    enemyHealthMax = 179.605160,
    perfectAttackRange = 86.665580,
    huntMinHealth = 160.211250,
    huntMaxHealth = 113.167850,

    ----retreat----
    willEnemyTowerTargetMe = 51.367590,
    isEnemyTowerTargetingMeNoAlly = 41.974620,
    hasEnemyCreepsNearby = 32.204540,
    hardRetreat = 89.341380,
    enemyRetreat = 29.901610,
    FountainMana = 13.994290,
    AreThereDangerPings = 56.266210,

    creepCount = 55.459730,
    hardHealth = 11.003860,
    dangerTime = 25.113810,
    dangerDistance = 1384.394220,

    ----farm----
    creepsAround = 35.950000,
    calcEnemyCreepHealth = 125.146160,
    calcEnemyCreepDist = 55.110740,

    creepHealthMaxClamp = 19.139880,

    ----finish him----
    timeToFinish = 2.544020,
    chaseWeight = 59.910170,
    chaseDistance = 441.891400,
    
    retreatEarly = 110.828860,
    retreatLate = 108.216540,
    farmEarly = 89.194760,
    farmLate = 83.553770,
    huntEarly = 87.078110,
    huntLate = 113.401360,
    
    towerWeight = 18.496950,
    buildingWeight = 36.634282
}

return gene

