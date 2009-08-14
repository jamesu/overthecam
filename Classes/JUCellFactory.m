//
//  JUCellFactory.m
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 17/06/2009.
//

#import "JUCellFactory.h"


@implementation JUCellFactory

- (id)initWithNib:(NSString*)aNibName
{
    if (self = [super init]) {
        entries = [[NSMutableDictionary alloc] initWithCapacity:1]; 
        NSArray *templates = [[NSBundle mainBundle] loadNibNamed:aNibName owner:self options:nil];
        for (id template in templates) {
            if ([template isKindOfClass:[UITableViewCell class]]) {  
                UITableViewCell * entry = (UITableViewCell *)template;
                NSString * key = entry.reuseIdentifier;
                
                // Set key == entry
                if (key)
                    [entries setObject:[NSKeyedArchiver archivedDataWithRootObject:template] forKey:key];
            }
        }
        
        //[templates release];
    }
    
    return self;
}

- (void)dealloc
{
    [entries release];
    [super dealloc];
}

- (UITableViewCell*)cell:(NSString*)identifier forTable:(UITableView*)table
{
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        // Try to unpack from template
        NSData *cellData = [entries objectForKey:identifier];
        if (cellData) {
            cell = [NSKeyedUnarchiver unarchiveObjectWithData:cellData];
            //[cell connectChildren];
        }
    }
    
    return cell;
}

@end
