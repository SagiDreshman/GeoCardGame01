//
//  GameViewController.swift
//  Ex1
//

import UIKit

class GameViewController: UIViewController {

    // Passed from menu
    var playerName: String = "Player"
    var playerSide: PlayerSide = .west

    // Score labels
    @IBOutlet weak var leftNameLabel: UILabel!
    @IBOutlet weak var leftScoreLabel: UILabel!
    @IBOutlet weak var rightNameLabel: UILabel!
    @IBOutlet weak var rightScoreLabel: UILabel!

    // Card image views
    @IBOutlet weak var leftCardImageView: UIImageView!
    @IBOutlet weak var rightCardImageView: UIImageView!

    // Timer
    @IBOutlet weak var timerLabel: UILabel!

    // Game state
    private var leftScore = 0      // West side
    private var rightScore = 0     // East side
    private var roundsPlayed = 0
    private let totalRounds = 10

    private var timer: Timer?
    private var remainingSeconds = 5

    private let suits = ["hearts", "diamonds", "clubs", "spades"]
    private var leftRank = 0
    private var leftSuit = ""
    private var rightRank = 0
    private var rightSuit = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        startNewRound()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Setup

    private func configureUI() {
        switch playerSide {
        case .west:
            leftNameLabel.text = playerName
            rightNameLabel.text = "PC"
        case .east:
            leftNameLabel.text = "PC"
            rightNameLabel.text = playerName
        }
        leftScoreLabel.text = "0"
        rightScoreLabel.text = "0"
        leftCardImageView.contentMode = .scaleAspectFit
        rightCardImageView.contentMode = .scaleAspectFit
        showCardsFaceDown()
    }

    // MARK: - Round flow

    private func startNewRound() {
        if roundsPlayed >= totalRounds {
            endGame()
            return
        }
        leftRank = Int.random(in: 1...13)
        leftSuit = suits.randomElement()!
        rightRank = Int.random(in: 1...13)
        rightSuit = suits.randomElement()!
        showCardsFaceDown()
        startCountdown(seconds: 5) { [weak self] in
            self?.flipCardsFaceUp()
        }
    }

    private func flipCardsFaceUp() {
        showCardsFaceUp()
        scoreRound()
        startCountdown(seconds: 3) { [weak self] in
            self?.roundsPlayed += 1
            self?.startNewRound()
        }
    }

    private func scoreRound() {
        if leftRank == rightRank { return }
        if leftRank > rightRank {
            leftScore += 1
            leftScoreLabel.text = "\(leftScore)"
        } else {
            rightScore += 1
            rightScoreLabel.text = "\(rightScore)"
        }
    }

    // MARK: - Countdown

    private func startCountdown(seconds: Int, onFinish: @escaping () -> Void) {
        timer?.invalidate()
        remainingSeconds = seconds
        timerLabel.text = "\(remainingSeconds)"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                t.invalidate()
                self.timer = nil
                onFinish()
            } else {
                self.timerLabel.text = "\(self.remainingSeconds)"
            }
        }
    }

    // MARK: - Card display

    private func showCardsFaceDown() {
        let back = UIImage(named: "card_back")
        leftCardImageView.image = back
        rightCardImageView.image = back
    }

    private func showCardsFaceUp() {
        leftCardImageView.image = UIImage(named: imageName(rank: leftRank, suit: leftSuit))
        rightCardImageView.image = UIImage(named: imageName(rank: rightRank, suit: rightSuit))
    }

    private func imageName(rank: Int, suit: String) -> String {
        let rankPart: String
        switch rank {
        case 1:  rankPart = "A"
        case 11: rankPart = "J"
        case 12: rankPart = "Q"
        case 13: rankPart = "K"
        default: rankPart = String(format: "%02d", rank)
        }
        return "card_\(suit)_\(rankPart)"
    }

    // MARK: - End

    private func endGame() {
        timer?.invalidate()
        let result = GameResult(
            playerName: playerName,
            playerSide: playerSide,
            leftScore: leftScore,
            rightScore: rightScore
        )
        performSegue(withIdentifier: "showSummary", sender: result)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSummary",
           let dest = segue.destination as? SummaryViewController,
           let result = sender as? GameResult {
            dest.result = result
        }
    }
}

struct GameResult {
    let playerName: String
    let playerSide: PlayerSide
    let leftScore: Int
    let rightScore: Int

    var winnerName: String {
        if leftScore == rightScore { return "PC" }
        let westWon = leftScore > rightScore
        let playerIsWest = (playerSide == .west)
        let playerWon = (westWon && playerIsWest) || (!westWon && !playerIsWest)
        return playerWon ? playerName : "PC"
    }

    var winnerScore: Int {
        max(leftScore, rightScore)
    }
}
