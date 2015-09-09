//
//  Common.h
//  VoronoiGame
//
//  Created by Robin on 3/17/15.
//  Copyright (c) 2015 Hongda. All rights reserved.
//

#import "MyView.h"

@interface Common : NSObject
+ (void)setMyViewPointer:(MyView *)pointer;
+ (MyView *)getMyViewPointer;
@end