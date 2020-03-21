//
//  ViewController.swift
//  PickerViewDemo
//
//  Created by 史晓义 on 2020/3/11.
//  Copyright © 2020 piggybear. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.datas1 = ["北京", "上海", "天津", "重庆", "四川", "贵州", "云南", "西藏", "河南", "湖北"]
        self.datas2 = ["东城区","西城区","崇文区","宣武区","朝阳区","丰台区","石景山区","海淀区","门头沟区","房山区"]
        self.datas3 = ["黄浦区","卢湾区","徐汇区","长宁区","静安区","普陀区","闸北区","虹口区","杨浦区","宝山区"]
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.type = .typelineSegment
        
        pickerView.selectRow(5, inComponent: 0, animated: true)
        pickerView.selectRow(7, inComponent: 1, animated: true)
        self.pickerView.rowHeight = 45
        self.pickerView.isHiddenMiddleText = false
        
        //设置线条的颜色
        self.pickerView.lineBackgroundColor = .red
        //设置选中行的字体颜色
        self.pickerView.textColorOfSelectedRow = .blue
        //设置未选中行的字体颜色
        self.pickerView.textColorOfOtherRow = .black
    }
    @IBOutlet weak var pickerView: PGPickerView!
    var string = ""
    var datas1 = [String]()
    var datas2 = [String]()
    var datas3 = [String]()
}

let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

extension ViewController : PGPickerViewDelegate, PGPickerViewDataSource
{
    func numberOfComponents(in pickerView: PGPickerView!) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: PGPickerView!, numberOfRowsInComponent component: Int) -> Int {
        return self.datas1.count
    }
    
    func pickerView(_ pickerView: PGPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        if (component == 0) {
            return self.datas1[row]
        }
        if (component == 1) {
            return self.datas2[row]
        }
        return self.datas3[row]
    }
    
    func pickerView(_ pickerView: PGPickerView!, didSelectRow row: Int, inComponent component: Int) {
        NSLog("row = %ld component = %ld", row, component)
    }
    
}

