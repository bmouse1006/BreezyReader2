


#import <Foundation/Foundation.h>

enum GenderType
{
	G_None,
	G_M,
	G_F
};
typedef enum GenderType Gender;

enum EthnicityType
{
	Eth_None,
	Eth_Mixed,
	Eth_Asian,
	Eth_Black,
	Eth_Hispanic,
	Eth_NativeAmerican,
	Eth_White,
	Eth_Other
};
typedef enum EthnicityType Ethnicity;

enum EducationType
{
	Edu_None, 
	Edu_HighSchool,
	Edu_SomeCollege,
	Edu_InCollege,
	Edu_BachelorsDegree,
	Edu_MastersDegree,
	Edu_DoctoralDegree,
	Edu_Other
};
typedef enum EducationType Education;

/*
 * IMAdRequest.h
 * @description Specifies optional parameters for ad requests.
 * @author: InMobi
 * Copyright 2011 InMobi Technologies Pvt. Ltd.. All rights reserved.
 */

@interface IMAdRequest : NSObject

/**
 * Returns an autoreleased IMAdRequest instance.
 */
+ (id)request;

#pragma optional properties to be specified for targeted advertising during an ad request.
/**
 * Postal code of the user may be used to deliver more relevant ads.
 */
@property( nonatomic,copy) NSString *postalCode; 
/**
 * Area code of the user may be used to deliver more relevant ads.
 */
@property( nonatomic,copy) NSString *areaCode;
/**
 * Date of birth of the user may be used to deliver more relevant ads.
 * @note The date should be of the format dd-mm-yyyy
 */
@property( nonatomic,copy) NSString *dateOfBirth; 
/**
 * Gender of the user may be used to deliver more relevant ads.
 * @note Look for IMAdRequest.h class to set the relevant values 
 */
@property( nonatomic,assign) Gender gender; 
/**
 * Use contextually relevant strings to deliver more relevant ads.
 * e.g. @"offers sale shopping"
 */
@property( nonatomic,copy) NSString *keywords;
/**
 * search string provided by the user, e.g. @"Hotel Bangalore India"
 */
@property( nonatomic,copy) NSString *searchString;
/**
 * optional, if the user has specified his/her income
 * @note income should be in USD.
 */
@property( nonatomic,assign) NSUInteger income; 
/**
 * Educational qualification of the user may be used to deliver more relevant ads.
 */
@property( nonatomic,assign) Education education;		
/**
 * Ethnicity of the user may be used to deliver more relevant ads.
* @note Look for IMAdRequest.h class to set the relevant values  
 */
@property( nonatomic,assign) Ethnicity ethnicity;
/**
 * Age of the user may be used to deliver more relevant ads.
* @note Look for IMAdRequest.h class to set the relevant values  
 */
@property( nonatomic,assign) NSUInteger age;
/**
 * Use contextually relevant strings to deliver more relevant ads.
 * Eg @"cars bikes racing"
 */
@property( nonatomic,copy) NSString *interests;
/**
 * Provide additional values to be passed in the ad request as key-value pair.
 */
@property (nonatomic, assign) NSDictionary *paramsDictionary;
/**
 * Allow InMobi to access location of the user for geo-targeted advertising.
 * @note This value is set to YES by default.
 */
@property (nonatomic, assign) BOOL isLocationEnquiryAllowed;
/**
 * Set testMode to YES for receiving test-ads.
 * @note default value is NO.
 */
@property ( nonatomic , assign) BOOL testMode;
/**
 * Default value is YES.
 * You may set this to NO if you want Inmobi to send UDID value of publisher as plain text.
 */
@property (nonatomic , assign) BOOL UDIDHashingAllowed;
 
@end
