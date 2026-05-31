//
//  SummaryViewController.swift
//  Ex1
//

import UIKit

class SummaryViewController: UIViewController {

    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    var result: GameResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let result = result else { return }
        winnerLabel.text = "Winner: \(result.winnerName)"
        scoreLabel.text = "score: \(result.winnerScore)"
    }

    @IBAction func backToMenuTapped(_ sender: UIButton) {
        // Dismiss both Summary and Game by dismissing what the menu presented.
        view.window?.rootViewController?.dismiss(animated: true)
    }
}
