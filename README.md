# BRPickerView

## 介绍
基于BRPickerView封装增强，集成BRTextPickerView类，封装了BRTextAddressPickerView。
1、可以指定区域码，限定区域的显示，即对结果进行筛选，例如传@[@"110000"]，只显示北京市-北京城区-北京下面的所有区
2、可以根据区域码默认选中
3、可以设置ignoreColumnNum设置只显示市和区，不显示省份的情况。showColumnNum配合ColumnNum可以灵活显示，省，省市，省市区，市区，区等。

## 如何导入
```
pod 'BRPickerViewExtension', :git => 'https://github.com/xuzeyu/BRPickerViewExtension.git'
```

## 如何使用
```objc
@interface BRTextModel (BRTextAddressPickerView)
/** 原始字符串，设置showLetters显示为YES才用到，此时text值增加了字母前缀，此为原字符串 */
@property (nonatomic, copy) NSString *originalText;

@end

@interface BRTextAddressPickerView : BRTextPickerView

/**
 *  限制的区域码
 *    ① 限制只显示某个省，某个市，某个区，也可以传入多个省，多个市，多个区，或者省码、市码、区码混合数组。
 *    ② 传省码则显示省码的省份和省下面的市和区，传市码则显示当前市的省，和该市下的区，传区码则显示该区的省和市，与区码的区。
 *
 *    场景：  例如传@[@"110000"]，显示北京市-北京城区-北京下面的所有区
 *          例如传@[@"110101"]，显示北京市-北京城区-东城区
 */
@property (nonatomic, strong) NSArray <NSString *>*astrictAreaCodes;

/** 选中的区域码，可以是省码、市码、区码，如果是省码，则市区，默认显示选择第一个，也可以areCode可以只是前缀检索 */
@property (nonatomic, strong) NSString *selectAreaCode;

/** 设置选择器忽略显示的前面列数(即层级数) ，
 *  例如省市区，设置0，则显示省市区，1则显示市区，2则显示区
 *  结果会合并astrictAreaCodes筛选后的结果，0正常显示，1会合并所有省份的市，2会合并所有所有省市的区
 */
@property (nonatomic, assign)  NSInteger ignoreColumnNum;

/** 设置默认显示字母的位置【多列】例如@[@NO, @YES, @YES] */
@property (nullable, nonatomic, copy) NSArray <NSNumber *> *showLetters;

/** 设置默认按字母的排序位置【多列】例如@[@NO, @YES, @YES] */
@property (nullable, nonatomic, copy) NSArray <NSNumber *> *orderLetters;

//================================================= 华丽的分割线 =================================================

/**
 *  1.默认的数据源文件名称
 */
+ (NSString *)defaultFilename;

/**
 *  2.显示地址选择器
 *
 *  @param showColumnNum        设置选择器显示的列数(即层级数)，默认是根据数据源层级动态计算显示
 *  @param ignoreColumnNum      设置选择器忽略显示的前面列数(即层级数) ，
 *  @param astrictAreaCodes     限制的区域码
 *  @param selectAreaCode       选中的区域码
 *  @param resultBlock          选择后的回调
 */
+ (void)showAddressPickerWithShowColumnNum:(NSInteger)showColumnNum
                       ignoreColumnNum:(NSInteger)ignoreColumnNum
                 astrictAreaCodes:(nullable NSArray <NSString *>*)astrictAreaCodes
                         selectAreaCode:(NSString *)selectAreaCode
                      resultBlock:(nullable BRMultiResultBlock)resultBlock;

/**
 *  3.显示地址选择器
 *
 *  @param showColumnNum        设置选择器显示的列数(即层级数)，默认是根据数据源层级动态计算显示
 *  @param ignoreColumnNum      设置选择器忽略显示的前面列数(即层级数) ，
 *  @param astrictAreaCodes     限制的区域码
 *  @param selectAreaCode       选中的区域码
 *  @param showLetters          设置默认显示字母的位置【多列】
 *  @param orderLetters         设置默认按字母的排序位置【多列】
 *  @param resultBlock          选择后的回调
 */
+ (void)showAddressPickerWithShowColumnNum:(NSInteger)showColumnNum
                       ignoreColumnNum:(NSInteger)ignoreColumnNum
                 astrictAreaCodes:(nullable NSArray <NSString *>*)astrictAreaCodes
                         selectAreaCode:(NSString *)selectAreaCode
                          showLetters:(NSArray <NSNumber *> *)showLetters
                         orderLetters:(NSArray <NSNumber *> *)orderLetters
                      resultBlock:(nullable BRMultiResultBlock)resultBlock;

/**
 *  4.显示地址选择器
 *
 *  @param fileName             地址选择器的文件名称，必须按照BRTextModel格式
 *  @param showColumnNum        设置选择器显示的列数(即层级数)，默认是根据数据源层级动态计算显示
 *  @param ignoreColumnNum      设置选择器忽略显示的前面列数(即层级数) ，
 *  @param astrictAreaCodes     限制的区域码
 *  @param selectAreaCode       选中的区域码
 *  @param showLetters          设置默认显示字母的位置【多列】
 *  @param orderLetters         设置默认按字母的排序位置【多列】
 *  @param resultBlock          选择后的回调
 */
+ (void)showAddressPickerWithFileName:(nullable NSString *)fileName
                        showColumnNum:(NSInteger)showColumnNum
                       ignoreColumnNum:(NSInteger)ignoreColumnNum
                 astrictAreaCodes:(nullable NSArray <NSString *>*)astrictAreaCodes
                         selectAreaCode:(NSString *)selectAreaCode
                          showLetters:(NSArray <NSNumber *> *)showLetters
                         orderLetters:(NSArray <NSNumber *> *)orderLetters
                      resultBlock:(nullable BRMultiResultBlock)resultBlock;

@end

```

