//
//  ANTestableRange.h
//  Alister-Example
//
//  Created by Oksana Kovalchuk on 10/7/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANTestableRange : UITextRange

@property (nonatomic, strong) UITextPosition* rangePosition;

- (void)updateWithRange:(UITextPosition*)range;

@end
