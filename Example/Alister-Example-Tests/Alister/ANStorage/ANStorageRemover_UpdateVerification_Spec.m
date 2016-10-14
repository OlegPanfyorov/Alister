//
//  ANStorageRemover_UpdateVerification_Spec.m
//  Alister-Example
//
//  Created by Oksana Kovalchuk on 10/12/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

#import <Alister/ANStorageUpdater.h>
#import <Alister/ANStorageModel.h>
#import <Alister/ANStorageUpdateModel.h>
#import <Alister/ANStorageRemover.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

SpecBegin(ANStorageRemover_UpdateVerification_Spec)

__block ANStorageModel* storage = nil;

beforeEach(^{
    storage = [ANStorageModel new];
});

describe(@"removeItem:", ^{
    
    it(@"successfully removes item", ^{
        NSString* item = @"test";
        [ANStorageUpdater addItem:item toStorage:storage];
        ANStorageUpdateModel* update = [ANStorageRemover removeItem:item fromStorage:storage];
        
        ANStorageUpdateModel* expected = [ANStorageUpdateModel new];
        [expected addDeletedIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
        
        expect(update).equal(expected);
    });
    
    it(@"update will be empty if item is nil", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeItem:nil fromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"update will be empty if storage is nil", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeItem:@"test" fromStorage:nil];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"update will be empty if item not exist in storageModel", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeItem:@"test" fromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
});


describe(@"removeItemsAtIndexPaths:", ^{
    
    __block NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    it(@"removes only specified indexPaths", ^{
        NSString* item = @"test";
        [ANStorageUpdater addItem:item toStorage:storage];
        [ANStorageUpdater addItem:@"smt" atIndexPath:indexPath toStorage:storage];
        ANStorageUpdateModel* update = [ANStorageRemover removeItemsAtIndexPaths:[NSSet setWithObject:indexPath]
                                                                     fromStorage:storage];
        ANStorageUpdateModel* expected = [ANStorageUpdateModel new];
        [expected addDeletedIndexPaths:@[indexPath]];
        
        expect(update).equal(expected);
    });
    
    it(@"update will be empty if indexPaths are nil", ^{
        
        ANStorageUpdateModel* update = [ANStorageRemover removeItemsAtIndexPaths:nil fromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"update will be empty if storage is nil", ^{
        
        ANStorageUpdateModel* update = [ANStorageRemover removeItemsAtIndexPaths:[NSSet setWithObject:indexPath]
                                                                     fromStorage:nil];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"update will be empty if indexPaths are not exist in storageModel", ^{
        
        ANStorageUpdateModel* update = [ANStorageRemover removeItemsAtIndexPaths:[NSSet setWithObject:indexPath]
                                                                     fromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
});


describe(@"removeItems:", ^{
    
    it(@"removes only specified items", ^{
        NSString* item = @"test";
        [ANStorageUpdater addItems:@[item, @"test2"] toStorage:storage];
        ANStorageUpdateModel* update = [ANStorageRemover removeItems:[NSSet setWithObject:item]
                                                         fromStorage:storage];
        
        ANStorageUpdateModel* expected = [ANStorageUpdateModel new];
        [expected addDeletedIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
        
        expect(update).equal(expected);
    });
    
    it(@"update will be empty if items are nil", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeItems:nil fromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"no asert if items not exist in storageModel", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeItems:[NSSet setWithObject:@"test"]
                                                         fromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"update will be empty if storage is nil", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeItems:[NSSet setWithObject:@"test"]
                                                         fromStorage:nil];
        expect(update.isEmpty).beTruthy();
    });
});


describe(@"removeAllItemsAndSections", ^{
    
    it(@"removes all sections", ^{
        
        [ANStorageUpdater addItem:@"test" toStorage:storage];
        [ANStorageUpdater addItem:@"test2" atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] toStorage:storage];
        
        ANStorageUpdateModel* update = [ANStorageRemover removeAllItemsAndSectionsFromStorage:storage];
        ANStorageUpdateModel* expected = [ANStorageUpdateModel new];
        expected.isRequireReload = YES;
        
        //TODO: check this after unit tests on operations
//        [expected addDeletedSectionIndex:0];
//        [expected addDeletedSectionIndex:1];
        
        expect(update).equal(expected);
    });
    
    it(@"update will be empty if storage is empty", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeAllItemsAndSectionsFromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"update will be empty if storage is nil", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeAllItemsAndSectionsFromStorage:nil];
        expect(update.isEmpty).beTruthy();
    });
});


describe(@"removeSections:", ^{
    
    it(@"removes only specified sections", ^{
        NSString* testModel = @"test0";
        NSArray* items = @[@"test1", @"test2", @"test3"];
        
        [ANStorageUpdater addItem:testModel toSection:1 toStorage:storage];
        [ANStorageUpdater addItems:items toSection:0 toStorage:storage];
        ANStorageUpdateModel* update = [ANStorageRemover removeSections:[NSIndexSet indexSetWithIndex:0] fromStorage:storage];
        
        ANStorageUpdateModel* expected = [ANStorageUpdateModel new];
        [expected addDeletedSectionIndex:0];
        
        expect(update).equal(expected);
    });
    
    it(@"update will be empty if section is not exist", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeSections:[NSIndexSet indexSetWithIndex:2] fromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"update will be empty if indexSet is nil", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeSections:nil fromStorage:storage];
        expect(update.isEmpty).beTruthy();
    });
    
    it(@"update will be empty if storage is nil", ^{
        ANStorageUpdateModel* update = [ANStorageRemover removeSections:[NSIndexSet indexSetWithIndex:0] fromStorage:nil];
        expect(update.isEmpty).beTruthy();
    });
});


SpecEnd

#pragma clang diagnostic pop