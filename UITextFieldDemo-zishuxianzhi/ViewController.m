//
//  ViewController.m
//  UITextFieldDemo-zishuxianzhi
//
//  Created by 张福润 on 16/9/1.
//  Copyright © 2016年 张福润. All rights reserved.
//

#import "ViewController.h"

static NSInteger CharacterCount = 8;

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *totalCharacterLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.nameField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    self.nameField.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Method
- (void)textFieldChanged:(UITextField *)textField {
    NSString *toBeString = textField.text;
    if (![self isInputRuleAndBlank:toBeString]) {
        textField.text = [self disable_emoji:toBeString];
        return;
    }
    
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 获取当前键盘输入模式
    //简体中文输入,第三方输入法（搜狗）所有模式下都会显示“zh-Hans”
    if([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            NSString *getStr = [self getSubString:toBeString];
            if(getStr && getStr.length > 0) {
                textField.text = getStr;
            }
        }
    } else{
        NSString *getStr = [self getSubString:toBeString];
        if(getStr && getStr.length > 0) {
            textField.text= getStr;
        }
    }
}


/**
 * 字母、数字、中文正则判断（不包括空格）
 */
- (BOOL)isInputRuleNotBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    
    if (!isMatch) {
        NSString *other = @"➋➌➍➎➏➐➑➒";
        unsigned long len=str.length;
        for(int i=0;i<len;i++)
        {
            unichar a=[str characterAtIndex:i];
            if(!((isalpha(a))
                 ||(isalnum(a))
                 ||((a=='_') || (a == '-'))
                 ||((a >= 0x4e00 && a <= 0x9fa6))
                 ||([other rangeOfString:str].location != NSNotFound)
                 ))
                return NO;
        }
        return YES;
        
    }
    return isMatch;
}
/**
 * 字母、数字、中文正则判断（包括空格）（在系统输入法中文输入时会出现拼音之间有空格，需要忽略，当按return键时会自动用字母替换，按空格输入响应汉字）
 */
- (BOOL)isInputRuleAndBlank:(NSString *)str {
    
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

/**
 *  过滤字符串中的emoji
 */
- (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

/**
 *  获得 CharacterCount长度的字符
 */
-(NSString *)getSubString:(NSString*)string
{
    //    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //    NSData* data = [string dataUsingEncoding:encoding];
    //    NSInteger length = [data length];
    //    if (length > CharacterCount) {
    //        NSData *data1 = [data subdataWithRange:NSMakeRange(0, CharacterCount)];
    //        NSString *content = [[NSString alloc] initWithData:data1 encoding:encoding];//注意：当截取CharacterCount长度字符时把中文字符截断返回的content会是nil
    //        if (!content || content.length == 0) {
    //            data1 = [data subdataWithRange:NSMakeRange(0, CharacterCount - 1)];
    //            content =  [[NSString alloc] initWithData:data1 encoding:encoding];
    //        }
    //        return content;
    //    }
    //    return nil;
    
    if (string.length > CharacterCount) {
        NSLog(@"超出字数上限");
        _totalCharacterLabel.text = @"0";
        return [string substringToIndex:CharacterCount];
    }else {
        _totalCharacterLabel.text = [NSString stringWithFormat:@"%ld",(long)(CharacterCount - string.length)];
    }
    return nil;
}

#pragma mark - TouchDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self isInputRuleNotBlank:string] || [string isEqualToString:@""]) {//当输入符合规则和退格键时允许改变输入框
        return YES;
    } else {
        NSLog(@"超出字数限制");
        return NO;
    }
}





@end
