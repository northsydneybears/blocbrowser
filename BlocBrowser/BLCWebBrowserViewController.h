//
//  BLCWebBrowserViewController.h
//  BlocBrowser
//
//  Created by Peter Gow on 16/10/2014.
//  Copyright (c) 2014 Peter Gow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCWebBrowserViewController : UIViewController

/**
 Replaces the web view with a fresh one, erasing all history. Also updates the URL field and toolbar buttons appropriately.
 */
- (void) resetWebView;

- (void) showAlert;

@end
