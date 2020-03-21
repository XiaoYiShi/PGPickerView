////
////  PGPickerColumnView.swift
////  PickerViewDemo
////
////  Created by 史晓义 on 2020/3/10.
////  Copyright © 2020 piggybear. All rights reserved.
////
//
//import UIKit
//
//@objc class PGPickerColumnView: UIView
//{
//    @objc public weak var delegate : PGPickerColumnViewDelegate?
//    @objc public var datas = [NSAttributedString]()
//    {
//        didSet {
//            setupCycleScrollWithDatas(datas: datas)
//            safeReloadData()
//        }
//    }
//    
//    @objc public var component : Int = 0
//    @objc public var selectedRow : Int = 0 {
//        didSet {
//            if (self.datas.count > selectedRow) {
//                let attriString = self.datas[selectedRow]
//                self.textOfSelectedRow = attriString.string
//            }
//            if (self.delegate && [self.delegate respondsToSelector:@selector(pickerColumnView:didSelectRow:)]) {
//                [self.delegate pickerColumnView:self didSelectRow:selectedRow];
//            }
//            if (self.delegate && [self.delegate respondsToSelector:@selector(pickerColumnView:title:didSelectRow:)]) {
//                [self.delegate pickerColumnView:self title:self.textOfSelectedRow didSelectRow:selectedRow];
//            }
//        }
//    }
//    
//    @objc public var viewBackgroundColors : [UIColor]?
//    @objc public var refresh : ObjCBool = false
//    @objc public var textOfSelectedRow = ""
//    @objc public var textColorOfSelectedRow : UIColor?
//    @objc public var textFontOfSelectedRow : UIFont?
//    @objc public var textColorOfOtherRow : UIColor?
//    @objc public var textFontOfOtherRow : UIFont?
//    @objc public var isHiddenWheels : ObjCBool = false
//    @objc public var isCycleScroll : ObjCBool = false
//    
//    private var kWidth : CGFloat {
//        return self.frame.size.width
//    }
//    private var kHeight : CGFloat {
//        return self.frame.size.height
//    }
//    
//    - (instancetype)initWithFrame:(CGRect)frame rowHeight:(CGFloat)rowHeight upLineHeight:(CGFloat)upLineHeight downLineHeight:(CGFloat)downLineHeight isCycleScroll:(BOOL)isCycleScroll datas:(NSArray *)datas {
//        if (self = [super initWithFrame:frame]) {
//            self.isCycleScroll = isCycleScroll;
//            self.copyCycleScroll = isCycleScroll;
//            self.rowHeight = rowHeight;
//            self.upLineHeight = upLineHeight;
//            self.downLineHeight = downLineHeight;
//            self.backgroundColor = [UIColor clearColor];
//            self.upLinePosY = (self.bounds.size.height - self.rowHeight) / 2 - self.upLineHeight;
//            NSInteger index = self.upLinePosY / self.rowHeight;
//            self.offsetCount = index + 1;
//            self.offset = self.offsetCount * self.rowHeight - self.upLinePosY;
//            if (self.offset == self.rowHeight) {
//                self.offset = 0;
//                self.offsetCount -= 1;
//            }
//            self.showCount = (frame.size.height / self.rowHeight - 1) / 2;
//            self.circumference = self.rowHeight * self.showCount * 2 - 25;
//            self.radius = self.circumference / M_PI * 2;
//            self.copyOffsetCount = self.offsetCount;
//            
//            [self setupCycleScrollWithDatas:datas];
//            [self setupView];
//        }
//        return self;
//    }
//    @objc(selectRow:animated:)
//    public func selectRow(row:Int,animated:ObjCBool)
//    {
//        NSInteger newRow = row;
//        if (self.isCycleScroll) {
//            newRow = row - self.copyOffsetCount;
//        }
//        if (animated) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRow inSection:0];
//            [self.centerTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
//            self.selectedRow = row;
//            self.isSelectedRow = true;
//        }else {
//            self.centerTableView.contentOffset = CGPointMake(0, newRow * self.rowHeight);
//            [self scrollViewDidEndDecelerating: self.centerTableView];
//        }
//    }
//    private var rowHeight:CGFloat = 0
//    private var upView:UIView?
//    
//    private var centerView:UIView?
//    private var downView:UIView?
//    
//    private var upTableView:PGPickerTableView?
//    private var centerTableView:PGPickerTableView?
//    private var downTableView:PGPickerTableView?
//    
//    private var offset:CGFloat?
//    private var offsetCount = 0
//    
//    private var upLinePosY:CGFloat = 0
//    
//    private var upLineHeight:CGFloat = 0
//    private var downLineHeight:CGFloat = 0
//    
//    private var showCount:CGFloat = 0
//    
//    private var isSubViewLayouted:Bool = false
//    private var circumference:CGFloat = 0
//    private var radius:CGFloat = 0
//    
//    private var copyCycleScroll:Bool = false
//    private var copyOffsetCount:Int = 0
//    
//    private var isSelectedRow:Bool = false
//    
//}
//extension PGPickerColumnView
//{
//
//    
//    
//
//    
//}
//extension PGPickerColumnView:UITableViewDelegate, UITableViewDataSource
//{
//
//    ///MARK: - UIScrollViewDelegate
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        CGPoint offset = tableView.contentOffset;
//        NSInteger rowHeight = self.rowHeight;
//        NSInteger posY = offset.y;
//        NSInteger value = posY % rowHeight;
//        CGFloat itemAngle = value * ((rowHeight / self.radius) / rowHeight);
//        
//        if (self.isCycleScroll) {
//            if (posY < self.rowHeight * self.datas.count * 2) {
//                posY = posY + self.rowHeight * self.datas.count;
//            }
//            if (posY > self.rowHeight * self.datas.count * 3) {
//                posY = posY - self.rowHeight * self.datas.count;
//            }
//        }
//        
//        if (self.centerTableView == tableView) {
//            self.upTableView.contentOffset = CGPointMake(0, posY);
//            self.downTableView.contentOffset = CGPointMake(0, posY);
//            return;
//        }
//        
//        if (tableView == self.downTableView) {
//            self.centerTableView.contentOffset = CGPointMake(0, posY);
//            if (!self.isHiddenWheels) {
//                [tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof PGPickerColumnCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    NSUInteger index = idx - self.showCount;
//                    NSInteger length = index * rowHeight;
//                    CGFloat angle = length / self.radius - itemAngle;
//                    CGFloat scale = cos(angle / 2);
//                    [obj transformWith:angle scale:scale];
//                }];
//            }
//            return;
//        }
//        
//        if (tableView == self.upTableView) {
//            self.centerTableView.contentOffset = CGPointMake(0, posY);
//            if (!self.isHiddenWheels) {
//                [tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof PGPickerColumnCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    NSUInteger index = self.showCount - idx;
//                    NSInteger length = index * rowHeight;
//                    CGFloat angle = length / self.radius + itemAngle;
//                    CGFloat scale = cos(angle / 2);
//                    [obj transformWith:angle scale: scale];
//                }];
//            }
//        }
//    }
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        
//        if (decelerate) return;
//        [self scrollViewDidEndDecelerating:scrollView];
//    }
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        
//        [self setupTableViewScroll:tableView animated:true];
//        self.selectedRow = [self setupSelectedRow];
//    }
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        
//        if (!self.isSelectedRow) {
//            [self setupTableViewScroll:tableView animated:false];
//            NSUInteger row = [self setupSelectedRow];
//            self.selectedRow = row;
//        }
//        if (self.isSelectedRow) {
//            self.isSelectedRow = false;
//        }
//        
//    }
//
//    ///MARK: - row logic
//    func numberOfRowsInTableView() -> Int {
//        return self.datas.count + self.offsetCount * 2;
//    }
//
//    ///MARK: - UITableViewDataSource
//    func numberOfSections(in tableView: UITableView) -> Int {
//        if (self.isCycleScroll) {
//            return 10;
//        }
//        return 1;
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return [self numberOfRowsInTableView];
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        PGPickerColumnCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
//        NSInteger row = indexPath.row - self.offsetCount;
//        
//        if (indexPath.row < self.offsetCount || row >= self.datas.count) {
//            cell.label.attributedText = [[NSAttributedString alloc] initWithString: @""];
//            cell.contentView.backgroundColor = [UIColor clearColor];
//        }else {
//            cell.label.attributedText = self.datas[row];
//            cell.contentView.backgroundColor = self.viewBackgroundColors[row];
//            
//            if (!self.isHiddenWheels) {
//                if (tableView == self.downTableView) {
//                    NSUInteger index = row - self.selectedRow;
//                    NSInteger length = index * self.rowHeight;
//                    CGFloat angle = length / self.radius;
//                    CGFloat scale = cos(angle / 2);
//                    [cell transformWith:angle scale:scale];
//                }else if (tableView == self.upTableView) {
//                    NSUInteger index = self.selectedRow - row;
//                    NSInteger length = index * self.rowHeight;
//                    CGFloat angle = length / self.radius;
//                    CGFloat scale = cos(angle / 2);
//                    [cell transformWith:angle scale:scale];
//                }
//            }
//        }
//        if (tableView == self.centerTableView) {
//            cell.label.textColor = self.textColorOfSelectedRow;
//            cell.label.font = self.textFontOfSelectedRow;
//        }else {
//            cell.label.textColor = [self textColorOfOtherRow:row];
//            cell.label.font = [self textFontOfOtherRow:row];
//        }
//        return cell;
//    }
//
//    ///MARK: - UITableViewDelegate
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        NSInteger row = indexPath.row;
//        if (row < self.offsetCount || row >= self.datas.count + self.offsetCount) {
//            return;
//        }
//        UITableViewScrollPosition position = UITableViewScrollPositionTop;
//        if (self.isCycleScroll) {
//            position = UITableViewScrollPositionMiddle;
//        }
//        row = indexPath.row - self.offsetCount;
//        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - self.offsetCount inSection: indexPath.section] animated:true scrollPosition:position];
//        self.selectedRow = indexPath.row - self.offsetCount;
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if ([self numberOfRowsInTableView] - 1 == indexPath.row && !self.isCycleScroll) {
//            CGFloat tmp = self.offsetCount * self.rowHeight - self.upLinePosY;
//            if (self.rowHeight > 44) {
//                return fabs(tmp - self.rowHeight);
//            }
//        }
//        return self.rowHeight;
//    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.rowHeight
//    }
//}
//
//
//private let cellReuseIdentifier = "PGPickerColumnCell"
//
//extension PGPickerColumnView
//{
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        if (self.isSubViewLayouted) {
//            return;
//        }
//        self.isSubViewLayouted = true;
//    }
//    
//    func setupCycleScrollWithDatas(datas:[NSAttributedString])
//    {
//        
//        if (self.frame.size.height >= self.rowHeight * datas.count) {
//            self.isCycleScroll = false;
//        }else {
//            self.isCycleScroll = self.copyCycleScroll;
//        }
//        if (self.isCycleScroll) {
//            self.offsetCount = 0;
//        }else {
//            self.offsetCount = self.copyOffsetCount;
//        }
//    }
//    func setupView()
//    {
//        CGFloat upViewHeight = kHeight / 2 - self.rowHeight / 2 - self.upLineHeight;
//        CGFloat centerViewPosY = upViewHeight + self.upLineHeight;
//        CGFloat downViewPosY = centerViewPosY + self.rowHeight + self.downLineHeight;
//        
//        UIView *upView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, upViewHeight)];
//        upView.backgroundColor = [UIColor clearColor];
//        upView.clipsToBounds = true;
//        [self addSubview:upView];
//        self.upView = upView;
//        
//        UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, downViewPosY, kWidth, kHeight - downViewPosY)];
//        downView.backgroundColor = [UIColor clearColor];
//        downView.clipsToBounds = true;
//        [self addSubview:downView];
//        self.downView = downView;
//        
//        UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake(0, centerViewPosY, kWidth, self.rowHeight)];
//        centerView.backgroundColor = [UIColor clearColor];
//        centerView.clipsToBounds = true;
//        [self addSubview:centerView];
//        self.centerView = centerView;
//        [self setupTableView];
//    }
//
//    func setupTableView()
//    {
//        {
//            CGRect frame = self.bounds;
//            frame.origin.y = -self.offset;
//            frame.size.height += self.offset;
//            PGPickerTableView *tableView = [[PGPickerTableView alloc]initWithFrame:frame style:UITableViewStylePlain];
//            [tableView registerClass:[PGPickerColumnCell class] forCellReuseIdentifier:cellReuseIdentifier];
//            tableView.delegate = self;
//            tableView.dataSource = self;
//            tableView.showsVerticalScrollIndicator = false;
//            tableView.showsHorizontalScrollIndicator = false;
//            [self.upView addSubview:tableView];
//            self.upTableView = tableView;
//        }
//        {
//            CGRect frame = [self convertRect:self.upTableView.frame toView:self.centerView];
//            PGPickerTableView *tableView = [[PGPickerTableView alloc]initWithFrame:frame style:UITableViewStylePlain];
//            [tableView registerClass:[PGPickerColumnCell class] forCellReuseIdentifier:cellReuseIdentifier];
//            tableView.delegate = self;
//            tableView.dataSource = self;
//            tableView.showsVerticalScrollIndicator = false;
//            tableView.showsHorizontalScrollIndicator = false;
//            [self.centerView addSubview:tableView];
//            self.centerTableView = tableView;
//            [self bringSubviewToFront:tableView];
//        }
//        
//        {
//            CGRect frame = [self convertRect:self.upTableView.frame toView:self.downView];
//            PGPickerTableView *tableView = [[PGPickerTableView alloc]initWithFrame:frame style:UITableViewStylePlain];
//            [tableView registerClass:[PGPickerColumnCell class] forCellReuseIdentifier:cellReuseIdentifier];
//            tableView.delegate = self;
//            tableView.dataSource = self;
//            tableView.showsVerticalScrollIndicator = false;
//            tableView.showsHorizontalScrollIndicator = false;
//            [self.downView addSubview:tableView];
//            self.downTableView = tableView;
//        }
//    }
//    func setupSelectedRow() -> Int
//    {
//        NSInteger row =  self.centerTableView.contentOffset.y / self.rowHeight +  0.5;
//        if (self.isCycleScroll) {
//            CGFloat posY = self.centerTableView.contentOffset.y + self.copyOffsetCount * self.rowHeight + self.rowHeight / 2;
//            NSInteger count = posY / (self.datas.count * self.rowHeight);
//            CGFloat newPosY = (self.centerTableView.contentOffset.y + self.copyOffsetCount * self.rowHeight) - (self.datas.count * self.rowHeight) * count;
//            if (newPosY < 0) {
//                newPosY = 0;
//            }
//            row =  newPosY / self.rowHeight +  0.5;
//        }
//        return row;
//    }
//
//    func setupTableViewScroll(tableView:UITableView,animated:Bool)
//    {
//        CGPoint offsetPoint = CGPointMake(tableView.contentOffset.x, tableView.contentOffset.y + self.rowHeight / 2);
//        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint: offsetPoint];
//         [tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionTop animated:animated];
//    }
//
//
//    // mark - Setter
//    
//
//
//    // mark - other
//    func textFontOfOtherRow(row:Int) -> UIFont {
//        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerColumnView:textFontOfOtherRow:InComponent:)]) {
//            return [self.delegate pickerColumnView:self textFontOfOtherRow:row InComponent:self.component];
//        }
//        return self.textFontOfOtherRow;
//    }
//
//    func textColorOfOtherRow(row:Int) -> UIColor {
//        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerColumnView:textColorOfOtherRow:InComponent:)]) {
//            return [self.delegate pickerColumnView:self textColorOfOtherRow:row InComponent:self.component];
//        }
//        return self.textColorOfOtherRow;
//    }
//
//    func safeReloadData() {
//        
//        [self.centerTableView reloadData];
//        [self.upTableView reloadData];
//        [self.downTableView reloadData];
//        
//        NSInteger index =  [self setupSelectedRow];
//        NSAttributedString *attriString = [[NSAttributedString alloc]initWithString:@""];
//        if (self.datas.count > index) {
//            attriString = self.datas[index];
//            self.textOfSelectedRow = attriString.string;
//        }
//    }
//
//}
//
