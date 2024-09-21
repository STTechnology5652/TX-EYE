//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <Photos/Photos.h>

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting (ARC).
#endif

@interface ALAssetsLibrary (Private)

/*! A block wraper to be executed after asset adding process done. (Private)
 *
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed to add the asset to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */
- (ALAssetsLibraryWriteImageCompletionBlock)_resultBlockOfAddingToAlbum:(NSString *)albumName
                                                             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! A block wraper to be executed after |-assetForURL:resultBlock:failureBlock:| succeed.
 *  Generally, this block will be excused when user confirmed the application's access
 *    to the library.
 *
 * \param group A group to be used to add photo to the target album
 * \param assetURL The URL for the target asset
 * \param completion Block to be executed when succeed to add the asset to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 *
 * \return An ALAssetsLibraryAssetForURLResultBlock type block
 */
- (ALAssetsLibraryAssetForURLResultBlock)_assetForURLResultBlockWithGroup:(ALAssetsGroup *)group
                                                                 assetURL:(NSURL *)assetURL
                                                               completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                  failure:(ALAssetsLibraryAccessFailureBlock)failure;

@end


@implementation ALAssetsLibrary (CustomPhotoAlbum)

#pragma mark - Private Method

- (ALAssetsLibraryWriteImageCompletionBlock)_resultBlockOfAddingToAlbum:(NSString *)albumName
                                                             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    return ^(NSURL *assetURL, NSError *error) {
        // Run the completion block for writing image to saved
        //   photos album
        //if (completion) completion(assetURL, error);
        
        // If an error occured, do not try to add the asset to
        //   the custom photo album
        if (error != nil) {
            if (failure) failure(error);
            return;
        }
        
        // Add the asset to the custom photo album
        [self addAssetURL:assetURL
                  toAlbum:albumName
               completion:completion
                  failure:failure];
    };
}

- (ALAssetsLibraryAssetForURLResultBlock)_assetForURLResultBlockWithGroup:(ALAssetsGroup *)group
                                                                 assetURL:(NSURL *)assetURL
                                                               completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                  failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    return ^(ALAsset *asset) {
        // Add photo to the target album
        if ([group addAsset:asset]) {
            // Run the completion block if the asset was added successfully
            if (completion) completion(assetURL, nil);
        }
        // |-addAsset:| may fail (return NO) if the group is not editable,
        //   or if the asset could not be added to the group.
        else {
            NSString * message = [NSString stringWithFormat:@"ALAssetsGroup failed to add asset: %@.", asset];
            if (failure) failure([NSError errorWithDomain:@"LIB_ALAssetsLibrary_CustomPhotoAlbum"
                                                     code:0
                                                 userInfo:@{NSLocalizedDescriptionKey : message}]);
        }
    };
}

- (void)addAssetFromImage:(UIImage *)image
                  toAlbum:(NSString *)albumName
               completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                  failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    void (^requestBlock)(PHAssetCollection *assetCollection) = ^(PHAssetCollection *assetCollection){
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    };
    
    [self addAssetUsingRequestBlock:requestBlock
                            toAlbum:albumName
                         completion:completion
                            failure:failure];
}

- (void)addAssetFromVideoUrl:(NSURL *)videoUrl
                     toAlbum:(NSString *)albumName
                  completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                     failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    void (^requestBlock)(PHAssetCollection *assetCollection) = ^(PHAssetCollection *assetCollection){
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    };
    
    [self addAssetUsingRequestBlock:requestBlock
                            toAlbum:albumName
                         completion:completion
                            failure:failure];
}

- (void)addAssetFromImageUrl:(NSURL *)imageUrl
                     toAlbum:(NSString *)albumName
                  completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                     failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    void (^requestBlock)(PHAssetCollection *assetCollection) = ^(PHAssetCollection *assetCollection){
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:imageUrl];
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    };
    
    [self addAssetUsingRequestBlock:requestBlock
                            toAlbum:albumName
                         completion:completion
                            failure:failure];
}

- (void)addAssetUsingRequestBlock:(void (^)(PHAssetCollection *assetCollection))requestBlock
                          toAlbum:(NSString *)albumName
                       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    BOOL shouldInvokeSuccessBlockInMainThread = ([NSThread currentThread] == [NSThread mainThread]);
    
    void (^saveBlock)(PHAssetCollection *assetCollection) = ^void(PHAssetCollection *assetCollection) {
        // Set the |changeBlock| for saving video file
        void (^changeBlock)() = ^{
            requestBlock(assetCollection);
        };
        
        // Perfom selector |-performChangesAndWait:error:| in main thread.
        if (shouldInvokeSuccessBlockInMainThread) {
            NSError *error = nil;
            BOOL saveFileSucceed = [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:changeBlock error:&error];
            
            if (saveFileSucceed) {
                if (completion) completion(nil, nil);
            } else {
                if (failure) failure(error);
            }
        }
        // Perfom selector |-performChanges:completionHandler:| in non-main thread.
        else {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:changeBlock completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    if (completion) completion(nil, nil);
                } else {
                    if (failure) failure(error);
                }
            }];
        }
    };
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localizedTitle = %@", albumName];
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    if (fetchResult.count > 0) {
        saveBlock(fetchResult.firstObject);
    } else {
        __block PHObjectPlaceholder *albumPlaceholder;
        // Set the |changeBlock| for create album
        void (^changeBlock)() = ^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
            albumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;
            
        };
        // Set the |changeBlock| for checking existence of album and saving file to it
        void (^checkAndSaveBlock)() = ^{
            PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumPlaceholder.localIdentifier] options:nil];
            if (fetchResult.count > 0) {
                saveBlock(fetchResult.firstObject);
            } else {
                // if create album failed
                NSString * message = [NSString stringWithFormat:@"PHAssetCollection failed to fetch asset collection: %@.", albumName];
                if (failure) failure([NSError errorWithDomain:@"LIB_ALAssetsLibrary_CustomPhotoAlbum"
                                                         code:0
                                                     userInfo:@{NSLocalizedDescriptionKey : message}]);
            }
        };
        
        // Perfom selector |-performChangesAndWait:error:| in main thread.
        if (shouldInvokeSuccessBlockInMainThread) {
            NSError *error = nil;
            BOOL createAlbumSucceed = [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:changeBlock error:&error];
            
            if (createAlbumSucceed) {
                checkAndSaveBlock();
            } else {
                if (failure) failure(error);
            }
        }
        // Perfom selector |-performChanges:completionHandler:| in non-main thread.
        else {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:changeBlock completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    checkAndSaveBlock();
                } else {
                    if (failure) failure(error);
                }
            }];
        }
    }
}

#pragma mark - Public Method

- (void)saveImage:(UIImage *)image
          toAlbum:(NSString *)albumName
       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        [self addAssetFromImage:image
                        toAlbum:albumName
                     completion:completion
                        failure:failure];
    } else {
        [self writeImageToSavedPhotosAlbum:image.CGImage
                               orientation:(ALAssetOrientation)image.imageOrientation
                           completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                  completion:completion
                                                                     failure:failure]];
    }
}

- (void)saveVideo:(NSURL *)videoUrl
          toAlbum:(NSString *)albumName
       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        [self addAssetFromVideoUrl:videoUrl
                           toAlbum:albumName
                        completion:completion
                           failure:failure];
    } else {
        [self writeVideoAtPathToSavedPhotosAlbum:videoUrl
                                 completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                        completion:completion
                                                                           failure:failure]];
    }
}

- (void)saveImageData:(NSData *)imageData
              toAlbum:(NSString *)albumName
             metadata:(NSDictionary *)metadata
           completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
              failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        UIImage *image = [UIImage imageWithData:imageData];
        [self addAssetFromImage:image
                        toAlbum:albumName
                     completion:completion
                        failure:failure];
    } else {
        [self writeImageDataToSavedPhotosAlbum:imageData
                                      metadata:metadata
                               completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                      completion:completion
                                                                         failure:failure]];
    }
}

- (void)addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
         completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
            failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    __block BOOL albumWasFound = NO;
    
    // Signature for the block executed when a match is found during enumeration using
    //   |-enumerateGroupsWithTypes:usingBlock:failureBlock:|.
    //
    // |group|: The current asset group in the enumeration.
    // |stop| : A pointer to a boolean value; set the value to YES to stop enumeration.
    //
    ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock;
    enumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        // Compare the names of the albums
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            // Target album is found
            albumWasFound = YES;
            
            // Get a hold of the photo's asset instance
            // If the user denies access to the application, or if no application is allowed to
            //   access the data, the failure block is called.
            ALAssetsLibraryAssetForURLResultBlock assetForURLResultBlock =
            [self _assetForURLResultBlockWithGroup:group
                                          assetURL:assetURL
                                        completion:completion
                                           failure:failure];
            [self assetForURL:assetURL
                  resultBlock:assetForURLResultBlock
                 failureBlock:failure];
            
            // Album was found, bail out of the method
            *stop = YES;
        }
        
        if (group == nil && albumWasFound == NO) {
            // Photo albums are over, target album does not exist, thus create it
            
            // Since you use the assets library inside the block,
            //   ARC will complain on compile time that there’s a retain cycle.
            //   When you have this – you just make a weak copy of your object.
            ALAssetsLibrary * __weak weakSelf = self;
            
            void(^addPhotoToLibraryBlock)(ALAssetsGroup *group) = ^void(ALAssetsGroup *group) {
                // Get the photo's instance
                //   add the photo to the newly created album
                ALAssetsLibraryAssetForURLResultBlock assetForURLResultBlock =
                [weakSelf _assetForURLResultBlockWithGroup:group
                                                  assetURL:assetURL
                                                completion:completion
                                                   failure:failure];
                [weakSelf assetForURL:assetURL
                          resultBlock:assetForURLResultBlock
                         failureBlock:failure];
            };
            
            // If iOS version is lower than 5.0, throw a warning message
            if (! [self respondsToSelector:@selector(addAssetsGroupAlbumWithName:resultBlock:failureBlock:)]) {
                NSLog(@"%s: WARNING: |-addAssetsGroupAlbumWithName:resultBlock:failureBlock:| \
                      only available on iOS 5.0 or later. Asset cannot be saved to album.", __PRETTY_FUNCTION__);
            }
            // Create new assets album
            else {
                // Different code for iOS 7 and 8
                // See: http://stackoverflow.com/questions/26003211/assetslibrary-framework-broken-on-ios-8
                // See: http://stackoverflow.com/questions/8867496/get-last-image-from-photos-app/8872425#8872425
                // PHPhotoLibrary_class will only be non-nil on iOS 8.0 or later.
                Class PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");
                
                if (PHPhotoLibrary_class) {
                    // dynamic runtime code for code chunk listed above
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    id sharedPhotoLibrary = [PHPhotoLibrary_class performSelector:NSSelectorFromString(@"sharedPhotoLibrary")];
#pragma clang diagnostic pop
                    
                    BOOL shouldInvokeSuccessBlockInMainThread = ([NSThread currentThread] == [NSThread mainThread]);
                    
                    SEL performChanges;
                    if (shouldInvokeSuccessBlockInMainThread) {
                        // Synchronously runs a block that requests changes to be performed in the Photos library
                        performChanges = NSSelectorFromString(@"performChangesAndWait:error:");
                    } else {
                        // Asynchronously runs a block that requests changes to be performed in the Photos library
                        performChanges = NSSelectorFromString(@"performChanges:completionHandler:");
                    }
                    
                    NSMethodSignature * methodSignature = [sharedPhotoLibrary methodSignatureForSelector:performChanges];
                    
                    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                    [invocation setTarget:sharedPhotoLibrary];
                    [invocation setSelector:performChanges];
                    
                    // Set the |changeBlock| for |-performChangesAndWait:error:| or |-performChanges:completionHandler:|.
                    void (^changeBlock)() = ^{
                        Class PHAssetCollectionChangeRequest_class = NSClassFromString(@"PHAssetCollectionChangeRequest");
                        SEL creationRequestForAssetCollectionWithTitle = NSSelectorFromString(@"creationRequestForAssetCollectionWithTitle:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [PHAssetCollectionChangeRequest_class performSelector:creationRequestForAssetCollectionWithTitle withObject:albumName];
#pragma clang diagnostic pop
                    };
                    [invocation setArgument:&changeBlock atIndex:2];
                    
                    // Block to be invoked after created album succeed.
                    void (^blockToEnumerateGroups)() = ^{
                        [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                if (group) {
                                                    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                                                    if ([albumName isEqualToString:name]) {
                                                        addPhotoToLibraryBlock(group);
                                                    }
                                                }
                                            }
                                          failureBlock:failure];
                    };
                    
                    // Setup invocation to perfom selector |-performChangesAndWait:error:| in main thread.
                    if (shouldInvokeSuccessBlockInMainThread) {
                        // Set error point for |-performChangesAndWait:error:|.
                        NSError * error = nil;
                        [invocation setArgument:&error atIndex:3];
                        [invocation invoke];
                        
                        // Get return value of |-performChangesAndWait:error:|.
                        BOOL createAlbumSucceed;
                        [invocation getReturnValue:&createAlbumSucceed];
                        
                        if (createAlbumSucceed) {
                            blockToEnumerateGroups();
                        } else {
                            if (error) {
                                NSLog(@"%s: Error creating album (%@) :  %@",
                                      __PRETTY_FUNCTION__, albumName, [error localizedDescription]);
                            }
                        }
                    }
                    // Setup invocation to perfom selector |-performChanges:completionHandler:| in non-main thread.
                    else {
                        void (^completionHandler)(BOOL success, NSError *error) = ^(BOOL success, NSError *error) {
                            if (success) {
                                blockToEnumerateGroups();
                            } else {
                                if (error) {
                                    NSLog(@"%s: Error creating album (%@) : %@",
                                          __PRETTY_FUNCTION__, albumName, [error localizedDescription]);
                                }
                            }
                        };
                        // Set the |completionHandler| for |-performChanges:completionHandler:|.
                        [invocation setArgument:&completionHandler atIndex:3];
                        [invocation invoke];
                    }
                }
                else {
                    // code that always creates an album on iOS 7.x.x but fails
                    // in certain situations such as if album has been deleted
                    // previously on iOS 8.x.
                    [self addAssetsGroupAlbumWithName:albumName
                                          resultBlock:addPhotoToLibraryBlock
                                         failureBlock:failure];
                }
            }
            // Should be the last iteration anyway, but just in case
            *stop = YES;
        }
    };
    
    // Search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:enumerationBlock
                      failureBlock:failure];
}

- (void)loadAssetsForProperty:(NSString *)property
                    fromAlbum:(NSString *)albumName
                   completion:(void (^)(NSMutableArray *, NSError *))completion
{
    ALAssetsLibraryGroupsEnumerationResultsBlock block = ^(ALAssetsGroup *group, BOOL *stop) {
        // Checking if library exists
        if (group == nil) {
            *stop = YES;
            return;
        }
        
        // If we have found library with given title we enumerate it
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            NSMutableArray * array = [[NSMutableArray alloc] init];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                // Checking if group isn't empty
                if (! result) return;
                
                [array addObject:(property ? ([result valueForProperty:property] ?: [NSNull null]) : result)];
            }];
            
            // Execute the |completion| block
            if (completion) completion(array, nil);
            
            // Album was found, bail out of the method
            *stop = YES;
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
        if (completion) completion(nil, error);
    };
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAll
                        usingBlock:block
                      failureBlock:failureBlock];
}

- (void)loadImagesFromAlbum:(NSString *)albumName
                 completion:(void (^)(NSMutableArray *, NSError *))completion
{
    ALAssetsLibraryGroupsEnumerationResultsBlock block = ^(ALAssetsGroup *group, BOOL *stop) {
        // Checking if library exists
        if (group == nil) {
            *stop = YES;
            return;
        }
        
        // If we have found library with given title we enumerate it
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            NSMutableArray * images = [[NSMutableArray alloc] init];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                // Checking if group isn't empty
                if (! result) return;
                
                // Getting the image from the asset
                UIImageOrientation orientation =
                (UIImageOrientation)[[result valueForProperty:@"ALAssetPropertyOrientation"] intValue];
                UIImage * image = [UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]
                                                      scale:1.0
                                                orientation:orientation];
                // Saving this image to the array
                [images addObject:image];
            }];
            
            // Execute the |completion| block
            if (completion) completion(images, nil);
            
            // Album was found, bail out of the method
            *stop = YES;
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
        if (completion) completion(nil, error);
    };
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAll
                        usingBlock:block
                      failureBlock:failureBlock];
}

@end

