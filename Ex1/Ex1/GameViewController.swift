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
    // Holds the callback to fire when the current countdown reaches zero.
    // We keep it as a property so we can recreate the timer after
    // resuming from background and still call the correct continuation.
    private var currentOnFinish: (() -> Void)?

    private let suits = ["hearts", "diamonds", "clubs", "spades"]
    private var leftRank = 0
    private var leftSuit = ""
    private var rightRank = 0
    private var rightSuit = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        registerLifecycleObservers()
        startNewRound()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Leaving the screen (e.g. moving to summary). Stop the timer entirely.
        invalidateTimer()
    }

    deinit {
        // Remove observers so we don't get callbacks on a deallocated controller.
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Lifecycle handling

    /// Register for app-level background/foreground events so the timer
    /// pauses when the user leaves the app and resumes when they return.
    private func registerLifecycleObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(appWillResignActive),
                       name: UIApplication.willResignActiveNotification,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(appDidBecomeActive),
                       name: UIApplication.didBecomeActiveNotification,
                       object: nil)
    }

    /// Called when the app is about to go to background (home / lock / call).
    /// Pause the countdown by invalidating the timer but keep `remainingSeconds`
    /// and `currentOnFinish` so we can resume from the exact point.
    @objc private func appWillResignActive() {
        timer?.invalidate()
        timer = nil
    }

    /// Called when the app comes back to the foreground.
    /// If we still have a countdown in progress, restart it from the
    /// remaining seconds with the same continuation callback.
    @objc private func appDidBecomeActive() {
        guard timer == nil, let onFinish = currentOnFinish, remainingSeconds > 0 else { return }
        scheduleTimer(onFinish: onFinish)
    }

    // MARK: - Setup

    private func configureUI() {
        // Display the player on their side (left=west, right=east) and PC opposite.
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

    /// Starts a new round: deal two random cards face down,
    /// wait 5 seconds, then flip them face up.
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

    /// Flips the cards face up, awards a point, and waits 3 seconds before
    /// moving to the next round (or ending the game after 10 rounds).
    private func flipCardsFaceUp() {
        showCardsFaceUp()
        scoreRound()
        startCountdown(seconds: 3) { [weak self] in
            self?.roundsPlayed += 1
            self?.startNewRound()
        }
    }

    /// Compare the two card ranks. Equal ranks are ignored (per the spec).
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

    /// Start a countdown from `seconds` and call `onFinish` when it reaches 0.
    /// The callback is stored so that if the app goes to background mid-countdown,
    /// we can recreate the timer on return without losing the continuation.
    private func startCountdown(seconds: Int, onFinish: @escaping () -> Void) {
        invalidateTimer()
        remainingSeconds = seconds
        timerLabel.text = "\(remainingSeconds)"
        currentOnFinish = onFinish
        scheduleTimer(onFinish: onFinish)
    }

    /// Internal helper: create the repeating 1-second timer using the existing
    /// `remainingSeconds` value. Used both for a fresh countdown and for resume.
    private func scheduleTimer(onFinish: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                t.invalidate()
                self.timer = nil
                self.currentOnFinish = nil
                onFinish()
            } else {
                self.timerLabel.text = "\(self.remainingSeconds)"
            }
        }
    }

    /// Stop the timer entirely (no resume).
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
        currentOnFinish = nil
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

    /// Build the asset name for a card, e.g. (13, "clubs") -> "card_clubs_K".
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
        invalidateTimer()
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
        // House wins ties (per the spec).
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
