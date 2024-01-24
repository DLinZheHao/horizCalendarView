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
        
        // 計算 section 左右的邊距，讓 section 能夠置中
        // Calculate the side insets to center the first and last items.
        // You adjust this if you want a different amount of space on the sides.
        let sideInset = (collectionView.bounds.width - self.itemSize.width) / 2
        self.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    
    // This function returns point at which the collection view will come to rest.
    // Used to center the cell.
    
//    當使用者在 UICollectionView 中滑動時，系統會提供一個預期的停止點，這就是 proposedContentOffset。而這段程式碼的目的是在使用者停止滑動後，調整最終的 Content Offset，以確保最接近 CollectionView 中心的 cell 會被放置在 CollectionView 的正中央位置。
//
//    假設 proposedContentOffset.x 是 250，表示系統預期 Content Offset 的 x 座標為 250。
//
//    找到最接近中心的cell的中心位置 (closest?.center.x):
//
//    假設三個 cells 的中心位置分別是 100、200 和 300。
//    因此，在這個例子中，最接近中心的是中心位置在 200 的 cell。
//    調整 Content Offset，使得最接近中心的cell會被放置在 CollectionView 的中央位置 (floor(...) - center):
//
//    使用 floor 將最接近中心的cell的中心位置取整數，這裡取整後為 200。
//    將取整後的值減去 center（CollectionView 寬度的一半），假設 center 為 150。
//    計算結果為 200 - 150 = 50。
//    因此，新的 Content Offset.x 將被調整為 50，確保最接近中心的cell會被放置在 CollectionView 的正中央位置。
//    這樣，這段程式碼的目的是根據滑動的情況，調整 Content Offset 以確保最接近中心的 cell 會被置中在 CollectionView 的正中央位置。

    // Content offset.x 是整個 content 畫面裡的座標位置
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }
        //  proposedContentOffset 是在使用者滑動 UICollectionView 時，系統提供的預期的Content Offset。當使用者手指離開螢幕後，CollectionView會繼續滑動一段時間，而這個時間內的預期終點就是 proposedContentOffset。換句話說，它代表了使用者停止滑動後，CollectionView預計停留的位置。
        
        // 取得CollectionView當前可見範圍內所有cell的layoutAttributes。
        // Adjust the proposedContentOffset to make sure the cell is centered.
        let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
        
        // 計算CollectionView的中心位置
        let center = collectionView.bounds.size.width / 2
        // 計算建議的Content Offset的中心位置
        let proposedCenter = proposedContentOffset.x + center
        // 找到離建議中心位置最近的cell的layoutAttributes
        let closest = layoutAttributes?.min(by: { abs($0.center.x - proposedCenter) < abs($1.center.x - proposedCenter) })
        
        // 返回更準確的『換畫面顯示中心位置』
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

