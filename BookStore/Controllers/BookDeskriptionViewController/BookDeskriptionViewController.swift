//
//  BookDeskriptionViewController.swift
//  BookStore
//
//  Created by Юрий on 11.12.2023.
//

import UIKit
import OpenLibraryKit

class BookDescriptionViewController: UIViewController {
    
    private var isLiked = false
    private let likedService = LikeService.shared
    private let openLibraryService = OpenLibraryService()
    var bookId: String
    var ifBookLoaded = false
    

    //MARK: - init
    init(bookId: String) {
        self.bookId = bookId
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.bookId = ""
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var bookNameLabel: UILabel = {
        createLabel(with: "", fontSize: 30, fontWeight: .bold)
    }()
    
    private let bookImage: UIImageView = {
        let bookImage = UIImageView()
        bookImage.image = UIImage(named: "noImage")
        bookImage.contentMode = .scaleAspectFit
        bookImage.translatesAutoresizingMaskIntoConstraints = false
        return bookImage
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var authorLabel: UILabel = {
        createLabel(with: "Author:", fontSize: 16, fontWeight: .medium)
    }()
    
    private lazy var authorNameLabel: UILabel = {
        createLabel(with: "Oscar Wilde", fontSize: 16, fontWeight: .bold)
    }()
    
    private lazy var categoryLabel: UILabel = {
        createLabel(with: "Category:", fontSize: 16, fontWeight: .medium)
    }()
    
    private lazy var categoryNameLabel: UILabel = {
        createLabel(with: "", fontSize: 16, fontWeight: .bold)
    }()
    
    private lazy var ratingLabel: UILabel = {
        createLabel(with: "Rating:", fontSize: 16, fontWeight: .medium)
    }()
    
    private lazy var bookRatingLabel: UILabel = {
        createLabel(with: "", fontSize: 16, fontWeight: .bold)
    }()
    
    private lazy var descriptionLabel: UILabel = {
        createLabel(with: "Description:", fontSize: 16, fontWeight: .bold)
    }()
    
    private lazy var bookDescriptionLabel: UILabel = {
        let label = createLabel(with: "", fontSize: 16, fontWeight: .regular)
        
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var authorStackView: UIStackView = {
        createStack(arrangedSubviews: [authorLabel, authorNameLabel], axis: .horizontal)
    }()
    
    private lazy var categoryStackView: UIStackView = {
        createStack(arrangedSubviews: [categoryLabel, categoryNameLabel], axis: .horizontal)
    }()
    
    private lazy var ratingStackView: UIStackView = {
        createStack(arrangedSubviews: [ratingLabel, bookRatingLabel], axis: .horizontal)
    }()
    
    private lazy var verticalStack: UIStackView = {
        createStack(arrangedSubviews: [authorStackView, categoryStackView, ratingStackView], axis: .vertical)
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBookDetails(id: bookId)
        setupNavigationBar()
        likeButtonCheck()
        setupViews()
        setConstraints()
    }
}

//MARK: - Private Methods

private extension BookDescriptionViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(bookNameLabel)
        contentView.addSubview(bookImage)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(verticalStack)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(bookDescriptionLabel)
    }
    
    func setupUI(with data: Work) {
        //authorNameLabel.text = data.subjectPeople
        DispatchQueue.main.async {
            self.categoryNameLabel.text = data.subjects[0]
            self.navigationItem.title = data.subjects[0]
            //self.authorNameLabel.text = data.subjectPeople?[0]
            self.fetchRating()
            self.bookNameLabel.text = data.title
            self.bookDescriptionLabel.text = data.bookDescription.debugDescription
            ImageLoader.loadImage(withCoverID: "\(data.covers[0])", size: .M) { image in
                if let myImage = image {
                    self.bookImage.image = myImage
                    self.activityIndicator.stopAnimating()
                    print("Successfully loaded image")
                } else {
                    print("Failed to load image")
                }
            }
            self.view.reloadInputViews()
            self.ifBookLoaded = true
        }
    }
    
    func createLabel(with text: String, fontSize: CGFloat, fontWeight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createStack(arrangedSubviews views: [UIView], axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = axis
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.tabBarController?.tabBar.isHidden = true
        navigationItem.title = "Classics"

        let likeButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(likeButtonTapped))
        navigationItem.rightBarButtonItem = likeButton
    }
    
    private func likeButtonCheck() {
        isLiked = likedService.ifElementLiked(bookId)
            if isLiked {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            } else {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            }
    }
    
    @objc func likeButtonTapped() {
        isLiked = likedService.ifElementLiked(bookId)
        let book: Book = Book(
            id: bookId,
            title: bookNameLabel.text ?? "",
            image: bookImage.image ?? UIImage(),
            category: categoryLabel.text ?? ""
        )
        if isLiked {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            likedService.removeElement(book)
        } else {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            likedService.appendElement(book)
        }
        
        print(likedService.likedBooks)
    }
    
    func fetchBookDetails(id: String?) {
        activityIndicator.startAnimating()
        guard let id else { return }
        openLibraryService.fetchBookDetails(bookID: id) { result in
            switch result {
            case .success(let data):
                self.setupUI(with: data)
                print(data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchRating() {
        let random = Float.random(in: 3.5...5)
        let formattedRandom = String(format: "%.1f", random)
        DispatchQueue.main.async {
            self.bookRatingLabel.text = "\(formattedRandom)/5"
        }
    }
}


// MARK: - Set Constraints

extension BookDescriptionViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            bookNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            bookNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bookNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            activityIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            
            bookImage.topAnchor.constraint(equalTo: bookNameLabel.bottomAnchor, constant: 15),
            bookImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            verticalStack.topAnchor.constraint(equalTo: bookNameLabel.bottomAnchor, constant: 25),
            verticalStack.leadingAnchor.constraint(equalTo: bookImage.trailingAnchor, constant: 15),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: bookImage.bottomAnchor, constant: 15),
            descriptionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 10),
            
            bookDescriptionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
            bookDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bookDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bookDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
