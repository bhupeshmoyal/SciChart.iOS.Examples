//
//  ErrorBarsChartView.m
//  SciChartDemo
//
//  Created by Hrybenuik Mykola on 9/17/16.
//  Copyright © 2016 ABT. All rights reserved.
//

#import "ErrorBarsChartView.h"
#import <SciChart/SciChart.h>
#import "DataManager.h"

@implementation ErrorBarsChartView


@synthesize surface;

- (void)initializeSurfaceRenderableSeries {
    
    SCIXyDataSeries * data = [[SCIXyDataSeries alloc] initWithXType:SCIDataType_Float YType:SCIDataType_Float];
    [DataManager getFourierSeriesZoomed:data amplitude:1.0 phaseShift:0.1 xStart:5.0 xEnd:5.15 count:5000];
    
    SCIHlDataSeries * dataSeries0 = [[SCIHlDataSeries alloc] initWithXType:SCIDataType_Float YType:SCIDataType_Float];
    SCIHlDataSeries * dataSeries1 = [[SCIHlDataSeries alloc] initWithXType:SCIDataType_Float YType:SCIDataType_Float];
    
    [self fillSeries:dataSeries0 sourceData:data scale:0.06];
    [self fillSeries:dataSeries1 sourceData:data scale:0.1];
    
    SCIFastErrorBarsRenderableSeries * errorBars0 = [SCIFastErrorBarsRenderableSeries new];
    [errorBars0 setDataPointWidth:0.7];
    errorBars0.strokeStyle = [[SCISolidPenStyle alloc] initWithColorCode:0xFFC6E6FF withThickness:1.f];
    errorBars0.dataSeries = dataSeries0;
    [errorBars0 addAnimation:[[SCIScaleRenderableSeriesAnimation alloc] initWithDuration:3 curveAnimation:SCIAnimationCurve_EaseOutElastic]];
    
    SCIFastLineRenderableSeries * lineSeries = [SCIFastLineRenderableSeries new];
    lineSeries.strokeStyle = [[SCISolidPenStyle alloc] initWithColorCode:0xFFC6E6FF withThickness:1.f];
    lineSeries.dataSeries = dataSeries0;
    [lineSeries addAnimation:[[SCIScaleRenderableSeriesAnimation alloc] initWithDuration:3 curveAnimation:SCIAnimationCurve_EaseOutElastic]];
    
    SCIEllipsePointMarker * pMarker = [[SCIEllipsePointMarker alloc]init];
    pMarker.width = 5;
    pMarker.height = 5;
    pMarker.fillStyle = [[SCISolidBrushStyle alloc]initWithColorCode:0xFFC6E6FF];
    lineSeries.pointMarker = pMarker;
    
    [surface.renderableSeries add:errorBars0];
    [surface.renderableSeries add:lineSeries];
    
    SCIFastErrorBarsRenderableSeries * errorBars1 = [SCIFastErrorBarsRenderableSeries new];
    errorBars1.strokeStyle = [[SCISolidPenStyle alloc] initWithColorCode:0xFFC6E6FF withThickness:1.f];
    errorBars1.dataSeries = dataSeries1;
    [errorBars1 setDataPointWidth:0.7];
    [errorBars1 addAnimation:[[SCIScaleRenderableSeriesAnimation alloc] initWithDuration:3 curveAnimation:SCIAnimationCurve_EaseOutElastic]];
    
    SCIXyScatterRenderableSeries * scatterSeries = [SCIXyScatterRenderableSeries new];
    scatterSeries.dataSeries = dataSeries1;
    [scatterSeries addAnimation:[[SCIScaleRenderableSeriesAnimation alloc] initWithDuration:3 curveAnimation:SCIAnimationCurve_EaseOutElastic]];
    
    SCIEllipsePointMarker * sMarker = [[SCIEllipsePointMarker alloc]init];
    sMarker.width = 7;
    sMarker.height = 7;
    sMarker.fillStyle = [[SCISolidBrushStyle alloc]initWithColorCode:0x00FFFFFF];
    scatterSeries.style.pointMarker = sMarker;
    scatterSeries.dataSeries = dataSeries1;
    
    [surface.renderableSeries add:errorBars1];
    [surface.renderableSeries add:scatterSeries];
    
    [surface invalidateElement];
}

-(void) fillSeries:(id<SCIHlDataSeriesProtocol>)dataSeries sourceData:(id<SCIXyDataSeriesProtocol>)sourceData scale:(double)scale{
    SCIArrayController * xValues = [sourceData xValues];
    SCIArrayController * yValues = [sourceData yValues];
    
    for (int i =0 ; i< xValues.count; i++){
        double y = SCIGenericDouble([yValues valueAt:i]) * scale;
        [dataSeries appendX: [xValues valueAt:i] Y:SCIGeneric(y) High:SCIGeneric(randf(0.0, 1.0)*0.2) Low:SCIGeneric(randf(0.0, 1.0)*0.2)];
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        SCIChartSurface * view = [[SCIChartSurface alloc]initWithFrame:frame];
        surface = view;
        
        [surface setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:surface];
        NSDictionary *layout = @{@"SciChart":surface};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[SciChart]-(0)-|" options:0 metrics:0 views:layout]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[SciChart]-(0)-|" options:0 metrics:0 views:layout]];
        
        [self setupSurface];
        [self addAxes];
        [self addModifiers];
        [self initializeSurfaceRenderableSeries];
    }
    return self;
}

- (void)setupSurface {
    
}

- (void)addAxes{
    id<SCIAxis2DProtocol> axis = [[SCINumericAxis alloc] init];
    [surface.yAxes add:axis];
    
    axis = [[SCINumericAxis alloc] init];
    [surface.xAxes add:axis];
}

- (void)addModifiers{
    SCIXAxisDragModifier * xDragModifier = [SCIXAxisDragModifier new];
    xDragModifier.dragMode = SCIAxisDragMode_Scale;
    xDragModifier.clipModeX = SCIClipMode_None;
    
    SCIYAxisDragModifier * yDragModifier = [SCIYAxisDragModifier new];
    yDragModifier.dragMode = SCIAxisDragMode_Pan;
    
    SCIPinchZoomModifier * pzm = [[SCIPinchZoomModifier alloc] init];
    
    SCIZoomExtentsModifier * zem = [[SCIZoomExtentsModifier alloc] init];
    [zem setModifierName:@"ZoomExtents Modifier"];
    
    SCIRolloverModifier * rollover = [[SCIRolloverModifier alloc] init];
    rollover.style.tooltipSize = CGSizeMake(200, NAN);
    [rollover setModifierName:@"Rollover Modifier"];
    
    SCIChartModifierCollection * gm = [[SCIChartModifierCollection alloc] initWithChildModifiers:@[xDragModifier, yDragModifier, zem, pzm, rollover]];
    surface.chartModifiers = gm;
}

@end
