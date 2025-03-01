//
//  BRTextAddressPickerView.m
//  Example
//
//  Created by xuzy on 2025/2/28.
//

#import "BRTextAddressPickerView.h"
#import <objc/runtime.h>

/// 工具方法
@implementation BRTextModel (BRTextAddressPickerView)

- (NSString *)originalText {
    return objc_getAssociatedObject(self, @selector(originalText));
}

- (void)setOriginalText:(NSString *)originalText {
    /**
     * OBJC_ASSOCIATION_COPY : copy
     * OBJC_ASSOCIATION_ASSIGN : 基本数据类型
     * OBJC_ASSOCIATION_RETAIN : 对象类型
     * OBJC_ASSOCIATION_COPY_NONATOMIC : copy+非原子性
     * OBJC_ASSOCIATION_RETAIN_NONATOMIC : 对象类型+非原子性
     */
    objc_setAssociatedObject(self, @selector(originalText), originalText, OBJC_ASSOCIATION_COPY);
}

@end

@interface BRTextAddressPickerView ()

@end

@implementation BRTextAddressPickerView

+ (NSArray *)getDataSourceWithFileName:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (filePath && filePath.length > 0) {
        if ([fileName hasSuffix:@".plist"]) {
            // 获取本地 plist文件 数据源
            NSArray *dataArr = [[NSArray alloc] initWithContentsOfFile:filePath];
            if (dataArr && dataArr.count > 0) {
                return [NSArray br_modelArrayWithJson:dataArr mapper:nil];
            }
        } else if ([fileName hasSuffix:@".json"]) {
            // 获取本地 JSON文件 数据源
            NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
            NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            if (dataArr && dataArr.count > 0) {
                return [NSArray br_modelArrayWithJson:dataArr mapper:nil];
            }
        }
    }
    return nil;
}

#pragma mark - 1.默认的数据源文件名称
+ (NSString *)defaultFilename {
    return @"region_tree_data.json";
}

#pragma mark - 2.显示地址选择器
+ (void)showAddressPickerWithShowColumnNum:(NSInteger)showColumnNum
                       ignoreColumnNum:(NSInteger)ignoreColumnNum
                 astrictAreaCodes:(nullable NSArray <NSString *>*)astrictAreaCodes
                         selectAreaCode:(NSString *)selectAreaCode
                               resultBlock:(nullable BRMultiResultBlock)resultBlock {
    [self showAddressPickerWithShowColumnNum:showColumnNum ignoreColumnNum:ignoreColumnNum astrictAreaCodes:astrictAreaCodes selectAreaCode:selectAreaCode showLetters:@[] orderLetters:@[] resultBlock:resultBlock];
}

#pragma mark - 3.显示地址选择器
+ (void)showAddressPickerWithShowColumnNum:(NSInteger)showColumnNum
                       ignoreColumnNum:(NSInteger)ignoreColumnNum
                 astrictAreaCodes:(nullable NSArray <NSString *>*)astrictAreaCodes
                         selectAreaCode:(NSString *)selectAreaCode
                          showLetters:(NSArray <NSNumber *> *)showLetters
                         orderLetters:(NSArray <NSNumber *> *)orderLetters
                      resultBlock:(nullable BRMultiResultBlock)resultBlock {
    [self showAddressPickerWithFileName:nil showColumnNum:showColumnNum ignoreColumnNum:ignoreColumnNum astrictAreaCodes:astrictAreaCodes selectAreaCode:selectAreaCode showLetters:showLetters orderLetters:orderLetters resultBlock:resultBlock];
}

#pragma mark - 4.显示地址选择器
+ (void)showAddressPickerWithFileName:(nullable NSString *)fileName
                        showColumnNum:(NSInteger)showColumnNum
                       ignoreColumnNum:(NSInteger)ignoreColumnNum
                 astrictAreaCodes:(nullable NSArray <NSString *>*)astrictAreaCodes
                         selectAreaCode:(NSString *)selectAreaCode
                          showLetters:(NSArray <NSNumber *> *)showLetters
                         orderLetters:(NSArray <NSNumber *> *)orderLetters
                      resultBlock:(nullable BRMultiResultBlock)resultBlock {
    // 创建地址选择器
    BRTextAddressPickerView *addressPickerView = [[BRTextAddressPickerView alloc] initWithPickerMode:BRTextPickerComponentCascade];
    addressPickerView.dataSourceArr = [self getDataSourceWithFileName:fileName.length > 0 ? fileName : [self defaultFilename]];
    addressPickerView.showColumnNum = showColumnNum;
    addressPickerView.astrictAreaCodes = astrictAreaCodes;
    addressPickerView.ignoreColumnNum = ignoreColumnNum;
    addressPickerView.multiResultBlock = resultBlock;
    addressPickerView.selectAreaCode = selectAreaCode;
    addressPickerView.showLetters = showLetters;
    addressPickerView.orderLetters = orderLetters;
    // 显示
    [addressPickerView show];
}

#pragma mark - 重写父类方法
- (void)show {
    //递归设置parentCode
    [BRTextAddressPickerView setParentCodeForModels:self.dataSourceArr parentCode:nil];
    
    //根据astrictAreaCodes对数据进行筛选
    if (self.dataSourceArr.count > 0 && [self.dataSourceArr.firstObject isKindOfClass:[BRTextModel class]] && self.astrictAreaCodes.count > 0) {
        NSArray<BRTextModel *> *array = [BRTextAddressPickerView filterDataSource:self.dataSourceArr astrictAreaCodes:self.astrictAreaCodes];
        self.dataSourceArr = array;
    }
    
    //根据ignoreColumnNum对数据进行筛选
    if (self.ignoreColumnNum > 0) {
        NSMutableArray *array = [NSMutableArray array];
        [BRTextAddressPickerView ignoreColumnNodes:self.dataSourceArr currentLevel:0 maxLevel:self.ignoreColumnNum results:array];
        self.dataSourceArr = array;
    }
    
    //根据showLetters显示字母，或者根据orderLetters根据字母进行排序
    if (self.showLetters.count > 0 || self.orderLetters.count > 0) {
        self.dataSourceArr = [BRTextAddressPickerView orderColumnNodes:self.dataSourceArr currentLevel:0 showLetters:self.showLetters orderLetters:self.orderLetters];
    }
    
    //根据selectAreaCode设置选中的selectIndexs参数
    if (self.selectAreaCode.length > 0) {
        //递归设置index
        [BRTextAddressPickerView setIndexForDataSource:self.dataSourceArr];
        
        //查找并添加选中的index
        BRTextModel *node = [BRTextAddressPickerView findNodeWithCode:self.selectAreaCode dataSource:self.dataSourceArr isSearchPrefix:YES];
        NSMutableArray <NSNumber *>*selectIndexs = [NSMutableArray array];
        if (node) {
            do {
                [selectIndexs insertObject:@(node.index) atIndex:0];
                node = [BRTextAddressPickerView findNodeWithCode:node.parentCode dataSource:self.dataSourceArr isSearchPrefix:NO];
            } while (node);
        }
        self.selectIndexs = selectIndexs;
    }
    
    //显示处理后的数据
    [super show];
}

#pragma mark - 递归设置parentCode
+ (void)setParentCodeForModels:(NSArray<BRTextModel *> *)models parentCode:(NSString *)parentCode {
    for (BRTextModel *model in models) {
        // 设置当前模型的parentCode
        model.parentCode = parentCode;
        
        // 如果有子级，递归设置子级的parentCode
        if (model.children && model.children.count > 0) {
            [self setParentCodeForModels:model.children parentCode:model.code];
        }
    }
}

#pragma mark - 递归设置index
+ (void)setIndexForDataSource:(NSArray<BRTextModel *> *)dataSource {
    // 遍历数据源数组
    for (NSInteger i = 0; i < dataSource.count; i++) {
        BRTextModel *currentModel = dataSource[i];
        currentModel.index = i;
        if (currentModel.children && currentModel.children.count > 0) {
            // 如果有children数组，遍历children数组并设置index
            for (NSInteger j = 0; j < currentModel.children.count; j++) {
                BRTextModel *childModel = currentModel.children[j];
                childModel.index = j; // 设置index
            }
            // 递归处理children数组
            [self setIndexForDataSource:currentModel.children];
        }
    }
}

#pragma mark - 根据astrictAreaCodes筛选DataSource
+ (NSArray<BRTextModel *> *)filterDataSource:(NSArray<BRTextModel *> *)dataSource astrictAreaCodes:(NSArray<NSString *> *)astrictAreaCodes {
    // 清空maxLevelMap
    NSMutableArray<NSString *> *nodeCodes = [NSMutableArray array];
    
    for (NSString *code in astrictAreaCodes) {
        BRTextModel *node = [self findNodeWithCode:code dataSource:dataSource isSearchPrefix:NO];
        if (!node) continue;
        
        // 标记路径上的节点
        [self markPath:node nodeCodes:nodeCodes dataSource:dataSource];
        
        // 遍历后代节点
        [self traverseDescendants:node nodeCodes:nodeCodes];
    }
    
    // 构建结果树
    return [self buildResultTree:dataSource nodeCodes:nodeCodes];
}

// 查找指定code的节点
+ (BRTextModel *)findNodeWithCode:(NSString *)code dataSource:(NSArray<BRTextModel *> *)dataSource isSearchPrefix:(BOOL)isSearchPrefix {
    // 遍历所有节点查找
    for (BRTextModel *node in dataSource) {
        if (isSearchPrefix) {
            if ([node.code hasPrefix:code]) {
                return node;
            }
        }else {
            if ([node.code isEqualToString:code]) {
                return node;
            }
        }
        BRTextModel *found = [self findNodeInChildren:node.children withCode:code isSearchPrefix:isSearchPrefix];
        if (found) {
            return found;
        }
    }
    return nil;
}

// 在子节点中查找code
+ (BRTextModel *)findNodeInChildren:(NSArray<BRTextModel *> *)children withCode:(NSString *)code isSearchPrefix:(BOOL)isSearchPrefix {
    for (BRTextModel *child in children) {
        if (isSearchPrefix) {
            if ([child.code hasPrefix:code]) {
                return child;
            }
        }else {
            if ([child.code isEqualToString:code]) {
                return child;
            }
        }
        BRTextModel *found = [self findNodeInChildren:child.children withCode:code isSearchPrefix:isSearchPrefix];
        if (found) {
            return found;
        }
    }
    return nil;
}

// 标记路径上的Node
+ (void)markPath:(BRTextModel *)node nodeCodes:(NSMutableArray <NSString *>*)nodeCodes dataSource:(NSArray<BRTextModel *> *)dataSource {
    if (!node) return;
    [nodeCodes addObject:node.code];
    BRTextModel *parent = [self findNodeWithCode:node.parentCode dataSource:dataSource isSearchPrefix:NO];
    [self markPath:parent nodeCodes:nodeCodes dataSource:dataSource];
}

// 遍历后代并添加节点
+ (void)traverseDescendants:(BRTextModel *)node nodeCodes:(NSMutableArray <NSString *>*)nodeCodes {
    for (BRTextModel *child in node.children) {
        [nodeCodes addObject:child.code];
        [self traverseDescendants:child nodeCodes:nodeCodes];
    }
}

// 构建结果树
+ (NSArray<BRTextModel *> *)buildResultTree:(NSArray<BRTextModel *> *)dataSource nodeCodes:(NSMutableArray <NSString *>*)nodeCodes {
    NSMutableArray<BRTextModel *> *newRoots = [NSMutableArray array];
    for (BRTextModel *root in dataSource) {
        if ([nodeCodes containsObject:root.code]) { // 使用index作为层级
            root.children = [self filterChildren:root.children nodeCodes:nodeCodes];
            [newRoots addObject:root];
        }
    }
    return newRoots;
}

// 过滤子节点
+ (NSArray<BRTextModel *> *)filterChildren:(NSArray<BRTextModel *> *)children nodeCodes:(NSMutableArray <NSString *>*)nodeCodes {
    NSMutableArray<BRTextModel *> *filtered = [NSMutableArray array];
    for (BRTextModel *child in children) {
        if ([nodeCodes containsObject:child.code]) {
            child.children = [self filterChildren:child.children nodeCodes:nodeCodes];
            [filtered addObject:child];
        }
    }
    return filtered;
}

#pragma mark - ignoreColumnNum对数据进行筛选
+ (void)ignoreColumnNodes:(NSArray <BRTextModel *>*)nodes currentLevel:(NSInteger)currentLevel maxLevel:(NSInteger)max_level results:(NSMutableArray <BRTextModel *> *)results {
    if (currentLevel > max_level) return;
    if (currentLevel == max_level) {
        for (NSInteger i = 0; i < nodes.count; i++) {
            [results addObject:nodes[i]];
        }
    }
    for (BRTextModel *child in nodes) {
        [self ignoreColumnNodes:child.children currentLevel:currentLevel + 1 maxLevel:max_level results:results];
    }
}

#pragma mark - 根据showLetters显示字母，或者根据orderLetters根据字母进行排序
+ (NSArray<BRTextModel *> *)orderColumnNodes:(NSArray <BRTextModel *>*)nodes currentLevel:(NSInteger)currentLevel showLetters:(NSArray <NSNumber *> *)showLetters orderLetters:(NSArray <NSNumber *> *)orderLetters {
    NSArray<BRTextModel *> *newRoots = nodes;
    
    if (currentLevel < orderLetters.count && [orderLetters[currentLevel] boolValue]) {
        newRoots = [nodes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            BRTextModel *model1 = obj1;
            BRTextModel *model2 = obj2;
            NSString *firstPinYin1 = [BRTextAddressPickerView transformToPinyin:model1.text];
            NSString *firstPinYin2 = [BRTextAddressPickerView transformToPinyin:model2.text];
            return [firstPinYin1 compare:firstPinYin2];
        }];
    }
    
    if (currentLevel < showLetters.count && [showLetters[currentLevel] boolValue]) {
        for (NSInteger i = 0; i < nodes.count; i++) {
            BRTextModel *model = nodes[i];
            model.originalText = model.text;
            model.text = [NSString stringWithFormat:@"%@ %@", [BRTextAddressPickerView transformToPinyin:model.text], model.text];
        }
    }
    
    for (BRTextModel *child in nodes) {
        child.children = [self orderColumnNodes:child.children currentLevel:currentLevel + 1 showLetters:showLetters orderLetters:orderLetters];
    }
    return newRoots;
}

#pragma mark - 工具方法
//获取字符串首字符的拼音第一个字母
+ (NSString *)transformToPinyin:(NSString *)string {
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    NSString *PinYin = [mutableString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    // 将拼音首字母装换成大写
    NSString *strPinYin = [PinYin uppercaseString];
    // 截取大写首字母
    NSString *firstString = [strPinYin substringToIndex:1];
    return firstString;
}

@end
