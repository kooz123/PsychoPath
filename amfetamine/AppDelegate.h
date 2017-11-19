//
//  AppDelegate.h
//  amfetamine
//
//  Created by Sem Voigtländer on 19/11/2017.
//  Copyright © 2017 Sem Voigtländer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

