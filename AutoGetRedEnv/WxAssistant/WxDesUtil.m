//
//  WxDesUtil.m
//
//  Created by User on 11/1/2016.
//  Copyright © 2016年 musk. All rights reserved.
//

#import "WxDesUtil.h"
#import <CommonCrypto/CommonCryptor.h>
#import "Base64.h"

@implementation WxDesUtil

#pragma mark - public function

#pragma mark encrypt
+ (NSString *)encrypt:(NSString *)text withKey:(NSString *)key {
	return [self encrypt:text encryptOrDecrypt:kCCEncrypt key:key];
}

#pragma mark decrypt
+ (NSString *)decrypt:(NSString *)text withKey:(NSString *)key {
	return [self encrypt:text encryptOrDecrypt:kCCDecrypt key:key];
}

#pragma mark - private function
/*
 Include encrypt and decrypt function
 Encrypt: DES Encrypt -> BASE64 Encrypt -> result
 Decrypt: BASE64 Decrypt -> DES Decrypt -> result
 */
+ (NSString *)encrypt:(NSString *)text encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key {
	const void *dataIn;
	size_t dataInLength;
	
	if (encryptOperation == kCCDecrypt) {
		//decrypt data base on BASE64
		NSData *decryptData = [text base64DecodedData];
		dataInLength = [decryptData length];
		dataIn = [decryptData bytes];
	}else{
		NSData* encryptData = [text dataUsingEncoding:NSUTF8StringEncoding];
		dataInLength = [encryptData length];
		dataIn = (const void *)[encryptData bytes];
	}
	
	//decrypt or encrypt result stauts
	CCCryptorStatus ccStatus;
	uint8_t *dataOut = NULL;
	size_t dataOutAvailable = 0;
	size_t dataOutMoved = 0;
	
	dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
	dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
	memset((void *)dataOut, 0x0, dataOutAvailable);
	
	NSString *initIv = @"12345678";
	const void *vkey = (const void *) [key UTF8String];
	const void *iv = (const void *) [initIv UTF8String];
	
	//core function
	ccStatus = CCCrypt(encryptOperation,
					   kCCAlgorithmDES,
					   kCCOptionPKCS7Padding|kCCOptionECBMode,
					   vkey,
					   kCCKeySizeDES,
					   iv,
					   dataIn,
					   dataInLength,
					   (void *)dataOut,
					   dataOutAvailable,
					   &dataOutMoved);
	
	NSString *result = nil;
	
	if (ccStatus == kCCSuccess) {
		if (encryptOperation == kCCDecrypt) {
			result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved] encoding:NSUTF8StringEncoding];
		} else {
			//BASE64 Encrypt
			NSData *data = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
			result = [data base64EncodedString];
		}
	} else {
		NSLog(@"DES error %i; operation %i", ccStatus, encryptOperation);
	}
	
	return result;
}

@end
