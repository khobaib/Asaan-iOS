//
//  HTMLFaxOrder.m
//  Savoir
//
//  Created by Nirav Saraiya on 3/19/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

// http://webdesign.tutsplus.com/articles/build-an-html-email-template-from-scratch--webdesign-12770

/*
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>New Savoir Order</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
</head>
<body style="margin:5%; padding: 0;">
<table align="center" border="0" cellpadding="10px" cellspacing="0" width="100%">
<tr>
<td align="right" style="padding: 10px 10px 10px 10px;"><img
src="http://static1.squarespace.com/static/54ce8734e4b08a9c05c30098/t/54e545d5e4b052bf9dad58df/1425522195820/?format=1500w" />
</td>
</tr>
<tr>
<td align="center" style="font-family: Arial, sans-serif; font-size: 24px; padding: 10px 10px 10px 10px;">
<b>New Savoir Order</b>
</td>
</tr>
<tr>
<td style="font-family: Arial, sans-serif; font-size: 14px;">
<table border="0" cellpadding="10px" cellspacing="0" width="100%">
<tr>
<td width="50%" valign="top">Name: <b>Nathan Loring</b></td>
<td width="50%" valign="top">To: <b>Kama Indian Bistro</b></td>
</tr>
<tr>
<td width="50%" valign="top">Phone: <b>(703) 615-9572</b></td>
<td width="50%" valign="top">Order #: <b>13309</b></td>
</tr>
<tr>
<td width="50%" valign="top">Email: <b>nathan.loring@gmail.com</b></td>
<td width="50%" valign="top">Order Type: <b>Delivery</b></td>
</tr>
<tr>
<td width="50%" valign="top">Address: <b>7001 34th St, 60402</b></td>
<td width="50%" valign="top">Placed: <b>3/17/2015 07:09 pm</b></td>
</tr>
<tr>
<td width="50%" valign="top"></td>
<td width="50%" valign="top">Prepaid: <b>Visa 2256</b></td>
</tr>
<tr>
<td width="50%" valign="top"></td>
<td width="50%" style="font-family: Arial, sans-serif; font-size: 24px;" valign="top">Delivery Time: <b><i><u>8:19PM</u></i></b></td>
</tr>
</table>
</td>
</tr>
<tr>
<td style="font-family: Arial, sans-serif; font-size: 14px;">
<table border="1" cellpadding="10px" cellspacing="0" width="100%">
<tr>
<th width="35%" valign="top">Product</th>
<th width="20%" valign="top">Options</th>
<th width="20%" valign="top">Notes</th>
<th width="10%" valign="top">Quantity</th>
<th width="15%" valign="top">Total</th>
</tr>
<tr>
<td width="35%" valign="top"><b>Appetizer:</b><br>Baby Back Ribs Namaste</td>
<td width="20%" valign="top"></td>
<td width="20%" valign="top"></td>
<td width="10%" valign="top" align="right">1</td>
<td width="15%" valign="top" align="right" >$10.00</td>
</tr>
<tr>
<td width="35%" valign="top"><b>Entree:</b><br>Lamb Roganjosh</td>
<td width="20%" valign="top"></td>
<td width="20%" valign="top">mild spiciness please</td>
<td width="10%" valign="top" align="right" >1</td>
<td width="15%" valign="top" align="right" >$17.50</td>
</tr>
</table>
</td>
</tr>
</table>
</body>
</html>
*/

#import "HTMLFaxOrder.h"
#import "OnlineOrderSelectedMenuItem.h"
#import "OnlineOrderSelectedModifierGroup.h"
#import "UtilCalls.h"
#import <Parse/Parse.h>
#import "DeliveryOrCarryoutViewController.h"
#import "AppDelegate.h"

@implementation HTMLFaxOrder : NSObject 

// --NAME--
// --STORE_NAME--
// --PHONE--
// --ORDER_ID--
// --EMAIL--
// --ORDER_TYPE--
// --ADDRESS--
// --ORDER_TIME--
// --CARD_TYPE_LASTFOUR--
// --EXPECTED_TIME--
NSString *beginStr = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"> <html xmlns=\"http://www.w3.org/1999/xhtml\"> <head> <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /> <title>New Savoir Order</title> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" /> </head> <body style=\"margin: 0; padding: 0; \"> <table align=\"center\" border=\"0\" cellpadding=\"10px\" cellspacing=\"0\" width=\"900px\"> <tr> <td align=\"right\" style=\"padding: 10px 10px 10px 10px;\"><img src=\"http://static1.squarespace.com/static/54ce8734e4b08a9c05c30098/t/54e545d5e4b052bf9dad58df/1425522195820/?format=1500w\" /> </td> </tr> <tr> <td align=\"center\" style=\"font-family: Arial, sans-serif; font-size: 24px; padding: 10px 10px 10px 10px;\"> <b>New Savoir Order</b> </td> </tr> <tr> <td style=\"font-family: Arial, sans-serif; font-size: 14px;\"> <table border=\"0\" cellpadding=\"10px\" cellspacing=\"0\" width=\"100%%\"> <tr> <td width=\"60%%\" valign=\"top\">Name: <b>%@</b></td> <td width=\"40%%\" valign=\"top\">To: <b>%@</b></td> </tr> <tr> <td width=\"60%%\" valign=\"top\">Phone: <b>%@</b></td> <td width=\"40%%\" valign=\"top\">Order #: <b>%@</b></td> </tr> <tr> <td width=\"60%%\" valign=\"top\">Email: <b>%@</b></td> <td width=\"40%%\" valign=\"top\">Order Type: <b>%@</b></td> </tr> <tr> <td width=\"60%%\" valign=\"top\">Address: <b>%@</b></td> <td width=\"40%%\" valign=\"top\">Placed: <b>%@</b></td> </tr> <tr> <td width=\"60%%\" valign=\"top\"></td> <td width=\"40%%\" valign=\"top\">Prepaid: <b>%@</b></td> </tr> <tr> <td width=\"60%%\" valign=\"top\"></td> <td width=\"40%%\" style=\"font-family: Arial, sans-serif; font-size: 24px;\" valign=\"top\">Expected Time: <b><i><u>%@</u></i></b></td> </tr> </table> </td> </tr> <tr> <td style=\"font-family: Arial, sans-serif; font-size: 14px;\"> <table border=\"1\" cellpadding=\"10px\" cellspacing=\"0\" width=\"100%%\"> <tr> <th width=\"35%%\" valign=\"top\">Product</th> <th width=\"20%%\" valign=\"top\">Options</th> <th width=\"20%%\" valign=\"top\">Notes</th> <th width=\"10%%\" valign=\"top\">Quantity</th> <th width=\"15%%\" valign=\"top\">Total</th> </tr>";

// --SUBMENU--
// --MENUITEM--
// --OPTION--
// --NOTES--
// --QUANTITY--
// --AMOUNT--
NSString *tableRow = @"<tr> <td width=\"35%%\" valign=\"top\"><b>%@</b><br>%@</td> <td width=\"20%%\" valign=\"top\">%@</td> <td width=\"20%%\" valign=\"top\">%@</td> <td width=\"10%%\" valign=\"top\" align=\"right\">%@</td> <td width=\"15%%\" valign=\"top\" align=\"right\">%@</td> </tr>";

NSString *endStr = @"</table> </td> </tr> </table> </body> </html>";

+ (NSString *)buildHTMLOrder:(OnlineOrderDetails *)orderInProgress gratuity:(double)gratuity discountTitle:(NSString *)discountTitle discountAmount:(double)discountAmount subTotal:(double)subTotal deliveryFee:(double)deliveryFee taxAmount:(double)taxAmount finalAmount:(double)finalAmount orderEstTime:(NSString *)orderEstTime
{
    PFUser *user = [PFUser currentUser];
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLUserendpointUserAddress *address = appDelegate.globalObjectHolder.defaultUserAddress;
    NSString *addressStr =[NSString stringWithFormat:@"%@ %@ %@", address.title, address.fullAddress, address.notes];
    
    NSString *orderType = @"Carryout";
    if (orderInProgress.orderType == [DeliveryOrCarryoutViewController ORDERTYPE_DELIVERY])
        orderType = @"Delivery";

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy 'at' hh:mm a"];
    NSString *currDateStr = [dateFormatter stringFromDate: [NSDate date]];

    NSString *orderHTMLStr = [NSString stringWithFormat:beginStr, name, orderInProgress.selectedStore.name, user[@"phone"], @"--ORDER_ID--", user[@"email"], orderType, addressStr, currDateStr, @"Yes", orderEstTime]; //strOrder
    
    NSString *allTableRows = nil;
    
    for (OnlineOrderSelectedMenuItem *object in orderInProgress.selectedMenuItems)
    {
        NSString *subMenu = object.selectedItem.subMenuName;
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
                    option = [NSString stringWithFormat:@"%@, %@", option, modifier.shortDescription];
                }
            }
        }
        NSString *notes = object.specialInstructions;
        NSString *quantity = [NSString stringWithFormat:@"%lu", (unsigned long)object.qty];
        NSNumber *amount = [[NSNumber alloc] initWithLong:object.amount];
        NSString *amountStr = [UtilCalls amountToString:amount];
        
        NSString *menuItemRow = [NSString stringWithFormat:tableRow, subMenu, menuItemName, option, notes, quantity, amountStr];
        
        allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
    }
    
    // Add all the extra rows ...
    
    // 1. discount
    if (discountAmount > 0)
    {
        NSNumber *amount = [[NSNumber alloc] initWithDouble:discountAmount];
        NSString *amountStr = [UtilCalls doubleAmountToString:amount];
        NSString *menuItemRow = [NSString stringWithFormat:tableRow, discountTitle, nil, nil, nil, nil, amountStr];
        allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
    }
    // 2. subtotal
    {
        NSNumber *amount = [[NSNumber alloc] initWithDouble:subTotal];
        NSString *amountStr = [UtilCalls doubleAmountToString:amount];
        NSString *menuItemRow = [NSString stringWithFormat:tableRow, @"Subtotal", nil, nil, nil, nil, amountStr];
        allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
    }
    // 3. gratuity
    {
        NSNumber *amount = [[NSNumber alloc] initWithDouble:gratuity];
        NSString *amountStr = [UtilCalls doubleAmountToString:amount];
        NSString *menuItemRow = [NSString stringWithFormat:tableRow, @"Gratuity", nil, nil, nil, nil, amountStr];
        allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
    }
    // 4. delivery fee
    if (deliveryFee > 0)
    {
        NSNumber *amount = [[NSNumber alloc] initWithDouble:deliveryFee];
        NSString *amountStr = [UtilCalls doubleAmountToString:amount];
        NSString *menuItemRow = [NSString stringWithFormat:tableRow, @"Delivery", nil, nil, nil, nil, amountStr];
        allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
    }
    // 5. tax
    {
        NSNumber *amount = [[NSNumber alloc] initWithDouble:taxAmount];
        NSString *amountStr = [UtilCalls doubleAmountToString:amount];
        NSString *menuItemRow = [NSString stringWithFormat:tableRow, @"Tax", nil, nil, nil, nil, amountStr];
        allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
    }
    // 6. Order Total
    {
        NSNumber *amount = [[NSNumber alloc] initWithDouble:finalAmount];
        NSString *amountStr = [UtilCalls doubleAmountToString:amount];
        NSString *menuItemRow = [NSString stringWithFormat:tableRow, @"Order Total", nil, nil, nil, nil, amountStr];
        allTableRows = [NSString stringWithFormat:@"%@ %@", allTableRows, menuItemRow];
    }
    
    orderHTMLStr = [NSString stringWithFormat:@"%@ %@ %@", orderHTMLStr, allTableRows, endStr];
    NSLog(@"%@",orderHTMLStr);
    
    orderHTMLStr = [orderHTMLStr stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    NSLog(@"%@",orderHTMLStr);
    orderHTMLStr = [orderHTMLStr stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    NSLog(@"%@",orderHTMLStr);

    return orderHTMLStr;
}

@end
