//
//  WxDesUtil.h
//
//  Created by User on 11/1/2016.
//  Copyright © 2016年 musk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WxDesUtil : NSObject

/**
 *	DES encryption
 *
 *	@param text The text used to be encrypted.
 *	@param key  DES Secret key
 *
 *	@return An `NSString` object
 */
+ (NSString *)encrypt:(NSString *)text withKey:(NSString *)key;

/**
 *	DES decryption
 *
 *	@param text The text is the encrypted string.
 *	@param key  DES Secret key
 *
 *	@return An `NSString` object
 */
+ (NSString *)decrypt:(NSString *)text withKey:(NSString *)key;

@end
