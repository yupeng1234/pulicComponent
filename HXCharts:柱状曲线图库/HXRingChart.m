//
//  HXRingChart.m
//  移动巡检
//
//  Created by 韩旭 on 2018/4/27.
//  Copyright © 2018年 韩旭. All rights reserved.
//

#import "HXRingChart.h"

static const CGFloat sAngle = - M_PI_2;
static const CGFloat eAngle = M_PI * 2;

@interface HXRingChart()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) NSMutableArray *layerArray;
@property (nonatomic, strong) NSMutableArray *mvArray;
@property (nonatomic, assign) CGFloat beginAngle;
@property (nonatomic, assign) CGPoint ACenter;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) float totality;
@property (nonatomic, assign) MarkViewDirection markViewDirection;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@end


@implementation HXRingChart

- (instancetype)initWithFrame:(CGRect)frame markViewDirection:(MarkViewDirection)markViewDirection{
    
    self =  [super initWithFrame:frame];
    
    if (self) {
        _beginAngle = sAngle;
        _markViewDirection = markViewDirection;
        _width = self.frame.size.width;
        _height = self.frame.size.height;
        
        CGFloat centerX = _width * 0.5;
        CGFloat centerY = _height * 0.5;
        if (markViewDirection == MarkViewDirectionLeft) {
            centerX = _width * 0.75;
            centerY = _height * 0.5;
        } else if (markViewDirection == MarkViewDirectionRight){
            centerX = _width * 0.25;
            centerY = _height * 0.5;
        } else if (markViewDirection == MarkViewDirectionTop){
            centerX = _width * 0.5;
            centerY = _height * 0.75;
        } else if (markViewDirection == MarkViewDirectionBottom){
            centerX = _width * 0.5;
            centerY = _height * 0.25;
        }
        
        _ACenter = CGPointMake(centerX,centerY);
        _radius = _height > _width ? _width * 0.5 - 15 : _height * 0.5 - 15;
        
        
        CGFloat count = [[NSString stringWithFormat:@"1"] floatValue];
        
        UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:_ACenter radius:_radius startAngle:0 endAngle:M_PI*2  clockwise:YES];
        
        CAShapeLayer *shapelayer = [CAShapeLayer layer];
        
        shapelayer.lineWidth = 10.0;
        UIColor *color = [UIColor lightGrayColor];
        shapelayer.strokeColor = color.CGColor;
        shapelayer.fillColor = [UIColor clearColor].CGColor;
        shapelayer.path = arcPath.CGPath;
        [self.layer addSublayer:shapelayer];
    }
    
    return self;
}

- (void)valueForTotality{
    _totality = 0;
    for (int i = 0; i < _valueArray.count; i++) {
        CGFloat count = [[NSString stringWithFormat:@"%@",_valueArray[i]] floatValue];
        _totality += count;
    }
}

- (void)setColorArray:(NSArray *)colorArray{
    _colorArray = colorArray;
}

- (void)setValueArray:(NSArray *)valueArray{
    _valueArray = valueArray;
    [self valueForTotality];
    
    for (CAShapeLayer *shapelayer in _layerArray) {
        [shapelayer removeFromSuperlayer];
    }
    
    _layerArray = [NSMutableArray array];
    _beginAngle = sAngle;
    for (int i = 0; i < _valueArray.count; i++) {
        CGFloat count = [[NSString stringWithFormat:@"%@",_valueArray[i]] floatValue];
        
        if (i == 0) {
            _endAngle = eAngle * (count / _totality) - M_PI_2;
        } else{
            _endAngle = _beginAngle + eAngle * (count / _totality);
        }
        
        UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:_ACenter radius:_radius startAngle:_beginAngle endAngle:_endAngle  clockwise:YES];
        
        _beginAngle = _endAngle;
        
        CAShapeLayer *shapelayer = [CAShapeLayer layer];
        
        shapelayer.lineWidth = 15.0;
        if (i<_colorArray.count) {
            
        }
        UIColor *color = (i<_colorArray.count) ? _colorArray[i]:_colorArray[_colorArray.count-1];
        shapelayer.strokeColor = color.CGColor;
        shapelayer.fillColor = [UIColor clearColor].CGColor;
        shapelayer.path = arcPath.CGPath;
        [self.layer addSublayer:shapelayer];
        [_layerArray addObject:shapelayer];
    }
    if (self.markViewDirection == MarkViewDirectionNone) {
        
        for (UIView *view in _mvArray) {
            [view removeFromSuperview];
        }
        _mvArray = [NSMutableArray array];
        for (int i = 0; i < (self.titleArray.count); i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_ACenter.x - _radius - 10, _ACenter.y + _radius + 20 + 20 * (i), 125, 20)];
            
            [self addSubview:view];
            view.alpha = 0;
            [_mvArray addObject:view];
            
            UIView *colorV = [[UIView alloc] initWithFrame:CGRectMake(0, 7.5, 5, 5)];
            [view addSubview:colorV];
            colorV.backgroundColor = (i<_colorArray.count) ? _colorArray[i]:_colorArray[_colorArray.count-1];
            colorV.layer.cornerRadius = 1;
            colorV.layer.masksToBounds = YES;
            
            UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 115, 12)];
            [view addSubview:tLabel];
            tLabel.text = [NSString stringWithFormat:@"%@ %g%%",_titleArray[i],[[NSString stringWithFormat:@"%.2f",[_valueArray[i] floatValue]/_totality*100] floatValue]];//_titleArray[i];
            tLabel.font = [UIFont systemFontOfSize:12];
            tLabel.textColor = [UIColor colorWithHexString:@"#666666"];
            tLabel.textAlignment = NSTextAlignmentLeft;
            
//            UILabel *vLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 50, 12)];
//            [view addSubview:vLabel];
//            vLabel.text = [NSString stringWithFormat:@"%g%%",[[NSString stringWithFormat:@"%.2f",[_valueArray[i] floatValue]/_totality*100] floatValue]];
//            vLabel.font = [UIFont systemFontOfSize:12];
//            vLabel.textColor = [UIColor colorWithHexString:@"#666666"];
//            vLabel.textAlignment = NSTextAlignmentCenter;
        }
    }else{
//        _valueLabel = [UILabel new];
//        [self addSubview:_valueLabel];
//        _valueLabel.frame = CGRectMake(_ACenter.x - 50, _ACenter.y , 100, 20);
//        _valueLabel.textColor = [UIColor colorWithHexString:@"#666666"];
//        _valueLabel.font = [UIFont systemFontOfSize:16 weight:0.2];
//        _valueLabel.textAlignment = NSTextAlignmentCenter;
//        //_valueLabel.text = [NSString stringWithFormat:@"%.0f",_totality];
//        _valueLabel.text = @"";
    }
    
}


-(void)drawArc
{
    if (_markViewDirection) {
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat mvWidth = 100;
        CGFloat mvHeight = 12;
        CGFloat margin = 0;
        
        for (UIView *view in _mvArray) {
            [view removeFromSuperview];
        }
        
        _mvArray = [NSMutableArray array];
        for (int i = 0; i < _valueArray.count; i++) {
            int indexX = i % 2;
            int indexY = i / 2;
            
            if (_markViewDirection == MarkViewDirectionLeft) {
                margin = (_radius * 2 - 12 * _valueArray.count) / 5;
                x = _width * 0.75 - _radius - mvWidth - 30;
                y = (_height - _radius * 2) / 2 + (margin + mvHeight) * i;
            } else if (_markViewDirection == MarkViewDirectionRight){
                margin = (_radius * 2 - 12 * _valueArray.count) / 5;
                x = _width * 0.25 + _radius + 30;
                y = (_height - _radius * 2) / 2 + (margin + mvHeight) * i;
            } else if (_markViewDirection == MarkViewDirectionTop){
                x = indexX == 0 ? _width / 2 - 15 - mvWidth : _width / 2 + 15;
                y = _height * 0.75 - _radius - 30 - (_valueArray.count / 2) * 12 - (_valueArray.count / 2 - 1) * 10 + indexY * (12 + 10);
            }  else if (_markViewDirection == MarkViewDirectionBottom){
                x = indexX == 0 ? _width / 2 - 15 - mvWidth : _width / 2 + 15;
                y = _height * 0.25 + _radius + 30 + indexY * (12 + 10);
            }
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, 90, 12)];
            [self addSubview:view];
            view.alpha = 0;
            [_mvArray addObject:view];
            
            UIView *colorV = [[UIView alloc] initWithFrame:CGRectMake(0, 3.5, 5, 5)];
            [view addSubview:colorV];
            colorV.backgroundColor = _colorArray[i];
            colorV.layer.cornerRadius = 1;
            colorV.layer.masksToBounds = YES;
            
            UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 54, 12)];
            [view addSubview:tLabel];
            tLabel.text = _titleArray[i];
            tLabel.font = [UIFont systemFontOfSize:12];
            tLabel.textColor = [UIColor colorWithHexString:@"#666666"];
            tLabel.textAlignment = NSTextAlignmentCenter;
            
            UILabel *vLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 30, 12)];
            [view addSubview:vLabel];
            vLabel.text = [NSString stringWithFormat:@"%g%%",[[NSString stringWithFormat:@"%.2f",[_valueArray[i] floatValue]/_totality*100] floatValue]];
            vLabel.font = [UIFont systemFontOfSize:12];
            vLabel.textColor = [UIColor colorWithHexString:@"#666666"];
            vLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    [_layerArray enumerateObjectsUsingBlock:^(CAShapeLayer *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath : NSStringFromSelector ( @selector (strokeEnd))];
        ani.fromValue = @0;
        ani.toValue = @1;
        ani.duration = 1.0;
        [obj addAnimation:ani forKey:NSStringFromSelector(@selector(strokeEnd))];
    }];
    
    [_mvArray enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:1 animations:^{
            obj.alpha = 1;
        }];
    }];
}

#pragma mark set
- (void)setTitle:(NSString *)title{
    ///标注
//    if (self.markViewDirection == MarkViewDirectionNone) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_ACenter.x - 35, _ACenter.y - 20, 70, 12)];
//        [self addSubview:view];
//        //view.alpha = 0;
//        [_mvArray addObject:view];
//
//        UIView *colorV = [[UIView alloc] initWithFrame:CGRectMake(0, 3.5, 5, 5)];
//        [view addSubview:colorV];
//        colorV.backgroundColor = _colorArray[0];
//        colorV.layer.cornerRadius = 1;
//        colorV.layer.masksToBounds = YES;
//
//        UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 30, 12)];
//        [view addSubview:tLabel];
//        tLabel.text = _titleArray[0];
//        tLabel.font = [UIFont systemFontOfSize:12];
//        tLabel.textColor = [UIColor colorWithHexString:@"#666666"];
//        tLabel.textAlignment = NSTextAlignmentCenter;
//
//        UILabel *vLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 30, 12)];
//        [view addSubview:vLabel];
//        vLabel.text = [NSString stringWithFormat:@"%@",_valueArray[0]];
//        vLabel.font = [UIFont systemFontOfSize:12];
//        vLabel.textColor = [UIColor colorWithHexString:@"#666666"];
//        vLabel.textAlignment = NSTextAlignmentCenter;
//    }else{
//        _titleLabel = [UILabel new];
//        [self addSubview:_titleLabel];
//        _titleLabel.frame = CGRectMake(_ACenter.x - 50, _ACenter.y - 20, 100, 15);
//        _titleLabel.textColor = [UIColor colorWithHexString:@"#666666"];
//        _titleLabel.font = [UIFont systemFontOfSize:12];
//        _titleLabel.textAlignment = NSTextAlignmentCenter;
//        _titleLabel.text = title;
//    }
    
}

- (void)setTitleFont:(UIFont *)titleFont{
    _titleLabel.font = titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleLabel.textColor = titleColor;
}

- (void)setValueFont:(UIFont *)valueFont{
    _valueLabel.font = valueFont;
}

- (void)setValueColor:(UIColor *)valueColor{
    _valueLabel.textColor = valueColor;
}

- (void)setRingWidth:(CGFloat)ringWidth{
    [_layerArray enumerateObjectsUsingBlock:^(CAShapeLayer *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.lineWidth = ringWidth;
    }];
}
@end

