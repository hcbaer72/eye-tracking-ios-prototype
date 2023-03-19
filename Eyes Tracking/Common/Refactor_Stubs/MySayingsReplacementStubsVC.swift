//
//  MySayingsReplacementStubsVC.swift
//  Vocable
//
//  Created by Chris Stroud on 4/29/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import CoreData

class MySayingsReplacementStubsVC: PagingCarouselViewController, NSFetchedResultsControllerDelegate {

    private var disposables = Set<AnyCancellable>()

    private lazy var diffableDataSource = CarouselCollectionViewDataSourceProxy<Int, PhraseViewModel>(collectionView: collectionView) { [weak self] (collectionView, indexPath, phrase) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditPhrasesCollectionViewCell.reuseIdentifier, for: indexPath) as! EditPhrasesCollectionViewCell
        cell.textLabel.text = phrase.utterance
        cell.deleteButton.addTarget(self,
                                    action: #selector(self.handleCellDeletionButton(_:)),
                                    for: .primaryActionTriggered)
        cell.editButton.addTarget(self,
                                  action: #selector(self.handleCellEditButton(_:)),
                                  for: .primaryActionTriggered)
        return cell
    }

    private lazy var fetchRequest: NSFetchRequest<Phrase> = {
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, true)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        return request
    }()

    private lazy var fetchResultsController = NSFetchedResultsController<Phrase>(fetchRequest: self.fetchRequest,
                                                                                 managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                                 sectionNameKeyPath: nil,
                                                                                 cacheName: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.title = Category.userFavoritesCategoryName()
        navigationBar.rightButton = {
            let button = VocableNavigationBarButton(frame: .zero)
            button.buttonImage = UIImage(systemName: "plus")
            button.addTarget(self, action: #selector(addPhrasePressed), for: .primaryActionTriggered)
            return button
        }()

        collectionView.register(UINib(nibName: "EditPhrasesCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: EditPhrasesCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .collectionViewBackgroundColor

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        updateDataSource(animated: false)
    }

    @IBAction private func addPhrasePressed() {
        let vc = EditTextViewController()
        vc.editTextCompletionHandler = { (newText) -> Void in
            let context = NSPersistentContainer.shared.viewContext

            _ = Phrase.create(withUserEntry: newText, in: context)
            do {
                try context.save()

                let alertMessage: String = {
                    let format = NSLocalizedString("phrase_editor.toast.successfully_saved_to_favorites.title_format", comment: "Saved to user favorites category toast title")
                    let categoryName = Category.userFavoritesCategoryName()
                    return String.localizedStringWithFormat(format, categoryName)
                }()

                ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
            } catch {
                assertionFailure("Failed to save user generated phrase: \(error)")
            }
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {
        collectionView.layout.interItemSpacing = 8

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .fixedCount(4)
        case (.compact, .regular):
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .minimumHeight(130)
        case (.compact, .compact), (.regular, .compact):
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .fixedCount(2)
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true)
    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {

        let pageCountBefore = collectionView.layout.pagesPerSection

        let content = fetchResultsController.fetchedObjects ?? []
        let viewModels = content.compactMap(PhraseViewModel.init)
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhraseViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModels)
        diffableDataSource.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)

        let pageCountAfter = collectionView.layout.pagesPerSection

        if viewModels.isEmpty {
            installEmptyStateIfNeeded()
        } else {
            removeEmptyStateIfNeeded()
        }

        if pageCountBefore < 2, pageCountAfter > 1 {
            collectionView.scrollToMiddleSection(animated: true)
        }
    }

    private func installEmptyStateIfNeeded() {
        guard AppConfig.emptyStatesEnabled else { return }
        guard collectionView.backgroundView == nil else { return }
        paginationView.isHidden = true
        collectionView.backgroundView = PhraseCollectionEmptyStateView(action: addPhrasePressed)
    }

    private func removeEmptyStateIfNeeded() {
        paginationView.isHidden = false
        collectionView.backgroundView = nil
    }

    @objc private func handleCellDeletionButton(_ sender: UIButton) {

        func deleteAction() {
            self.deletePhrase(sender)
        }

        let title = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.title",
                                      comment: "Delete phrase confirmation alert title")
        let deleteButtonTitle = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.button.delete.title",
                                                  comment: "Delete phrase alert action button title")
        let cancelButtonTitle = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.button.cancel.title",
                                                  comment: "Delete phrase alert cancel button title")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle))
        alert.addAction(GazeableAlertAction(title: deleteButtonTitle, handler: deleteAction))
        self.present(alert, animated: true)
    }

    private func deletePhrase(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }

        let safeIndexPath = diffableDataSource.indexPath(fromMappedIndexPath: indexPath)
        let phrase = self.fetchResultsController.object(at: safeIndexPath)
        let context = NSPersistentContainer.shared.viewContext
        context.delete(phrase)
        try? context.save()
    }

    @objc private func handleCellEditButton(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }

        let safeIndexPath = diffableDataSource.indexPath(fromMappedIndexPath: indexPath)
        let vc = EditTextViewController()

        let phrase = fetchResultsController.object(at: safeIndexPath)
        vc.initialText = phrase.utterance ?? ""
        vc.editTextCompletionHandler = { (newText) -> Void in
            let context = NSPersistentContainer.shared.viewContext

            if let phraseIdentifier = phrase.identifier {
                let originalPhrase = Phrase.fetchObject(in: context, matching: phraseIdentifier)
                originalPhrase?.utterance = newText
            }
            do {
                try context.save()

                let alertMessage = NSLocalizedString("category_editor.toast.changes_saved.title",
                                                     comment: "changes to an existing phrase were saved successfully")

                ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
            } catch {
                assertionFailure("Failed to save user generated phrase: \(error)")
            }
        }
        present(vc, animated: true)

    }

    private func handleDismissAlert() {
        func discardChangesAction() {
            self.navigationController?.popViewController(animated: true)
        }

        let title = NSLocalizedString("phrase_editor.alert.cancel_editing_confirmation.title",
                                      comment: "Exit edit sayings alert title")
        let discardButtonTitle = NSLocalizedString("phrase_editor.alert.cancel_editing_confirmation.button.discard.title",
                                                   comment: "Discard changes alert action title")
        let continueButtonTitle = NSLocalizedString("phrase_editor.alert.cancel_editing_confirmation.button.continue_editing.title",
                                                    comment: "Continue editing alert action title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: discardButtonTitle, handler: discardChangesAction))
        alert.addAction(GazeableAlertAction(title: continueButtonTitle, style: .bold))
        self.present(alert, animated: true)
    }
}
