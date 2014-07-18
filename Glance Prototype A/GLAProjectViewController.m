//
//  GLAPrototypeBProjectViewController.m
//  Blik
//
//  Created by Patrick Smith on 7/07/2014.
//  Copyright (c) 2014 Burnt Caramel. All rights reserved.
//

@import QuartzCore;
#import "GLAProjectViewController.h"
#import "GLAUIStyle.h"


NSString *GLAProjectViewControllerDidBeginEditingItemsNotification = @"GLA.projectViewController.didBeginEditingItems";
NSString *GLAProjectViewControllerDidEndEditingItemsNotification = @"GLA.projectViewController.didEndEditingItems";

NSString *GLAProjectViewControllerDidBeginEditingPlanNotification = @"GLA.projectViewController.didBeginEditingPlan";
NSString *GLAProjectViewControllerDidEndEditingPlanNotification = @"GLA.projectViewController.didEndEditingPlan";


@interface GLAProjectViewController ()

@property(nonatomic) id private_project;

@property(nonatomic) BOOL focusedOnItemsView;
@property(nonatomic) BOOL focusedOnPlanView;

@property(nonatomic, getter = isAnimatingFocusChange) BOOL animatingFocusChange;

@property(strong, nonatomic) NSLayoutConstraint *itemsViewXConstraint;
@property(strong, nonatomic) NSLayoutConstraint *planViewXConstraint;

@property(nonatomic) CGFloat itemsViewLeadingConstraintDefaultConstant;
@property(nonatomic) CGFloat itemsViewHeightConstraintDefaultConstant;

@property(nonatomic) CGFloat planViewTrailingConstraintDefaultConstant;
@property(nonatomic) CGFloat planViewHeightConstraintDefaultConstant;

@end

@implementation GLAProjectViewController

- (GLAPrototypeBProjectView *)projectView
{
	return (id)(self.view);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
	}
    return self;
}


- (void)loadView
{
	[super loadView];
	
	(self.projectView.delegate) = self;
	/*
	NSTextField *nameTextField = (self.nameTextField);
	(nameTextField.delegate) = self;
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(nameTextDidBeginEditing:) name:NSControlTextDidBeginEditingNotification object:nameTextField];
	[nc addObserver:self selector:@selector(nameTextDidEndEditing:) name:NSControlTextDidEndEditingNotification object:nameTextField];
	*/
	(self.itemsViewLeadingConstraintDefaultConstant) = (self.itemsViewLeadingConstraint.constant);
	(self.itemsViewHeightConstraintDefaultConstant) = (self.itemsViewHeightConstraint.constant);
	
	(self.planViewTrailingConstraintDefaultConstant) = (self.planViewTrailingConstraint.constant);
	(self.planViewHeightConstraintDefaultConstant) = (self.planViewHeightConstraint.constant);
}

- (id)project
{
	return (self.private_project);
}

- (void)setProject:(id)project
{
	if ((self.private_project) != project) {
		(self.private_project) = project;
		
		(self.nameTextField.stringValue) = project;
	}
}

- (void)editItems:(id)sender
{
	if (self.animatingFocusChange) {
		return;
	}
	
	if (!(self.focusedOnItemsView)) {
		[self focusOnItemsView];
		[(self.actionsBarController) showBarForEditingItems];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GLAProjectViewControllerDidBeginEditingItemsNotification object:self];
	}
	else {
		[self endFocusingOnItemsView];
		[(self.actionsBarController) hideBarForEditingItems];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GLAProjectViewControllerDidEndEditingItemsNotification object:self];
	}
}

- (void)editPlan:(id)sender
{
	if (self.animatingFocusChange) {
		return;
	}
	
	if (!(self.focusedOnPlanView)) {
		[self focusOnPlanView];
		[(self.actionsBarController) showBarForEditingPlan];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GLAProjectViewControllerDidBeginEditingPlanNotification object:self];
	}
	else {
		[self endFocusingOnPlanView];
		[(self.actionsBarController) hideBarForEditingPlan];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GLAProjectViewControllerDidEndEditingPlanNotification object:self];
	}
}


- (NSScrollView *)itemsScrollView
{
	return (self.itemsViewController.tableView.enclosingScrollView);
}

- (NSScrollView *)planScrollView
{
	return (self.planViewController.tableView.enclosingScrollView);
}

- (void)animateItemsViewForFocusChange:(BOOL)isFocused
{
	(self.animatingFocusChange) = YES;
	
	GLAPrototypeBProjectView *projectView = (self.projectView);
	NSScrollView *itemsScrollView = [self itemsScrollView];
	NSScrollView *planScrollView = [self planScrollView];
	
	if (isFocused) {
		// Center items view
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 6.0 / 12.0;
			(context.allowsImplicitAnimation) = YES;
			
			(self.itemsViewXConstraint) = [self addConstraintForCenteringView:itemsScrollView inView:projectView];
			
			[projectView layoutSubtreeIfNeeded];
		} completionHandler:^ {
			(self.animatingFocusChange) = NO;
		}];
		
		// Resize item view to be taller, and animate plan view off.
		(self.itemsViewHeightConstraintDefaultConstant) = NSHeight(itemsScrollView.frame);
		[projectView removeConstraint:(self.planViewBottomConstraint)];
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 4.0 / 12.0;
			(context.timingFunction) = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
			
			(self.itemsViewHeightConstraint.animator.constant) = 300;
			(self.planViewTrailingConstraint.animator.constant) = -600;
		} completionHandler:nil];
		
		// Fade out plan view
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 2.5 / 12.0;
			
			(planScrollView.animator.alphaValue) = 0.0;
		} completionHandler:nil];
	}
	else {
		// Remove centering constraint
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 6.0 / 12.0;
			(context.allowsImplicitAnimation) = YES;
			
			[projectView removeConstraint:(self.itemsViewXConstraint)];
			
			[projectView layoutSubtreeIfNeeded];
		} completionHandler:^ {
			(self.animatingFocusChange) = NO;
		}];
		
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 3.0 / 12.0;
			
			(self.itemsViewHeightConstraint.animator.constant) = (self.itemsViewHeightConstraintDefaultConstant);
		} completionHandler:^ {
			[projectView addConstraint:(self.planViewBottomConstraint)];
		}];
		
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 6.0 / 12.0;
			(context.timingFunction) = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			
			(planScrollView.animator.alphaValue) = 1.0;
			(self.planViewTrailingConstraint.animator.constant) = (self.planViewTrailingConstraintDefaultConstant);
		} completionHandler:nil];
	}
}

- (void)animatePlanViewForFocusChange:(BOOL)isFocused
{
	(self.animatingFocusChange) = YES;
	
	GLAPrototypeBProjectView *projectView = (self.projectView);
	NSScrollView *itemsScrollView = [self itemsScrollView];
	NSScrollView *planScrollView = [self planScrollView];
	
	if (isFocused) {
		// Center items view
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 6.0 / 12.0;
			(context.allowsImplicitAnimation) = YES;
			
			(self.planViewXConstraint) = [self addConstraintForCenteringView:planScrollView inView:projectView];
			
			[projectView layoutSubtreeIfNeeded];
		} completionHandler:^ {
			(self.animatingFocusChange) = NO;
		}];
		
		// Store the current height so it can be animated back to later.
		(self.planViewHeightConstraintDefaultConstant) = NSHeight(planScrollView.frame);
		// Stop allowing the items view to affect the window height.
		[projectView removeConstraint:(self.itemsViewBottomConstraint)];
		// Resize item view to be taller, and animate plan view off.
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 4.0 / 12.0;
			(context.timingFunction) = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
			
			(self.planViewHeightConstraint.animator.constant) = 300;
			(self.itemsViewLeadingConstraint.animator.constant) = -600;
		} completionHandler:nil];
		
		// Fade out plan view
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 2.5 / 12.0;
			
			(itemsScrollView.animator.alphaValue) = 0.0;
		} completionHandler:nil];
	}
	else {
		// Remove centering constraint
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 6.0 / 12.0;
			(context.allowsImplicitAnimation) = YES;
			
			[projectView removeConstraint:(self.planViewXConstraint)];
			
			[projectView layoutSubtreeIfNeeded];
		} completionHandler:^ {
			(self.animatingFocusChange) = NO;
		}];
		
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 4.0 / 12.0;
			
			(self.planViewHeightConstraint.animator.constant) = (self.planViewHeightConstraintDefaultConstant);
		} completionHandler:^ {
			[projectView addConstraint:(self.itemsViewBottomConstraint)];
		}];
		
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			(context.duration) = 6.0 / 12.0;
			(context.timingFunction) = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			
			(itemsScrollView.animator.alphaValue) = 1.0;
			(self.itemsViewLeadingConstraint.animator.constant) = (self.itemsViewLeadingConstraintDefaultConstant);
		} completionHandler:nil];
	}
}

- (void)focusOnItemsView
{
	(self.focusedOnItemsView) = YES;
	(self.focusedOnPlanView) = NO;
	
	[self animateItemsViewForFocusChange:YES];
}

- (void)endFocusingOnItemsView
{
	(self.focusedOnItemsView) = NO;
	
	[self animateItemsViewForFocusChange:NO];
}

- (void)focusOnPlanView
{
	(self.focusedOnItemsView) = NO;
	(self.focusedOnPlanView) = YES;
	
	[self animatePlanViewForFocusChange:YES];
	//[self updateConstraintsWithAnimatedDuration:7.0 / 12.0];
}

- (void)endFocusingOnPlanView
{
	(self.focusedOnPlanView) = NO;
	
	[self animatePlanViewForFocusChange:NO];
	//[self updateConstraintsWithAnimatedDuration:7.0 / 12.0];
}

- (NSLayoutConstraint *)addConstraintForCenteringView:(NSView *)view inView:(NSView *)holderView
{
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:holderView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
	(constraint.priority) = NSLayoutPriorityRequired;
	[holderView addConstraint:constraint];
	
	return constraint;
}

/*
- (void)nameTextDidBeginEditing:(NSNotification *)obj
{
	NSLog(@"nameTextDidBeginEditing:");
	NSTextField *nameTextField = (self.nameTextField);
	GLAUIStyle *uiStyle = [GLAUIStyle styleA];
	(nameTextField.textColor) = (uiStyle.editedTextColor);
	(nameTextField.backgroundColor) = (uiStyle.editedTextBackgroundColor);
}

- (void)nameTextDidEndEditing:(NSNotification *)obj
{
	
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
	NSLog(@"%@", NSStringFromSelector(command));
	return NO;
}
*/
@end



@implementation GLAProjectItemsViewController

- (NSTableView *)tableView
{
	return (id)(self.view);
}

- (void)prepareDummyContent
{
	(self.mutableItems) =
	[
	 @[
	   @"Working Items",
	   @"Briefs",
	   @"Contacts",
	   @"Apps",
	   @"Research"
	   ] mutableCopy];
	
	[(self.tableView) reloadData];
}

- (void)prepareViews
{
	NSTableView *tableView = (self.tableView);
	(tableView.backgroundColor) = ([GLAUIStyle styleA].contentBackgroundColor);
	(tableView.enclosingScrollView.backgroundColor) = ([GLAUIStyle styleA].contentBackgroundColor);
}

- (void)loadView
{
	[super loadView];
	
	[self prepareViews];
}

- (void)awakeFromNib
{
	[self prepareViews];
	[self prepareDummyContent];
}

#pragma mark Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return (self.mutableItems.count);
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return (self.mutableItems)[row];
}

#pragma mark Table View Delegate

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView
{
	return NO;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:(tableColumn.identifier) owner:nil];
	(cellView.canDrawSubviewsIntoLayer) = YES;
	
	NSString *displayName = (self.mutableItems)[row];
	(cellView.objectValue) = displayName;
	(cellView.textField.stringValue) = displayName;
	
	return cellView;
}

@end



@implementation GLAProjectPlanViewController

- (NSTableView *)tableView
{
	return (id)(self.view);
}

- (void)prepareDummyContent
{
	(self.mutableReminders) =
	[
	 @[
	   [GLAReminderItem dummyReminderItemWithTitle:@"About page redesign blah blah blah blah longer name"],
	   [GLAReminderItem dummyReminderItemWithTitle:@"Double check Muted Light logo and gallery sliders"],
	   [GLAReminderItem dummyReminderItemWithTitle:@"Prototyping landing page blah blah blah longer name blah blah"],
	   [GLAReminderItem dummyReminderItemWithTitle:@"Brief Stage D completed blah blah blah longer name blah blah"],
	   [GLAReminderItem dummyReminderItemWithTitle:@"Brief Stage E completed blah blah blah longer name blah blah"],
	   [GLAReminderItem dummyReminderItemWithTitle:@"Brief Stage F completed blah blah blah longer name blah blah"],
	   ] mutableCopy];
	
	[(self.tableView) reloadData];
}

- (void)prepareViews
{
	NSTableView *tableView = (self.tableView);
	(tableView.backgroundColor) = ([GLAUIStyle styleA].contentBackgroundColor);
	(tableView.enclosingScrollView.backgroundColor) = ([GLAUIStyle styleA].contentBackgroundColor);
}

- (void)loadView
{
	[super loadView];
	
	[self prepareViews];
}

- (void)awakeFromNib
{
	[self prepareViews];
	[self prepareDummyContent];
}

#pragma mark Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return (self.mutableReminders.count);
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	GLAReminderItem *reminderItem = (self.mutableReminders)[row];
	return (reminderItem.title);
}

#pragma mark Table View Delegate

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView
{
	return NO;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:(tableColumn.identifier) owner:nil];
	(cellView.canDrawSubviewsIntoLayer) = YES;
	
	GLAReminderItem *reminderItem = (self.mutableReminders)[row];
	NSString *title = (reminderItem.title);
	NSString *middleDot = @"\u00b7";
	NSString *displayText = [NSString stringWithFormat:@"4PM Today %@ %@", middleDot, title];
	//NSString *displayText = @"dfs";
	//(cellView.objectValue) = displayText;
	//(cellView.textField.stringValue) = displayText;
	
	NSFont *font;
	
	NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
	(paragraphStyle.alignment) = NSRightTextAlignment;
	
	if (row == 0) {
		font = ([GLAUIStyle styleA]).highlightedReminderFont;
		(paragraphStyle.maximumLineHeight) = 21.0; //(font.pointSize);
		(paragraphStyle.lineSpacing) = 0.0;
	}
	else {
		font = ([GLAUIStyle styleA]).smallReminderFont;
		(paragraphStyle.maximumLineHeight) = 18.0; //(font.pointSize);
	}
	
	NSDictionary *attributes =
  @{
	NSFontAttributeName: font,
	NSParagraphStyleAttributeName: paragraphStyle
	};
	(cellView.textField.attributedStringValue) = [[NSMutableAttributedString alloc] initWithString:displayText attributes:attributes];
	//(cellView.textField.font) = font;
	
	(cellView.textField.preferredMaxLayoutWidth) = (tableColumn.width);
	
	return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	/*
	NSTableCellView *cellView = [tableView viewAtColumn:0 row:row makeIfNecessary:YES];
	NSTextField *textField = (cellView.textField);
	return (textField.intrinsicContentSize.height);
	 */
	
	if (row == 0) {
		return 2.0 * 24.0;
	}
	else {
		//return 2.0 * 18.0;
		return 2.0 * 21.0;
	}
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
	return [tableView makeViewWithIdentifier:NSTableViewRowViewKey owner:nil];
}

@end