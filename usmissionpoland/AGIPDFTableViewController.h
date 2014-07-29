//
//  AGIPDFTableViewController.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 10.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AGIPdfInfoTableViewCell.h"
#import "BaseViewController.h"

@interface AGIPDFTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, AGIPdfInfoTableViewCellDelegate, MFMailComposeViewControllerDelegate, SWTableViewCellDelegate, UIDocumentInteractionControllerDelegate>

@end
