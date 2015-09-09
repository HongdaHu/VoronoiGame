//
//  MyView.m
//  VoronoiGame
//
//  Created by Robin on 3/17/15.
//  Copyright (c) 2015 Hongda. All rights reserved.
//

#import "MyView.h"
#import "VoronoiDiagramGenerator.h"
#import "Common.h"
#import "GamePoint.cpp"

const float DIAMETER = 8.0;
const float minX=0;
const float minY=0;
const float maxX=320;
const float maxY=536;
const float minDist = 0;
const UIColor * cocaColor = [UIColor colorWithRed: (255.0/255.0 ) green: (51.0/255.0) blue: (51.0/255.0) alpha:1.0];
const UIColor * pepsiColor = [UIColor colorWithRed: (51.0/255.0 ) green: (51.0/255.0) blue: (255.0/255.0) alpha:1.0];

@interface MyView()
@property (nonatomic) CGPoint myPoint;
@property (nonatomic) NSMutableArray *myPointsArray;
@end

@implementation MyView

//Gettor and Settor
@synthesize myPoint = _myPoint;
@synthesize myPointsArray = _myPointsArray;
//@synthesize myPointsArray = _myPointsArray;

//initialize
- (id)initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        self.myPointsArray = [[NSMutableArray alloc]init];
        self.myPoint = CGPointMake(-20,-20);
    }
    [Common setMyViewPointer:self];
    return self;
}

- (void)clearGraph
{
    [self.myPointsArray removeAllObjects];
    self.myPoint = CGPointMake(-20,-20);
    [self setNeedsDisplay];
}

//---fired when the user finger(s) touches the screen---
-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
    //---get all touches on the screen---
    NSSet *allTouches = [event allTouches];
    
    //---compare the number of touches on the screen---
    switch ([allTouches count])
    {
        //---single touch---
        case 1: {
            //---get info of the touch---
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint point = [touch locationInView:self];
            self.myPoint = point;
            [self.myPointsArray addObject:[NSValue valueWithCGPoint:self.myPoint]];
            //---compare the touches---
            switch ([touch tapCount])
            {
                //---single tap---
                case 1: {
                    //NSLog(@"Single tap");
                } break;
                //---double tap---
                case 2: {
                    //NSLog(@"DoubleTap");
                } break;
            }
        }   break;
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //---get all touches on the screen---
    NSSet *allTouches = [event allTouches];
    //---get info of the touch---
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint point = [touch locationInView:self];
    [self.myPointsArray removeLastObject];
    self.myPoint = point;
    [self.myPointsArray addObject:[NSValue valueWithCGPoint:self.myPoint]];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //---get all touches on the screen---
    NSSet *allTouches = [event allTouches];
    //---get info of the touch---
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint point = [touch locationInView:self];
    [self.myPointsArray removeLastObject];
    self.myPoint = point;
    [self.myPointsArray addObject:[NSValue valueWithCGPoint:self.myPoint]];
//    NSLog(@"point# %lu", (unsigned long)[self.myPointsArray count]);
    [self setNeedsDisplay];
}

- (float*)getxValues:(NSMutableArray *)myPointsArray{
    NSUInteger numPoints = [myPointsArray count];
    float *xValues = (float *)malloc(sizeof(float) * (numPoints+2));
    for(int i=0;i<numPoints;i++){
        NSValue *val = myPointsArray[i];
        CGPoint p = [val CGPointValue];
        xValues[i]=p.x;
    }
    return xValues;
}

- (float*)getyValues:(NSMutableArray *)myPointsArray{
    NSUInteger numPoints = [myPointsArray count];
    float *yValues = (float *)malloc(sizeof(float) * (numPoints+2));
    for(int i=0;i<numPoints;i++){
        NSValue *val = myPointsArray[i];
        CGPoint p = [val CGPointValue];
        yValues[i]=p.y;
    }
    return yValues;
}

//Whenever there is a setNeedsDisplay => call drawRect to draw the UIView
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 2.0);
    //color of the point
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1.0);
    //Draw current point
    CGRect circlePoint = CGRectMake(self.myPoint.x -(DIAMETER/2), self.myPoint.y -(DIAMETER/2), DIAMETER, DIAMETER);
    CGContextFillEllipseInRect(ctx, circlePoint);
    //Draw previous points
    for (NSValue *val in _myPointsArray)
    {
        CGPoint p = [val CGPointValue];
        //rect size
        CGRect circlePoint = CGRectMake(p.x -(DIAMETER/2), p.y -(DIAMETER/2), DIAMETER, DIAMETER);
        //draw rect
        CGContextFillEllipseInRect(ctx, circlePoint);
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //Start run voronoiGame:
    ///////////////////////////////////////////////////////////////////////////////////////////////
    float *xValues = [self getxValues: self.myPointsArray];
    float *yValues = [self getyValues: self.myPointsArray];
    //int numPoints=(int)[[self myPointsArray] count];
    int numPoints=(int)[self.myPointsArray count];
    VoronoiDiagramGenerator *v1 = new VoronoiDiagramGenerator();
    //add a temp point:
    v1->generateVoronoi(xValues, yValues, numPoints, minX, maxX, minY, maxY, minDist);
    
    //------------------------------------------------------------------------------
    //Generate the regions' class.
    //------------------------------------------------------------------------------
    Border *CommonBorder = new Border();
    vector<GamePoint*> GamePoints;
    for (int i=0; i<numPoints; i++) {
        NSValue *val = self.myPointsArray[i];
        CGPoint p = [val CGPointValue];
        //xValues[i]=p.x;
        GamePoints.push_back(new GamePoint(i,i/2,p.x,p.y,CommonBorder));
    }
    
    //for every edge, put it into the gamepoints and cutboards.
    GraphEdge * edgeindex = v1->allEdges;
    int count=0;
    while (edgeindex!=nullptr){
        int s1 = edgeindex->s1n;
        int s2 = edgeindex->s2n;
        float x1 = (int)(10*edgeindex->x1)/10.0;
        float y1 = (int)(10*edgeindex->y1)/10.0;
        float x2 = (int)(10*edgeindex->x2)/10.0;
        float y2 = (int)(10*edgeindex->y2)/10.0;
        GamePoints[s1]->add_edge(PolyPoint(x1,y1), PolyPoint(x2,y2), s1);
        GamePoints[s2]->add_edge(PolyPoint(x1,y1), PolyPoint(x2,y2), s2);
        CommonBorder->cutBorder(x1,y1);
        CommonBorder->cutBorder(x2,y2);

        edgeindex=edgeindex->next;
        count++;
    }

    //generate the commonborderlist.
    CommonBorder->init_bplist();
    //all needed is set, sort and connect them.
    float area[2] = {0,0};
    for (int i=0; i<numPoints; i++) {
        GamePoints[i]->genEdgeLoop();
        area[i%2] += GamePoints[i]->get_area();
        //print color!!!
        int en = (int) GamePoints[i]->loopVertexID.size();
        float tx,ty;
        if (en>0) {
            GamePoints[i]->get_ref_xy(0,tx,ty);
            CGContextMoveToPoint(ctx, tx, ty);
            for (int e=1; e< en ; e++) {
                GamePoints[i]->get_ref_xy(e,tx,ty);
                CGContextAddLineToPoint(ctx, tx, ty);
            }
            if(i%2==0) CGContextSetFillColorWithColor(ctx, cocaColor.CGColor);
            if(i%2!=0) CGContextSetFillColorWithColor(ctx, pepsiColor.CGColor);

            CGContextFillPath(ctx);
        }
    }

    cout<<"Area0 = "<<(area[0])/(LENGTH*HEIGHT)*100<<" %"<<endl;
    area[0]=(area[0])/(LENGTH*HEIGHT)*100;
    area[1]=(area[1])/(LENGTH*HEIGHT)*100;
    
    delete CommonBorder;
    for (int i=0; i<numPoints; i++) {
        delete GamePoints[i];
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //Draw voronoi lines
    ///////////////////////////////////////////////////////////////////////////////////////////////
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    GraphEdge * p = v1->allEdges;
    int i=0;
    while (p!=nullptr){
        //Start point
        CGContextMoveToPoint(ctx, p->x1, p->y1);
        //End point
        CGContextAddLineToPoint(ctx, p->x2, p->y2);
        //Draw line
        CGContextDrawPath(ctx, kCGPathStroke);
        p=p->next;
        i++;
    }
    
    delete v1;
    delete xValues;
    delete yValues;
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    circlePoint = CGRectMake(self.myPoint.x -(DIAMETER/2), self.myPoint.y -(DIAMETER/2), DIAMETER, DIAMETER);
    CGContextFillEllipseInRect(ctx, circlePoint);
    
    //Draw previous points
    for (NSValue *val in _myPointsArray)
    {
        CGPoint p = [val CGPointValue];
        //rect size
        CGRect circlePoint = CGRectMake(p.x -(DIAMETER/2), p.y -(DIAMETER/2), DIAMETER, DIAMETER);
        //draw rect
        CGContextFillEllipseInRect(ctx, circlePoint);
    }
    
    for (UIView *view in [self subviews])
    {
        [view removeFromSuperview];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0/*left*/, 0/*top*/, 320/*wedth*/, 80/*top margin*/)];
    label.text = [NSString stringWithFormat:@" Coca-Cola: %.2f%% \n Pepsi-Cola: %.2f%% ", area[0],area[1]];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 2;
    label.font = [UIFont fontWithName:@"Georgia-Italic-Bold" size:18];   //设置label的字体和字体大小。
    [self addSubview:label];

}

@end