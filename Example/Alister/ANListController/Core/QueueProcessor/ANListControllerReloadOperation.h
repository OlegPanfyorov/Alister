//
//  ANListControllerReloadOperation.h
//  Alister
//
//  Created by Oksana Kovalchuk on 7/1/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

#import "ANListControllerReloadOperationInterface.h"

@interface ANListControllerReloadOperation : NSOperation <ANListControllerReloadOperationInterface>

@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, weak) id<ANListControllerReloadOperationDelegate> delegate;

@end
