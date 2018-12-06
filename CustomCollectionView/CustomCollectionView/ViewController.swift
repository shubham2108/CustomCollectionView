//
//  ViewController.swift
//  CustomCollectionView
//
//  Created by Shubham Choudhary on 15/11/18.
//  Copyright © 2018 Shubham. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellSize: [(CGFloat, CGFloat)] = [(234, 149), (300, 200), (100, 100), (100, 100), (200, 300), (60, 300), (200, 200), (50, 200), (124, 200), (60, 200),(230, 149), (70, 200), (130, 100), (70, 100), (260, 300), (190, 200), (274, 149), (265, 200), (170, 100), (100, 100), (180, 300), (200, 200), (200, 200), (50, 200), (30, 200), (50, 198),(284, 200)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Register the cell for collection view
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        
        //Assign the delegate
        if let layout = collectionView.collectionViewLayout as? CustomLayout{
            layout.layoutDelegate = self
        }
    }
    
    // UICollectionViewDataSource methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellSize.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.gray
        (cell.viewWithTag(1) as! UILabel).text = "\(indexPath.item)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
}

//CustomLayoutDelegate method


extension ViewController: CustomLayoutDelegate {
    
    func cellWidthAndHight(index : Int) -> (CGFloat, CGFloat) {
        return cellSize[index]
    }
}

