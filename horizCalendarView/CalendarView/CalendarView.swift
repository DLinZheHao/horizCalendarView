//
//  CalendarView.swift
//  horizCalendarView
//
//  Created by LinZheHao on 2024/1/23.
//

import UIKit

class CustomXibView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setBasicValue()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
        setBasicValue()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
        setBasicValue()
    }
    
    func loadXib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "\(classForCoder)", bundle: bundle)
        /// 透過nib來取得xibView
        let xibView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        addSubview(xibView)
        
        /// 設置xibView的Constraint
        xibView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xibView.topAnchor.constraint(equalTo: topAnchor),
            xibView.leftAnchor.constraint(equalTo: leftAnchor),
            xibView.rightAnchor.constraint(equalTo: rightAnchor),
            xibView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 設定基本畫面要的值 (由子類別複寫)
    /// 必須在 awakeFromNib、init(frame: CGRect)、init?(coder: NSCoder) 都呼叫
    /// 因為用 code init 跟用 xib 呼叫的 func 不一樣
    func setBasicValue() {}
    
}

class CalendarView: CustomXibView {
    /// 月份容器
    @IBOutlet weak var monthCollectionView: UICollectionView!
    /// 日期容器
    @IBOutlet weak var daysCollectionView: UICollectionView!
    
    @IBOutlet weak var daysCollectionViewH: NSLayoutConstraint!
    
    /// 日期 collectionView Layout
    private let dateLayout = {
        let layout = HorizDayFlowLayout()
        let sectionInset = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
        let width = (UIScreen.main.bounds.size.width - sectionInset.left - sectionInset.right) / 7
        let height = width * 54 / ((375 - sectionInset.left - sectionInset.right) / 7)
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = sectionInset
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    var calendarViewModel = CalendarViewModel()
    
    /// 初始化設定
    override func setBasicValue() {
        calendarViewModel.calendarModel = CalendarDataSourceModel(year: calendarViewModel.calendar.component(.year, from: Date()),
                                                                  totalMonth: 6)
        monthCollectionView.delegate = self
        monthCollectionView.dataSource = self
        monthCollectionView.register(CalendarMonthCollectionViewCell.self,
                                     forCellWithReuseIdentifier: CalendarMonthCollectionViewCell.identifier)
        setupMonthCollectionViewLayout()
        
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        daysCollectionView.registerCellWithNib(identifier: CalendarDaysCollectionViewCell.identifier, bundle: nil)
        setupDaysCollectionViewLayout()
    }
    private func setupMonthCollectionViewLayout() {
        let layout = HorizMonthFlowLayout()
        layout.scrollDirection = .horizontal
        monthCollectionView.collectionViewLayout = layout
        monthCollectionView.decelerationRate = .fast // 快速減速
    }
    /// 設定日期 CollectionView Layout
    private func setupDaysCollectionViewLayout() {
        daysCollectionView.collectionViewLayout = dateLayout
        daysCollectionView.isPagingEnabled = true
    }
}

extension CalendarView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        /// 用資料給的需求月份，沒有則用預設的 12 個月
        return calendarViewModel.calendarModel?.totalMonth ?? 12
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case monthCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarMonthCollectionViewCell.identifier, for: indexPath)
            guard let monthCell = cell as? CalendarMonthCollectionViewCell else { return cell }
            monthCell.monthLabel.text = "2024 12 20"
            return monthCell
        case daysCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDaysCollectionViewCell.identifier, for: indexPath)
            guard let daysCell = cell as? CalendarDaysCollectionViewCell else { return cell }
            daysCell.dayLabel.text = "\(indexPath.item)"
            return daysCell
        default:
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let newH = dateLayout.itemSize.height * CGFloat(6 ?? 5)
        daysCollectionViewH.constant = CGFloat(newH)
    }
}
// MARK: - UIScrollViewDelegate
extension CalendarView: UIScrollViewDelegate {
    //scrollView滾動時，就呼叫該方法（任何offset值改變都會呼叫該方法，滾動過程中，呼叫多次）
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 使用者滾動的 collectionView 才計算（因為設 contentOffset 也會觸發這）
        guard scrollView.isDragging else { return }
        let offsetX = scrollView.contentOffset.x
        let scale = callculateScale(of: scrollView, offsetX)
        guard let toView = scrollView == monthCollectionView ? daysCollectionView : monthCollectionView else { return }
        scrollToScaleOffset(scale: scale, to: toView)
    }

    // 滑動scrollView，並且手指離開時執行（只執行一次）
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offsetX = targetContentOffset.pointee.x // 最終位置
        let scale = callculateScale(of: scrollView, offsetX)
        guard let toView = scrollView == monthCollectionView ? daysCollectionView : monthCollectionView else { return }
        scrollToScaleOffset(scale: scale, to: toView)
    }
    
    // 减速停止的時候開始執行（只執行一次）
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let scale = callculateScale(of: scrollView, offsetX)
        calculateDayCollectionHeight(at: lround(scale))
    }
    
    // MARK: - 滾動
    /// 滾動到對應比例位置
    /// - Parameters:
    ///   - scale: 滾動比例/頁數
    ///   - scrollView: 是哪個 CollectionView 要處理
    private func scrollToScaleOffset(scale: CGFloat, to scrollView: UIScrollView) {
        // 設置 CollectionView 的偏移量
        if scrollView == monthCollectionView {
            let monthItemWidth = monthCollectionView.frame.width / 2
            monthCollectionView.contentOffset = CGPoint(x:  monthItemWidth * scale, y: 0)
        } else {
            let dayItemWidth = daysCollectionView.frame.width
            daysCollectionView.contentOffset = CGPoint(x:  dayItemWidth * scale, y: 0)
        }
        /// lround 用于将浮点数转换为最接近的整数
        calculateDayCollectionHeight(at: lround(scale))
    }
    
    /// 計算滾動比例
    /// - Parameter offsetX: 當下是哪個 CollectionView
    /// - Returns:
    private func callculateScale(of scrollView: UIScrollView, _ offsetX: CGFloat) -> CGFloat {
        let monthItemWidth = monthCollectionView.frame.width / 2
        let dayItemWidth = daysCollectionView.frame.width
        var scale: CGFloat = 0
        // 計算當下移動頁面比例
        if scrollView == monthCollectionView {
            scale = offsetX / monthItemWidth
        } else {
            scale = offsetX / dayItemWidth
        }
        return scale
    }

    /// 計算日期 collectionView 高度
    /// - Parameter index: 月份滾到哪一頁了
    private func calculateDayCollectionHeight(at index: Int) {
        
        let newH = dateLayout.itemSize.height * CGFloat(6 ?? 5)
        daysCollectionViewH.constant = CGFloat(newH)
        
    }
}
