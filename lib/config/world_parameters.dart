// how many "pixels" the ship is
const double gameUnit = 0.1;

// in percentages of the screen
const double shipSize = 10.0 * gameUnit;

// max velocity in percentages of the world size
const double shipMaxVelocity = 1.0 * gameUnit;

const double shipAcceleration = 0.2 * gameUnit;
const double shipDeceleration = 0.1 * gameUnit;

// rotation speed (angular impulse)
const double shipRotationSpeed = 1 * gameUnit;
const double shipDensity = 3 * gameUnit;
const double shipAngularDamping = 10.0 * gameUnit;
const double mapSize = 3000 * gameUnit;

const int clusterCount = 10;

class CollisionType {
  static const int sundiver = 0x0001;
  static const int monster = 0x0002;
  static const int boundary = 0x0004;
  static const int laser = 0x0008;
}
