local gene = {
    ----hunt----
    enemyHealth = 20.0,
    enemyDistance = 12.0,
    isUnderTower = 40.0,
    weDisabled = 40.0,
    eUnderTower = 20.0,
    EnemyWeak = 30.0,
    EnemyDisabled = 20.0,
    allyInFight = 40.0,

	enemyHealthMax = 60.0,
	perfectAttackRange = 80.0,
	FuckMinRatio = -50.0,
	FuckMaxRatio = 50.0,

    ----retreat----
    willEnemyTowerTargetMe = 40.0,
    isEnemyTowerTargetingMeNoAlly = 50.0,
    hasPassiveEnemyNearby = 5.0,
    hasAggressiveEnemyNearby = 20.0,
    hasEnemyCreepsNearby = 30.0,
    hardRetreat = 60.0,
    enemyRetreat = 60.0,
    FountainMana = 30.0,
    AreThereDangerPings = 40.0,

	creepCount = 50.0,
	hardHealth = 25.0,
	dangerTime = 60.0,
	dangerDistance = 1600.0,
	powerConsider = 40.0,

    ----farm----
    creepsAround = 20.0,
    calcEnemyCreepHealth = 110.0,
    calcEnemyCreepDist = 70.0,

	creepHealthMaxClamp = 50.0,

	----finish him----
	timeToFinish = 4.0,
	chaseWeight = 40.0,
	chaseDistance = 1000.0
}

return gene