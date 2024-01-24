//
//  HorizMonthFlowLayout.swift
//  horizCalendarView
//
//  Created by LinZheHao on 2024/1/24.
//

import UIKit

class HorizMonthFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        // Assuming there is only one section and one item per row.
        guard let collectionView = collectionView else { return }
        
        // Configure the item size based on the collection view's size.
        // The height might be less than the collection view height if you want some vertical padding.
        self.itemSize = CGSize(width: collectionView.bounds.width / 2, height: collectionView.bounds.height)
        
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        
        // Calculate the side insets to center the first and last items.
        // You adjust this if you want a different amount of space on the sides.
        let sideInset = (collectionView.bounds.width - self.itemSize.width) / 2
        self.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    
    // This function returns point at which the collection view will come to rest.
    // Used to center the cell.
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }
        
        // Adjust the proposedContentOffset to make sure the cell is centered.
        let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
        
        let center = collectionView.bounds.size.width / 2
        let proposedCenter = proposedContentOffset.x + center
        
        let closest = layoutAttributes?.min(by: { abs($0.center.x - proposedCenter) < abs($1.center.x - proposedCenter) })
        
        return CGPoint(x: floor(closest?.center.x ?? proposedContentOffset.x) - center, y: proposedContentOffset.y)
    }
    
    /// item 變色處理
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesArray = super.layoutAttributesForElements(in: rect)
        
        // 修改每個 item 的 alpha 值，基於他們離中心的距離
        layoutAttributesArray?.forEach { layoutAttributes in
            guard let collectionView = collectionView else { return }
            let distanceFromCenter = abs((layoutAttributes.center.x - collectionView.contentOffset.x) - collectionView.bounds.width / 2)
            let maxDistance = collectionView.bounds.width / 2
            // 這裡設置 alpha 最小值為 0.5
            let alpha = max(1 - (distanceFromCenter / maxDistance), 0.5)
            layoutAttributes.alpha = alpha
        }
        
        return layoutAttributesArray
    }
    
    // Invalidate layout for bounds change to recalculate for the new width.
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

