//
//  XMLPOSOrder.m
//  Savoir
//
//  Created by Nirav Saraiya on 3/19/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "XMLPOSOrder.h"
#import "OnlineOrderSelectedMenuItem.h"
#import "OnlineOrderSelectedModifierGroup.h"
#import "UtilCalls.h"
#import <Parse/Parse.h>
#import "DeliveryOrCarryoutViewController.h"
#import "AppDelegate.h"
#import "OrderItemSummaryFromPOS.h"
#import "InlineCalls.h"


@implementation XMLPOSOrder

+ (NSString *)buildPOSOrder:(OnlineOrderDetails *)orderInProgress gratuity:(double)gratuity
{    
    NSString *strItems = @"<ITEMREQUESTS>";
    for (OnlineOrderSelectedMenuItem *object in orderInProgress.selectedMenuItems)
    {
        NSString *itemString=[NSString stringWithFormat:@"<ADDITEM QTY=\"%lu\" ITEMID=\"%@\" >",(unsigned long)object.qty,object.selectedItem.menuItemPOSId];
        strItems=[strItems stringByAppendingString:itemString];
        for (OnlineOrderSelectedModifierGroup *modGroup in object.selectedModifierGroups)
        {
            for (int i = 0; i < modGroup.selectedModifierIndexes.count; i++)
            {
                NSNumber *value = [modGroup.selectedModifierIndexes objectAtIndex:i];
                if (value.boolValue)
                {
                    GTLStoreendpointStoreMenuItemModifier *modifier = [modGroup.modifiers objectAtIndex:i];
                    NSString *modString=[NSString stringWithFormat:@"<MODITEM QTY=\"1\" ITEMID=\"%@\" />",modifier.modifierPOSId];
                    strItems=[strItems stringByAppendingString:modString];
                }
            }
        }
        strItems=[strItems stringByAppendingString:@"</ADDITEM>"];
    }
    strItems=[strItems stringByAppendingString:@"</ITEMREQUESTS>"];
    
    NSString *discountStr;
    if (orderInProgress.selectedDiscount != nil)
    {
        NSString *discountAmtOrPercent = [UtilCalls amountToStringNoCurrency:[NSNumber numberWithLongLong:orderInProgress.selectedDiscount.value.longLongValue]];
        discountStr = [NSString stringWithFormat:@"<DISCOUNTS ID=\"%lld\" AMOUNT=\"%@\" REFERENCE=\"Discounts FROM ASAAN\" />", orderInProgress.selectedDiscount.posDiscountId.longLongValue, discountAmtOrPercent];
        strItems=[strItems stringByAppendingString:discountStr];
    }
    
    NSString *gratuityStr;
    if (gratuity > 0)
    {
        //        gratuityStr = [NSString stringWithFormat:@"<SERVICECHARGES ID=\"%d\" AMOUNT=\"%@\" REFERENCE=\"SVC CHRG FROM ASAAN\" />", 902, [UtilCalls percentAmountToStringNoCurrency:[NSNumber numberWithLong:[self gratuity]]]];
        gratuityStr = [NSString stringWithFormat:@"<SERVICECHARGES ID=\"%d\" AMOUNT=\"%@\" REFERENCE=\"SVC CHRG FROM ASAAN\" />", 901, [UtilCalls doubleAmountToStringNoCurrency:[NSNumber numberWithLong:gratuity]]];
        strItems=[strItems stringByAppendingString:gratuityStr];
    }
    
    //NSString *contactString=[NSString stringWithFormat:@"<CONTACT FIRSTNAME=\"%@\" LASTNAME=\"%@\" PHONE1=\"%@\" PHONE2=\"8012345678\" COMPANY=\"TEST CO\" DEPT=\"DEPT 123\" />"];
    
    PFUser *user = [PFUser currentUser];
    NSString *contactString=[NSString stringWithFormat:@"<CONTACT FIRSTNAME=\"%@\" LASTNAME=\"%@\" PHONE1=\"%@\" />", user[@"firstName"], user[@"lastName"], user[@"phone"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *orderTime = [dateFormatter stringFromDate: orderInProgress.orderTime];
    
    NSString *orderString;
    if (orderInProgress.orderType == [DeliveryOrCarryoutViewController ORDERTYPE_DELIVERY])
    {
        
        //    NSString *deliveryString=[NSString stringWithFormat:@"<DELIVERY DELIVERYACCT=\"%@\" DELIVERYNOTE=\"%@\" ADDRESS1=\"123 Main street\" ADDRESS2=\"APT 123\" ADDRESS3=\"Back Door\" CITY=\"DENVER\" STATE=\"CO\" POSTALCODE=\"12345\" CROSSSTREET=\"MAIN AND 1st\" />"];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLUserendpointUserAddress *address = appDelegate.globalObjectHolder.defaultUserAddress;
        NSString *deliveryString=[NSString stringWithFormat:@"<DELIVERY DELIVERYACCT=\"%@\" DELIVERYNOTE=\"%@\" ADDRESS=\"%@\" />", address.title, address.notes, address.fullAddress];
        
        orderString=[NSString stringWithFormat:@"<CHECKREQUESTS><ADDCHECK EXTCHECKID=\"ASAAN\" READYTIME=\"%@\" GUESTCOUNT=\"%d\" NOTE=\"%@\" ORDERMODE=\"@ORDER_MODE\">%@%@%@</ADDCHECK></CHECKREQUESTS>",orderTime, orderInProgress.partySize, orderInProgress.specialInstructions, contactString, deliveryString, strItems];
    }
    else
        orderString=[NSString stringWithFormat:@"<CHECKREQUESTS><ADDCHECK EXTCHECKID=\"ASAAN\" READYTIME=\"%@\" GUESTCOUNT=\"%d\" NOTE=\"%@\" ORDERMODE=\"@ORDER_MODE\">%@%@</ADDCHECK></CHECKREQUESTS>",orderTime, orderInProgress.partySize, orderInProgress.specialInstructions, contactString, strItems];
    
    NSLog(@"%@",orderString);
    
    orderString = [orderString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    return orderString;
}

/*
 <POSRESPONSE>
 <GETCHECKDETAILS INTCHECKID="1161">
 <CHECK ID="59" TABLENUMBER="1" SUBTOTAL="39.90" TAX="0.00" SERVICECHARGES="0.00" COMPLETETOTAL="39.90" GUESTCOUNT="0" EMPLOYEE="101" EMPLOYEECHECKNAME="Sally S">
 <ENTRIES>
 <ENTRY ID="002130001" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="19.95" DISP_NAME="N.Y. Strip" ITEMID="7001" />
 <ENTRY ID="002130002" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="0.00" DISP_NAME="Medium Well" ITEMID="91303" PARENTENTRY="002130001" />
 <ENTRY ID="002130003" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="0.00" DISP_NAME="Spinach Salad" ITEMID="90210" PARENTENTRY="002130001" />
 <ENTRY ID="002130004" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="0.00" DISP_NAME="Coleslaw" ITEMID="90305" PARENTENTRY="002130001" />
 <ENTRY ID="002130005" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="0.00" DISP_NAME="Potato Salad" ITEMID="91602" PARENTENTRY="002130001" />
 <ENTRY ID="002130006" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="19.95" DISP_NAME="N.Y. Strip" ITEMID="7001" />
 <ENTRY ID="002130007" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="0.00" DISP_NAME="Medium Well" ITEMID="91303" PARENTENTRY="002130006" />
 <ENTRY ID="002130008" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="0.00" DISP_NAME="Spinach Salad" ITEMID="90210" PARENTENTRY="002130006" />
 <ENTRY ID="002130009" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="0.00" DISP_NAME="Coleslaw" ITEMID="90305" PARENTENTRY="002130006" />
 <ENTRY ID="002130010" ENTRYTYPE="0" ORDERMODE="0" QUANTITY="1" PRICE="0.00" DISP_NAME="Potato Salad" ITEMID="91602" PARENTENTRY="002130006" />
 </ENTRIES>
 <DISCOUNTS DISP_NAME="Manager's Discount" AMOUNT="5.25"/>
 <PAYMENTS />
 </CHECK>
 </GETCHECKDETAILS>
 </POSRESPONSE>
 */

NSString *beginXMLResponseStr = @"<POSRESPONSE> <GETCHECKDETAILS> <CHECK ENTRYCOUNT=\"%ld\" GUESTCOUNT=\"%ld\" TABLENUMBER=\"%ld\" SUBTOTAL=\"%@\" TAX=\"%@\" SERVICECHARGES=\"%@\" COMPLETETOTAL=\"%@\" DELIVERY=\"%@\"> <ENTRIES>";

NSString *tableRowXML = @"<ENTRY ID=\"%d\" QUANTITY=\"%@\" PRICE=\"%@\" DISP_NAME=\"%@\" OPTION=\"%@\" ITEMID=\"%ld\" />";

NSString *discountStrFormat = @"<DISCOUNTS DESC=\"%@\" AMOUNT=\"%@\"/>";
NSString *discountStrEmptyFormat = @"<DISCOUNTS />";

+ (NSString *)buildPOSResponseXML:(OnlineOrderDetails *)orderInProgress gratuity:(double)gratuity discountTitle:(NSString *)discountTitle discountAmount:(double)discountAmount subTotal:(double)subTotal deliveryFee:(double)deliveryFee taxAmount:(double)taxAmount finalAmount:(double)finalAmount guestCount:(NSUInteger)guestCount tableNumber:(NSUInteger)tableNumber
{
    NSString *discountStr = nil;
    if (discountAmount > 0)
    {
        NSNumber *amount = [[NSNumber alloc] initWithDouble:discountAmount];
        NSString *amountStr = [UtilCalls doubleAmountToStringNoCurrency:amount];
        discountStr = [NSString stringWithFormat:discountStrFormat, discountTitle, amountStr];
    }
    else
        discountStr = discountStrEmptyFormat;
    
    NSString *paymentStr = [NSString stringWithFormat:@"<PAYMENTS BRAND=\"--CARDTYPE--\" LASTFOUR=\"--CARDLASTFOUR--\" />"];
    
    NSNumber *amount = [[NSNumber alloc] initWithDouble:subTotal];
    NSString *subTotalStr = [UtilCalls doubleAmountToStringNoCurrency:amount];
    amount = [[NSNumber alloc] initWithDouble:gratuity];
    NSString *gratuityStr = [UtilCalls doubleAmountToStringNoCurrency:amount];
    amount = [[NSNumber alloc] initWithDouble:taxAmount];
    NSString *taxStr = [UtilCalls doubleAmountToStringNoCurrency:amount];
    amount = [[NSNumber alloc] initWithDouble:deliveryFee];
    NSString *deliveryFeeStr = [UtilCalls doubleAmountToStringNoCurrency:amount];
    amount = [[NSNumber alloc] initWithDouble:finalAmount];
    NSString *orderTotalStr = [UtilCalls doubleAmountToStringNoCurrency:amount];
    NSString *allTableRows = nil;
    NSUInteger entryId = 1;
    for (OnlineOrderSelectedMenuItem *object in orderInProgress.selectedMenuItems)
    {
        NSString *menuItemName = object.selectedItem.shortDescription;
        NSString *option = nil;
        for (OnlineOrderSelectedModifierGroup *modGroup in object.selectedModifierGroups)
        {
            for (int i = 0; i < modGroup.selectedModifierIndexes.count; i++)
            {
                NSNumber *value = [modGroup.selectedModifierIndexes objectAtIndex:i];
                if (value.boolValue)
                {
                    GTLStoreendpointStoreMenuItemModifier *modifier = [modGroup.modifiers objectAtIndex:i];
                    if (option == nil)
                        option = modifier.shortDescription;
                    else
                        option = [NSString stringWithFormat:@"%@, %@", option, modifier.shortDescription];
                }
            }
        }
        NSString *quantity = [NSString stringWithFormat:@"%lu", (unsigned long)object.qty];
        NSNumber *amount = [[NSNumber alloc] initWithLong:object.amount];
        NSString *amountStr = [UtilCalls amountToStringNoCurrency:amount];
        
        NSString *menuItemRow = [NSString stringWithFormat:tableRowXML, entryId, quantity, amountStr, menuItemName, option, object.selectedItem.identifier.longLongValue];
        allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
        entryId++;
    }
    NSString *orderHTMLStr = [NSString stringWithFormat:beginXMLResponseStr, (long)entryId, (long)guestCount, (long)tableNumber, subTotalStr, taxStr, gratuityStr, orderTotalStr, deliveryFeeStr];
    
    NSString *finalStr = [NSString stringWithFormat:@"%@ %@ </ENTRIES> %@ %@</CHECK></GETCHECKDETAILS></POSRESPONSE>", orderHTMLStr, allTableRows, discountStr, paymentStr];
    finalStr = [finalStr stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
   
    return finalStr;
}

+ (NSString *)buildPOSResponseXMLByAddingNewItems:(OnlineOrderDetails *)orderInProgress ToOrderString:(NSString *)XMLOrderStr
{
    NSString *allTableRows = nil;
    NSUInteger entryId = [XMLPOSOrder findEntryCountInOrderString:XMLOrderStr];
    NSUInteger oldEntryCount = entryId;
    for (OnlineOrderSelectedMenuItem *object in orderInProgress.selectedMenuItems)
    {
        NSString *menuItemName = object.selectedItem.shortDescription;
        NSString *option = nil;
        for (OnlineOrderSelectedModifierGroup *modGroup in object.selectedModifierGroups)
        {
            for (int i = 0; i < modGroup.selectedModifierIndexes.count; i++)
            {
                NSNumber *value = [modGroup.selectedModifierIndexes objectAtIndex:i];
                if (value.boolValue)
                {
                    GTLStoreendpointStoreMenuItemModifier *modifier = [modGroup.modifiers objectAtIndex:i];
                    if (option == nil)
                        option = modifier.shortDescription;
                    else
                        option = [NSString stringWithFormat:@"%@ %@", option, modifier.shortDescription];
                }
            }
        }
        if (option == nil)
        {
            if (object.specialInstructions != nil)
                option = [NSString stringWithFormat:@"NOTE: %@ \n", object.specialInstructions];
        }
        else
        {
            if (object.specialInstructions != nil)
                option = [NSString stringWithFormat:@"OPTIONS: %@ NOTE: %@ \n", option, object.specialInstructions];
        }
        
        NSString *quantity = [NSString stringWithFormat:@"%lu", (unsigned long)object.qty];
        NSNumber *amount = [[NSNumber alloc] initWithLong:object.amount];
        NSString *amountStr = [UtilCalls amountToStringNoCurrency:amount];
        
        NSString *menuItemRow = [NSString stringWithFormat:tableRowXML, entryId, quantity, amountStr, menuItemName, option, object.selectedItem.identifier.longLongValue];
        
        if (allTableRows == nil)
            allTableRows = menuItemRow;
        else
            allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
        entryId++;
    }
    
    NSString *newItemsStr = [NSString stringWithFormat:@"%@ </ENTRIES>", allTableRows];
    
    NSString *finalStr = [XMLOrderStr stringByReplacingOccurrencesOfString:@"</ENTRIES>" withString:newItemsStr];
    
    finalStr = [XMLPOSOrder replaceEntryCountFrom:oldEntryCount To:entryId In:finalStr];
    
    finalStr = [finalStr stringByReplacingOccurrencesOfString:@"(null)" withString:@""];

    NSLog(@"AddingNewItems finalStr = %@", finalStr);
    return finalStr;
}
//                NSString *beginXMLResponseStr = @"<POSRESPONSE> <GETCHECKDETAILS> <CHECK ENTRYCOUNT=\"%ld\" GUESTCOUNT=\"%ld\" TABLENUMBER=\"%ld\" SUBTOTAL=\"%@\" TAX=\"%@\" SERVICECHARGES=\"%@\" COMPLETETOTAL=\"%@\" DELIVERY=\"%@\"> <ENTRIES>";

// gratuity:(double)gratuity discountTitle:(NSString *)discountTitle discountAmount:(double)discountAmount subTotal:(double)subTotal deliveryFee:(double)deliveryFee taxAmount:(double)taxAmount finalAmount:(double)finalAmount guestCount:(NSUInteger)guestCount tableNumber:(NSUInteger)tableNumber

+ (NSString *)buildPOSResponseXMLByRemovingItem:(int)entryId FromOrderString:(NSString *)XMLOrderStr
{
    if (IsEmpty(XMLOrderStr) == true || entryId == 0)
        return XMLOrderStr;
    
    NSString *searchStr = [NSString stringWithFormat:@"<ENTRY ID=\"%d\"", entryId];
    NSRange startRange = [XMLOrderStr rangeOfString:searchStr];
    if (startRange.location == NSNotFound)
        return XMLOrderStr;
    
    NSString *startStr = [XMLOrderStr substringToIndex:startRange.location-1];
    NSString *tempStr = [XMLOrderStr substringFromIndex:startRange.location];
    searchStr = @"/>";
    NSRange endRange = [tempStr rangeOfString:searchStr];
    NSString *endStr = [tempStr substringFromIndex:NSMaxRange(endRange)];
    
    NSString *finalStr = [NSString stringWithFormat:@"%@%@", startStr, endStr];
    
    finalStr = [finalStr stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    NSLog(@"RemovingItem finalStr = %@", finalStr);
    return finalStr;
}

+ (NSString *) replaceValuesInOrderString:(NSString *)XMLOrderStr gratuity:(double)gratuity discountTitle:(NSString *)discountTitle discountAmount:(double)discountAmount subTotal:(double)subTotal deliveryFee:(double)deliveryFee taxAmount:(double)taxAmount finalAmount:(double)finalAmount guestCount:(NSUInteger)guestCount tableNumber:(NSUInteger)tableNumber
{
    XMLOrderStr = [XMLPOSOrder changeOldAmountTo:gratuity InOrderString:XMLOrderStr forAmountType:@"SERVICECHARGES"];
    XMLOrderStr = [XMLPOSOrder changeOldAmountTo:subTotal InOrderString:XMLOrderStr forAmountType:@"SUBTOTAL"];
    XMLOrderStr = [XMLPOSOrder changeOldAmountTo:taxAmount InOrderString:XMLOrderStr forAmountType:@"TAX"];
    XMLOrderStr = [XMLPOSOrder changeOldAmountTo:finalAmount InOrderString:XMLOrderStr forAmountType:@"COMPLETETOTAL"];
    XMLOrderStr = [XMLPOSOrder changeOldAmountTo:guestCount InOrderString:XMLOrderStr forAmountType:@"GUESTCOUNT"];
    XMLOrderStr = [XMLPOSOrder changeOldAmountTo:tableNumber InOrderString:XMLOrderStr forAmountType:@"TABLENUMBER"];
    XMLOrderStr = [XMLPOSOrder replaceDiscountStrWithDescription:discountTitle Amount:discountAmount InOrderString:XMLOrderStr];
    
    XMLOrderStr = [XMLOrderStr stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    NSLog(@"RemovingItem XMLOrderStr = %@", XMLOrderStr);
    return XMLOrderStr;
}

+ (NSUInteger)findEntryCountInOrderString:(NSString *)XMLOrderStr
{
    if (IsEmpty(XMLOrderStr) == true)
        return 0;
    
    NSString *searchStr = @"ENTRYCOUNT=\"";
    NSRange startRange = [XMLOrderStr rangeOfString:searchStr];
    if (startRange.location == NSNotFound)
        return 0;
    
    NSString *tempStr = [XMLOrderStr substringFromIndex:NSMaxRange(startRange)];
    searchStr = @"\"";
    NSRange endRange = [tempStr rangeOfString:searchStr];
    NSString *countStr = [tempStr substringToIndex:NSMaxRange(endRange)-1];
    
    NSLog(@"findEntryCountInOrderString countStr = %@", countStr);
    
    return [countStr intValue];
}

+ (NSString *)replaceEntryCountFrom:(NSUInteger)oldCount To:(NSUInteger)newCount In:(NSString *)XMLOrderStr
{
    NSString *searchStr = [NSString stringWithFormat:@"ENTRYCOUNT=\"%ld\"",(long)oldCount];
    NSString *replaceStr = [NSString stringWithFormat:@"ENTRYCOUNT=\"%ld\"",(long)newCount];
    return [XMLOrderStr stringByReplacingOccurrencesOfString:searchStr withString:replaceStr];
}

+ (NSString *)changeOldAmountTo:(double)newAmount InOrderString:(NSString *)XMLOrderStr forAmountType:(NSString *)amountType
{
    if (IsEmpty(XMLOrderStr) == true)
        return XMLOrderStr;
    
    NSString *searchStr = [NSString stringWithFormat:@"%@=\"", amountType];
    NSRange startRange = [XMLOrderStr rangeOfString:searchStr];
    if (startRange.location == NSNotFound)
        return XMLOrderStr;
    
    NSString *tempStr = [XMLOrderStr substringFromIndex:NSMaxRange(startRange)];
    searchStr = @"\"";
    NSRange endRange = [tempStr rangeOfString:searchStr];
    NSString *countStr = [tempStr substringToIndex:NSMaxRange(endRange)-1];

    NSNumber *amount = [[NSNumber alloc] initWithDouble:newAmount];
    NSString *newAmountStr = [UtilCalls doubleAmountToStringNoCurrency:amount];
    
    NSLog(@"findEntryOldAmountInOrderString countStr = %@, amountType = %@", countStr, amountType);
    searchStr = [NSString stringWithFormat:@"%@=\"%@\"", amountType, countStr];
    NSString *replaceStr = [NSString stringWithFormat:@"%@=\"%@\"",amountType, newAmountStr];
    return [XMLOrderStr stringByReplacingOccurrencesOfString:searchStr withString:replaceStr];
}

//NSString *discountStrFormat = @"<DISCOUNTS DESC=\"%@\" AMOUNT=\"%@\"/>";
//NSString *discountStrEmptyFormat = @"<DISCOUNTS />";

+ (NSString *)replaceDiscountStrWithDescription:(NSString *)desc Amount:(double)newAmount InOrderString:(NSString *)XMLOrderStr
{
    NSString *newDiscountStr = nil;
    if (newAmount > 0)
    {
        NSNumber *amount = [[NSNumber alloc] initWithDouble:newAmount];
        NSString *amountStr = [UtilCalls doubleAmountToStringNoCurrency:amount];
        newDiscountStr = [NSString stringWithFormat:discountStrFormat, desc, amountStr];
    }
    else
        newDiscountStr = discountStrEmptyFormat;
    
    NSRange startRange = [XMLOrderStr rangeOfString:discountStrEmptyFormat];
    if (startRange.location != NSNotFound)
        return [XMLOrderStr stringByReplacingOccurrencesOfString:discountStrEmptyFormat withString:newDiscountStr];
    
    NSString *searchStr = @"<DISCOUNTS DESC=\"";
    startRange = [XMLOrderStr rangeOfString:searchStr];
    searchStr = @"/>";
    NSString *tempStr = [XMLOrderStr substringFromIndex:NSMaxRange(startRange)];
    NSRange endRange = [tempStr rangeOfString:searchStr];
    NSString *detailStr = [tempStr substringToIndex:NSMaxRange(endRange)];
    
    searchStr = [NSString stringWithFormat:@"<DISCOUNTS DESC=\"%@", detailStr];
    return [XMLOrderStr stringByReplacingOccurrencesOfString:searchStr withString:newDiscountStr];
}

@end
