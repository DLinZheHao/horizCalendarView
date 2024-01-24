//
//  HorizDayFlowLayout.swift
//  horizCalendarView
//
//  Created by LinZheHao on 2024/1/23.
//
import UIKit

class HorizDayFlowLayout: UICollectionViewFlowLayout {
    
    // 緩存 attributes
    private var cache = [UICollectionViewLayoutAttributes]()
    
    // 保存內容的總寬度
    private var contentWidth: CGFloat = 0
    
    // collectionView 的内容大小
    override var collectionViewContentSize: CGSize {
        let height = collectionView?.frame.height ?? 0
        return CGSize(width: contentWidth, height: height)
    }

    // 布局操作
    override func prepare() {
        guard let collectionView = collectionView else { return }
        cache.removeAll()
        contentWidth = 0

        /// 所有月份
        let sections = collectionView.numberOfSections
        /// xOffset 起始位置會是 section 左邊的 inset
        /// 用於左邊空間
        var xOffset: CGFloat = sectionInset.left
        
        for section in 0..<sections {
            let itemCount = collectionView.numberOfItems(inSection: section)
            /// 用於換行
            var yOffset: CGFloat = 0
            var row = 0
            
            for item in 0..<itemCount {
                let indexPath = IndexPath(item: item, section: section)
                let itemSize = self.itemSize
                
                // 新的開始
                if item % numberOfItemsPerRow == 0 && item != 0 {
                    yOffset += itemSize.height + minimumLineSpacing
                    row += 1
                }
                
                // 計算每個 item 的 frame
                let frame = CGRect(x: xOffset + CGFloat(item % numberOfItemsPerRow) * (itemSize.width + minimumInteritemSpacing),
                                   y: yOffset,
                                   width: itemSize.width,
                                   height: itemSize.height)
                
                // 創建 attributes 並緩存
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                
                // 計算 contentWidth
                contentWidth = max(contentWidth, frame.maxX + sectionInset.right)
            }
            
            // 在每個 section 後增加偏移
            if itemCount > 0 {
                xOffset += CGFloat(numberOfItemsPerRow) * itemSize.width + CGFloat(numberOfItemsPerRow - 1) * minimumInteritemSpacing + sectionInset.left + sectionInset.right
            }
            
        }
    }
    
    // 返回對應指定矩形的所有布局屬性
    // 用于返回在给定矩形内的所有元素的布局属性
    // 当你自定义 UICollectionViewLayout 时，你可以重写这个方法来提供自定义的布局属性，以便 UICollectionView 在显示内容时能够正确布局和显示每个元素。
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            // 判断该布局属性的框架（frame）是否与给定的矩形 rect 相交
            // 如果相交，就将该布局属性对象添加到 visibleLayoutAttributes 数组中，表示它是可见的。

            // 最终，visibleLayoutAttributes
            // 数组中包含了与给定矩形相交的可见元素的布局属性。这种方式可以用于在滚动或更新布局时，选择需要更新或显示的元素，而不必重新计算所有元素的布局属性，提高性能
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    // 返回對應於指定索引路徑的 item 的布局屬性
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath }
    }
    
    // 每行 item 數量
    private var numberOfItemsPerRow: Int {
        guard let collectionView = collectionView else { return 0 }        
        // inset(by:) 方法则是在给定的矩形周围添加内边距。这可以用于将原始矩形的大小缩小，以反映出内边距的影响。实际上，collectionView.bounds.inset(by: collectionView.contentInset) 返回一个新的矩形，该矩形的边界已经考虑了 collectionView 的内容内边距。

        // 例如，如果 collectionView 的内容内边距是 (10, 20, 10, 20)，那么通过 inset(by:) 方法调整边界矩形，就会在左边添加 20 点的内边距，右边添加 20 点的内边距，顶部添加 10 点的内边距，底部添加 10 点的内边距。这样，你就获得了一个考虑了内容内边距的新边界矩形。
        let availableWidth = collectionView.bounds.inset(by: collectionView.contentInset).width
        let numberOfItems = Int(availableWidth / (itemSize.width + minimumInteritemSpacing))
        return max(numberOfItems, 1)
    }
}
