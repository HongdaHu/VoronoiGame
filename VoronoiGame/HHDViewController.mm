//
//  HHDViewController.m
//  VoronoiGame
//
//  Created by Robin on 3/17/15.
//  Copyright (c) 2015 Hongda. All rights reserved.
//

#import "HHDViewController.h"
#import "Common.h"


@interface HHDViewController ()
@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) UIAlertView *alert;
@end

@implementation HHDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.alertView = [[UIAlertView alloc]
                      initWithTitle:@"Voronoi Game"
                      message:@"Do you want to restart?"
                      delegate:self
                      cancelButtonTitle:@"Yes"
                      otherButtonTitles:@"No",nil
                      ];
    self.alertView.tag = 1;
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//shake!!!
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake){
        NSLog(@"Detected a shake");
        [self showAlert];
    }
}
-(BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}
-(IBAction)showAlert
{
    [self.alertView show];
    [self.alert show];
}

#pragma marks -- UIAlertViewDelegate --
//根据被点击按钮的索引处理点击事件
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"clickButtonAtIndex:%d",buttonIndex);
//}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case 1:
		{
			switch (buttonIndex) {
				case 0: // yes
				{
					NSLog(@"Yeeeeeeeeeeeeees!");
                    //[view clearGraph];
                    [[Common getMyViewPointer] clearGraph];

                    
				}
					break;
				case 1: // no
				{
					NSLog(@"Nooooooooooooooo!");
				}
					break;
			}
            
			break;
		default:
			NSLog(@"WebAppListVC.alertView: clickedButton at index. Unknown alert type");
		}
	}	
}







@end
