local gene = {
    ----hunt----
    enemyHealth = 2,
    enemyDistance = 1.2,
    isUnderTower = 4,
    weDisabled = 4,
    eUnderTower = 2,
    EnemyWeak = 3,
    EnemyDisabled = 2,
    allyInFight = 4,

	enemyHealthMax = 0.6, --bump 100
	perfectAttackRange = 0.8, --bump 100
	FuckMinRatio = -0.5, --bump 100
	FuckMaxRatio = 0.5, --bump 100

    ----retreat----
    willEnemyTowerTargetMe = 4,
    isEnemyTowerTargetingMeNoAlly = 5,
    hasPassiveEnemyNearby = 0.5,
    hasAggressiveEnemyNearby = 2,
    hasEnemyCreepsNearby = 3,
    hardRetreat = 6,
    enemyRetreat = 6,
    FountainMana = 3,
    AreThereDangerPings = 4,

	creepCount = 50.0, --dont bump
	hardHealth = 0.25, -- bump 100
	dangerTime = 6.0, -- bump 10
	dangerDistance = 1600,
	powerConsider = 0.4, -- bump 100

    ----farm----
    creepsAround = 2,
    calcEnemyCreepHealth = 11,
    calcEnemyCreepDist = 7,

	creepHealthMaxClamp = 50.0,

	----finish him----
	timeToFinish = 4.0,--dont bump
	chaseWeight = 40.0,--dont bump
	chaseDistance = 1000.0--dont bump
}

return gene