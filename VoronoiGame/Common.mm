//
//  Common.mm
//  VoronoiGame
//
//  Created by Robin on 3/17/15.
//  Copyright (c) 2015 Hongda. All rights reserved.
//


#import "Common.h"

static MyView * MyViewPointer = nil;
@implementation Common
+ (void)setMyViewPointer:(MyView *)pointer
{
    MyViewPointer = pointer;
}
+ (MyView *)getMyViewPointer
{
    return MyViewPointer;
}

@end