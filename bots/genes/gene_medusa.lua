local gene = {
    --tune this
    teamworkDist = 500.0,
    teamworkMod = 15.0,
    teamworkThreshold = 30.0,
    huntTOTWMod = 80.0,
    retreatTOTWMod = 120.0,
    PowerMinConsider = -54.119140,
    PowerMaxConsider = 50.000000,
    PowerMaxMult = 150.000000,
    PowerMinMult = 51.418290,
    PowerMaxFlee = 188.199410,
    FleeMinMult = 111.402370,
    FleeMaxMult = 200.000000,

    ----hunt----
    enemyHealth = 43.325030,
    enemyDistance = 7.897370,
    isUnderTower = 35.589620,
    weDisabled = 21.889290,
    eUnderTower = 6.944730,
    EnemyDisabled = 10.579500,
    allyInFight = 22.457930,

    enemyHealthMax = 49.507760,
    perfectAttackRange = 129.214930,
    huntMinHealth = 86.261470,
    huntMaxHealth = 210.293350,

    ----retreat----
    willEnemyTowerTargetMe = 38.932550,
    isEnemyTowerTargetingMeNoAlly = 27.256770,
    hasEnemyCreepsNearby = 28.675820,
    hardRetreat = 47.403050,
    enemyRetreat = 113.435640,
    FountainMana = 59.064700,
    AreThereDangerPings = 16.341780,

    creepCount = 73.031630,
    hardHealth = 21.372820,
    dangerTime = 49.663320,
    dangerDistance = 890.603530,

    ----farm----
    creepsAround = 6.030920,
    calcEnemyCreepHealth = 66.417860,
    calcEnemyCreepDist = 92.011430,

    creepHealthMaxClamp = 12.997530,

    ----finish him----
    timeToFinish = 1.688900,
    chaseWeight = 53.819410,
    chaseDistance = 331.144810,
    
    retreatEarly = 126.186760,
    retreatLate = 117.241500,
    farmEarly = 135.445140,
    farmLate = 64.603170,
    huntEarly = 71.700100,
    huntLate = 150.438360,
    
    towerWeight = 11.818180,
    buildingWeight = 30.074530
}

return gene

