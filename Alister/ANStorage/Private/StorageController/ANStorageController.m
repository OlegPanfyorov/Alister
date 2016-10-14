//
//  ANStorageController.m
//  Pods
//
//  Created by Oksana Kovalchuk on 1/28/16.
//
//

#import <Alister/ANStorageController.h>
#import "ANStorageUpdateModel.h"
#import "ANStorageUpdater.h"
#import "ANStorageSupplementaryManager.h"
#import "ANStorageRemover.h"
#import "ANStorageLoader.h"
#import <Alister/ANStorageModel.h>
#import <Alister/ANStorageSectionModel.h>

@implementation ANStorageController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storageModel = [ANStorageModel new];
    }
    return self;
}

- (void)addItem:(id)item
{
    ANStorageUpdateModel* update = [ANStorageUpdater addItem:item toStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)addItems:(NSArray*)items
{
    ANStorageUpdateModel* update = [ANStorageUpdater addItems:items toStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)addItem:(id)item toSection:(NSUInteger)sectionIndex
{
    ANStorageUpdateModel* update = [ANStorageUpdater addItem:item toSection:sectionIndex toStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)addItems:(NSArray*)items toSection:(NSUInteger)sectionIndex
{
    ANStorageUpdateModel* update = [ANStorageUpdater addItems:items toSection:sectionIndex toStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)addItem:(id)item atIndexPath:(NSIndexPath*)indexPath
{
    ANStorageUpdateModel* update = [ANStorageUpdater addItem:item atIndexPath:indexPath toStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}


#pragma mark - Reloading

- (void)reloadItem:(id)item
{
    ANStorageUpdateModel* update = [ANStorageUpdater reloadItem:item inStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)reloadItems:(id)items
{
    ANStorageUpdateModel* update = [ANStorageUpdater reloadItems:items inStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}


#pragma mark - Removing

- (void)removeItem:(id)item
{
    ANStorageUpdateModel* update = [ANStorageRemover removeItem:item fromStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)removeItemsAtIndexPaths:(NSSet*)indexPaths
{
    ANStorageUpdateModel* update = [ANStorageRemover removeItemsAtIndexPaths:indexPaths fromStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)removeItems:(NSSet*)items
{
    ANStorageUpdateModel* update = [ANStorageRemover removeItems:items fromStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)removeAllItemsAndSections
{
    ANStorageUpdateModel* update = [ANStorageRemover removeAllItemsAndSectionsFromStorage:self.storageModel];
    update.isRequireReload = YES;
    [self.updateDelegate collectUpdate:update];
}

- (void)removeSections:(NSIndexSet*)indexSet
{
    ANStorageUpdateModel* update = [ANStorageRemover removeSections:indexSet fromStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}


#pragma mark - Replacing / Moving

- (void)replaceItem:(id)itemToReplace withItem:(id)replacingItem
{
    ANStorageUpdateModel* update = [ANStorageUpdater replaceItem:itemToReplace withItem:replacingItem inStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)moveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
    ANStorageUpdateModel* update = [ANStorageUpdater moveItemFromIndexPath:fromIndexPath
                                                               toIndexPath:toIndexPath
                                                                 inStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}


#pragma mark - Loading

- (NSArray*)sections
{
    return [self.storageModel sections];
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [ANStorageLoader itemAtIndexPath:indexPath inStorage:self.storageModel];
}

- (ANStorageSectionModel*)sectionAtIndex:(NSUInteger)sectionIndex
{
    return [ANStorageLoader sectionAtIndex:sectionIndex inStorage:self.storageModel];
}

- (NSArray*)itemsInSection:(NSUInteger)sectionIndex
{
    return [ANStorageLoader itemsInSection:sectionIndex inStorage:self.storageModel];
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath
{
    return [ANStorageLoader itemAtIndexPath:indexPath inStorage:self.storageModel];
}

- (NSIndexPath*)indexPathForItem:(id)item
{
    return [ANStorageLoader indexPathForItem:item inStorage:self.storageModel];
}

- (BOOL)isEmpty
{
    __block NSInteger count = 0;
    [[self sections] enumerateObjectsUsingBlock:^(ANStorageSectionModel*  _Nonnull obj, __unused NSUInteger idx, __unused BOOL*  _Nonnull stop) {
        
        count += [obj numberOfObjects];
        if (count)
        {
           *stop = YES;
        }
    }];
    return (count == 0);
}

#pragma mark - Supplementaries

- (void)updateSectionHeaderModel:(id)headerModel forSectionIndex:(NSInteger)sectionIndex
{
    ANStorageUpdateModel* update = [ANStorageSupplementaryManager updateSectionHeaderModel:headerModel
                                                                           forSectionIndex:sectionIndex
                                                                                 inStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)updateSectionFooterModel:(id)footerModel forSectionIndex:(NSInteger)sectionIndex
{
    ANStorageUpdateModel* update = [ANStorageSupplementaryManager updateSectionFooterModel:footerModel
                                                                           forSectionIndex:sectionIndex
                                                                                 inStorage:self.storageModel];
    [self.updateDelegate collectUpdate:update];
}

- (void)updateSupplementaryHeaderKind:(NSString*)headerKind
{
    self.storageModel.headerKind = headerKind;
}

- (void)updateSupplementaryFooterKind:(NSString*)footerKind
{
    self.storageModel.footerKind = footerKind;
}

- (id)headerModelForSectionIndex:(NSUInteger)index
{
    return [ANStorageSupplementaryManager supplementaryModelOfKind:self.storageModel.headerKind
                                                   forSectionIndex:index
                                                         inStorage:self.storageModel];
}

- (id)footerModelForSectionIndex:(NSUInteger)index
{
    return [ANStorageSupplementaryManager supplementaryModelOfKind:self.storageModel.footerKind
                                                   forSectionIndex:index
                                                         inStorage:self.storageModel];
}

- (id)supplementaryModelOfKind:(NSString*)kind forSectionIndex:(NSUInteger)sectionIndex
{
    return [ANStorageSupplementaryManager supplementaryModelOfKind:kind
                                                   forSectionIndex:sectionIndex
                                                         inStorage:self.storageModel];
}

- (NSString*)footerSupplementaryKind
{
    return self.storageModel.footerKind;
}

- (NSString*)headerSupplementaryKind
{
    return self.storageModel.headerKind;
}


#pragma mark - Private

- (void)setUpdateDelegate:(id<ANStorageUpdateOperationInterface>)updateDelegate
{
    if ([updateDelegate conformsToProtocol:@protocol(ANStorageUpdateOperationInterface)] || !updateDelegate)
    {
        _updateDelegate = updateDelegate;
    }
    else
    {
        NSAssert(NO, @"Delegate must conforms to protocol");
    }
}

@end
