//
//  ViewController.swift
//  WordScramble
//
//  Created by Mehmet Ergün on 2022-07-30.
//

import UIKit

class ViewController: UITableViewController {
    
     var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsPath = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsPath) {
                self.allWords = startWords.components(separatedBy: "\n")
            }
        }else {
            self.allWords = ["silkworm"]
        }
        
        self.startGame()
        
    }
    
    @objc func promptForAnswer() {
        
        let alert = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak alert] _ in
            guard let answer = alert?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        alert.addAction(submitAction)
        present(alert, animated: true)
        
    }
    
    func submit(_ answer: String) {
        
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                }else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You cannot write that!"
                }
            }else {
                errorTitle = "Word already used"
                errorMessage = "You should be more original!"
            }
        }else {
            errorTitle = "Word not possible"
            guard let title = title?.lowercased() else  {
                return
            }
            errorMessage = "You cannot spell that word from \(title). "
        }
        
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position =  tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
                
            }else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func startGame() {
        title = self.allWords.randomElement()
        self.usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = self.usedWords[indexPath.row]
        return cell
    }


}

