//
//  ANListControllerQueueProcessorInterface.h
//  Alister-Example
//
//  Created by Oksana Kovalchuk on 11/4/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

@protocol ANListViewInterface;
@protocol ANListControllerConfigurationModelInterface;

@protocol ANListControllerQueueProcessorInterface <NSObject>

- (void)storageNeedsReloadWithIdentifier:(NSString*)identifier animated:(BOOL)isAnimated;

- (id<ANListViewInterface>)listView;

//TODO: temp!
- (id<ANListControllerConfigurationModelInterface>)configurationModel;

@end