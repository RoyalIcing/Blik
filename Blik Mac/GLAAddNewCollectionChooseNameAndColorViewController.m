//
//  GLAAddNewCollectionViewController.m
//  Blik
//
//  Created by Patrick Smith on 27/09/2014.
//  Copyright (c) 2014 Patrick Smith. All rights reserved.
//

#import "GLAAddNewCollectionChooseNameAndColorViewController.h"
#import "GLAUIStyle.h"
#import "GLAProjectManager.h"
#import "GLACollectionColorPickerPopover.h"
#import "GLACollectionColorPickerViewController.h"


@interface GLAAddNewCollectionChooseNameAndColorViewController ()

@end

@implementation GLAAddNewCollectionChooseNameAndColorViewController

- (void)prepareView
{
	[super prepareView];
	
	NSView *view = (self.view);
	(view.wantsLayer) = YES;
	(view.canDrawSubviewsIntoLayer) = YES;
	(view.layerContentsRedrawPolicy) = NSViewLayerContentsRedrawDuringViewResize;
	
	(self.chosenCollectionColor) = [GLACollectionColor pastelLightBlue];
	
	GLAUIStyle *uiStyle = [GLAUIStyle activeStyle];
	
	[uiStyle prepareTextLabel:(self.nameLabel)];
	[uiStyle prepareOutlinedTextField:(self.nameTextField)];
	[uiStyle prepareTextLabel:(self.colorLabel)];
	(self.nameTextField.wantsLayer) = YES;
	
	GLAColorChoiceView *colorChoiceView = (self.colorChoiceView);
	(colorChoiceView.color) = [uiStyle colorForCollectionColor:(self.chosenCollectionColor)];
	(colorChoiceView.togglesOnAndOff) = NO;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(nameTextFieldTextDidChange:) name:NSControlTextDidChangeNotification object:(self.nameTextField)];
	[nc addObserver:self selector:@selector(colorChoiceViewDidClick:) name:GLAColorChoiceViewDidClickNotification object:(self.colorChoiceView)];
}

- (void)viewWillTransitionIn
{
	[super viewWillTransitionIn];
	
	[self resetAndFocus];
}

- (void)checkNameTextFieldIsValid
{
	NSString *stringValue = (self.nameTextField.stringValue);
	
	GLAProjectManager *projectManager = [GLAProjectManager sharedProjectManager];
	(self.confirmCreateButton.enabled) = [projectManager nameIsValid:stringValue];
}

- (GLAAddNewCollectionSection *)currentAddNewCollectionSection
{
	GLAMainSectionNavigator *sectionNavigator = (self.sectionNavigator);
	GLAAddNewCollectionSection *addNewCollectionSection = (GLAAddNewCollectionSection *)(sectionNavigator.currentSection);
	NSAssert(addNewCollectionSection != nil, @"Current section must be present");
	NSAssert([addNewCollectionSection isKindOfClass:[GLAAddNewCollectionSection class]], @"Current section must be an 'add new collection' section");
	
	return addNewCollectionSection;
}

- (NSString *)defaultName
{
	GLAAddNewCollectionSection *currentAddNewCollectionSection = (self.currentAddNewCollectionSection);
	
	NSURL *fileURL = nil;
	NSString *suffixString = nil;
	
	if ([currentAddNewCollectionSection isKindOfClass:[GLAAddNewCollectedFilesCollectionSection class]]) {
		GLAAddNewCollectedFilesCollectionSection *collectedFilesSection = (GLAAddNewCollectedFilesCollectionSection *)currentAddNewCollectionSection;
		GLAPendingAddedCollectedFilesInfo *pendingAddedCollectedFilesInfo = (collectedFilesSection.pendingAddedCollectedFilesInfo);
		if (pendingAddedCollectedFilesInfo) {
			NSArray *fileURLs = (pendingAddedCollectedFilesInfo.fileURLs);
			if ((fileURLs.count) == 1) {
				GLACollectedFile *collectedFile = [[GLACollectedFile alloc] initWithFileURL:fileURLs[0]];
				// Get the name synchronously, just to get it done immediately.
				fileURL = ([collectedFile accessFile].filePathURL);
			}
		}
	}
	else if ([currentAddNewCollectionSection isKindOfClass:[GLAAddNewFilteredFolderCollectionSection class]]) {
		GLAAddNewFilteredFolderCollectionSection *filteredFolderSection = (GLAAddNewFilteredFolderCollectionSection *)currentAddNewCollectionSection;
		
		NSURL *folderURL = (filteredFolderSection.chosenFolderURL);
		NSString *tagName = (filteredFolderSection.chosenTagName);
		
		fileURL = folderURL;
		suffixString = [@" " stringByAppendingString:tagName];
	}
	
	if (fileURL) {
		NSString *localizedName = nil;
		BOOL success = [fileURL getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:nil];
		if (success) {
			if (suffixString) {
				return [localizedName stringByAppendingString:suffixString];
			}
			else {
				return localizedName;
			}
		}
	}
	
	return @"";
}

- (void)resetAndFocus
{
	(self.nameTextField.stringValue) = (self.defaultName);
	[self checkNameTextFieldIsValid];
	
	[(self.view.window) makeFirstResponder:(self.nameTextField)];
}

- (void)nameTextFieldTextDidChange:(NSNotification *)note
{
	[self checkNameTextFieldIsValid];
}

- (void)colorChoiceViewDidClick:(NSNotification *)note
{
	[self chooseColor];
}

- (GLACollectionColorPickerPopover *)colorPickerPopover
{
	return [GLACollectionColorPickerPopover sharedColorPickerPopover];
}

- (void)collectionColorPickerChosenColorDidChangeNotification:(NSNotification *)note
{
	GLACollectionColorPickerViewController *colorPickerViewController = (note.object);
	GLACollectionColor *color = (colorPickerViewController.chosenCollectionColor);
	
	(self.chosenCollectionColor) = color;
	
	GLAUIStyle *uiStyle = [GLAUIStyle activeStyle];
	(self.colorChoiceView.color) = [uiStyle colorForCollectionColor:(self.chosenCollectionColor)];
}

- (void)collectionColorPickerPopupDidCloseNotification:(NSNotification *)note
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:nil object:(self.colorPickerPopover)];
	
	(self.colorChoiceView.on) = NO;
}

- (void)chooseColor
{
	GLACollectionColorPickerPopover *colorPickerPopover = (self.colorPickerPopover);
	
	if (colorPickerPopover.isShown) {
		[colorPickerPopover close];
	}
	else {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(collectionColorPickerChosenColorDidChangeNotification:) name:GLACollectionColorPickerPopoverChosenColorDidChangeNotification object:colorPickerPopover];
		[nc addObserver:self selector:@selector(collectionColorPickerPopupDidCloseNotification:) name:NSPopoverDidCloseNotification object:colorPickerPopover];
		
		(colorPickerPopover.chosenCollectionColor) = (self.chosenCollectionColor);
		
		GLAColorChoiceView *colorChoiceView = (self.colorChoiceView);
		// Show underneath.
		[colorPickerPopover showRelativeToRect:NSZeroRect ofView:colorChoiceView preferredEdge:NSMaxYEdge];
	}
}

- (IBAction)confirmCreate:(id)sender
{
	GLAProject *project = (self.project);
	GLAProjectManager *projectManager = [GLAProjectManager sharedProjectManager];
	
	NSString *name = [projectManager normalizeName:(self.nameTextField.stringValue)];
	if (![projectManager nameIsValid:name]) {
		return;
	}
	
	
	
	GLACollectionColor *color = (self.chosenCollectionColor);
	GLACollection *collection = nil;
	
	GLAAddNewCollectionSection *addNewCollectionSection = (self.currentAddNewCollectionSection);
	
	if ([addNewCollectionSection isKindOfClass:[GLAAddNewCollectedFilesCollectionSection class]]) {
		GLAAddNewCollectedFilesCollectionSection *collectedFilesSection = (GLAAddNewCollectedFilesCollectionSection *)addNewCollectionSection;
		
	GLAPendingAddedCollectedFilesInfo *pendingAddedCollectedFilesInfo = (collectedFilesSection.pendingAddedCollectedFilesInfo);
		if (pendingAddedCollectedFilesInfo) {
			collection = [projectManager createNewCollectionWithName:name type:GLACollectionTypeFilesList color:color inProject:project insertingInCollectionsListAtIndex:(pendingAddedCollectedFilesInfo.indexOfNewCollectionInList)];
			
			NSArray *fileURLs = (pendingAddedCollectedFilesInfo.fileURLs);
			NSArray *collectedFiles = [GLACollectedFile collectedFilesWithFileURLs:fileURLs];
			
			[projectManager editFilesListOfCollection:collection insertingCollectedFiles:collectedFiles atOptionalIndex:NSNotFound];
		}
		else {
			collection = [projectManager createNewCollectionWithName:name type:GLACollectionTypeFilesList color:color inProject:project insertingInCollectionsListAtIndex:NSNotFound];
		}
	}
	else if ([addNewCollectionSection isKindOfClass:[GLAAddNewFilteredFolderCollectionSection class]]) {
		GLAAddNewFilteredFolderCollectionSection *filteredFolderSection = (GLAAddNewFilteredFolderCollectionSection *)addNewCollectionSection;
		
		collection = [projectManager createNewCollectionWithName:name type:GLACollectionTypeFilteredFolder color:color inProject:project insertingInCollectionsListAtIndex:NSNotFound];
		
		NSURL *folderURL = (filteredFolderSection.chosenFolderURL);
		NSString *tagName = (filteredFolderSection.chosenTagName);
		GLAFolderQuery *folderQuery = [[GLAFolderQuery alloc] initCreatingByEditing:^(id<GLAFolderQueryEditing> editor) {
			(editor.collectedFileForFolderURL) = [[GLACollectedFile alloc] initWithFileURL:folderURL];
			(editor.tagNames) = @[tagName];
		}];
		[projectManager setFolderQuery:folderQuery forFilteredFolderCollectionWithUUID:(collection.UUID)];
	}
	else {
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GLAAddNewCollectionViewControllerDidConfirmCreatingNotification object:self userInfo:@{@"collection": collection, @"project": project}];
}

@end

NSString *GLAAddNewCollectionViewControllerDidConfirmCreatingNotification = @"GLAAddNewCollectionViewControllerDidConfirmCreatingNotification";
