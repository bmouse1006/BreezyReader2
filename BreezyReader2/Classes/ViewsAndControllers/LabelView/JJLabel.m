//
//  JJLabel.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJLabel.h"
#import "UIColor+Addition.h"

@interface JJLabel()

-(void)drawTextInRect:(CGRect)rect;
//- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;

@end

@implementation JJLabel

@synthesize shadowBlur = _shadowBlur, shadowEnable = _shadowEnable;
@synthesize shadowColor = _shadowColor, shadowOffset = _shadowOffset;
@synthesize text = _text, font = _font, textColor = _textColor;
@synthesize textAlignment = _textAlignment;
@synthesize autoResize = _autoResize;
@synthesize verticalAlignment = _verticalAlignment;
@synthesize actualLineNumber = _actualLineNumber;

-(void)dealloc{
    self.shadowColor = nil;
    self.text = nil;
    self.font = nil;
    self.textColor = nil;
    [super dealloc];
}

#pragma mark - getter and setter

-(void)setText:(NSString *)text{
    if (_text != text){
        [_text release];
        _text = [text copy];
        if (self.autoResize){
            [self resizeToFitText];
        }
        [self performSelector:@selector(setNeedsDisplay)];
    }
}

-(void)setTextColor:(UIColor *)textColor{
    if (_textColor != textColor){
        [_textColor release];
        _textColor = [textColor retain];
        [self performSelector:@selector(setNeedsDisplay)];
    }
}

-(void)setShadowEnable:(CGFloat)shadowEnable{
    _shadowEnable = shadowEnable;
    [self performSelector:@selector(setNeedsDisplay)];
}
//- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines{
//    return UIEdgeInsetsInsetRect(bounds, _insets);
//}

-(UIFont*)font{
    if (_font == nil){
        _font = [[UIFont systemFontOfSize:[UIFont systemFontSize]] retain];
    }
    
    return _font;
}

-(void)setContentEdgeInsets:(UIEdgeInsets)insets{
    _insets = UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
}

-(NSInteger)actualLineNumber{
    CGSize size = [self.text sizeWithFont:self.font forWidth:99999 lineBreakMode:UILineBreakModeTailTruncation];
    return (NSInteger)(size.width/self.contentSize.width+1);
}

-(CGSize)contentSize{
    return UIEdgeInsetsInsetRect(self.bounds, _insets).size;
}

#pragma mark - draw
-(void)drawTextInRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
//    CGContextSetRGBStrokeColor(ctx, self.textColor.red, self.textColor.green, self.textColor.blue, self.textColor.alpha);
    CGContextSetFillColorWithColor(ctx, self.textColor.CGColor);
    
    CGSize size = [self.text sizeWithFont:self.font constrainedToSize:rect.size lineBreakMode:UILineBreakModeCharacterWrap];
    
    CGRect newRect = rect;
    newRect.size.height = size.height;
    
    switch (self.verticalAlignment) {
        case JJTextVerticalAlignmentTop:
            break;
        case JJTextVerticalAlignmentMiddle:
            newRect.origin.y += (rect.size.height - size.height)/2;
            break;
        case JJTextVerticalAlignmentBottom:
            newRect.origin.y += rect.size.height - size.height;
            break;
        default:
            break;
    }
    
    
    [self.text drawInRect:newRect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];

    CGContextRestoreGState(ctx);
}

-(void)drawRect:(CGRect)rect{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    if (self.shadowEnable){
        CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
        CGContextBeginTransparencyLayer(ctx, nil);
    }
    [self drawTextInRect:UIEdgeInsetsInsetRect(rect, _insets)];
    if (self.shadowEnable){
        CGContextEndTransparencyLayer(ctx);
    }
    CGContextRestoreGState(ctx);
}

-(void)resizeToFitText{
    if (self.text == nil){
        CGRect frame = self.frame;
        frame.size.height = 0;
        frame.size.width = 0;
        [self setFrame:frame];
    }else{
        CGSize size = [self.text sizeWithFont:self.font];
        CGRect frame = self.frame;
        frame.size.width = size.width+_insets.right+_insets.left;
        frame.size.height = size.height+_insets.top+_insets.bottom;
        [self setFrame:frame];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

@end
