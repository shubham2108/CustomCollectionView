//
//  CustomLayout.swift
//  CustomCollectionView
//
//  Created by Shubham Choudhary on 15/11/18.
//  Copyright © 2018 Shubham. All rights reserved.
//

import UIKit

//Protocol to accept height and width of cell
protocol CustomLayoutDelegate {
    func cellWidthAndHight(index : Int) -> (CGFloat, CGFloat)
}

class CustomLayout: UICollectionViewFlowLayout {
    //Variables
    var layoutDelegate : CustomLayoutDelegate?
    
    var cellPadding: CGFloat = 5
    
    private var xOffset = CGFloat(0)
    private var yOffset = CGFloat(0)
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var collectionViewOffSets: [(CGPoint, CGPoint)] = []
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    fileprivate var contentHeight: CGFloat = 0
    
    //Reset FlowLayout
    func resetLayout() {
        cache = []
        xOffset = 0
        yOffset = 0
        contentHeight = 0
        collectionViewOffSets = []
    }
    
    
    override func prepare() {
        guard let collectionView = collectionView else{
            return
        }
        
        if collectionViewOffSets.isEmpty {
            collectionViewOffSets = [(CGPoint(x: xOffset, y: yOffset), CGPoint(x: xOffset + contentWidth, y: yOffset))]
        }
        
        let cachedItems = cache.count
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        for item in cachedItems ..< numberOfItems{
            var frame = CGRect.zero
            if let delegate = layoutDelegate {
                let cellSize = delegate.cellWidthAndHight(index: item)
                frame.size.width = cellSize.0
                frame.size.height = cellSize.1
            }
            
            // Skip item if item width is more then content width
            if frame.size.width > contentWidth {
                continue
            }
            
            let result = getOriginToPlaceCell(frame: frame, array: collectionViewOffSets)
            frame = result.0
            collectionViewOffSets = result.1
            
            //Here merge lines with same y-axis and same last and initial x-axis
            collectionViewOffSets = mergeLines(array: collectionViewOffSets)
            
            print("item = ", item, " y-axis = ", collectionViewOffSets)
            
            contentHeight = max(contentHeight, frame.maxY + cellPadding)
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
        }
        
    }
    
    // Here calculate collection view bottom boundery and cell origin point
    private func getOriginToPlaceCell(frame: CGRect ,array: [(CGPoint, CGPoint)]) -> (CGRect, [(CGPoint, CGPoint)]) {
        // Here calculate collection view bottom boundery and cell origin point
        var array = array
        var frame = frame
        //Here sort bottom boundery based on y-axis
        array.sort{ $0.1.y < $1.1.y }
        for (index, line) in array.enumerated() {
            if index > 0 {
                array = realignLines(index: index, yAxis: line.0.y, array: array)
                let mergedArray = mergeLines(array: array)
                if array.count != mergedArray.count {
                    array = mergedArray
                    let result = getOriginToPlaceCell(frame: frame, array: array)
                    frame = result.0
                    array = result.1
                    break
                }
            }
            let length = line.1.x - line.0.x
            if length >= frame.size.width {
                frame.origin = line.0
                let newLine = (CGPoint(x: frame.minX, y: frame.maxY), CGPoint(x: frame.maxX, y: frame.maxY))
                //Handle if line length is zero or not
                if newLine.1.x.isEqual(to: line.1.x) {
                    array.remove(at: index)
                }else {
                    let updatedLine = (CGPoint(x: newLine.1.x, y: line.0.y), line.1)
                    array[index] = updatedLine
                }
                array.append(newLine)
                break
            }
        }
        return (frame, array)
    }
    
    
    private func realignLines(index: Int, yAxis: CGFloat ,array: [(CGPoint, CGPoint)]) -> [(CGPoint, CGPoint)] {
        var array = array
        for indexx in 0 ..< index {
            var oldLine = array[indexx]
            oldLine.0.y = yAxis
            oldLine.1.y = yAxis
            array[indexx] = oldLine
        }
        return array
    }
    
    //Here merge lines if lines are of same lavels or line length is less then the double of cell padding
    private func mergeLines(index: Int = 0, array: [(CGPoint, CGPoint)]) -> [(CGPoint, CGPoint)] {
        var arrayOfLine = array
        
        //Here sort bottom boundery based on x-axis
        arrayOfLine.sort{ $0.0.x < $1.0.x }
        
        for indexx in index ..< arrayOfLine.count {
            guard arrayOfLine.count > indexx + 1  else {
                return arrayOfLine
            }
            let line1 = arrayOfLine[indexx]
            let line2 = arrayOfLine[indexx+1]
            
            // if line1 is on same lavel of line2 then merge the line1 with line2 ane remove line2 from array
            if line1.0.y == line2.0.y {
                let newLine = (line1.0, line2.1)
                arrayOfLine[indexx] = newLine
                arrayOfLine.remove(at: indexx + 1)
                arrayOfLine = mergeLines(index: indexx, array: arrayOfLine)
            }
            
            // if line1 is less then twice of cell padding then merge the line1 with line2 ane remove line1 from array
            let lineOneLenght = line1.1.x - line1.0.x
            if lineOneLenght < (2 * cellPadding) + 1 {
                let newLine = (CGPoint(x: line1.0.x, y: line2.0.y), line2.1)
                arrayOfLine[indexx] = newLine
                arrayOfLine.remove(at: indexx + 1)
                arrayOfLine = mergeLines(index: indexx, array: arrayOfLine)
            }
        }
        
        return arrayOfLine
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override var collectionViewContentSize: CGSize{
        return CGSize.init(width: contentWidth, height: contentHeight)
    }
    
}

extension CGFloat {
    func roundToFloat(_ fractionDigits: Int) -> CGFloat {
        let multiplier = pow(10, CGFloat(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

