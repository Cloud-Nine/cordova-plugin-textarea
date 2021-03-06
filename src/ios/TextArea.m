/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "TextArea.h"

@implementation MyTextAttachment
@end

@implementation TextAreaNavController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
    self.navigationBar.barTintColor = [UIColor colorWithRed:0.20 green:0.08 blue:0.20 alpha:1.0];
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

    //self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: [UIColor whiteColor]]
    //self.navigationBar.barStyle = [UIBarStyle.Black];
    //self.navigationBar.barStyle = UIBarStyle.de
}

@end

@interface TextArea()<UITextViewDelegate> {

    NSString* titleString;
    NSString* confirmButtonString;
    NSString* cancelButtonString;
    NSString* placeHolderString;
    NSString* bodyText;
    BOOL isRichText;

    TextAreaNavController* navController;
    UITextView* textView;
    UILabel* placeholder;
    CGRect originalTextViewFrame;
    UISwipeGestureRecognizer* swipeGesture;
    UIColor* themeColor;
    UIColor* themeColorDisabled;
    UIColor* navBarColor;
    UIBarButtonItem *confirmBarBtnItem;
}

@end

@implementation TextArea

- (void)openTextView:(CDVInvokedUrlCommand*)command {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    themeColor = [UIColor colorWithRed:(100/255.0) green:(56/255.0) blue:(0/255.0) alpha:1];
    themeColorDisabled = [UIColor colorWithRed:(100/255.0) green:(56/255.0) blue:(0/255.0) alpha:0.3];
    //navBarColor = [UIColor colorWithRed:(65/255.0) green:(28/255.0) blue:(66/255.0) alpha:1];

    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(65/255.0) green:(28/255.0) blue:(66/255.0) alpha:1];
    //self.navigationBar.barTintColor = [UIColor colorWithRed:(65/255.0) green:(28/255.0) blue:(66/255.0) alpha:1];
    //self.navigationController.navigationBar.translucent = NO;
    // self.navigationBar.barTintColor = [UIColor blueColor];
    // self.navigationBar.tintColor = [UIColor whiteColor];

    self.currentCallbackId = command.callbackId;

    titleString = command.arguments[0];
    confirmButtonString = command.arguments[1];
    cancelButtonString = command.arguments[2];
    placeHolderString = command.arguments[3];
    bodyText = command.arguments[4];

    UIFont* textFont = [UIFont fontWithName:@"STHeitiSC-Light" size:16];

    // create controllers
    UIViewController* viewController = [[UIViewController alloc] init];
    navController = [[TextAreaNavController alloc] initWithRootViewController:viewController];

    // create view
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, viewController.view.frame.size.width-20, viewController.view.frame.size.height-10)];
    [textView becomeFirstResponder];

    // for keyboard hide
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [textView addGestureRecognizer:swipeGesture];

    // load body for textView and add border
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = 0;
    paragraphStyle.firstLineHeadIndent = 0;
    paragraphStyle.tailIndent = 0;
    NSDictionary *attrsDictionary = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:paragraphStyle};
    [textView setDelegate:self];
    [textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    //[textView setTintColor:themeColor];
    //[textView setFont:textFont];
    //[textView setTextColor:[UIColor blackColor]];
    textView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:attrsDictionary];
    textView.text = bodyText;

    [viewController setTitle:titleString];

    [navController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];

    UIBarButtonItem* cancelBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:cancelButtonString style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];
    //[cancelBarBtnItem setTintColor:[UIColor grayColor]];
    confirmBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:confirmButtonString style:UIBarButtonItemStylePlain target:self action:@selector(confirmBtnPressed:)];
    //[confirmBarBtnItem setTintColor:themeColorDisabled];

    [navController.topViewController.navigationItem setLeftBarButtonItem:cancelBarBtnItem animated:NO];
    [navController.topViewController.navigationItem setRightBarButtonItem:confirmBarBtnItem animated:NO];

    // add view
    [viewController.view addSubview:textView];

    // add placeholder
    placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, viewController.view.frame.size.width, 18)];
    //placeholder.font = textFont;
    placeholder.textColor = [UIColor lightGrayColor];
    placeholder.text = placeHolderString;
    placeholder.backgroundColor = [UIColor clearColor];

    if (![bodyText isEqualToString:@""]) {
        placeholder.hidden = YES;
        //[confirmBarBtnItem setTintColor:themeColor];
    }

    [textView addSubview:placeholder];

    viewController.view.backgroundColor = [UIColor whiteColor];
    navController.textView = textView;

    // present the controller
    [self.viewController presentViewController:navController animated:YES completion:NULL];
}

#pragma Actions

- (NSString *)getPlainString
{
    //最终纯文本
    NSMutableString* plainString = [NSMutableString stringWithString:textView.attributedText.string];
    //替换下标的偏移量
    __block NSUInteger base = 0;
    //遍历
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:0
                                     usingBlock:^(id value, NSRange range, BOOL *stop) {
                                         //检查类型是否是NSTextAttachment类
                                         if (value && [value isKindOfClass:[MyTextAttachment class]]) {
                                             //替换
                                             MyTextAttachment* myAttachment = (MyTextAttachment *) value;
                                             NSString* imgStr = [NSString stringWithFormat:@"<img src=\"%@\" width=\"%d\" height=\"%d\">", myAttachment.filePath, (int)myAttachment.image.size.width, (int)myAttachment.image.size.height];
                                             [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:imgStr];
                                             //增加偏移量
                                             base += imgStr.length - 1;
                                         }
                                     }];
    return plainString;
}

-(void)handleGesture:(UIGestureRecognizer*)gesture
{
    [textView resignFirstResponder];
}

- (void)cancelBtnPressed: (id) sender {
        [self canceled];
        return;
}

- (void)canceled {
    [textView resignFirstResponder];
    [self.viewController dismissViewControllerAnimated:YES completion:^(void) {
        [self removeObservers];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
    }];
}

- (void)confirmBtnPressed: (id) sender {
    // if (textView.attributedText.length == 0) {
    //     return;
    // }
    [textView resignFirstResponder];
    NSString *sendingString = @"";
    sendingString = [self getPlainString];
    NSMutableDictionary* textResult = [NSMutableDictionary dictionaryWithDictionary:@{@"text":sendingString}];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:textResult];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];

    [self.viewController dismissViewControllerAnimated:YES completion:^(void) {
        [self removeObservers]; //closed
    }];
}

- (void) removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [textView removeGestureRecognizer:swipeGesture];
}

#pragma TextView Delegate methods

- (void)textViewDidChange:(UITextView *)tView
{
    if (tView.attributedText.length == 0) {
        placeholder.hidden = NO;
        //[confirmBarBtnItem setTintColor:themeColorDisabled];
    } else {
        placeholder.hidden = YES;
        //[confirmBarBtnItem setTintColor:themeColor];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)tView
{
    [tView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)tView
{
    [tView resignFirstResponder];
}

#pragma keyboard Notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    [self moveTextViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self moveTextViewForKeyboard:notification up:NO];
}

- (void)moveTextViewForKeyboard:(NSNotification*)notification up:(BOOL)up {

    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        return;
    }

    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;

    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.viewController.view convertRect:keyboardRect fromView:nil];

    //[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    //[UIView setAnimationDuration:animationDuration];
    //[UIView setAnimationCurve:animationCurve];

    if (up == YES) {
        CGFloat keyboardTop = keyboardRect.origin.y;
        CGRect newTextViewFrame = textView.frame;
        originalTextViewFrame = textView.frame;
        newTextViewFrame.size.height = keyboardTop - textView.frame.origin.y;

        textView.frame = newTextViewFrame;
    } else {
        // Keyboard is going away (down) - restore original frame
        textView.frame = originalTextViewFrame;
    }

    [UIView commitAnimations];
}

@end
