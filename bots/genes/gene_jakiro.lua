local gene = {
    --tune this
    teamworkDist = 500.0,
    teamworkMod = 15.0,
    teamworkThreshold = 30.0,
    huntTOTWMod = 80.0,
    retreatTOTWMod = 120.0,
    PowerMinConsider = -43.440690,
    PowerMaxConsider = 50.000000,
    PowerMaxMult = 144.143110,
    PowerMinMult = 57.107110,
    PowerMaxFlee = 228.389220,
    FleeMinMult = 79.114260,
    FleeMaxMult = 229.530820,

    ----hunt----
    enemyHealth = 8.979740,
    enemyDistance = 9.970530,
    isUnderTower = 27.307280,
    weDisabled = 51.559830,
    eUnderTower = 24.833070,
    EnemyDisabled = 14.351860,
    allyInFight = 23.561900,

    enemyHealthMax = 192.947050,
    perfectAttackRange = 104.194470,
    huntMinHealth = 183.525420,
    huntMaxHealth = 130.063830,
    ----retreat----
    willEnemyTowerTargetMe = 60.154330,
    isEnemyTowerTargetingMeNoAlly = 41.974620,
    hasEnemyCreepsNearby = 32.204540,
    hardRetreat = 86.000020,
    enemyRetreat = 31.055480,
    FountainMana = 13.994290,
    AreThereDangerPings = 56.266210,

    creepCount = 62.064930,
    hardHealth = 11.442590,
    dangerTime = 18.409330,
    dangerDistance = 1317.057000,

    ----farm----
    creepsAround = 40.016220,
    calcEnemyCreepHealth = 125.146160,
    calcEnemyCreepDist = 61.592210,

    creepHealthMaxClamp = 19.139880,

    ----finish him----
    timeToFinish = 2.544020,
    chaseWeight = 59.910170,
    chaseDistance = 362.991730,
    
    retreatEarly = 122.082670,
    retreatLate = 108.216540,
    farmEarly = 89.194760,
    farmLate = 83.553770,
    huntEarly = 81.509530,
    huntLate = 113.311960,
    
    towerWeight = 19.599350,
    buildingWeight = 35.386533
}

return gene

