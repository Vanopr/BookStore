//
//  CardForLikes.swift
//

import UIKit
import SnapKit
import Foundation
import RealmSwift

protocol CardForLikesDelegate: AnyObject {
    func deleteButtonTapped(at indexPath: IndexPath)
}

class CardForLikes: UITableViewCell {
    var indexPath: IndexPath!
    weak var delegate: CardForLikesDelegate?
    var book: Book?
    private let likedService = LikeService.shared
    
    private let delButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cross"), for: .normal)
        button.backgroundColor = .black
        
        return button
    }()
    
    private let rectView: UIView = {
        let rectView = UIView()
        rectView.backgroundColor = .black
        rectView.layer.cornerRadius = 10
        rectView.layer.masksToBounds = true
        
        return rectView
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.textColor = .white
        
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        
        return label
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(rectView)
        rectView.addSubview(delButton)
        rectView.addSubview(titleLabel)
        rectView.addSubview(authorLabel)
        rectView.addSubview(coverImageView)
        rectView.addSubview(categoryLabel)
        
        rectView.snp.makeConstraints { make in
            make.height.equalTo(140)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        coverImageView.snp.makeConstraints { make in
            make.height.equalTo(rectView.snp.height)
            make.width.equalTo(100)
            make.leading.equalToSuperview()
        }
        
        delButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.height.width.equalTo(20)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(8)
            make.trailing.equalTo(delButton.snp.leading).offset(-8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryLabel)
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.trailing.equalTo(categoryLabel)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.equalTo(titleLabel)
        }
    }
    
    func configure(title: String, image: UIImage, subjects: String, indexPath: IndexPath,  delegate: CardForLikesDelegate ) {
        titleLabel.text = title
        coverImageView.image = image
        authorLabel.text = subjects
        self.indexPath = indexPath
        self.delegate = delegate
        delButton.addTarget(self, action: #selector(delCell), for: .touchUpInside)
    }
    
    @objc func delCell() {
        delegate?.deleteButtonTapped(at: indexPath)
    }
}



