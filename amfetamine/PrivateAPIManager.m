//
//  PrivateAPIManager.m
//  amfetamine
//
//  Created by Sem Voigtländer on 29/11/2017.
//  Copyright © 2017 Sem Voigtländer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrivateAPIManager.h"
@interface PrivateAPI()
@end
@implementation PrivateAPI
+ (BOOL)loadPrivateAPIWithPath:(NSString*)path {
    NSBundle*b = [NSBundle bundleWithPath:path];
    return [b load];
}


@end
