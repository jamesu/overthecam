//
//  JUCellFactory.h
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 17/06/2009.
//

#import <Foundation/Foundation.h>


@interface JUCellFactory : NSObject {
    NSMutableDictionary *entries;
}

- (id)initWithNib:(NSString*)aNibName;
- (UITableViewCell*)cell:(NSString*)identifier forTable:(UITableView*)table;

@end
