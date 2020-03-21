//
//  PGPickerView.swift
//  PickerViewDemo
//
//  Created by 史晓义 on 2020/3/11.
//  Copyright © 2020 piggybear. All rights reserved.
//

import UIKit

class PGPickerView: UIView
{
    
    
    public var type : PGPickerViewLineType?
    public weak var dataSource : PGPickerViewDataSource? = nil
    {
        didSet {
            numberOfComponents = dataSource?.numberOfComponents(in: self) ?? 0
        }
    }
    
    public var delegate : PGPickerViewDelegate? = nil// default is nil. weak reference
    
    public var lineBackgroundColor : UIColor = .gray
    {
        didSet {
            for (idx, obj) in self.upLines.enumerated() {
                obj.backgroundColor = lineBackgroundColor
                self.downLines[idx].backgroundColor = lineBackgroundColor
            }
        }
    }
    
    public var lineHeight:CGFloat = 0.5
    
    public var verticalLineBackgroundColor : UIColor = .gray // default is [UIColor grayColor] type3 vertical line
    public var verticalLineWidth : CGFloat  = 0.5
    
    public var textColorOfSelectedRow : UIColor = .black
    {
        didSet {
            for item in self.columnViewList {
                item.textColorOfSelectedRow = textColorOfSelectedRow
            }
        }
    }
    
    public var textFontOfSelectedRow : UIFont?
    
    public var textColorOfOtherRow : UIColor = .gray// default is [UIColor grayColor]
    {
        didSet {
            for item in self.columnViewList {
                item.textColorOfOtherRow = textColorOfOtherRow
            }
        }
    }
    
    public var textFontOfOtherRow : UIFont?
    
    // info that was fetched and cached from the data source and delegate
    public private(set) var numberOfComponents : Int = 0
    
    public var rowHeight:CGFloat = 0 // default is 44
    
    public var isHiddenMiddleText : Bool = false// default is true  true -> hidden
    public var middleTextColor : UIColor?
    public var middleTextFont : UIFont?
    
    public var isHiddenWheels : Bool = false // default is true  true -> hidden
    public var isCycleScroll : Bool = false //default is false
    
    
    
    public func numberOfRowsInComponent(component:Int) -> Int {
        return self.dataSource?.pickerView(self, numberOfRowsInComponent: component) ?? 0
    }
    
    // selection. in this case, it means showing the appropriate row in the middle
    
    // scrolls the specified row to center.
    public func selectRow(row:Int, in component:Int, animated:Bool) {
        if (isSubViewLayouted) {
            let view = self.columnViewInComponent(component: component)
            view?.selectRow(row, animated: animated)
            return
        }
        if (!isSubViewLayouted) {
            numberOfSelectedComponentList.append(component)
            numberOfSelectedRowList.append(row)
            animationOfSelectedRowList.append(animated)
        }
        isSelected = true
    }
    
    // returns selected row. -1 if nothing selected
    public func selectedRowInComponent(component:Int) -> Int {
        if let view = self.columnViewInComponent(component: component) {
            return Int(view.selectedRow)
        }
        return -1
    }
    
    public func textOfSelectedRowInComponent(component:Int) -> String {
        if let view = self.columnViewInComponent(component: component) {
            return view.textOfSelectedRow
        }
        return ""
    }
    // Reloading whole view or single component
    public func reloadAllComponents() {
        setupColumnView()
    }
    
    public func reloadComponent(component:Int) {
        createColumnViewAtComponent(component: component, refresh: false)
    }
    public func reloadComponent(component:Int,refresh:Bool) {
        createColumnViewAtComponent(component: component, refresh: refresh)
    }
    
    private var kWidth: CGFloat {
        return self.frame.size.width
    }
    private var kHeight: CGFloat {
        return self.frame.size.height
    }
    
    private var animationOfSelectedRowList = [Bool]()
    private var numberOfSelectedRowList = [Int]()
    private var numberOfSelectedComponentList = [Int]()
    
    private var upLines = [UIView]()
    private var downLines = [UIView]()
    
    private lazy var numberOfRows: Int = {
        if let num = self.dataSource?.pickerView(self, numberOfRowsInComponent: numberOfComponents) {
            return num
        }
        return 0
    }()
    
    private var columnViewList = [PGPickerColumnView]()
    private var isSubViewLayouted = false
    private var isSelected = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (isSubViewLayouted) {
            return
        }
        isSubViewLayouted = true
        setupColumnView()
        setupView()
        
        for (idx, obj) in self.upLines.enumerated() {
            self.bringSubviewToFront(obj)
            self.bringSubviewToFront(self.downLines[idx])
        }
        
        if (isSelected) {
            for (idx, obj) in self.numberOfSelectedRowList.enumerated() {
                let component = self.numberOfSelectedComponentList[idx]
                let isAnimation = self.animationOfSelectedRowList[idx]
                self.selectRow(row: obj, in: component, animated: isAnimation)
            }
        }
    }
}

extension PGPickerView
{
    func setup() {
        
        self.lineBackgroundColor = .lightGray
        self.textColorOfSelectedRow = .black
        self.textColorOfOtherRow = .lightGray
        self.isHiddenMiddleText = true
        self.isHiddenWheels = true
        self.lineHeight = 0.5
        self.verticalLineWidth = 0.5
        self.verticalLineBackgroundColor = self.lineBackgroundColor
    }
    
    @discardableResult
    func createColumnViewAtComponent(component:Int, refresh:Bool) -> PGPickerColumnView {
        
        let width:CGFloat = kWidth / CGFloat(numberOfComponents)
        let row:Int = [self.dataSource pickerView:self numberOfRowsInComponent:component];
        NSMutableArray *datas = [NSMutableArray arrayWithCapacity:row];
        NSMutableArray *colors = [NSMutableArray arrayWithCapacity:row];
        for (int j = 0; j < row; j++) {
            BOOL tf = true;
            NSAttributedString *attriStr = [[NSAttributedString alloc]initWithString:@"?"];
            UIColor *color = [UIColor clearColor];
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(pickerView:attributedTitleForRow:forComponent:)]) {
                    attriStr = [self.delegate pickerView:self attributedTitleForRow:j forComponent:component];
                    if (!attriStr) {
                        tf = false;
                    }
                }else {
                    tf = false;
                }
                if (!tf && [self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
                    NSString *title = [self.delegate pickerView:self titleForRow:j forComponent:component];
                    title = title ? title : @"?";
                    attriStr = [[NSAttributedString alloc]initWithString:title];
                }
                
                if ([self.delegate respondsToSelector:@selector(pickerView:viewBackgroundColorForRow:forComponent:)]) {
                    UIColor *temp = [self.delegate pickerView:self viewBackgroundColorForRow:j forComponent:component];
                    if (temp) {
                        color = temp;
                    }
                }
            }
            [colors addObject:color];
            [datas addObject:attriStr];
        }
        PGPickerColumnView *view = [self columnViewInComponent:component];
        if (!view) {
            CGFloat rowHeight = [self rowHeightInComponent:component];
            CGFloat upLineHeight = [self upLineHeightForComponent:component];
            CGFloat downLineHeight = [self downLineHeightForComponent:component];
            view = [[PGPickerColumnView alloc]initWithFrame:CGRectMake(component * width, 0, width, kHeight) rowHeight: rowHeight upLineHeight:upLineHeight downLineHeight:downLineHeight isCycleScroll:self.isCycleScroll datas:datas];
            view.delegate = self;
            [self addSubview:view];
        }
        view.isHiddenWheels = self.isHiddenWheels;
        view.refresh = refresh;
        view.viewBackgroundColors = colors;
        view.textFontOfSelectedRow = [self textFontOfSelectedRowInComponent:component];
        view.textFontOfOtherRow = [self textFontOfOtherRowInComponent:component];
        view.component = component;
        view.datas = datas;
        view.textColorOfSelectedRow = [self textColorOfSelectedRowInComponent:component];
        view.textColorOfOtherRow = [self textColorOfOtherRowInComponent:component];
        return view;
    }

    func setupColumnView() {
        var columnViewList = [PGPickerColumnView]()
        for i in 0..<numberOfComponents {
            let view = self.createColumnViewAtComponent(component: i, refresh: false)
            columnViewList.append(view)
        }
        self.columnViewList = columnViewList
    }
    
    func setupView() {
        
        if (!self.isHiddenMiddleText) {
            self.setupMiddleTextLogic()
        }
        switch (self.type) {
        case .typeline:
            self.setupLineView1()
        case .typelineSegment:
            self.setupLineView2()
        case .typelineVertical:
            self.setupLineView3()
        case .none:
            break
        case .some(_):
            break
        }
    }
    
    func setupLineView1() {
        
        NSMutableArray *upLines = [NSMutableArray arrayWithCapacity:_numberOfComponents];
        NSMutableArray *downLines = [NSMutableArray arrayWithCapacity:_numberOfComponents];
        CGFloat lineWidth = (kWidth / _numberOfComponents);
        for (int i = 0; i < _numberOfComponents; i++) {
            CGFloat rowHeight = [self rowHeightInComponent:i];
            CGFloat upLineHeight = [self upLineHeightForComponent:i];
            CGFloat upLinePosY = kHeight / 2 - rowHeight / 2 - upLineHeight;
            UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(i * lineWidth, upLinePosY, lineWidth, upLineHeight)];
            upLine.backgroundColor = self.lineBackgroundColor;
            [self addSubview:upLine];
            [upLines addObject:upLine];
            
            CGFloat downLineHeight = [self downLineHeightForComponent:i];
            CGFloat downLinePosY = CGRectGetMaxY(upLine.frame) + rowHeight;
            UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(i * lineWidth, downLinePosY, lineWidth, downLineHeight)];
            downLine.backgroundColor = self.lineBackgroundColor;
            [self addSubview:downLine];
            [downLines addObject:downLine];
        }
        self.upLines = upLines;
        self.downLines = downLines;
    }

    func setupLineView2() {
        
        NSMutableArray *upLines = [NSMutableArray arrayWithCapacity:_numberOfComponents];
        NSMutableArray *downLines = [NSMutableArray arrayWithCapacity:_numberOfComponents];
        CGFloat lineWidth = (self.frame.size.width / _numberOfComponents) - 20;
        CGFloat space = (self.frame.size.width / _numberOfComponents);
        if (_numberOfComponents == 1) {
            CGFloat rowHeight = [self rowHeightInComponent:0];
            CGFloat upLineHeight = [self upLineHeightForComponent:0];
            upLineHeight = upLineHeight > 1.5 ? upLineHeight: 1.5;
            CGFloat upLinePosY = kHeight / 2 - rowHeight / 2 - upLineHeight;
            UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width / 2 - 43, upLinePosY, 90, upLineHeight)];
            upLine.backgroundColor = self.lineBackgroundColor;
            [self addSubview:upLine];
            [upLines addObject:upLine];
            
            CGFloat downLineHeight = [self downLineHeightForComponent:0];
            downLineHeight = downLineHeight > 1.5 ? downLineHeight: 1.5;
            CGFloat downLinePosY = CGRectGetMaxY(upLine.frame) + rowHeight;
            UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width / 2 - 43, downLinePosY, 90, downLineHeight)];
            downLine.backgroundColor = self.lineBackgroundColor;
            [self addSubview:downLine];
            [downLines addObject:downLine];
            
            self.upLines = upLines;
            self.downLines = downLines;
            return;
        }
        for (int i = 0; i < _numberOfComponents; i++) {
            CGFloat rowHeight = [self rowHeightInComponent:i];
            CGFloat upLineHeight = [self upLineHeightForComponent:i];
            upLineHeight = upLineHeight > 1.5 ? upLineHeight: 1.5;
            CGFloat upLinePosY = kHeight / 2 - rowHeight / 2 - upLineHeight;
            UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(10 + space * i, upLinePosY, lineWidth, upLineHeight)];
            upLine.backgroundColor = [self upLineBackgroundColorForComponent:i];
            [self addSubview:upLine];
            [upLines addObject:upLine];
            
            CGFloat downLineHeight = [self downLineHeightForComponent:i];
            downLineHeight = downLineHeight > 1.5 ? downLineHeight: 1.5;
            CGFloat downLinePosY = CGRectGetMaxY(upLine.frame) + rowHeight;
            UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(10 + space * i, downLinePosY, lineWidth, downLineHeight)];
            downLine.backgroundColor = [self downLineBackgroundColorForComponent:i];
            [self addSubview:downLine];
            [downLines addObject:downLine];
        }
        self.upLines = upLines;
        self.downLines = downLines;
    }

    func setupLineView3() {
        
        CGFloat space = (self.frame.size.width / _numberOfComponents);
        [self setupLineView2];
        for (int i = 0; i < _numberOfComponents; i++) {
            if (i != _numberOfComponents - 1) {
                CGFloat width = [self verticalLineWidthForComponent:i];
                UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(space * (i+1), 0, width, kHeight)];
                verticalLine.backgroundColor = [self verticalLineBackgroundColorForComponent:i];
                [self addSubview:verticalLine];
            }
        }
    }

    func setupMiddleTextLogic() {
        
        CGFloat lineWidth = (self.frame.size.width / _numberOfComponents);
        CGFloat space = 10;
        for (int i = 0; i < _numberOfComponents; i++) {
            UILabel *label = [[UILabel alloc]init];
            if ([self.delegate respondsToSelector:@selector(pickerView:middleTextSpaceForcomponent:)]) {
                space = [self.delegate pickerView:self middleTextSpaceForcomponent:i];
            }
            label.frame = CGRectMake(lineWidth / 2 + lineWidth * i + space, kHeight / 2 - 15, 30, 30);
            NSString *text = @"";
            if ([self.delegate respondsToSelector:@selector(pickerView:middleTextForcomponent:)]) {
                text = [self.delegate pickerView:self middleTextForcomponent:i];
            }
            label.text = text;
            label.textColor = self.middleTextColor;
            label.font = self.middleTextFont;
            [self addSubview:label];
        }
    }
    
    func verticalLineBackgroundColorForComponent(component:Int) -> UIColor {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:verticalLineBackgroundColorForComponent:)]) {
            return [self.delegate pickerView:self verticalLineBackgroundColorForComponent:component];
        }
        return self.verticalLineBackgroundColor;
    }

    func verticalLineWidthForComponent(component:Int) -> CGFloat {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:verticalLineWidthForComponent:)]) {
            return [self.delegate pickerView:self verticalLineWidthForComponent:component];
        }
        return self.verticalLineWidth;
    }

    func upLineBackgroundColorForComponent(component:Int) -> UIColor {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:upLineBackgroundColorForComponent:)]) {
            return [self.delegate pickerView:self upLineBackgroundColorForComponent:component];
        }
        return self.lineBackgroundColor;
    }
    
    func downLineBackgroundColorForComponent(component:Int) -> UIColor {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:downLineBackgroundColorForComponent:)]) {
            return [self.delegate pickerView:self downLineBackgroundColorForComponent:component];
        }
        return self.lineBackgroundColor;
    }
    
    func upLineHeightForComponent(component:Int) -> CGFloat {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:upLineHeightForComponent:)]) {
            return [self.delegate pickerView:self upLineHeightForComponent:component];
        }
        return self.lineHeight;
    }
    
    func downLineHeightForComponent(component:Int) -> CGFloat {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:downLineHeightForComponent:)]) {
            return [self.delegate pickerView:self downLineHeightForComponent:component];
        }
        return self.lineHeight;
    }
    
    func textColorOfSelectedRowInComponent(component:Int) -> UIColor {
        if let color = self.delegate?.pickerView?(self, textColorOfSelectedRowInComponent: component) {
            return color
        }
        return self.textColorOfSelectedRow
    }
    
    func textColorOfOtherRowInComponent(component:Int) -> UIColor! {
        if let color = self.delegate?.pickerView?(self, textColorOfOtherRowInComponent: component) {
            return color
        }
        return self.textColorOfOtherRow
    }
    
    func rowHeightInComponent(component:Int) -> CGFloat {
        if let float = self.delegate?.rowHeight?(in: self, forComponent: component) {
            return float
        } else if (self.rowHeight != 0) {
            return self.rowHeight
        }
        self.rowHeight = 44
        return self.rowHeight
    }
    
    func textFontOfSelectedRowInComponent(component:Int) -> UIFont! {
        if let font = self.delegate?.pickerView?(self, textFontOfSelectedRowInComponent: component) {
            return font
        }
        return self.textFontOfSelectedRow
    }

    func textFontOfOtherRowInComponent(component:Int) -> UIFont! {
        if let font = self.delegate?.pickerView?(self, textFontOfOtherRowInComponent: component) {
            return font
        }
        return self.textFontOfOtherRow
    }
    
    func columnViewInComponent(component:Int) -> PGPickerColumnView? {
        if self.columnViewList.count == 0 {
            return nil
        }
        var view :PGPickerColumnView? = nil
        
        for item in self.columnViewList {
            if (item.component == component) {
                view = item
                break
            }
        }
        
        return view
    }
}


extension PGPickerView :PGPickerColumnViewDelegate
{
    
    func pickerColumnView(_ pickerColumnView: PGPickerColumnView!, didSelectRow row: Int) {
        self.delegate?.pickerView?(self, didSelectRow: row, inComponent: Int(pickerColumnView!.component))
    }
    
    func pickerColumnView(_ pickerColumnView: PGPickerColumnView!, title: String!, didSelectRow row: Int) {
        self.delegate?.pickerView?(self, title: title, didSelectRow: row, inComponent: Int(pickerColumnView!.component))
    }
    
    func pickerColumnView(_ pickerColumnView: PGPickerColumnView!, textFontOfOtherRow row: Int, inComponent component: Int) -> UIFont! {
        if let font = self.delegate?.pickerView?(self, textFontOfOtherRow: row, inComponent: component) {
            return font
        }
        return self.textFontOfOtherRow
    }

    func pickerColumnView(_ pickerColumnView: PGPickerColumnView!, textColorOfOtherRow row: Int, inComponent component: Int) -> UIColor! {
        if let color = self.delegate?.pickerView?(self, textColorOfOtherRow: row, inComponent: component) {
            return color
        }
        return self.textColorOfOtherRow
    }
    
}

