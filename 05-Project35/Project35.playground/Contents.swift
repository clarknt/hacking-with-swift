import UIKit

// from swift 4.2
let int1 = Int.random(in: 0...10)
let int2 = Int.random(in: 0..<10)
let double1 = Double.random(in: 1000...10000)
let float1 = Float.random(in: -100...100)

// before that: range between 0 and 4,294,967,295
print(arc4random())

// incorrect way of restricting the range (pigeonhole principle)
print(arc4random() % 6)

// correct way, from zero to bound
print(arc4random_uniform(6))

// for a range not starting at zero
func RandomInt(min: Int, max: Int) -> Int {
    if max < min { return min }
    return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
}
RandomInt(min: 3, max: 12)

import GameplayKit

// truy random between -2,147,483,648 and 2,147,483,647
print(GKRandomSource.sharedRandom().nextInt())

// from zero to bound
print(GKRandomSource.sharedRandom().nextInt(upperBound: 9))

// choose the type of random source
// ARC4 is the middle-ground one
let arc4 = GKARC4RandomSource()
// Apple suggests flushing at least the first 769 values to avoid sequences that can be guessed
arc4.dropValues(1024)
arc4.nextInt(upperBound: 20)

// another type of random source (high randomness, lowest performance)
let mersenne = GKMersenneTwisterRandomSource()
mersenne.nextInt(upperBound: 20)

// high performance, lowest randomness
let lc = GKLinearCongruentialRandomSource()
lc.nextInt()

// built-in six-sided die
let d6 = GKRandomDistribution.d6()
d6.nextInt()

// or 20-sided
let d20 = GKRandomDistribution.d20()
d20.nextInt()

let crazy = GKRandomDistribution(lowestValue: 1, highestValue: 11539)
// can generate wnew numbers ithout specifying low/high each time
crazy.nextInt()

// will crash
//let distribution = GKRandomDistribution(lowestValue: 10, highestValue: 20)
//print(distribution.nextInt(upperBound: 9))

// force a specific random source
let rand = GKMersenneTwisterRandomSource()
let distribution = GKRandomDistribution(randomSource: rand, lowestValue: 10, highestValue: 20)
print(distribution.nextInt())

// anti-clustering distribution: will go through every possible number before there is a repeat
// will generate 1, 2, 3, 4, 5, 6 in a random order
let shuffled = GKShuffledDistribution.d6()
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())

// will generate more numbers towards the middle (9, 10, 11) in a bell shaped curve
let gaussian = GKGaussianDistribution.d20()
print(gaussian.nextInt())
print(gaussian.nextInt())
print(gaussian.nextInt())
print(gaussian.nextInt())
print(gaussian.nextInt())
print(gaussian.nextInt())

// in-place randomized array shuffling (Fisher-Yates alg)
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swapAt(i, j)
        }
    }
}

// equivalent with GameplayKit: arrayByShufflingObjects(in:)
let lotteryBalls = [Int](1...49)
let shuffledBalls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lotteryBalls)
print(shuffledBalls[0])
print(shuffledBalls[1])
print(shuffledBalls[2])
print(shuffledBalls[3])
print(shuffledBalls[4])
print(shuffledBalls[5])

// fix the starting point
let fixedLotteryBalls = [Int](1...49)
let fixedShuffledBalls = GKMersenneTwisterRandomSource(seed: 1001).arrayByShufflingObjects(in: fixedLotteryBalls)
print(fixedShuffledBalls[0])
print(fixedShuffledBalls[1])
print(fixedShuffledBalls[2])
print(fixedShuffledBalls[3])
print(fixedShuffledBalls[4])
print(fixedShuffledBalls[5])

// same order
let fixedShuffledBalls2 = GKMersenneTwisterRandomSource(seed: 1001).arrayByShufflingObjects(in: fixedLotteryBalls)
print(fixedShuffledBalls2[0])
print(fixedShuffledBalls2[1])
print(fixedShuffledBalls2[2])
print(fixedShuffledBalls2[3])
print(fixedShuffledBalls2[4])
print(fixedShuffledBalls2[5])
