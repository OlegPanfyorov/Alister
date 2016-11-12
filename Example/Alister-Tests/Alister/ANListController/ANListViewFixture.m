//
//  ANListViewFixture.m
//  Alister-Example
//
//  Created by Oksana Kovalchuk on 11/11/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

#import "ANListViewFixture.h"

@implementation ANListViewFixture

- (void)reloadData
{
    
}

- (void)registerCellClass:(Class)cellClass forReuseIdentifier:(NSString *)identifier
{
    self.lastCellClass = cellClass;
    self.lastIdentifier = identifier;
    self.wasRegisterCalled = YES;
}

- (id<ANListControllerUpdateViewInterface>)supplementaryViewForReuseIdentifer:(NSString *)reuseIdentifier
                                                                         kind:(NSString *)kind
                                                                  atIndexPath:(NSIndexPath *)indexPath
{
    self.wasRetriveCalled = YES;
    return nil;
}

- (id<ANListControllerUpdateViewInterface>)cellForReuseIdentifier:(NSString *)reuseIdentifier
                                                      atIndexPath:(NSIndexPath *)indexPath
{
    self.wasRetriveCalled = YES;
    return nil;
}

- (void)registerSupplementaryClass:(Class)supplementaryClass
                   reuseIdentifier:(NSString*)reuseIdentifier
                              kind:(NSString*)kind
{
    self.lastCellClass = supplementaryClass;
    self.lastIdentifier = reuseIdentifier;
    self.wasRegisterCalled = YES;
    self.lastKind = kind;
}

- (UIScrollView*)view
{
    return nil;
}

- (NSString*)headerDefaultKind
{
    if (!_headerDefaultKind)
    {
        _headerDefaultKind = [ANTestHelper randomString];
    }
    return _headerDefaultKind;
}

- (NSString*)footerDefaultKind
{
    if (!_footerDefaultKind)
    {
        _footerDefaultKind = [ANTestHelper randomString];
    }
    return _footerDefaultKind;
}

- (CGFloat)reloadAnimationDuration
{
    return 0;
}

- (NSString *)animationKey
{
    if (!_animationKey)
    {
        _animationKey = [ANTestHelper randomString];
    }
    return _animationKey;
}

- (void)performUpdate:(ANStorageUpdateModel *)update animated:(BOOL)animated
{
    
}

@end